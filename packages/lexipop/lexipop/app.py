"""Gtk4 user interface for lexipop: selection daemon, popup and mini editor.

The GTK bindings are imported lazily inside :func:`run_daemon` and
:func:`run_editor`, so headless commands (``lexipop version``) never need a GTK
typelib or a display.
"""

from __future__ import annotations

try:  # POSIX only: the daemon singleton is built on flock(2)
    import fcntl
except ImportError:  # pragma: no cover - non-POSIX platforms
    fcntl = None  # type: ignore[assignment]

import glob
import json
import logging
import os
import re
import select
import shutil
import signal
import socket
import struct
import sys
import threading
import time
from typing import Any, Callable, Optional

from . import ocr, pointer, selection

LOGGER = logging.getLogger(__name__)

DAEMON_APP_ID = "dev.lexipop.Daemon"
EDITOR_APP_ID = "dev.lexipop.Editor"
LAYER_NAMESPACE = "lexipop"

#: Every top-level window of this application uses this app_id prefix.
LEXIPOP_APP_PREFIX = "dev.lexipop"

#: How often the focused sway window is polled while the popup is visible.
FOCUS_POLL_MS = 400

#: sway IPC: magic, GET_TREE message type, socket timeout.
SWAY_IPC_MAGIC = b"i3-ipc"
SWAY_GET_TREE = 4
SWAY_IPC_TIMEOUT = 0.4

#: Fallbacks for the configurable popup labels (same values as config.py).
DEFAULT_LABELS: dict = {
    "detected": "(detected)",
    "translation": "Translation",
    "close": "Close",
    "ai": "AI Translate",
    "saveAs": "Save as",
    "edit": "Edit…",
    "word": "Word",
    "sentence": "Sentence",
    "targetLanguage": "Target language",
    # Editor section headers and actions (new in the sectioned editor).
    "front": "Front",
    "back": "Back (translation)",
    "deck": "Deck",
    "colours": "Colours",
    "preview": "Preview",
    "reset": "Reset",
    "coloursHint": "Colours appear after an AI translation.",
}

POPUP_WIDTH = 380
#: Hard cap for the popup width once the top-right target box is shown.
POPUP_MAX_WIDTH = 520
POPUP_ESTIMATED_HEIGHT = 200
#: The popup height is bounded: the labels are line-capped with ellipsization
#: and the content box cannot grow past this many pixels.
POPUP_MAX_CONTENT_HEIGHT = 420
MAX_SELECTION_LINES = 3
MAX_TRANSLATION_LINES = 5
POPUP_EDGE_MARGIN = 8
#: Small offsets that keep the popup just below-right of the marked text.
POPUP_CURSOR_X_OFFSET = 12
POPUP_CURSOR_Y_OFFSET = 16
POPUP_CURSOR_OFFSET = POPUP_CURSOR_Y_OFFSET
SUPPRESS_SECONDS = 2.0

#: Raw input device listener (``pointerClicks``): any real left-click anywhere
#: closes the popup.  ``/dev/input/event*`` is read with a dedicated group.
POINTER_CLICK_SCAN_SECONDS = 5.0
#: Grace window after a raw press: a press the popup itself handled (recorded by
#: its Gtk.GestureClick) suppresses the dismiss.
POINTER_CLICK_GRACE_MS = 250
#: Small slack so a popup click that lands just before the raw press (the two
#: cross the compositor and evdev on different paths) is still recognised.
POINTER_CLICK_SLACK_MS = 120
#: ``struct input_event`` (64-bit): 16-byte timeval + u16 type + u16 code + s32.
INPUT_EVENT = struct.Struct("=qqHHi")
EV_KEY = 1
BTN_LEFT = 0x110
KEY_PRESS = 1

#: Pointer probe: short-lived, invisible layer-shell surfaces that sample the
#: TRUE cursor position (``xdotool`` does not see the Wayland pointer, and the
#: Wayland protocol never exposes the global cursor).
POINTER_PROBE_NAMESPACE = "lexipop-probe"
#: The layer surface must be mapped before sway can report the pointer to it
#: (measured: ~50-70 ms), so several zero-delta rebases are attempted; the
#: timeout guard caps the wait when none of them produces a sample.
POINTER_PROBE_TIMEOUT_MS = 250
POINTER_PROBE_MAX_SURFACES = 4
#: sway only reports the pointer to a newly mapped surface on the NEXT pointer
#: event, so the compositor is asked for a zero-delta pointer move right after
#: the probe is mapped (two attempts, then the timeout guard).  The delta is 0,
#: so the user's cursor does not move; the compositor just re-issues the
#: current position to the probe surface.
POINTER_PROBE_REBASE_MS = (50, 95, 145, 195)
#: sway IPC command that triggers the pointer rebase.
POINTER_PROBE_REBASE_COMMAND = "seat - cursor move 0 0"
SWAY_RUN_COMMAND = 0
#: Nearly transparent: a surface that is fully invisible may stop receiving
#: pointer events on some compositors, so a tiny alpha is kept.
POINTER_PROBE_OPACITY = 0.01

#: Control socket: how long a client may take to send its one-line request.
CONTROL_SOCKET_TIMEOUT = 5.0
#: Upper bound for one request line, so a hostile client cannot exhaust memory.
CONTROL_SOCKET_MAX_BYTES = 1_000_000
#: Backlog of the listening socket.
CONTROL_SOCKET_BACKLOG = 8

_RGB_SPAN_RE = re.compile(r'<span style="color: rgb\((\d+),\s*(\d+),\s*(\d+)\);">')


# --------------------------------------------------------------------------
# small helpers
# --------------------------------------------------------------------------
class _Gtk:
    """Bundle of the lazily imported GTK objects."""

    __slots__ = ("Gtk", "Gdk", "GLib", "Gio", "layer_shell")

    def __init__(self, Gtk, Gdk, GLib, Gio, layer_shell) -> None:
        self.Gtk = Gtk
        self.Gdk = Gdk
        self.GLib = GLib
        self.Gio = Gio
        self.layer_shell = layer_shell


def _layer_shell_library() -> Optional[str]:
    """Locate ``libgtk4-layer-shell.so`` next to its typelib, if possible."""
    entries = (os.environ.get("GI_TYPELIB_PATH") or "").split(os.pathsep)
    for entry in entries:
        entry = entry.rstrip(os.sep)
        if not entry or os.path.basename(entry) != "girepository-1.0":
            continue
        libdir = os.path.dirname(entry)
        for name in ("libgtk4-layer-shell.so.0", "libgtk4-layer-shell.so"):
            candidate = os.path.join(libdir, name)
            if os.path.exists(candidate):
                return candidate
        matches = sorted(glob.glob(os.path.join(libdir, "libgtk4-layer-shell.so*")))
        if matches:
            return matches[0]
    return None


def _preload_layer_shell() -> bool:
    """Load gtk4-layer-shell before GDK loads libwayland-client.

    gtk4-layer-shell must be linked before libwayland-client; with gobject
    introspection both libraries are dlopen(3)ed at run time, so the layer
    shell library is pulled in first with ctypes.  Without this, every
    layer-shell call fails with "GtkWindow is not a layer surface".
    """
    if not sys.platform.startswith("linux"):
        return False
    import ctypes

    library = _layer_shell_library()
    names = ([library] if library else []) + [
        "libgtk4-layer-shell.so.0",
        "libgtk4-layer-shell.so",
    ]
    for name in names:
        try:
            ctypes.CDLL(name, mode=ctypes.RTLD_GLOBAL)
        except OSError:
            continue
        LOGGER.debug("preloaded %s", name)
        return True
    LOGGER.debug("libgtk4-layer-shell.so not found for preloading")
    return False


def _load_gtk() -> _Gtk:
    """Import GTK4 and, when available, the gtk4-layer-shell typelib."""
    import gi

    _preload_layer_shell()
    gi.require_version("Gtk", "4.0")
    gi.require_version("Gdk", "4.0")
    from gi.repository import Gdk, Gio, GLib, Gtk

    layer_shell = None
    try:
        gi.require_version("Gtk4LayerShell", "1.0")
        from gi.repository import Gtk4LayerShell as layer_shell  # type: ignore[no-redef]
    except (ValueError, ImportError):
        LOGGER.warning("Gtk4LayerShell typelib missing, using a plain popup window")
        layer_shell = None
    return _Gtk(Gtk, Gdk, GLib, Gio, layer_shell)


def _wl_paste_available(binary: str = "wl-paste") -> bool:
    """True when the primary-selection reader (wl-paste) can be executed."""
    if not binary:
        return False
    if os.sep in binary:
        return os.access(binary, os.X_OK)
    return shutil.which(binary) is not None


def _display_available() -> bool:
    return bool(os.environ.get("WAYLAND_DISPLAY") or os.environ.get("DISPLAY"))


def _raw(value: Any) -> dict:
    """Return a plain dict for a config node (dict or lexipop.config.Config)."""
    if isinstance(value, dict):
        return value
    raw = getattr(value, "raw", None)
    if isinstance(raw, dict):
        return raw
    as_dict = getattr(value, "as_dict", None)
    if callable(as_dict):
        try:
            out = as_dict()
        except Exception:
            return {}
        if isinstance(out, dict):
            return out
    return {}


def _cfg_get(config: Any, key: str, default: Any = None) -> Any:
    getter = getattr(config, "get", None)
    if callable(getter):
        try:
            value = getter(key, default)
        except Exception:
            return default
        return default if value is None else value
    if isinstance(config, dict):
        return config.get(key, default)
    return default


def _span_to_pango(match: "re.Match[str]") -> str:
    red, green, blue = (int(part) for part in match.groups())
    return '<span foreground="#%02x%02x%02x">' % (red, green, blue)


def _html_to_pango(html: str) -> str:
    """Convert the simple HTML produced by notes/classify into Pango markup."""
    text = _RGB_SPAN_RE.sub(_span_to_pango, html or "")
    text = text.replace("<br/>", "\n").replace("<br>", "\n")
    return text


def _popup_labels(config: Any) -> dict:
    """Return the configured popup labels, filled up with the defaults."""
    labels = dict(DEFAULT_LABELS)
    configured = _raw(_cfg_get(config, "popup", {})).get("labels")
    for key, value in _raw(configured).items():
        if value is not None:
            labels[str(key)] = str(value)
    return labels


def _label(config: Any, key: str) -> str:
    """Return one popup label, falling back to the built-in default."""
    return _popup_labels(config).get(key, DEFAULT_LABELS.get(key, ""))


def _language_name(config: Any, code: Any, fallback_name: Any = None) -> str:
    """Display name for a language code: config, then detected, then code."""
    if not code:
        return "?"
    code = str(code)
    names = _raw(_cfg_get(config, "languageNames", {}))
    name = names.get(code)
    if name:
        return str(name)
    if fallback_name:
        return str(fallback_name)
    return code.upper()


def _focused_node(tree: Any) -> Optional[dict]:
    """Return the focused node of a sway tree, or None when there is none."""
    stack: list = [tree]
    while stack:
        current = stack.pop()
        if isinstance(current, dict):
            if current.get("focused"):
                return current
            stack.extend(current.values())
        elif isinstance(current, list):
            stack.extend(current)
    return None


def _node_app_ids(node: Any) -> list[str]:
    """Wayland ``app_id`` plus the X11 class/instance of one sway tree node."""
    if not isinstance(node, dict):
        return []
    ids: list[str] = []

    def add(value: Any) -> None:
        text = str(value).strip() if value else ""
        if text and text not in ids:
            ids.append(text)

    add(node.get("app_id"))
    props = node.get("window_properties")
    if isinstance(props, dict):
        add(props.get("class"))
        add(props.get("instance"))
    return ids


def _focused_app_id(tree: Any) -> Optional[str]:
    """Return the app_id (or X11 class/instance) of the focused sway node."""
    node = _focused_node(tree)
    if node is None:
        return None
    ids = _node_app_ids(node)
    return ids[0] if ids else None


def _focused_rect(tree: Any) -> Optional[tuple]:
    """Return ``(x, y, width, height)`` of the focused sway window, else None."""
    node = _focused_node(tree)
    rect = node.get("rect") if isinstance(node, dict) else None
    if not isinstance(rect, dict):
        return None
    try:
        return (
            int(rect.get("x", 0)),
            int(rect.get("y", 0)),
            max(0, int(rect.get("width", 0))),
            max(0, int(rect.get("height", 0))),
        )
    except (TypeError, ValueError):
        return None


def _sway_socket_path() -> Optional[str]:
    """Return the sway IPC socket path, or None when there is none."""
    path = os.environ.get("SWAYSOCK")
    if path and os.path.exists(path):
        return path
    uid = os.getuid()
    pattern = "/run/user/%d/sway-ipc.%d.*.sock" % (uid, uid)
    for candidate in sorted(glob.glob(pattern)):
        if os.path.exists(candidate):
            return candidate
    return None


def _recv_exact(conn: Any, length: int) -> Optional[bytes]:
    """Read exactly *length* bytes from *conn*, or None on a short read."""
    chunks: list[bytes] = []
    remaining = int(length)
    while remaining > 0:
        chunk = conn.recv(remaining)
        if not chunk:
            return None
        chunks.append(chunk)
        remaining -= len(chunk)
    return b"".join(chunks)


def _sway_get_tree(socket_path: Optional[str] = None) -> Optional[dict]:
    """Send GET_TREE over the sway IPC socket.  Returns None on any failure."""
    path = socket_path or _sway_socket_path()
    if not path:
        return None
    conn = None
    try:
        conn = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        conn.settimeout(SWAY_IPC_TIMEOUT)
        conn.connect(path)
        body = b""
        conn.sendall(SWAY_IPC_MAGIC + struct.pack("=II", len(body), SWAY_GET_TREE) + body)
        header = _recv_exact(conn, 14)
        if header is None or len(header) < 14 or not header.startswith(SWAY_IPC_MAGIC):
            return None
        payload_len, _msg_type = struct.unpack("=II", header[6:14])
        payload = _recv_exact(conn, payload_len) if payload_len else b""
        if payload is None:
            return None
        tree = json.loads(payload.decode("utf-8", "replace"))
    except Exception as exc:  # never crash, never log a traceback
        LOGGER.debug("sway GET_TREE failed: %s", exc)
        return None
    finally:
        if conn is not None:
            try:
                conn.close()
            except OSError:
                pass
    return tree if isinstance(tree, dict) else None


def _sway_command(socket_path: Optional[str] = None, command: str = "") -> bool:
    """Send one RUN_COMMAND to sway.  Returns True when sway accepted it."""
    path = socket_path or _sway_socket_path()
    if not path or not command:
        return False
    conn = None
    try:
        conn = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        conn.settimeout(SWAY_IPC_TIMEOUT)
        conn.connect(path)
        body = command.encode("utf-8")
        conn.sendall(SWAY_IPC_MAGIC + struct.pack("=II", len(body), SWAY_RUN_COMMAND) + body)
        header = _recv_exact(conn, 14)
        if header is None or len(header) < 14 or not header.startswith(SWAY_IPC_MAGIC):
            return False
        payload_len, _msg_type = struct.unpack("=II", header[6:14])
        payload = _recv_exact(conn, payload_len) if payload_len else b""
        if payload is None:
            return False
        reply = json.loads(payload.decode("utf-8", "replace"))
    except Exception as exc:  # never crash, never log a traceback
        LOGGER.debug("sway RUN_COMMAND failed: %s", exc)
        return False
    finally:
        if conn is not None:
            try:
                conn.close()
            except OSError:
                pass
    if isinstance(reply, list):
        return all(bool(item.get("success")) for item in reply if isinstance(item, dict))
    return bool(reply)


def _sway_rebase_pointer(socket_path: Optional[str] = None) -> bool:
    """Ask sway to re-issue the pointer position to the fresh probe surface.

    sway (wlroots) does not send a pointer ``enter`` when a layer surface is
    mapped under a stationary cursor, so the compositor is asked for a
    zero-delta ``cursor move``: its pointer focus logic runs again and the
    probe surface receives the real position.  The cursor itself does not move.
    """
    return _sway_command(socket_path, POINTER_PROBE_REBASE_COMMAND)


def _sway_focused_app_id(socket_path: Optional[str] = None) -> Optional[str]:
    """Return the app_id of the focused sway window, or None when unknown."""
    tree = _sway_get_tree(socket_path)
    if tree is None:
        return None
    return _focused_app_id(tree)


def _sway_focused_identifiers(socket_path: Optional[str] = None) -> list[str]:
    """All identifiers of the focused sway window (``[]`` when unknown)."""
    tree = _sway_get_tree(socket_path)
    if tree is None:
        return []
    return _node_app_ids(_focused_node(tree))


def _sway_focused_rect(socket_path: Optional[str] = None) -> Optional[tuple]:
    """Rect of the focused sway window, or None when it cannot be read."""
    tree = _sway_get_tree(socket_path)
    if tree is None:
        return None
    return _focused_rect(tree)


def _place_popup(
    point: Optional[tuple],
    popup_width: int,
    popup_height: int,
    *,
    focus_rect: Optional[tuple] = None,
    origin_x: int = 0,
    origin_y: int = 0,
    area_width: int = 0,
    area_height: int = 0,
    margin: int = POPUP_EDGE_MARGIN,
) -> tuple[int, int, str]:
    """Place the popup near the marked text and return ``(x, y, source)``.

    The pointer wins: the popup goes just below-right of it with a small offset,
    flips ABOVE the pointer when it would overflow the bottom, flips to the LEFT
    of the pointer when it would overflow the right, and always keeps *margin*
    px from the monitor edges.  When the pointer is unknown the focused window's
    rect is used (near its top-centre, just under the top edge) and the monitor
    top-right corner is the last fallback.  Coordinates are monitor coordinates.
    """
    min_x = origin_x + margin
    min_y = origin_y + margin
    limit_x = origin_x + area_width - margin if area_width else 0
    limit_y = origin_y + area_height - margin if area_height else 0

    def clamp(x: int, y: int) -> tuple[int, int]:
        if area_width:
            x = min(max(x, min_x), max(min_x, limit_x - popup_width))
        if area_height:
            y = min(max(y, min_y), max(min_y, limit_y - popup_height))
        return x, y

    if point is not None:
        px, py = int(point[0]), int(point[1])
        x = px + POPUP_CURSOR_X_OFFSET
        y = py + POPUP_CURSOR_Y_OFFSET
        if limit_y and y + popup_height > limit_y:
            y = py - popup_height - POPUP_CURSOR_Y_OFFSET  # flip above
        if limit_x and x + popup_width > limit_x:
            x = px - popup_width - POPUP_CURSOR_X_OFFSET  # flip left
        x, y = clamp(x, y)
        return x, y, "pointer"

    if focus_rect is not None:
        fx, fy, fwidth = int(focus_rect[0]), int(focus_rect[1]), int(focus_rect[2])
        x = fx + max(0, (fwidth - popup_width) // 2)
        y = fy + POPUP_CURSOR_Y_OFFSET
        x, y = clamp(x, y)
        return x, y, "focus-window"

    x = origin_x + max(margin, area_width - popup_width - margin) if area_width else min_x
    y = min_y
    return x, y, "corner"


def _set_break_anywhere(label) -> None:
    """Let a wrapping label break INSIDE a long unbreakable token.

    Pango's WRAP_CHAR is used instead of WRAP_WORD_CHAR because GtkLabel 4.22
    measures WRAP_WORD_CHAR inconsistently: `label.measure(HORIZONTAL, -1)`
    reports (minimum 14, natural 384) like WRAP_CHAR, but the widget then claims
    "minimum width 1885 for height 16", so a non-resizable window holding it
    grows to 1909 px and renders only ONE line (measured with a mapped window).
    With WRAP_CHAR the same label reports a consistent height-for-width: the
    window stays 408 px and the 3-line cap renders 3 lines.  Both modes let the
    token break; only WRAP_CHAR keeps the popup width bounded.
    """
    try:
        from gi.repository import Pango

        label.set_wrap_mode(Pango.WrapMode.CHAR)
    except Exception:
        LOGGER.debug("cannot set the label wrap mode", exc_info=True)


def _limit_label_lines(label, lines: int) -> None:
    """Cap a popup label to *lines* wrapped lines with a trailing ellipsis.

    The DISPLAY is truncated only: the popup still saves and edits the full
    text, which is kept in the popup state.
    """
    try:
        label.set_lines(int(lines))
    except Exception:
        LOGGER.debug("cannot cap a label to %d lines", lines, exc_info=True)
    try:
        from gi.repository import Pango

        label.set_ellipsize(Pango.EllipsizeMode.END)
    except Exception:
        LOGGER.debug("cannot ellipsize a popup label", exc_info=True)


def _make_scrolled_text_view(gtk: _Gtk, min_height: int):
    """Return ``(view, scrolled_window)`` with a wrapped text view inside."""
    Gtk = gtk.Gtk
    view = Gtk.TextView()
    view.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
    view.set_top_margin(4)
    view.set_bottom_margin(4)
    view.set_left_margin(4)
    view.set_right_margin(4)
    scrolled = Gtk.ScrolledWindow()
    scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
    scrolled.set_min_content_height(min_height)
    scrolled.set_child(view)
    return view, scrolled


def _view_text(view) -> str:
    buffer = view.get_buffer()
    start, end = buffer.get_start_iter(), buffer.get_end_iter()
    return buffer.get_text(start, end, False)


def _set_view_text(view, text: str) -> None:
    view.get_buffer().set_text(text or "")


def _known_decks(config: Any, preselect: Optional[str]) -> list[str]:
    """Deck names from AnkiConnect plus decks found in the config."""
    names: list[str] = []
    try:
        from .anki import AnkiClient

        client = AnkiClient(str(_cfg_get(config, "ankiConnectUrl", "") or ""))
        names = [str(name) for name in client.deck_names()]
    except Exception as exc:  # AnkiConnect may be down
        LOGGER.warning("cannot list AnkiConnect decks: %s", exc)
    raw = _raw(config)
    for entry in (raw.get("languages") or {}).values():
        for key in ("words", "sentences"):
            deck = _raw(entry).get(key) or (entry.get(key) if isinstance(entry, dict) else None)
            if deck and str(deck) not in names:
                names.append(str(deck))
    fallback = raw.get("fallbackDeck")
    for extra in (fallback, preselect):
        if extra and str(extra) not in names:
            names.append(str(extra))
    return names


# --------------------------------------------------------------------------
# pointer probe (true cursor position)
# --------------------------------------------------------------------------
class _PointerProbe:
    """Sample the REAL pointer position with short-lived layer-shell surfaces.

    Wayland never gives a client the global cursor position and ``xdotool``
    only tracks the XWayland pointer, which stays stale while the pointer is
    over Wayland-native clients.  This probe therefore maps one invisible,
    fullscreen layer-shell surface per monitor for a few milliseconds: the
    compositor sends the pointer to the new surface (``enter`` when the pointer
    is already over it), and the first ``enter``/``motion`` position is
    converted to monitor coordinates.  Every surface is destroyed on the first
    sample and after the timeout guard, on every path; nothing raises.
    """

    def __init__(
        self,
        gtk: _Gtk,
        callback,
        timeout_ms: int = POINTER_PROBE_TIMEOUT_MS,
        rebase: Optional[Callable[..., bool]] = None,
    ) -> None:
        self.gtk = gtk
        self.callback = callback
        self.timeout_ms = max(1, int(timeout_ms))
        #: How the compositor is asked to re-issue the pointer position.
        self.rebase = rebase or _sway_rebase_pointer
        self.windows: list = []
        self._timeout_id = None
        self._rebase_ids: list = []
        self._done = False

    # -- lifecycle ---------------------------------------------------------
    def start(self) -> bool:
        """Map the probe surfaces; False when the probe cannot be used."""
        layer_shell = self.gtk.layer_shell
        if layer_shell is None:
            LOGGER.debug("pointer probe unusable: no layer shell")
            return False
        Gdk = self.gtk.Gdk
        try:
            display = Gdk.Display.get_default()
        except Exception:
            display = None
        if display is None:
            LOGGER.debug("pointer probe unusable: no display")
            return False
        monitors: list = []
        try:
            model = display.get_monitors()
            for index in range(min(int(model.get_n_items()), POINTER_PROBE_MAX_SURFACES)):
                monitors.append(model.get_item(index))
        except Exception:
            LOGGER.debug("cannot list the monitors for the pointer probe", exc_info=True)
            monitors = []
        if not monitors:
            LOGGER.debug("pointer probe unusable: no monitors")
            return False
        # sway only reports the pointer to a fresh surface after a zero-delta
        # rebase, so without its IPC socket there is nothing to send and the
        # probe would just add latency: let the chain use xdotool instead.
        socket_path = _sway_socket_path()
        if not socket_path:
            LOGGER.debug("pointer probe unusable: no sway IPC socket")
            return False
        for monitor in monitors:
            try:
                window = self._make_window(monitor)
            except Exception:
                LOGGER.debug("cannot create a pointer probe surface", exc_info=True)
                continue
            if window is not None:
                self.windows.append(window)
        if not self.windows:
            LOGGER.debug("pointer probe unusable: no surfaces could be created")
            return False
        LOGGER.debug(
            "pointer probe mapped %d surface(s), timeout %d ms", len(self.windows), self.timeout_ms
        )
        for window in self.windows:
            try:
                window.set_visible(True)
            except Exception:
                LOGGER.debug("cannot map a pointer probe surface", exc_info=True)
        # sway will not report the pointer to this fresh surface until a
        # pointer event happens, so ask the compositor for a zero-delta move.
        self._arm_rebase(socket_path)
        try:
            self._timeout_id = self.gtk.GLib.timeout_add(self.timeout_ms, self._on_timeout)
        except Exception:
            LOGGER.debug("cannot arm the pointer probe timeout", exc_info=True)
            self.finish(None)
        return True

    def _arm_rebase(self, socket_path: Optional[str] = None) -> None:
        """Schedule the zero-delta pointer moves that make sway report us."""
        for delay in POINTER_PROBE_REBASE_MS:
            state: dict = {"id": None}
            self._rebase_ids.append(state)

            def fire(state=state):
                if state in self._rebase_ids:
                    self._rebase_ids.remove(state)
                if not self._done:
                    try:
                        accepted = bool(self.rebase(socket_path))
                    except Exception:
                        LOGGER.debug("the pointer rebase failed", exc_info=True)
                        accepted = False
                    LOGGER.debug("pointer rebase requested (accepted=%s)", accepted)
                return False

            try:
                state["id"] = self.gtk.GLib.timeout_add(max(1, int(delay)), fire)
            except Exception:
                LOGGER.debug("cannot arm the pointer rebase", exc_info=True)
                if state in self._rebase_ids:
                    self._rebase_ids.remove(state)

    def finish(self, position: Optional[tuple]) -> None:
        """Destroy every probe surface and report *position* exactly once."""
        if self._done:
            return
        self._done = True
        if position is None:
            LOGGER.debug("pointer probe finished without a pointer sample")
        else:
            LOGGER.debug("pointer probe sampled pointer=(%d, %d)", int(position[0]), int(position[1]))
        self._teardown()
        try:
            self.callback(position)
        except Exception:
            LOGGER.exception("pointer probe callback failed")

    def _teardown(self) -> None:
        if self._timeout_id is not None:
            try:
                self.gtk.GLib.source_remove(self._timeout_id)
            except Exception:
                LOGGER.debug("cannot remove the pointer probe timeout")
            self._timeout_id = None
        pending, self._rebase_ids = self._rebase_ids, []
        for state in pending:
            source_id = state.get("id")
            if source_id is None:
                continue
            try:
                self.gtk.GLib.source_remove(source_id)
            except Exception:
                LOGGER.debug("cannot remove a pointer rebase timer")
        windows, self.windows = self.windows, []
        for window in windows:
            try:
                window.destroy()
            except Exception:
                LOGGER.debug("cannot destroy a pointer probe surface", exc_info=True)

    # -- widgets -----------------------------------------------------------
    def _make_window(self, monitor):
        """One invisible, fullscreen, non-focusable layer-shell probe surface."""
        Gtk = self.gtk.Gtk
        layer_shell = self.gtk.layer_shell
        window = Gtk.Window()
        window.set_decorated(False)
        window.set_can_focus(False)
        # NOTE: never call set_resizable(False) here -- it forces the layer
        # surface to 0x0, so the compositor never routes pointer events to it.
        window.add_css_class("lexipop-pointer-probe")
        try:
            window.set_opacity(POINTER_PROBE_OPACITY)
        except Exception:
            LOGGER.debug("pointer probe opacity is not supported", exc_info=True)
        geometry = None
        try:
            geometry = monitor.get_geometry()
        except Exception:
            geometry = None
        controller = Gtk.EventControllerMotion()
        controller.connect("enter", self._on_motion, geometry)
        controller.connect("motion", self._on_motion, geometry)
        window.add_controller(controller)
        layer_shell.init_for_window(window)
        layer_shell.set_namespace(window, POINTER_PROBE_NAMESPACE)
        layer_shell.set_layer(window, layer_shell.Layer.OVERLAY)
        layer_shell.set_keyboard_mode(window, layer_shell.KeyboardMode.NONE)
        layer_shell.set_monitor(window, monitor)
        for edge_name in ("TOP", "BOTTOM", "LEFT", "RIGHT"):
            layer_shell.set_anchor(window, Gtk4Edge(self.gtk, edge_name), True)
        return window

    def _on_motion(self, _controller, x, y, geometry) -> None:
        """First pointer sample wins; convert it to monitor coordinates."""
        if self._done:
            return
        LOGGER.debug("pointer probe motion/enter at %.1f,%.1f", float(x), float(y))
        origin_x = int(getattr(geometry, "x", 0)) if geometry is not None else 0
        origin_y = int(getattr(geometry, "y", 0)) if geometry is not None else 0
        self.finish((origin_x + int(round(float(x))), origin_y + int(round(float(y)))))

    def _on_timeout(self) -> bool:
        """Timeout guard: no motion arrived, give up and clean up."""
        self._timeout_id = None
        self.finish(None)
        return False


# --------------------------------------------------------------------------
# raw pointer clicks (event-driven dismiss)
# --------------------------------------------------------------------------
def _monotonic_ms() -> float:
    """Monotonic clock in milliseconds (never jumps with the wall clock)."""
    return time.monotonic() * 1000.0


def _pointer_device_paths() -> list:
    """Every ``/dev/input/event*`` node (the udev rule grants only pointers)."""
    return sorted(glob.glob("/dev/input/event*"))


def _parse_input_event(blob: bytes) -> Optional[tuple]:
    """Return ``(type, code, value)`` of one 24-byte input_event, else None."""
    if not blob or len(blob) != INPUT_EVENT.size:
        return None
    try:
        _seconds, _micros, etype, code, value = INPUT_EVENT.unpack(blob)
    except struct.error:
        return None
    return int(etype), int(code), int(value)


def _is_left_click_press(blob: bytes) -> bool:
    """True for a left-button press (``EV_KEY``/``BTN_LEFT``/value 1) only."""
    parsed = _parse_input_event(blob)
    if parsed is None:
        return False
    etype, code, value = parsed
    return etype == EV_KEY and code == BTN_LEFT and value == KEY_PRESS


class _PointerClickListener:
    """Read raw pointer devices and report left-button presses.

    Only devices that can actually be opened are read: a device that cannot be
    opened (no permission, e.g. the udev rule is missing) is skipped silently,
    and a device that disappears is dropped without raising.  The device list is
    rescanned periodically so a hot-plugged mouse starts working.  Nothing is
    ever written to a device and nothing is ever logged from its event data.
    """

    def __init__(
        self,
        on_press: Callable,
        *,
        scan_seconds: float = POINTER_CLICK_SCAN_SECONDS,
        opener: Optional[Callable] = None,
        scanner: Optional[Callable] = None,
    ) -> None:
        self.on_press = on_press
        self.scan_seconds = max(0.5, float(scan_seconds))
        self._opener = opener or os.open
        self._scanner = scanner or _pointer_device_paths
        self._devices: dict = {}
        self._thread: Optional[threading.Thread] = None
        self._stop = threading.Event()

    def start(self) -> bool:
        """Start the daemon listener thread; False when already running."""
        if self._thread is not None:
            return False
        thread = threading.Thread(
            target=self._run, name="lexipop-pointer-clicks", daemon=True
        )
        self._thread = thread
        thread.start()
        return True

    def stop(self) -> None:
        """Signal the thread and close every open device."""
        self._stop.set()
        self._close_all()
        thread, self._thread = self._thread, None
        if thread is not None and thread is not threading.current_thread():
            try:
                thread.join(timeout=2.0)
            except Exception:
                LOGGER.debug("could not join the pointer listener", exc_info=True)

    @property
    def running(self) -> bool:
        return self._thread is not None

    # -- device handling ---------------------------------------------------
    def _open_device(self, path: str) -> Optional[int]:
        """Open one event device read-only; None when it cannot be read."""
        try:
            return int(self._opener(path, os.O_RDONLY | os.O_NONBLOCK))
        except OSError:
            LOGGER.debug(
                "pointer device not readable, skipping: %s", os.path.basename(str(path))
            )
            return None
        except Exception:
            LOGGER.debug("pointer device could not be opened", exc_info=True)
            return None

    def _scan_devices(self) -> None:
        """Open newly appeared devices and drop the ones that went away."""
        try:
            paths = [str(path) for path in self._scanner()]
        except Exception:
            LOGGER.debug("could not scan the pointer devices", exc_info=True)
            return
        for path in paths:
            if path not in self._devices:
                fd = self._open_device(path)
                if fd is not None:
                    self._devices[path] = fd
        for path in list(self._devices):
            if path not in paths:
                self._close_device(path)

    def _close_device(self, path: str) -> None:
        fd = self._devices.pop(path, None)
        if fd is None:
            return
        try:
            os.close(fd)
        except OSError:
            LOGGER.debug("could not close a pointer device")

    def _close_all(self) -> None:
        for path in list(self._devices):
            self._close_device(path)

    def _close_fd(self, fd: int) -> None:
        for path, value in list(self._devices.items()):
            if value == fd:
                self._close_device(path)

    # -- reading -----------------------------------------------------------
    def _run(self) -> None:
        """Scan, wait for readable devices and rescan every ``scan_seconds``."""
        next_scan = 0.0
        while not self._stop.is_set():
            now = time.monotonic()
            if now >= next_scan:
                self._scan_devices()
                next_scan = now + self.scan_seconds
            wake = max(0.05, min(self.scan_seconds, next_scan - time.monotonic()))
            if not self._devices:
                self._stop.wait(wake)
                continue
            try:
                ready, _write, _error = select.select(
                    list(self._devices.values()), [], [], wake
                )
            except (OSError, ValueError):
                # a device disappeared while we were waiting on it
                self._close_all()
                continue
            except Exception:
                LOGGER.debug("pointer select failed", exc_info=True)
                self._close_all()
                continue
            for fd in ready:
                self._read_device(fd)

    def _read_device(self, fd: int) -> None:
        """Read whatever is available and hand each full event to the parser."""
        try:
            data = os.read(fd, INPUT_EVENT.size * 64)
        except BlockingIOError:
            return
        except OSError:
            self._close_fd(fd)
            return
        if not data:
            self._close_fd(fd)
            return
        for offset in range(0, len(data) - INPUT_EVENT.size + 1, INPUT_EVENT.size):
            self._handle_blob(data[offset : offset + INPUT_EVENT.size])

    def _handle_blob(self, blob: bytes) -> None:
        """React ONLY to a left-button press; ignore every other event."""
        if not _is_left_click_press(blob):
            return
        try:
            self.on_press()
        except Exception:
            LOGGER.debug("the raw pointer callback failed", exc_info=True)


# --------------------------------------------------------------------------
# daemon
# --------------------------------------------------------------------------
class _ControlSocket:
    """Newline-delimited JSON control socket for the running daemon.

    A client (``lexipop ocr``) connects and sends one JSON object; the daemon
    hands the text to the GTK main loop and replies.  The listener lives on its
    own daemon thread and never raises: a malformed request is answered with
    ``{"ok": false, ...}`` instead of killing the thread.
    """

    def __init__(self, controller: "_DaemonController") -> None:
        self.controller = controller
        self.path = ocr.control_socket_path()
        self._listener: Optional[socket.socket] = None
        self._thread: Optional[threading.Thread] = None
        self._stopped = False

    # -- lifecycle ---------------------------------------------------------
    def start(self) -> bool:
        """Create the directory, bind, listen and spawn the accept thread."""
        if self._listener is not None:
            return True
        try:
            directory = os.path.dirname(self.path)
            os.makedirs(directory, exist_ok=True)
            try:
                os.chmod(directory, 0o700)
            except OSError:
                LOGGER.debug("cannot tighten the control directory mode", exc_info=True)
            # A stale socket file (a crashed daemon) would make bind() fail.
            self._unlink()
            listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            listener.bind(self.path)
            os.chmod(self.path, 0o600)
            listener.listen(CONTROL_SOCKET_BACKLOG)
            listener.settimeout(1.0)
        except OSError as exc:
            LOGGER.warning("cannot start the control socket %s: %s", self.path, exc)
            return False
        self._listener = listener
        self._thread = threading.Thread(
            target=self._serve, name="lexipop-control", daemon=True
        )
        self._thread.start()
        LOGGER.info("control socket listening on %s", self.path)
        return True

    def stop(self) -> None:
        """Close the listener, join the thread and remove the socket file."""
        self._stopped = True
        listener = self._listener
        self._listener = None
        if listener is not None:
            try:
                listener.close()
            except OSError:
                LOGGER.debug("cannot close the control socket listener")
        thread = self._thread
        self._thread = None
        if (
            thread is not None
            and thread.is_alive()
            and thread is not threading.current_thread()
        ):
            thread.join(timeout=2.0)
        self._unlink()

    def _unlink(self) -> None:
        try:
            os.unlink(self.path)
        except OSError:
            pass

    # -- accept loop -------------------------------------------------------
    def _serve(self) -> None:
        while not self._stopped:
            listener = self._listener
            if listener is None:
                return
            try:
                connection, _ = listener.accept()
            except socket.timeout:
                continue
            except OSError:
                return  # the listener was closed during shutdown
            try:
                self._handle_connection(connection)
            except Exception:
                LOGGER.exception("control connection handling failed")
            finally:
                try:
                    connection.close()
                except OSError:
                    LOGGER.debug("cannot close the control connection")

    def _handle_connection(self, connection: socket.socket) -> None:
        try:
            connection.settimeout(CONTROL_SOCKET_TIMEOUT)
        except OSError:
            pass
        payload = self._read_line(connection)
        request = self._parse(payload)
        if request is None:
            self._reply(connection, {"ok": False, "error": "malformed request"})
            return
        text = request.get("text")
        if not isinstance(text, str) or not text.strip():
            self._reply(connection, {"ok": False, "error": "empty text"})
            return
        source = request.get("source") or "external"
        try:
            self.controller.show_external_text(text, str(source))
        except Exception as exc:
            LOGGER.exception("cannot show external text")
            self._reply(
                connection,
                {"ok": False, "error": str(exc) or "internal error"},
            )
            return
        self._reply(connection, {"ok": True, "reason": "shown"})

    @staticmethod
    def _read_line(connection: socket.socket) -> bytes:
        data = b""
        try:
            while b"\n" not in data and len(data) < CONTROL_SOCKET_MAX_BYTES:
                chunk = connection.recv(65536)
                if not chunk:
                    break
                data += chunk
        except OSError:
            LOGGER.debug("could not read the control request", exc_info=True)
        return data.split(b"\n", 1)[0]

    @staticmethod
    def _parse(payload: bytes) -> Optional[dict]:
        try:
            decoded = json.loads(payload.decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            return None
        return decoded if isinstance(decoded, dict) else None

    @staticmethod
    def _reply(connection: socket.socket, payload: dict) -> None:
        try:
            connection.sendall(json.dumps(payload).encode("utf-8") + b"\n")
        except OSError:
            LOGGER.debug("cannot send the control reply", exc_info=True)


class _DaemonController:
    """Holds the popup, the watcher and the background workers of the daemon."""

    def __init__(self, gtk: _Gtk, config: Any) -> None:
        self.gtk = gtk
        self.config = config
        self.app = None
        self.watcher: Optional[selection.SelectionWatcher] = None

        self.popup = None
        self.popup_labels = None
        self.popup_content = None
        self.popup_detail_label = None
        self.popup_text_label = None
        self.popup_caption_label = None
        self.popup_target_frame = None
        self.popup_target_box = None
        self.popup_target_buttons: dict = {}
        self.popup_target_button = None
        self.popup_target_popover = None
        self.popup_target_label = None
        self._target_css_provider = None
        self._target_css_display = None
        self.popup_translation_label = None
        self.popup_status_label = None
        self.popup_close_button = None
        self.popup_ai_button = None
        self.popup_save_button = None
        self.popup_save_popover = None
        self.state: Optional[dict] = None

        self._extra_windows: list = []
        self._generation = 0
        #: Target language chosen from the popup; lives for the whole session.
        self._target: Optional[str] = None
        self._stopped = False
        self._timeout_id = None
        self._focus_poll_id = None
        #: Primary-selection poller (closes the popup when the stream is silent).
        self._poll_id = None
        self._poll_inflight = False
        #: Consecutive empty poll reads (a lone empty is a transient race).
        self._poll_empty_hits = 0
        self._focus_socket: Optional[str] = None
        self._focus_app_id: Optional[str] = None
        self._pointer_inside = False
        #: The short-lived layer-shell probe that samples the true pointer.
        self._pointer_probe = None
        #: Bumped on every hide so a late probe result is never shown.
        self._show_epoch = 0
        #: Raw pointer listener (``pointerClicks``); None when disabled.
        self._pointer_listener = None
        #: Monotonic ms of the last button press the popup itself received.
        self._popup_click_ms: Optional[float] = None
        #: Monotonic ms when the raw press that armed the grace timer arrived.
        self._click_press_ms: Optional[float] = None
        self._click_grace_id = None
        #: ``lexipop ocr`` control socket (None until :meth:`attach`).
        self._control_socket: Optional[_ControlSocket] = None

    # -- wiring ------------------------------------------------------------
    def attach(self, app) -> None:
        self.app = app
        self.watcher = selection.SelectionWatcher(
            self._on_selection,
            min_length=1,
            initial=False,
            on_clear=self._on_selection_cleared,
            settle_ms=self._settle_ms(),
        )
        self.watcher.start()
        self._start_pointer_clicks()
        self._start_control_socket()

    def shutdown(self) -> None:
        if self._stopped:
            return
        self._stopped = True
        self._stop_control_socket()
        self._stop_pointer_clicks()
        self._finish_pointer_probe()
        self._stop_selection_poll()
        if self.watcher is not None:
            self.watcher.stop()

    # -- control socket ----------------------------------------------------
    def _start_control_socket(self) -> None:
        """Start the ``lexipop ocr`` control socket; never fatal."""
        socket_server = _ControlSocket(self)
        if socket_server.start():
            self._control_socket = socket_server

    def _stop_control_socket(self) -> None:
        socket_server = self._control_socket
        self._control_socket = None
        if socket_server is not None:
            try:
                socket_server.stop()
            except Exception:
                LOGGER.debug("could not stop the control socket", exc_info=True)

    def show_external_text(self, text: str, source: str = "external") -> None:
        """Queue text delivered over the control socket (callable off-thread).

        The text is shown EXACTLY like a selection: the same lookup worker, the
        same language/kind/deck logic and the same Save / AI / Close paths.  The
        watcher settle debounce is bypassed (the watcher is not involved) and
        so is :meth:`_popup_shows_text`, so feeding the same text twice shows
        the popup again.
        """
        self.gtk.GLib.idle_add(self._handle_external_text, str(text), str(source))

    def _handle_external_text(self, text: str, source: str) -> bool:
        try:
            LOGGER.info("popup from external text (source=%s)", source)
            self._generation += 1
            generation = self._generation
            thread = threading.Thread(
                target=self._lookup_worker,
                args=(text, generation),
                name="lexipop-lookup",
                daemon=True,
            )
            thread.start()
        except Exception:  # the daemon must survive every UI error
            LOGGER.exception("external text handling failed")
        return False

    # -- selection flow ----------------------------------------------------
    def _on_selection(self, text: str) -> None:
        """Called from the watcher thread; hop to the main loop."""
        self.gtk.GLib.idle_add(self._handle_selection, text)

    def _handle_selection(self, text: str) -> bool:
        try:
            if self._suppress_if_own_window():
                return False
            if self._popup_shows_text(text):
                LOGGER.debug("selection ignored: the popup already shows this text")
                return False
            if not self._popup_enabled():
                LOGGER.debug("popup disabled in the configuration")
                return False
            excluded = self._excluded_app()
            if excluded is not None:
                # No popup, no translation, no popup log line for this app.
                LOGGER.info("selection ignored (excluded app: %s)", excluded)
                return False
            self._generation += 1
            generation = self._generation
            thread = threading.Thread(
                target=self._lookup_worker,
                args=(text, generation),
                name="lexipop-lookup",
                daemon=True,
            )
            thread.start()
        except Exception:  # the daemon must survive every UI error
            LOGGER.exception("selection handling failed")
        return False

    def _on_selection_cleared(self) -> None:
        """Called from the watcher thread when the selection became empty."""
        self.gtk.GLib.idle_add(self._handle_selection_cleared)

    def _handle_selection_cleared(self) -> bool:
        try:
            if not self._popup_gate("hideWhenSelectionCleared"):
                return False
            if self.popup is None or not self.popup.get_visible():
                return False
            self._hide_popup("selection-cleared")
        except Exception:
            LOGGER.debug("clear handling failed", exc_info=True)
        return False

    def _popup_shows_text(self, text: str) -> bool:
        """True when the visible popup already shows exactly this text.

        Belt and braces for the same trap: if our own popup text ever becomes
        the primary selection, re-processing it would replace the popup with a
        popup about itself.
        """
        try:
            if self.popup is None or not self.popup.get_visible():
                return False
            state = self.state or {}
            return str(state.get("text") or "") == str(text)
        except Exception:
            return False

    def _suppress_if_own_window(self) -> bool:
        if self._own_window_active():
            if self.watcher is not None:
                self.watcher.suppress(SUPPRESS_SECONDS)
            LOGGER.debug("popup suppressed: a lexipop window has focus")
            return True
        return False

    def _own_window_active(self) -> bool:
        """True when one of the lexipop windows currently has the focus."""
        windows = list(self._extra_windows)
        if self.popup is not None:
            windows.append(self.popup)
        if self.app is not None:
            try:
                windows.extend(self.app.get_windows())
            except Exception:
                pass
        for window in windows:
            try:
                if window.get_visible() and window.is_active():
                    return True
            except Exception:
                continue
        return False

    def _popup_enabled(self) -> bool:
        return self._popup_gate("enabled")

    def _popup_gate(self, key: str, default: bool = True) -> bool:
        """Read a boolean popup option defensively (older configs lack them)."""
        popup = _raw(_cfg_get(self.config, "popup", {}))
        value = popup.get(key, default)
        return default if value is None else bool(value)

    def _excluded_app_ids(self) -> list[str]:
        """``excludeApps`` entries, trimmed and lower-cased (defensive read)."""
        raw = _cfg_get(self.config, "excludeApps", [])
        if isinstance(raw, (list, tuple)):
            values = list(raw)
        elif isinstance(raw, str):
            values = [raw]
        else:
            values = []
        entries: list[str] = []
        for item in values:
            text = str(item or "").strip().lower()
            if text and text not in entries:
                entries.append(text)
        return entries

    def _excluded_app(self) -> Optional[str]:
        """Focused app id when it is excluded, else None.  Never raises.

        The focused app is read from the sway tree (``SWAYSOCK`` or the glob
        socket); the Wayland ``app_id`` and the X11 ``class``/``instance`` are
        all compared.  When the app cannot be determined the check FAILS OPEN
        and the popup is shown as usual.
        """
        excluded = self._excluded_app_ids()
        if not excluded:
            return None
        try:
            identifiers = _sway_focused_identifiers()
        except Exception:
            LOGGER.debug("cannot read the focused app id", exc_info=True)
            return None
        if not identifiers:
            LOGGER.debug("focused app unknown, not excluding (fail open)")
            return None
        for identifier in identifiers:
            if str(identifier).strip().lower() in excluded:
                return str(identifier)
        return None

    def _poll_selection_ms(self) -> int:
        """``popup.pollSelectionMs``: primary-selection poll interval (ms)."""
        popup = _raw(_cfg_get(self.config, "popup", {}))
        try:
            value = int(popup.get("pollSelectionMs", 300) or 0)
        except (TypeError, ValueError):
            return 300
        return max(0, value)

    def _start_selection_poll(self) -> None:
        """Poll the primary selection while the popup is visible (fallback)."""
        self._stop_selection_poll()
        self._poll_empty_hits = 0
        interval = self._poll_selection_ms()
        if interval <= 0:
            return
        try:
            self._poll_id = self.gtk.GLib.timeout_add(interval, self._on_poll_tick)
        except Exception:
            LOGGER.debug("could not start the primary-selection poller", exc_info=True)
            self._poll_id = None

    def _stop_selection_poll(self) -> None:
        """Stop the poller; it must never run while no popup is visible."""
        if self._poll_id is not None:
            try:
                self.gtk.GLib.source_remove(self._poll_id)
            except Exception:
                LOGGER.debug("could not remove the primary-selection poller")
            self._poll_id = None

    def _on_poll_tick(self) -> bool:
        """Main-loop tick: read the primary selection in a worker thread."""
        try:
            if self.popup is None or not self.popup.get_visible():
                self._poll_id = None
                return False
            if self._poll_inflight:
                return True  # a read is still running, skip this tick
        except Exception:
            LOGGER.debug("primary-selection poll tick failed", exc_info=True)
            self._poll_id = None
            return False
        self._poll_inflight = True
        threading.Thread(target=self._poll_worker, name="lexipop-poll", daemon=True).start()
        return True

    def _poll_worker(self) -> None:
        """Read the primary selection OFF the main loop."""
        text: Optional[str] = None
        try:
            text = selection.read_primary()
        except Exception:
            LOGGER.debug("could not read the primary selection", exc_info=True)
        try:
            self.gtk.GLib.idle_add(self._finish_poll, text)
        except Exception:
            self._poll_inflight = False
            LOGGER.debug("could not report the primary-selection poll", exc_info=True)

    def _finish_poll(self, text: Optional[str]) -> bool:
        """Close the popup only when the primary selection really went away.

        Only an EMPTY selection closes the popup here, and it has to read empty
        twice in a row, so a transient empty during a selection transfer cannot
        close a popup that just opened.  A different non-empty text is the
        watch stream's business -- it reports that as a new selection, so the
        poller must never race it.
        """
        self._poll_inflight = False
        try:
            if self.popup is None or not self.popup.get_visible():
                return False
            if text is None and not _wl_paste_available():
                LOGGER.debug("primary selection reader unavailable, poll skipped")
                return False
            cleaned = "" if text is None else str(text).strip()
            if cleaned:
                self._poll_empty_hits = 0
                return False
            self._poll_empty_hits += 1
            if self._poll_empty_hits >= 2:
                self._hide_popup("selection-cleared")
            return False
        except Exception:
            LOGGER.debug("primary-selection poll handling failed", exc_info=True)
        return False

    def _settle_ms(self) -> float:
        """``popup.settleMs``: how long a selection must stay unchanged (ms)."""
        popup = _raw(_cfg_get(self.config, "popup", {}))
        try:
            return max(0.0, float(popup.get("settleMs", 250) or 0))
        except (TypeError, ValueError):
            return 250.0

    def _hide_after_seconds(self) -> int:
        """Configured auto-hide delay; 0 (or a bad value) disables it."""
        popup = _raw(_cfg_get(self.config, "popup", {}))
        try:
            seconds = int(popup.get("hideAfterSeconds", 0) or 0)
        except (TypeError, ValueError):
            return 0
        return max(0, seconds)

    def _ai_available(self) -> bool:
        try:
            from . import ai

            return bool(ai.available(self.config))
        except Exception:
            return False

    def _translation_target(self) -> str:
        """Current target language: the session choice, else the config value."""
        if self._target:
            return str(self._target)
        return str(_cfg_get(self.config, "translationTarget", "tr") or "tr")

    def _target_codes(self) -> list[str]:
        """Effective, de-duplicated, order-preserving list of target languages.

        The configured ``translationTargets`` come first, then ``translationTarget``;
        the result always contains ``translationTarget`` (and never repeats a code).
        """
        primary = str(_cfg_get(self.config, "translationTarget", "tr") or "tr")
        extra = _cfg_get(self.config, "translationTargets", [])
        codes: list[str] = []
        if isinstance(extra, (list, tuple)):
            for item in extra:
                code = str(item or "").strip()
                if code and code not in codes:
                    codes.append(code)
        if primary not in codes:
            codes.append(primary)
        return codes or [primary]

    def _word_limit(self) -> int:
        try:
            return int(_cfg_get(self.config, "wordTokenLimit", 1))
        except (TypeError, ValueError):
            return 1

    def _deck_for(self, lang: Optional[str], kind: str) -> Optional[str]:
        from .classify import select_deck

        languages = _raw(_cfg_get(self.config, "languages", {}))
        fallback = _cfg_get(self.config, "fallbackDeck", None)
        return select_deck(lang, kind, languages, fallback)

    def _lookup_worker(self, text: str, generation: int) -> None:
        from .classify import classify
        from .translate import translate as trans_translate

        lang: Optional[str] = None
        lang_name: Optional[str] = None
        try:
            from .translate import identify

            info = identify(text)
            if info:
                lang = info.get("code")
                lang_name = info.get("name")
        except Exception as exc:
            LOGGER.warning("language detection failed: %s", exc)
        kind = classify(text, word_limit=self._word_limit())
        deck = self._deck_for(lang, kind)
        translation: Optional[str] = None
        error: Optional[str] = None
        try:
            translation = trans_translate(text, target=self._translation_target())
        except Exception as exc:
            error = str(exc) or exc.__class__.__name__
            LOGGER.warning("translation failed: %s", error)
        self.gtk.GLib.idle_add(
            self._finish_lookup,
            {
                "generation": generation,
                "text": text,
                "lang": lang,
                "lang_name": lang_name,
                "kind": kind,
                "deck": deck,
                "translation": translation,
                "error": error,
                "ai": None,
            },
        )

    def _finish_lookup(self, result: dict) -> bool:
        try:
            if result.get("generation") != self._generation:
                return False
            if self._suppress_if_own_window():
                return False
            self._show_popup(result)
        except Exception:
            LOGGER.exception("cannot show the popup")
        return False

    # -- popup -------------------------------------------------------------
    def _ensure_popup(self):
        if self.popup is not None:
            return self.popup
        Gtk = self.gtk.Gtk
        window = Gtk.Window()
        window.set_title("lexipop")
        window.set_decorated(False)
        window.set_resizable(False)
        window.set_can_focus(False)
        window.set_size_request(POPUP_WIDTH, -1)
        if self.app is not None:
            try:
                window.set_application(self.app)
            except Exception:
                LOGGER.debug("popup window is not managed by the application")

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        box.set_margin_top(10)
        box.set_margin_bottom(10)
        box.set_margin_start(12)
        box.set_margin_end(12)

        # Rows 1-4 stack vertically; row 1 is itself a horizontal box that holds
        # the dim detail label on the left and the target box on the right.
        labels = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        self.popup_labels = labels
        row1 = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.popup_detail_label = Gtk.Label(xalign=0)
        self.popup_detail_label.set_wrap(True)
        _set_break_anywhere(self.popup_detail_label)
        self.popup_detail_label.set_max_width_chars(48)
        self.popup_detail_label.set_hexpand(True)
        self.popup_detail_label.set_halign(Gtk.Align.START)
        self.popup_detail_label.set_valign(Gtk.Align.CENTER)
        try:
            from gi.repository import Pango

            self.popup_detail_label.set_ellipsize(Pango.EllipsizeMode.END)
        except Exception:
            LOGGER.debug("Pango ellipsize is unavailable for the detail label")
        # Top-right: ONE compact MenuButton (same pattern as the "Save as"
        # button) that OPENS a popover holding the bordered VERTICAL list of the
        # target languages, one language per row, zebra-striped inside the box.
        self.popup_target_frame = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.popup_target_frame.add_css_class("frame")
        self.popup_target_frame.add_css_class("lexipop-target-box")
        self.popup_target_frame.set_hexpand(False)
        self.popup_target_frame.set_halign(Gtk.Align.START)
        self.popup_target_frame.set_valign(Gtk.Align.START)
        self.popup_target_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.popup_target_box.set_hexpand(False)
        self.popup_target_frame.append(self.popup_target_box)
        # The window is not focusable (keyboard mode NONE), so this popover must
        # not take keyboard focus either: asking the popover for keyboard focus
        # makes gtk_popover_popup() call gtk_widget_is_ancestor() with a NULL
        # widget and log a Gtk-CRITICAL.  Pointer clicks keep working.
        self.popup_target_popover = Gtk.Popover()
        self.popup_target_popover.set_can_focus(False)
        self.popup_target_popover.set_child(self.popup_target_frame)
        self._watch_own_clicks(self.popup_target_popover)
        self.popup_target_label = Gtk.Label()
        self.popup_target_label.set_use_markup(True)
        self.popup_target_button = Gtk.MenuButton()
        # Keyboard mode NONE: the button must not take keyboard focus either.
        self.popup_target_button.set_can_focus(False)
        self.popup_target_button.add_css_class("flat")
        self.popup_target_button.set_tooltip_text(_label(self.config, "targetLanguage"))
        self.popup_target_button.set_halign(Gtk.Align.END)
        self.popup_target_button.set_valign(Gtk.Align.CENTER)
        self.popup_target_button.set_popover(self.popup_target_popover)
        self.popup_target_button.set_child(self.popup_target_label)
        self.popup_target_button.set_visible(False)
        row1.append(self.popup_detail_label)
        row1.append(self.popup_target_button)
        # Row 2 (loud): the selected text itself.
        self.popup_text_label = Gtk.Label(xalign=0)
        self.popup_text_label.set_wrap(True)
        # NOT selectable: the popup never takes focus (keyboard mode NONE), so
        # selecting text inside it would set the primary selection to our own
        # text and the focus-based loop protection could not catch it.
        self.popup_text_label.set_selectable(False)
        self.popup_text_label.set_max_width_chars(40)
        # Break inside a long unbreakable token (a code line, hash or long
        # identifier): without this the label MINIMUM width is the whole token,
        # which pushed the popup off-screen horizontally.  See _BREAK_ANYWHERE.
        _set_break_anywhere(self.popup_text_label)
        # A very long selection must not grow the popup: cap the display.
        _limit_label_lines(self.popup_text_label, MAX_SELECTION_LINES)
        # Row 3 (dim): a plain "translation -> target language" caption again.
        self.popup_caption_label = Gtk.Label(xalign=0)
        self.popup_caption_label.set_wrap(True)
        _set_break_anywhere(self.popup_caption_label)
        self.popup_caption_label.set_max_width_chars(48)
        # Row 4: the translation, or the AI coloured HTML.
        self.popup_translation_label = Gtk.Label(xalign=0)
        self.popup_translation_label.set_wrap(True)
        self.popup_translation_label.set_max_width_chars(48)
        # Same for a very long translation: break anywhere, cap the display.
        _set_break_anywhere(self.popup_translation_label)
        _limit_label_lines(self.popup_translation_label, MAX_TRANSLATION_LINES)
        for label in (
            row1,
            self.popup_text_label,
            self.popup_caption_label,
            self.popup_translation_label,
        ):
            labels.append(label)

        self.popup_status_label = Gtk.Label(xalign=0)
        self.popup_status_label.set_wrap(True)
        _set_break_anywhere(self.popup_status_label)
        self.popup_status_label.set_max_width_chars(48)
        self.popup_status_label.set_visible(False)

        # Row 5: Close | AI Translate | Save as, in a single row.
        buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        buttons.set_homogeneous(True)
        self.popup_close_button = Gtk.Button(label=_label(self.config, "close"))
        self.popup_close_button.connect("clicked", lambda *_: self._hide_popup("close"))
        self.popup_ai_button = Gtk.Button(label=_label(self.config, "ai"))
        self.popup_ai_button.connect("clicked", self._on_popup_ai)
        self.popup_ai_button.set_sensitive(self._ai_available())
        self.popup_save_popover = Gtk.Popover()
        self._watch_own_clicks(self.popup_save_popover)
        # The window is not focusable (and the layer surface uses keyboard mode
        # NONE), so GTK has no focus widget to hand the popover: asking the
        # popover for keyboard focus makes gtk_popover_popup() call
        # gtk_widget_is_ancestor() with a NULL widget and log a Gtk-CRITICAL.
        # Pointer clicks on the buttons keep working without focus.
        self.popup_save_popover.set_can_focus(False)
        self.popup_save_button = Gtk.MenuButton(label=_label(self.config, "saveAs"))
        self.popup_save_button.set_popover(self.popup_save_popover)
        buttons.append(self.popup_close_button)
        buttons.append(self.popup_ai_button)
        buttons.append(self.popup_save_button)

        # The popup height is bounded: the rows scroll (never wider, only
        # taller up to the cap) so a huge selection cannot grow the window.
        content = Gtk.ScrolledWindow()
        content.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        content.set_can_focus(False)
        content.set_min_content_height(0)
        content.set_max_content_height(POPUP_MAX_CONTENT_HEIGHT)
        content.set_propagate_natural_height(True)
        content.set_child(labels)
        self.popup_content = content
        box.append(content)
        box.append(self.popup_status_label)
        box.append(buttons)
        window.set_child(box)

        motion = Gtk.EventControllerMotion()
        motion.connect("enter", self._on_pointer_enter)
        motion.connect("leave", self._on_pointer_leave)
        window.add_controller(motion)

        # Record a button press on the popup itself: the raw pointer listener
        # uses this to tell a click-outside from a click the popup handled.
        gesture = Gtk.GestureClick()
        gesture.connect("pressed", self._on_popup_button_pressed)
        window.add_controller(gesture)

        self._apply_layer_shell(window)
        # This is the ONE popup window of the process: it is created here, once,
        # and reused for the whole daemon lifetime.  Should it ever be destroyed,
        # the references are dropped so a later show path may recreate it once.
        window.connect("destroy", self._on_popup_destroyed)
        self.popup = window
        return window

    def _on_popup_destroyed(self, *_args) -> None:
        """Forget the popup widgets after the popup window was destroyed."""
        LOGGER.debug("popup window destroyed, it will be recreated on demand")
        self.popup = None
        self.popup_labels = None
        self.popup_content = None
        self.popup_detail_label = None
        self.popup_text_label = None
        self.popup_caption_label = None
        self.popup_target_frame = None
        self.popup_target_box = None
        self.popup_target_buttons = {}
        self.popup_target_button = None
        self.popup_target_popover = None
        self.popup_target_label = None
        self.popup_translation_label = None
        self.popup_status_label = None
        self.popup_close_button = None
        self.popup_ai_button = None
        self.popup_save_button = None
        self.popup_save_popover = None

    def _apply_layer_shell(self, window) -> None:
        layer_shell = self.gtk.layer_shell
        if layer_shell is None:
            return
        try:
            layer_shell.init_for_window(window)
            layer_shell.set_namespace(window, LAYER_NAMESPACE)
            layer_shell.set_layer(window, layer_shell.Layer.OVERLAY)
            layer_shell.set_keyboard_mode(window, layer_shell.KeyboardMode.NONE)
        except Exception:
            LOGGER.exception("Gtk4LayerShell setup failed, using a plain window")

    def _popup_width(self) -> int:
        """Requested popup width: wider with the target button, but capped."""
        button = self.popup_target_button
        if button is not None:
            try:
                if button.get_visible():
                    return POPUP_MAX_WIDTH
            except Exception:
                pass
        return POPUP_WIDTH

    def _popup_size(self) -> tuple[int, int]:
        """MEASURE the popup ``(width, height)`` before it is shown.

        The width is measured first because the height depends on the width the
        window will actually get; the old fixed estimates let a long selection
        overflow the monitor.  A measurement failure falls back to the estimate.
        """
        window = self.popup
        width = self._popup_width()
        height = 0
        if window is not None:
            measured = 0
            try:
                _minimum, natural, _min_baseline, _nat_baseline = window.measure(
                    self.gtk.Gtk.Orientation.HORIZONTAL, -1
                )
                measured = int(natural)
            except Exception:
                LOGGER.debug("cannot measure the popup width", exc_info=True)
                measured = 0
            if measured > 0:
                width = measured
            height = self._popup_height(width)
        if height <= 1:
            height = POPUP_ESTIMATED_HEIGHT
        return max(1, int(width)), int(height)

    def _popup_height(self, width: Optional[int] = None) -> int:
        """MEASURE the popup height before it is shown, else use the estimate.

        The position chain needs the real height: a wrong (too small) value let
        a long selection overflow the bottom of the monitor.
        """
        window = self.popup
        if window is not None:
            requested = max(1, int(width or self._popup_width()))
            measured = 0
            try:
                _minimum, natural, _min_baseline, _nat_baseline = window.measure(
                    self.gtk.Gtk.Orientation.VERTICAL, requested
                )
                measured = int(natural)
            except Exception:
                LOGGER.debug("cannot measure the popup height", exc_info=True)
                measured = 0
            if measured <= 1:
                try:
                    measured = int(window.get_preferred_size()[1].height)
                except Exception:
                    measured = 0
            if measured > 1:
                return measured
        for widget in (self.popup, self.popup_target_box):
            try:
                value = int(widget.get_height()) if widget is not None else 0
            except Exception:
                continue
            if value > 1:
                return value
        return POPUP_ESTIMATED_HEIGHT

    def _pointer_position(self) -> Optional[tuple]:
        """Return the xdotool pointer position, re-read just before showing."""
        try:
            return pointer.cursor_position()
        except Exception:
            LOGGER.debug("cannot read the pointer position", exc_info=True)
            return None

    def _position_popup(self, window, probe_position: Optional[tuple] = None) -> None:
        """Place the popup at the mouse, near the marked text.

        Source chain: the layer-shell pointer probe, then ``xdotool``, then the
        focused sway window's rect, then the monitor top-right corner.  The
        chosen source is logged so the journal proves which one ran.
        """
        layer_shell = self.gtk.layer_shell
        if layer_shell is None:
            return  # a plain window is placed by the compositor
        Gdk = self.gtk.Gdk
        display = None
        try:
            display = Gdk.Display.get_default()
        except Exception:
            display = None
        # Prefer the probe: it samples the real Wayland pointer, which xdotool
        # cannot see while the pointer is over a Wayland-native client.
        source = None
        position = probe_position
        if position is not None:
            source = "pointer-probe"
        else:
            position = self._pointer_position()
            if position is not None:
                source = "pointer-xdotool"
        monitor = None
        if display is not None and position is not None:
            try:
                monitor = display.get_monitor_at_point(position[0], position[1])
            except Exception:
                monitor = None
        if monitor is None and display is not None:
            try:
                monitors = display.get_monitors()
                if monitors.get_n_items():
                    monitor = monitors.get_item(0)
            except Exception:
                monitor = None
        geometry = None
        try:
            geometry = monitor.get_geometry() if monitor is not None else None
        except Exception:
            geometry = None
        try:
            if monitor is not None:
                layer_shell.set_monitor(window, monitor)
        except Exception:
            LOGGER.debug("layer shell monitor could not be set")

        origin_x = int(geometry.x) if geometry is not None else 0
        origin_y = int(geometry.y) if geometry is not None else 0
        width = int(geometry.width) if geometry is not None else 0
        height = int(geometry.height) if geometry is not None else 0

        focus_rect = None
        if position is None:
            # Fallback 1: the focused window's rect from the sway tree.
            try:
                focus_rect = _sway_focused_rect()
            except Exception:
                LOGGER.debug("could not read the focused window rect", exc_info=True)
                focus_rect = None
            LOGGER.debug("pointer unknown, focus rect=%s", focus_rect)

        popup_width, popup_height = self._popup_size()
        LOGGER.debug("measured popup size: %dx%d px", popup_width, popup_height)
        x, y, placement = _place_popup(
            position,
            popup_width,
            popup_height,
            focus_rect=focus_rect,
            origin_x=origin_x,
            origin_y=origin_y,
            area_width=width,
            area_height=height,
        )
        if position is not None and source is not None:
            detail = "%s=(%d, %d)" % (source, int(position[0]), int(position[1]))
        else:
            # ``_place_popup`` says focus-window or corner here.
            detail = placement
        LOGGER.info("popup position x=%d y=%d (%s)", int(x), int(y), detail)
        try:
            for edge, anchor in (
                (Gtk4Edge(self.gtk, "TOP"), True),
                (Gtk4Edge(self.gtk, "LEFT"), True),
                (Gtk4Edge(self.gtk, "BOTTOM"), False),
                (Gtk4Edge(self.gtk, "RIGHT"), False),
            ):
                layer_shell.set_anchor(window, edge, anchor)
            layer_shell.set_margin(window, Gtk4Edge(self.gtk, "LEFT"), max(0, int(x - origin_x)))
            layer_shell.set_margin(window, Gtk4Edge(self.gtk, "TOP"), max(0, int(y - origin_y)))
        except Exception:
            LOGGER.warning("could not position the layer shell popup")


    def _escape(self, text: Any) -> str:
        """Escape text for Pango markup."""
        text = "" if text is None else str(text)
        try:
            return self.gtk.GLib.markup_escape_text(text)
        except Exception:
            return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

    def _set_dim_label(self, label, text: str) -> None:
        """Show small, dim text (rows 1 and 3 of the popup)."""
        try:
            label.set_markup("<small>%s</small>" % self._escape(text))
        except Exception:
            label.set_text(text)

    def _set_popup_text(self, result: dict) -> None:
        """Fill row 2 (the selection) and row 4 (translation or AI HTML).

        With an AI result both rows show the coloured HTML, so every aligned pair
        gets the same colour on the source row and on the translation row.
        Without one, row 2 stays plain escaped text.
        """
        text = result.get("text") or ""
        ai_result = result.get("ai")
        front_html = getattr(ai_result, "front_html", None) if ai_result is not None else None
        if front_html:
            try:
                self.popup_text_label.set_markup("<big>%s</big>" % _html_to_pango(front_html))
            except Exception:
                LOGGER.debug("could not render the AI source markup")
                self.popup_text_label.set_text(text)
        else:
            try:
                self.popup_text_label.set_markup("<big>%s</big>" % self._escape(text))
            except Exception:
                self.popup_text_label.set_text(text)
        back_html = getattr(ai_result, "back_html", None) if ai_result is not None else None
        if back_html:
            try:
                self.popup_translation_label.set_markup(_html_to_pango(back_html))
                return
            except Exception:
                LOGGER.debug("could not render the AI translation markup")
        if result.get("translation"):
            self.popup_translation_label.set_text(result["translation"])
        elif result.get("error"):
            self.popup_translation_label.set_text("translation failed: %s" % result["error"])
        else:
            self.popup_translation_label.set_text("(no translation)")

    def _show_popup(self, result: dict) -> None:
        window = self._ensure_popup()
        self.state = result
        labels = _popup_labels(self.config)
        kind = str(result.get("kind") or "")
        detail = "%s %s · %s" % (
            _language_name(self.config, result.get("lang"), result.get("lang_name")),
            labels.get("detected", DEFAULT_LABELS["detected"]),
            labels.get(kind, kind),
        )
        self._set_dim_label(self.popup_detail_label, detail)
        self._set_popup_text(result)
        self._refresh_target_row()
        self._set_popup_status(None)
        self.popup_ai_button.set_sensitive(self._ai_available())
        self._rebuild_save_menu(result)
        # Sample the TRUE pointer position on the main loop first; the probe
        # answers through the first motion event or through the timeout guard.
        epoch = self._show_epoch
        if self._start_pointer_probe(result, epoch):
            return
        self._finish_show_popup(result, window, None, epoch)

    def _start_pointer_probe(self, result: dict, epoch: int) -> bool:
        """Map the invisible pointer probe; False when it is not usable."""
        self._finish_pointer_probe()
        try:
            self._install_target_css()  # this provider also carries the probe CSS
            probe = _PointerProbe(
                self.gtk,
                lambda position: self._on_pointer_probe(result, position, epoch),
            )
            if not probe.start():
                return False
        except Exception:
            LOGGER.debug("the pointer probe could not start", exc_info=True)
            return False
        self._pointer_probe = probe
        return True

    def _on_pointer_probe(self, result: dict, position: Optional[tuple], epoch: int) -> None:
        """Called by the probe on the main loop: place and show the popup."""
        self._pointer_probe = None
        if self.state is not result:
            LOGGER.debug("the pointer probe result is stale, ignoring it")
            return
        window = self.popup
        if window is None:
            return
        self._finish_show_popup(result, window, position, epoch)

    def _finish_pointer_probe(self) -> None:
        """Destroy a probe surface that is still mapped."""
        probe = self._pointer_probe
        self._pointer_probe = None
        if probe is not None:
            try:
                probe.finish(None)
            except Exception:
                LOGGER.debug("could not finish the pointer probe", exc_info=True)

    def _finish_show_popup(
        self, result: dict, window, position: Optional[tuple], epoch: int
    ) -> None:
        """Position and show the popup that was already filled with *result*."""
        try:
            if self._show_epoch != epoch or self.state is not result:
                LOGGER.debug("the popup was hidden or replaced before it was shown")
                return
            self._position_popup(window, probe_position=position)
            self._pointer_inside = False
            LOGGER.info(
                "popup for lang=%s kind=%s deck=%s",
                result.get("lang"),
                str(result.get("kind") or ""),
                result.get("deck"),
            )
            window.set_visible(True)
            self._arm_timeout()
            self._start_focus_watch()
            self._start_selection_poll()
        except Exception:
            LOGGER.exception("cannot show the popup")

    # -- target language ---------------------------------------------------
    def _caption_text(self) -> str:
        """Row 3 text: a plain ``Translation → Türkçe`` caption (no affordance)."""
        return "%s → %s" % (
            _label(self.config, "translation"),
            _language_name(self.config, self._translation_target()),
        )

    def _update_caption(self) -> None:
        """Refresh row 3, the button label and the active row of the list."""
        if self.popup_caption_label is not None:
            self._set_dim_label(self.popup_caption_label, self._caption_text())
        current = self._translation_target()
        if self.popup_target_label is not None:
            try:
                self.popup_target_label.set_markup(
                    "<small>%s ▾</small>" % self._escape(_language_name(self.config, current))
                )
            except Exception:
                LOGGER.debug("cannot update the target button label")
        for code, button in self.popup_target_buttons.items():
            active = code == current
            if button.get_active() != active:
                button.set_active(active)
            try:
                if active:
                    if not button.has_css_class("lexipop-row-active"):
                        button.add_css_class("lexipop-row-active")
                elif button.has_css_class("lexipop-row-active"):
                    button.remove_css_class("lexipop-row-active")
            except Exception:
                LOGGER.debug("cannot mark the active target row")

    def _refresh_target_row(self) -> None:
        """Show the target box when several targets exist, else the caption."""
        codes = self._target_codes()
        multi = len(codes) > 1
        self._rebuild_target_box(codes)
        # Row 3 stays a plain caption in both cases: it labels row 4, while the
        # top-right box is the control.
        if self.popup_caption_label is not None:
            self.popup_caption_label.set_visible(True)
        if self.popup_detail_label is not None:
            # Narrow the left label so the row stays inside the popup width cap.
            self.popup_detail_label.set_max_width_chars(30 if multi else 48)
        self._update_caption()

    def _zebra_overlay(self, alpha: float) -> str:
        """Subtle ``rgba()`` overlay for the zebra rows, taken from the theme."""
        red = green = blue = 1.0
        widget = self.popup_target_box if self.popup_target_box is not None else self.popup
        try:
            color = widget.get_style_context().get_color()
            red, green, blue = float(color.red), float(color.green), float(color.blue)
        except Exception:
            # Theme colours could not be read: use a very low-alpha
            # black (light theme) or white (dark theme) overlay.
            dark = False
            try:
                settings = self.gtk.Gtk.Settings.get_default()
                theme = str(settings.get_property("gtk-theme-name") or "") if settings else ""
                dark = "dark" in theme.lower()
            except Exception:
                LOGGER.debug("cannot read the GTK theme name")
            red = green = blue = 1.0 if dark else 0.0
        return "rgba(%d, %d, %d, %.3f)" % (
            round(red * 255), round(green * 255), round(blue * 255), float(alpha)
        )

    def _target_css(self) -> str:
        """CSS for the single target box: zebra rows plus the active row."""
        return "\n".join(
            [
                ".lexipop-target-box { border-radius: 6px; }",
                ".lexipop-target-row { border-radius: 0; padding: 2px 8px; }",
                ".lexipop-zebra-even { background-color: %s; }" % self._zebra_overlay(0.05),
                ".lexipop-zebra-odd { background-color: %s; }" % self._zebra_overlay(0.12),
                ".lexipop-target-row.lexipop-row-active { background-color: %s; font-weight: bold; }"
                % self._zebra_overlay(0.24),
                # The pointer probe surface must be invisible but still map:
                # a nearly transparent background keeps pointer events coming.
                ".lexipop-pointer-probe { background-color: rgba(0, 0, 0, 0.010);"
                " box-shadow: none; border: none; }",
            ]
        )

    def _install_target_css(self) -> None:
        """Add the zebra CssProvider to the display once per daemon run."""
        if self._target_css_provider is not None:
            return
        Gtk = self.gtk.Gtk
        Gdk = self.gtk.Gdk
        provider = Gtk.CssProvider()
        css = self._target_css()
        try:
            provider.load_from_data(css.encode("utf-8"))
        except TypeError:  # older PyGObject wants a str
            try:
                provider.load_from_data(css)
            except Exception:
                LOGGER.debug("cannot load the target-box CSS", exc_info=True)
                return
        except Exception:
            LOGGER.debug("cannot load the target-box CSS", exc_info=True)
            return
        self._target_css_provider = provider
        display = None
        try:
            display = Gdk.Display.get_default()
        except Exception:
            display = None
        if display is None:
            return
        try:
            Gtk.StyleContext.add_provider_for_display(
                display, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )
            self._target_css_display = display
        except Exception:
            LOGGER.debug("cannot add the target-box CSS provider", exc_info=True)

    def _rebuild_target_box(self, codes: Any) -> None:
        """(Re)build the one top-right box: a zebra-striped row per language."""
        box = self.popup_target_box
        if box is None:
            return
        Gtk = self.gtk.Gtk
        self._install_target_css()
        self.popup_target_buttons = {}
        child = box.get_first_child()
        while child is not None:
            box.remove(child)
            child = box.get_first_child()
        current = self._translation_target()
        for index, code in enumerate(codes):
            name = _language_name(self.config, code)
            active = code == current
            row = Gtk.ToggleButton()
            # The window is not focusable (keyboard mode NONE), so the rows of
            # the target box must not take keyboard focus either.
            row.set_can_focus(False)
            row.add_css_class("flat")
            row.add_css_class("lexipop-target-row")
            # ZEBRA: alternate rows get a different, subtle background.
            row.add_css_class("lexipop-zebra-odd" if index % 2 else "lexipop-zebra-even")
            if active:
                row.add_css_class("lexipop-row-active")
            row.set_halign(Gtk.Align.FILL)
            row.set_tooltip_text(name)
            label = Gtk.Label()
            label.set_use_markup(True)
            label.set_markup("<small>%s</small>" % self._escape(name))
            row.set_child(label)
            row.set_active(active)
            row.connect("clicked", lambda _b, chosen=code: self._choose_target(chosen))
            box.append(row)
            self.popup_target_buttons[code] = row
        # The whole box stays hidden when only one target language exists.
        # The button (and so the whole list) stays hidden with ONE target.
        visible = len(codes) > 1
        box.set_visible(visible)
        if self.popup_target_frame is not None:
            self.popup_target_frame.set_visible(visible)
        if self.popup_target_button is not None:
            self.popup_target_button.set_visible(visible)

    def _close_target_popover(self) -> None:
        """Close the language popover after a choice; never raise."""
        popover = self.popup_target_popover
        if popover is None:
            return
        try:
            popover.popdown()
        except Exception:
            LOGGER.debug("could not close the target popover")

    def _choose_target(self, code: Any) -> None:
        """Switch the session target, re-translate and close the popover."""
        code = str(code or "")
        if not code or code == self._translation_target():
            # Clicking the active row does nothing except close the popover.
            self._close_target_popover()
            self._update_caption()
            return
        self._target = code
        self._refresh_target_row()
        self._close_target_popover()
        state = self.state
        if state is None:
            return
        self._set_popup_status("translating into %s…" % _language_name(self.config, code))
        generation = state.get("generation")
        worker = self._retarget_ai_worker if state.get("ai") is not None else self._retarget_worker
        threading.Thread(
            target=worker,
            args=(state, generation, code),
            name="lexipop-retarget",
            daemon=True,
        ).start()

    def _retarget_worker(self, state: dict, generation: Any, code: str) -> None:
        """Re-translate the current text with ``trans`` in a worker thread."""
        from .translate import translate as trans_translate

        translation = None
        error = None
        try:
            translation = trans_translate(state.get("text") or "", target=code)
        except Exception as exc:
            error = str(exc) or exc.__class__.__name__
            LOGGER.warning("retranslation into %s failed: %s", code, error)
        self.gtk.GLib.idle_add(
            self._finish_retarget, state, generation, code, translation, None, error
        )

    def _retarget_ai_worker(self, state: dict, generation: Any, code: str) -> None:
        """Re-run the AI translation when an AI result is already shown."""
        from . import ai

        result = None
        error = None
        try:
            result = ai.ai_translate(
                self.config,
                state.get("text") or "",
                target=code,
                source=state.get("lang"),
            )
        except Exception as exc:
            error = str(exc) or exc.__class__.__name__
            LOGGER.warning("AI retranslation into %s failed: %s", code, error)
        self.gtk.GLib.idle_add(
            self._finish_retarget, state, generation, code, None, result, error
        )

    def _finish_retarget(
        self,
        state: dict,
        generation: Any,
        code: str,
        translation: Optional[str],
        ai_result: Any,
        error: Optional[str],
    ) -> bool:
        """Apply a finished retranslation on the main loop; never raise."""
        try:
            if state is not self.state or generation != self._generation:
                return False
            if code != self._translation_target():
                return False  # the target changed again while we were working
            if error is not None:
                self._set_popup_status("translation failed: %s" % error)
                return False
            if ai_result is not None:
                state["ai"] = ai_result
                if getattr(ai_result, "translation", None):
                    state["translation"] = ai_result.translation
                state["error"] = None
                self._set_popup_text(state)
                self._set_popup_status("AI translation ready (coloured)")
            else:
                state["translation"] = translation
                state["error"] = None
                self._set_popup_text(state)
                self._set_popup_status(None)
            self._update_caption()
        except Exception:
            LOGGER.exception("cannot apply the retranslation")
        return False

    def _set_popup_status(self, message: Optional[str]) -> None:
        if self.popup_status_label is None:
            return
        self.popup_status_label.set_text(message or "")
        self.popup_status_label.set_visible(bool(message))

    def _hide_popup(self, reason: Any = None) -> bool:
        """Hide the popup, stop its timers and let the same text pop up again."""
        try:
            self._show_epoch += 1
            self._finish_pointer_probe()
            self._cancel_timeout()
            self._stop_focus_watch()
            self._stop_selection_poll()
            self._close_save_menu()
            self._close_target_popover()
            if self.popup is not None:
                self.popup.set_visible(False)
            if self.watcher is not None:
                self.watcher.reset()
            LOGGER.info("popup hidden (%s)", reason if reason is not None else "requested")
        except Exception:  # hiding must never raise
            LOGGER.debug("could not hide the popup", exc_info=True)
        return False

    # -- popup closing: raw pointer clicks ---------------------------------
    def _pointer_clicks_enabled(self) -> bool:
        """``pointerClicks`` (older configs lack it): read defensively."""
        return bool(_cfg_get(self.config, "pointerClicks", False))

    def _start_pointer_clicks(self) -> None:
        """Start the raw pointer listener when the option is enabled."""
        if self._pointer_listener is not None:
            return
        if not self._pointer_clicks_enabled():
            LOGGER.debug("pointer-click dismiss is disabled in the configuration")
            return
        listener = _PointerClickListener(self._on_raw_pointer_press)
        if not listener.start():
            return
        self._pointer_listener = listener
        LOGGER.info("pointer-click dismiss enabled")

    def _stop_pointer_clicks(self) -> None:
        """Stop the listener and its grace timer (safe when never started)."""
        listener, self._pointer_listener = self._pointer_listener, None
        self._cancel_click_grace()
        if listener is not None:
            listener.stop()

    def _on_raw_pointer_press(self) -> None:
        """Called from the listener thread; hop to the main loop."""
        try:
            self.gtk.GLib.idle_add(self._arm_click_grace)
        except Exception:
            LOGGER.debug("could not schedule the click grace timer", exc_info=True)

    def _on_popup_button_pressed(self, *_args) -> None:
        """Record that one of our own surfaces received a button press."""
        self._popup_click_ms = _monotonic_ms()

    def _watch_own_clicks(self, widget) -> None:
        """Record button presses on one of our own surfaces.

        The raw pointer listener sees EVERY left press, including presses on our
        own popovers.  A `Gtk.Popover` is a separate Wayland surface (and can even
        be a separate window), so the popup window never sees those presses and
        they would look like a click-outside and dismiss the popup -- choosing a
        language or a deck would close it.
        """
        try:
            Gtk = self.gtk.Gtk
            gesture = Gtk.GestureClick()
            gesture.connect("pressed", self._on_popup_button_pressed)
            widget.add_controller(gesture)
        except Exception:
            LOGGER.debug("could not watch clicks on an own surface", exc_info=True)

    def _arm_click_grace(self) -> bool:
        """A raw left press was seen: arm the ~250 ms grace timer."""
        self._cancel_click_grace()
        self._click_press_ms = _monotonic_ms()
        try:
            self._click_grace_id = self.gtk.GLib.timeout_add(
                POINTER_CLICK_GRACE_MS, self._on_click_grace
            )
        except Exception:
            LOGGER.debug("could not arm the click grace timer", exc_info=True)
            self._click_grace_id = None
        return False

    def _cancel_click_grace(self) -> None:
        if self._click_grace_id is not None:
            try:
                self.gtk.GLib.source_remove(self._click_grace_id)
            except Exception:
                LOGGER.debug("could not remove the click grace timer")
            self._click_grace_id = None

    def _popup_handled_click(self) -> bool:
        """True when the popup itself received a button press for this click.

        The press and the popup's own button event travel on different paths
        (evdev vs. the compositor), so a small slack is allowed before the press.
        """
        click = self._popup_click_ms
        if click is None:
            return False
        press = self._click_press_ms
        if press is None:
            return True
        return click >= press - POINTER_CLICK_SLACK_MS

    def _on_click_grace(self) -> bool:
        """Grace elapsed: hide unless the popup handled the button press."""
        self._click_grace_id = None
        try:
            if self.popup is None or not self.popup.get_visible():
                return False
            if self._popup_handled_click():
                LOGGER.debug("click ignored: the popup handled it itself")
                return False
            self._hide_popup("click-outside")
        except Exception:
            LOGGER.debug("click grace handling failed", exc_info=True)
        return False

    # -- popup closing: safety timeout -------------------------------------
    def _cancel_timeout(self) -> None:
        if self._timeout_id is not None:
            try:
                self.gtk.GLib.source_remove(self._timeout_id)
            except Exception:
                LOGGER.debug("could not remove the hide timer")
            self._timeout_id = None

    def _arm_timeout(self) -> None:
        self._cancel_timeout()
        seconds = self._hide_after_seconds()
        if seconds <= 0:
            return
        try:
            self._timeout_id = self.gtk.GLib.timeout_add_seconds(seconds, self._on_timeout)
        except Exception:
            LOGGER.debug("could not arm the hide timer")

    def _on_timeout(self) -> bool:
        if self._pointer_inside:
            return True  # never hide while the pointer is over the popup
        self._timeout_id = None  # this source ends here
        self._hide_popup("timeout")
        return False

    def _on_pointer_enter(self, *_args) -> None:
        self._pointer_inside = True
        self._cancel_timeout()

    def _on_pointer_leave(self, *_args) -> None:
        self._pointer_inside = False
        try:
            visible = self.popup is not None and self.popup.get_visible()
        except Exception:
            visible = False
        if visible:
            self._arm_timeout()

    # -- popup closing: sway focus poller ----------------------------------
    def _start_focus_watch(self) -> None:
        self._stop_focus_watch()
        if not self._popup_gate("hideWhenFocusChanges"):
            return
        socket_path = _sway_socket_path()
        if not socket_path:
            LOGGER.debug("no sway IPC socket, focus-close disabled")
            return
        self._focus_socket = socket_path
        self._focus_app_id = _sway_focused_app_id(socket_path)
        try:
            self._focus_poll_id = self.gtk.GLib.timeout_add(FOCUS_POLL_MS, self._poll_focus)
        except Exception:
            LOGGER.debug("could not start the focus poller")
            self._focus_poll_id = None

    def _stop_focus_watch(self) -> None:
        if self._focus_poll_id is not None:
            try:
                self.gtk.GLib.source_remove(self._focus_poll_id)
            except Exception:
                LOGGER.debug("could not remove the focus poller")
            self._focus_poll_id = None
        self._focus_socket = None
        self._focus_app_id = None

    def _focus_moved_away(self) -> bool:
        """True when focus moved to another, non-lexipop window."""
        if not self._focus_socket:
            return False
        current = _sway_focused_app_id(self._focus_socket)
        if current is None or current == self._focus_app_id:
            return False
        return not current.startswith(LEXIPOP_APP_PREFIX)

    def _poll_focus(self) -> bool:
        try:
            if self.popup is None or not self.popup.get_visible():
                self._focus_poll_id = None  # this source ends here
                return False
            if self._focus_moved_away():
                self._hide_popup("focus-changed")
                return False
        except Exception:
            LOGGER.debug("focus poll failed", exc_info=True)
            self._focus_poll_id = None
            return False
        return True

    # -- popup actions -----------------------------------------------------
    def _deck_choices(self, lang: Optional[str], default_deck: Optional[str]) -> list:
        """Return (deck, is_default) entries for the Save as popover."""
        languages = _raw(_cfg_get(self.config, "languages", {}))
        entry = _raw(languages.get(str(lang)) if lang else None)
        choices: list = []

        def add(deck: Any, is_default: bool) -> None:
            deck = str(deck or "")
            if not deck or any(deck == name for name, _ in choices):
                return
            choices.append((deck, is_default))

        add(default_deck, True)
        for key in ("words", "sentences"):
            add(entry.get(key), False)
        for key, deck in entry.items():
            if key not in ("words", "sentences"):
                add(deck, False)
        if not choices:
            add(_cfg_get(self.config, "fallbackDeck", None), True)
        return choices

    def _rebuild_save_menu(self, result: dict) -> None:
        """(Re)build the Save as popover for the current selection."""
        popover = self.popup_save_popover
        if popover is None:
            return
        Gtk = self.gtk.Gtk
        labels = _popup_labels(self.config)
        kind = str(result.get("kind") or "")
        kind_label = labels.get(kind, kind)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        for margin in ("top", "bottom", "start", "end"):
            getattr(box, "set_margin_" + margin)(6)
        for deck, is_default in self._deck_choices(result.get("lang"), result.get("deck")):
            text = "%s (%s)" % (deck, kind_label) if is_default else deck
            button = Gtk.Button(label=text)
            button.set_halign(Gtk.Align.FILL)
            button.connect("clicked", lambda _b, name=deck: self._choose_deck(name))
            box.append(button)
        box.append(Gtk.Separator())
        edit_button = Gtk.Button(label=labels.get("edit", DEFAULT_LABELS["edit"]))
        edit_button.connect("clicked", self._on_popup_edit)
        box.append(edit_button)
        popover.set_child(box)

    def _close_save_menu(self) -> None:
        if self.popup_save_popover is None:
            return
        try:
            self.popup_save_popover.popdown()
        except Exception:
            LOGGER.debug("could not close the save menu")

    def _choose_deck(self, deck: str) -> None:
        """Save into the chosen deck, then hide the popup."""
        self._close_save_menu()
        if not deck:
            return
        state = self.state
        if not state:
            return
        front, back = self._popup_html()
        self._set_popup_status("saving…")
        self._save_note(
            deck,
            front,
            back,
            on_ok=self._popup_saved,
            on_error=lambda message: self._set_popup_status("AnkiConnect: %s" % message),
        )

    def _popup_saved(self, _note_id=None) -> None:
        self._set_popup_status("saved")
        try:
            self.gtk.GLib.timeout_add(1200, self._hide_popup)
        except Exception:
            self._hide_popup("saved")

    def _on_popup_edit(self, *_args) -> None:
        self._open_editor()

    def _open_editor(self) -> None:
        state = self.state
        if not state:
            return
        if self.watcher is not None:
            self.watcher.suppress(SUPPRESS_SECONDS)
        try:
            window = _EditorWindow(
                self.gtk,
                self.config,
                text=state.get("text") or "",
                lang=state.get("lang"),
                kind=state.get("kind"),
                deck=state.get("deck"),
                target=self._translation_target(),
                translation=state.get("translation"),
                ai_result=state.get("ai"),
                application=self.app,
                on_saved=self._hide_popup,
            )
        except Exception:
            LOGGER.exception("cannot open the editor")
            self._set_popup_status("cannot open the editor")
            return
        self._extra_windows.append(window)
        window.connect_destroy(lambda *_: self._forget_window(window))
        window.present()
        self._hide_popup()

    def _forget_window(self, window) -> None:
        try:
            self._extra_windows.remove(window)
        except ValueError:
            pass

    def _on_popup_ai(self, *_args) -> None:
        state = self.state
        if not state:
            return
        from . import ai

        if not ai.available(self.config):
            self._set_popup_status("AI disabled: enable ai and set ai.apiKeyFile")
            return
        self._set_popup_status("AI translation…")
        generation = state.get("generation")
        thread = threading.Thread(
            target=self._ai_worker,
            args=(state, generation),
            name="lexipop-ai",
            daemon=True,
        )
        thread.start()

    def _ai_worker(self, state: dict, generation: Optional[int]) -> None:
        from . import ai

        result = None
        error = None
        try:
            result = ai.ai_translate(
                self.config,
                state.get("text") or "",
                target=self._translation_target(),
                source=state.get("lang"),
            )
        except Exception as exc:
            error = str(exc) or exc.__class__.__name__
            LOGGER.warning("AI translation failed: %s", error)
        self.gtk.GLib.idle_add(self._finish_ai, state, generation, result, error)

    def _finish_ai(self, state: dict, generation: Optional[int], result, error) -> bool:
        try:
            if state is not self.state:
                return False
            if error is not None:
                self._set_popup_status("AI failed: %s" % error)
                return False
            state["ai"] = result
            self._set_popup_text(state)
            self._set_popup_status("AI translation ready (coloured)")
        except Exception:
            LOGGER.exception("cannot apply the AI result")
        return False

    def _popup_html(self) -> tuple[str, str]:
        from .classify import text_to_html

        state = self.state or {}
        front = text_to_html(state.get("text") or "")
        back = text_to_html(state.get("translation") or "")
        result = state.get("ai")
        if result is not None:
            front = getattr(result, "front_html", None) or front
            back = getattr(result, "back_html", None) or back
        return front, back

    # -- saving ------------------------------------------------------------
    def _save_note(self, deck: str, front_html: str, back_html: str, *,
                   on_ok: Callable[[Any], None],
                   on_error: Callable[[str], None]) -> None:
        """Add a note in a worker thread and report back on the main loop."""
        from .anki import AnkiClient
        from .notes import build_note_request

        config = self.config

        def worker() -> None:
            try:
                client = AnkiClient(str(_cfg_get(config, "ankiConnectUrl", "") or ""))
                request = build_note_request(config, deck, front_html, back_html)
                note_id = client.add_note(
                    request["deckName"],
                    request["modelName"],
                    request["fields"],
                    request.get("tags"),
                )
            except Exception as exc:
                message = str(exc) or exc.__class__.__name__
                LOGGER.warning("could not add the note: %s", message)
                self.gtk.GLib.idle_add(on_error, message)
            else:
                self.gtk.GLib.idle_add(on_ok, note_id)

        threading.Thread(target=worker, name="lexipop-save", daemon=True).start()


def Gtk4Edge(gtk: _Gtk, name: str):
    """Return a gtk4-layer-shell ``Edge`` member by name."""
    return getattr(gtk.layer_shell.Edge, name)


# --------------------------------------------------------------------------
# mini editor
# --------------------------------------------------------------------------
#: CSS class applied to the editor inputs (Front/Back, Deck) so they read as
#: a distinct, bordered column against the window background.
EDITOR_INPUT_CLASS = "lexipop-editor-input"
#: CSS class for the bordered preview card.
EDITOR_CARD_CLASS = "lexipop-editor-card"
#: CSS class for one colour swatch button (``-<index>`` carries the colour).
EDITOR_SWATCH_CLASS = "lexipop-swatch"
#: Marker class for the swatch that is currently assigned to a pair.
EDITOR_SWATCH_ACTIVE_CLASS = "lexipop-swatch-active"

#: Editor window geometry.
EDITOR_WIDTH = 560
EDITOR_HEIGHT = 640
#: Content margins and spacing between the editor sections.
EDITOR_MARGIN = 16
EDITOR_SPACING = 10

#: Text drawn between the two sides of an aligned pair row.
PAIR_ARROW = "\u2194"


class _EditorWindow:
    """Sectioned mini editor: Front/Back, deck, colour picker, preview, Save."""

    def __init__(
        self,
        gtk: _Gtk,
        config: Any,
        *,
        text: str,
        lang: Optional[str] = None,
        kind: Optional[str] = None,
        deck: Optional[str] = None,
        target: Optional[str] = None,
        translation: Optional[str] = None,
        ai_result: Any = None,
        application: Any = None,
        on_saved: Optional[Callable[[Any], None]] = None,
    ) -> None:
        from .classify import classify, select_deck
        from .notes import DEFAULT_PALETTE

        self.gtk = gtk
        self.config = config
        self.on_saved = on_saved
        self.text = text
        self.lang = lang
        self.word_limit = 1
        try:
            self.word_limit = int(_cfg_get(config, "wordTokenLimit", 1))
        except (TypeError, ValueError):
            self.word_limit = 1
        self.kind = kind or classify(text, word_limit=self.word_limit)
        if deck is None:
            deck = select_deck(
                lang,
                self.kind,
                _raw(_cfg_get(config, "languages", {})),
                _cfg_get(config, "fallbackDeck", None),
            )
        self.deck = deck
        # The target language chosen in the popup (else the configured one), so
        # translating, previewing and saving all use the same target.
        self.target = str(
            target or _cfg_get(config, "translationTarget", "tr") or "tr"
        )
        self.translation = translation or ""
        self.ai_result = ai_result
        #: Colour cycle used for the aligned pairs.  The ``palette`` config key
        #: is optional: fall back to the shared default palette.
        self.palette = self._read_palette(DEFAULT_PALETTE)
        #: pair index -> palette index chosen by the user (default: index).
        self.pair_choices: dict = {}
        #: Swatch rows rebuilt from the current AI result (introspection aid).
        self.swatch_rows: list = []
        self._css_provider = None
        self._css_display = None
        #: Exact CSS text registered for the display (introspection aid).
        self.css_text = ""

        Gtk = gtk.Gtk
        self.window = Gtk.Window()
        self.window.set_title("lexipop \u2014 %s" % self.kind)
        self.window.set_default_size(EDITOR_WIDTH, EDITOR_HEIGHT)
        if application is not None:
            try:
                self.window.set_application(application)
            except Exception:
                LOGGER.debug("editor window is not managed by the application")

        # Install the editor-only CSS before the widgets are styled.
        self._install_css()

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=EDITOR_SPACING)
        root.set_margin_top(EDITOR_MARGIN)
        root.set_margin_bottom(EDITOR_MARGIN)
        root.set_margin_start(EDITOR_MARGIN)
        root.set_margin_end(EDITOR_MARGIN)

        #: Every section header, in display order (introspection aid).
        self.section_labels: list = []

        # 1 -- Front -------------------------------------------------------
        root.append(
            self._section_header("%s (%s)" % (_label(self.config, "front"), lang or "?"))
        )
        self.front_entry = Gtk.Entry()
        self.front_entry.set_hexpand(True)
        self.front_entry.set_text(text or "")
        try:
            self.front_entry.set_placeholder_text(_label(self.config, "front"))
        except Exception:
            LOGGER.debug("cannot set the front placeholder")
        self._style_input(self.front_entry)
        #: Backwards-compatible alias (the field used to be a text view).
        self.front_view = self.front_entry
        root.append(self.front_entry)

        # 2 -- Back --------------------------------------------------------
        root.append(self._section_header(_label(self.config, "back")))
        self.back_entry = Gtk.Entry()
        self.back_entry.set_hexpand(True)
        self.back_entry.set_text(self.translation)
        try:
            self.back_entry.set_placeholder_text(_label(self.config, "back"))
        except Exception:
            LOGGER.debug("cannot set the back placeholder")
        self._style_input(self.back_entry)
        self.back_view = self.back_entry
        root.append(self.back_entry)

        # 3 -- Deck --------------------------------------------------------
        root.append(self._section_header(_label(self.config, "deck")))
        self.deck_names = _known_decks(config, deck)
        self.deck_dropdown = None
        self.deck_combo = None
        self.deck_entry = None
        control = self._make_deck_control(Gtk, deck)
        deck_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        deck_row.append(control)
        self.deck_row = deck_row
        root.append(deck_row)

        # 4 -- Colours -----------------------------------------------------
        colours_header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        colours_header.append(
            self._section_header(_label(self.config, "colours"), hexpand=True)
        )
        self.reset_button = Gtk.Button(label=_label(self.config, "reset"))
        self.reset_button.connect("clicked", self._on_reset_colours)
        colours_header.append(self.reset_button)
        root.append(colours_header)
        self.colours_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        root.append(self.colours_box)
        # The hint sits right under the swatch rows and is toggled, never moved.
        self.colours_hint = Gtk.Label(xalign=0)
        self.colours_hint.set_text(_label(self.config, "coloursHint"))
        self.colours_hint.set_wrap(True)
        try:
            self.colours_hint.add_css_class("dim-label")
        except Exception:
            LOGGER.debug("cannot dim the colours hint")
        root.append(self.colours_hint)

        # 5 -- Preview -----------------------------------------------------
        root.append(self._section_header(_label(self.config, "preview")))
        self.preview_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.preview_card.set_hexpand(True)
        try:
            self.preview_card.add_css_class(EDITOR_CARD_CLASS)
        except Exception:
            LOGGER.debug("cannot style the preview card")
        preview_scrolled = Gtk.ScrolledWindow()
        preview_scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        preview_scrolled.set_min_content_height(120)
        self.preview_label = Gtk.Label(xalign=0)
        self.preview_label.set_wrap(True)
        _set_break_anywhere(self.preview_label)
        self.preview_label.set_selectable(True)
        self.preview_label.set_valign(Gtk.Align.START)
        preview_scrolled.set_child(self.preview_label)
        self.preview_card.append(preview_scrolled)
        root.append(self.preview_card)

        # 6 -- actions -----------------------------------------------------
        buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        preview_button = Gtk.Button(label=_label(self.config, "preview"))
        preview_button.connect("clicked", lambda *_: self._update_preview())
        self.ai_button = Gtk.Button(label="AI")
        self.ai_button.connect("clicked", self._on_ai)
        self.ai_button.set_sensitive(self._ai_available())
        save_button = Gtk.Button(label="Save")
        save_button.connect("clicked", self._on_save)
        buttons.append(preview_button)
        buttons.append(self.ai_button)
        buttons.append(save_button)
        root.append(buttons)

        self.status_label = Gtk.Label(xalign=0)
        self.status_label.set_wrap(True)
        root.append(self.status_label)

        self.window.set_child(root)
        self._rebuild_colour_rows()
        self._update_preview()

    # -- palette -----------------------------------------------------------
    def _read_palette(self, fallback) -> list:
        """Read ``palette`` from the config, falling back to ``fallback``."""
        values = _cfg_get(self.config, "palette", [])
        if isinstance(values, dict):
            values = list(values.values())
        colors: list = []
        if isinstance(values, (list, tuple)):
            for value in values:
                if isinstance(value, str) and value.strip():
                    colors.append(value.strip())
        if not colors:
            colors = [str(value) for value in fallback]
        return colors

    def _pair_palette_index(self, index: int) -> int:
        """Palette index chosen for pair ``index`` (defaults to ``index``)."""
        colors = self.palette or []
        if not colors:
            return 0
        try:
            choice = int(self.pair_choices.get(int(index), int(index)))
        except (TypeError, ValueError):
            choice = int(index)
        return choice % len(colors)

    def _pairs(self) -> list:
        """Aligned ``(source, target)`` pairs of the current AI result."""
        result = self.ai_result
        if result is None:
            return []
        pairs = getattr(result, "pairs", None)
        if pairs is None and isinstance(result, dict):
            pairs = result.get("pairs")
        if not pairs:
            return []
        out: list = []
        for pair in pairs:
            try:
                source, target = pair
            except (TypeError, ValueError):
                continue
            out.append((str(source), str(target)))
        return out

    def _pair_palette(self) -> list:
        """Palette list for :func:`notes.colored_html`, index = pair index."""
        from .notes import DEFAULT_PALETTE

        colors = self.palette or list(DEFAULT_PALETTE)
        return [colors[self._pair_palette_index(i)] for i in range(len(self._pairs()))]

    # -- theme colours and CSS --------------------------------------------
    def _theme_foreground(self) -> tuple:
        """Theme foreground as ``(r, g, b)`` in 0..1, with a sane fallback."""
        try:
            color = self.window.get_style_context().get_color()
            return (float(color.red), float(color.green), float(color.blue))
        except Exception:
            LOGGER.debug("cannot read the theme foreground colour", exc_info=True)
        dark = False
        try:
            settings = self.gtk.Gtk.Settings.get_default()
            theme = (
                str(settings.get_property("gtk-theme-name") or "") if settings else ""
            )
            dark = "dark" in theme.lower()
        except Exception:
            LOGGER.debug("cannot read the GTK theme name")
        return (1.0, 1.0, 1.0) if dark else (0.0, 0.0, 0.0)

    def _css_colour(self, alpha: float) -> str:
        """Low-alpha overlay of the theme foreground (see the zebra shading)."""
        red, green, blue = self._theme_foreground()
        return "rgba(%d, %d, %d, %.3f)" % (
            round(red * 255),
            round(green * 255),
            round(blue * 255),
            float(alpha),
        )

    def _accent_colour(self) -> Optional[str]:
        """Theme accent colour, or ``None`` when it cannot be looked up."""
        try:
            found, color = self.window.get_style_context().lookup_color("accent_color")
        except Exception:
            LOGGER.debug("the theme has no lookupable accent_color", exc_info=True)
            return None
        if not found:
            return None
        return "rgb(%d, %d, %d)" % (
            round(float(color.red) * 255),
            round(float(color.green) * 255),
            round(float(color.blue) * 255),
        )

    def _editor_css(self) -> str:
        """CSS for the editor inputs, the preview card and the swatches.

        Every rule is scoped to a ``lexipop-*`` class, so nothing outside the
        editor window is restyled.  The input and card backgrounds are a
        low-alpha overlay of the theme foreground, so they stay readable on
        both light and dark themes.
        """
        soft = self._css_colour(0.10)
        strong = self._css_colour(0.18)
        border = self._css_colour(0.35)
        card = self._css_colour(0.05)
        card_border = self._css_colour(0.28)
        focus = self._accent_colour() or self._css_colour(0.85)
        swatch_border = self._css_colour(0.45)
        swatch_active = self._css_colour(0.95)

        rules = [
            "/* lexipop editor only: inputs, preview card, colour swatches */",
            ".%s {" % EDITOR_INPUT_CLASS,
            "  background-color: %s;" % soft,
            "  background-image: none;",
            "  border: 1px solid %s;" % border,
            "  border-radius: 6px;",
            "  padding: 7px 8px;",
            "  min-height: 22px;",
            "}",
            ".%s:hover {" % EDITOR_INPUT_CLASS,
            "  background-color: %s;" % strong,
            "}",
            ".%s:focus, .%s:focus-within, .%s:focus > button, .%s > button:focus {"
            % (EDITOR_INPUT_CLASS, EDITOR_INPUT_CLASS, EDITOR_INPUT_CLASS, EDITOR_INPUT_CLASS),
            "  border-color: %s;" % focus,
            "}",
            "/* the widget inside a dropdown/popup control stays transparent */",
            ".%s > button {" % EDITOR_INPUT_CLASS,
            "  background-color: transparent;",
            "  background-image: none;",
            "  border: none;",
            "  box-shadow: none;",
            "  padding: 0;",
            "  margin: 0;",
            "  min-width: 0;",
            "  min-height: 0;",
            "}",
            ".%s {" % EDITOR_CARD_CLASS,
            "  background-color: %s;" % card,
            "  background-image: none;",
            "  border: 1px solid %s;" % card_border,
            "  border-radius: 8px;",
            "  padding: 8px;",
            "}",
            ".%s {" % EDITOR_SWATCH_CLASS,
            "  min-width: 16px;",
            "  min-height: 16px;",
            "  padding: 0;",
            "  margin: 0;",
            "  background-image: none;",
            "  border: 1px solid %s;" % swatch_border,
            "  border-radius: 3px;",
            "}",
            ".%s {" % EDITOR_SWATCH_ACTIVE_CLASS,
            "  border: 2px solid %s;" % swatch_active,
            "}",
        ]
        for position, colour in enumerate(self.palette):
            rules.append(
                ".%s-%d { background-color: %s; }"
                % (EDITOR_SWATCH_CLASS, position, colour)
            )
        return "\n".join(rules)

    def _install_css(self) -> None:
        """Register the editor CssProvider for the display (mirrors the popup)."""
        if self._css_provider is not None:
            return
        Gtk = self.gtk.Gtk
        Gdk = self.gtk.Gdk
        provider = Gtk.CssProvider()
        css = self._editor_css()
        try:
            provider.load_from_data(css.encode("utf-8"))
        except TypeError:  # older PyGObject wants a str
            try:
                provider.load_from_data(css)
            except Exception:
                LOGGER.debug("cannot load the editor CSS", exc_info=True)
                return
        except Exception:
            LOGGER.debug("cannot load the editor CSS", exc_info=True)
            return
        self._css_provider = provider
        self.css_text = css
        display = None
        try:
            display = Gdk.Display.get_default()
        except Exception:
            display = None
        if display is None:
            LOGGER.warning("no display: the editor CSS is not registered")
            return
        try:
            Gtk.StyleContext.add_provider_for_display(
                display, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )
            self._css_display = display
        except Exception:
            LOGGER.debug("cannot add the editor CSS provider", exc_info=True)

    def _style_input(self, widget) -> None:
        """Mark one editor input with the shared input CSS class."""
        try:
            widget.add_css_class(EDITOR_INPUT_CLASS)
        except Exception:
            LOGGER.debug("cannot style an editor input", exc_info=True)

    def _section_header(self, text: str, hexpand: bool = False):
        """Small bold, dimmed section header label."""
        Gtk = self.gtk.Gtk
        label = Gtk.Label(xalign=0)
        try:
            label.set_markup("<b>%s</b>" % self.gtk.GLib.markup_escape_text(text))
        except Exception:
            label.set_text(text)
        try:
            label.add_css_class("dim-label")
        except Exception:
            LOGGER.debug("cannot dim a section header")
        if hexpand:
            try:
                label.set_hexpand(True)
            except Exception:
                LOGGER.debug("cannot expand a section header")
        self.section_labels.append((text, label))
        return label

    # -- deck control ------------------------------------------------------
    def _make_deck_control(self, Gtk, deck):
        """Build the single full-width deck control (DropDown, else a combo)."""
        names = list(self.deck_names) or [""]
        dropdown = None
        if hasattr(Gtk, "DropDown"):
            try:
                dropdown = Gtk.DropDown.new_from_strings(names)
            except Exception:
                LOGGER.debug("cannot build a Gtk.DropDown for the deck", exc_info=True)
                dropdown = None
        if dropdown is not None:
            dropdown.set_hexpand(True)
            index = 0
            if deck and str(deck) in names:
                index = names.index(str(deck))
            try:
                dropdown.set_selected(index)
            except Exception:
                LOGGER.debug("cannot preselect the deck")
            dropdown.connect("notify::selected", self._on_deck_changed)
            self.deck_dropdown = dropdown
            self._style_input(dropdown)
            return dropdown
        combo = Gtk.ComboBoxText()
        combo.set_hexpand(True)
        for name in names:
            combo.append_text(name)
        if deck:
            try:
                combo.set_active_id(str(deck))
            except Exception:
                combo.set_active(0)
        combo.connect("changed", self._on_deck_changed)
        self.deck_combo = combo
        self._style_input(combo)
        return combo

    def _selected_deck(self) -> str:
        """Deck currently selected in the control."""
        if self.deck_dropdown is not None:
            try:
                index = int(self.deck_dropdown.get_selected())
            except Exception:
                return self.deck or ""
            if 0 <= index < len(self.deck_names):
                return str(self.deck_names[index])
            return self.deck or ""
        if self.deck_combo is not None:
            active = self.deck_combo.get_active_text()
            if active:
                return str(active)
        return self.deck or ""

    # -- text helpers ------------------------------------------------------
    @staticmethod
    def _input_text(widget) -> str:
        """Text of an ``Gtk.Entry`` (or of a legacy ``Gtk.TextView``)."""
        if widget is None:
            return ""
        getter = getattr(widget, "get_text", None)
        if callable(getter):
            try:
                return getter() or ""
            except Exception:
                LOGGER.debug("cannot read the input text")
        getter = getattr(widget, "get_buffer", None)
        if callable(getter):
            try:
                return _view_text(widget)
            except Exception:
                LOGGER.debug("cannot read the input buffer")
        return ""

    @staticmethod
    def _set_input_text(widget, text: str) -> None:
        if widget is None:
            return
        setter = getattr(widget, "set_text", None)
        if callable(setter):
            try:
                setter(text or "")
                return
            except Exception:
                LOGGER.debug("cannot set the input text")
        try:
            _set_view_text(widget, text)
        except Exception:
            LOGGER.debug("cannot set the input buffer")

    # -- helpers -----------------------------------------------------------
    def connect_destroy(self, callback) -> None:
        self.window.connect("destroy", callback)

    def present(self) -> None:
        self.window.present()

    def _ai_available(self) -> bool:
        try:
            from . import ai

            return bool(ai.available(self.config))
        except Exception:
            return False

    def _set_status(self, message: Optional[str]) -> None:
        self.status_label.set_text(message or "")

    def _on_deck_changed(self, combo, *_args) -> None:
        deck = self._selected_deck()
        if deck:
            self.deck = deck

    def _html_for(self, text: str, side: str) -> str:
        from .classify import text_to_html

        result = self.ai_result
        if result is not None:
            if side == "front" and text == self.text:
                return getattr(result, "front_html", None) or text_to_html(text)
            if side == "back" and text == self.translation:
                return getattr(result, "back_html", None) or text_to_html(text)
        return text_to_html(text)

    def _render(self) -> tuple:
        """``(front_html, back_html)`` coloured with the chosen pair colours."""
        front_text = self._input_text(self.front_entry)
        back_text = self._input_text(self.back_entry)
        pairs = self._pairs()
        if pairs:
            from .notes import colored_html, pair_ranges

            source_ranges, target_ranges = pair_ranges(front_text, back_text, pairs)
            palette = self._pair_palette()
            return (
                colored_html(front_text, source_ranges, palette),
                colored_html(back_text, target_ranges, palette),
            )
        return self._html_for(front_text, "front"), self._html_for(back_text, "back")

    def _update_preview(self, *_args) -> None:
        front, back = self._render()
        html = front + "<br>" + back
        try:
            self.preview_label.set_markup(_html_to_pango(html))
        except Exception:
            LOGGER.debug("preview markup failed, showing the raw HTML")
            self.preview_label.set_text(html)
        self._set_status(None)

    # -- colours -----------------------------------------------------------
    def _rebuild_colour_rows(self) -> None:
        """Rebuild one swatch row per aligned pair (hidden without pairs)."""
        from .notes import DEFAULT_PALETTE

        box = self.colours_box
        while True:
            child = box.get_first_child()
            if child is None:
                break
            box.remove(child)
        self.swatch_rows = []
        pairs = self._pairs()
        has_pairs = bool(pairs)
        try:
            self.reset_button.set_visible(has_pairs)
        except Exception:
            LOGGER.debug("cannot toggle the reset button")
        try:
            self.colours_hint.set_visible(not has_pairs)
        except Exception:
            LOGGER.debug("cannot toggle the colours hint")
        if not has_pairs:
            return
        colors = self.palette or list(DEFAULT_PALETTE)
        Gtk = self.gtk.Gtk
        for index, (source, target) in enumerate(pairs):
            active = self._pair_palette_index(index)
            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            swatches = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
            buttons: list = []
            for position in range(len(colors)):
                button = Gtk.Button()
                try:
                    button.set_size_request(18, 18)
                except Exception:
                    LOGGER.debug("cannot size a swatch button")
                try:
                    button.set_tooltip_text(str(colors[position]))
                except Exception:
                    LOGGER.debug("cannot set a swatch tooltip")
                for css_class in (
                    EDITOR_SWATCH_CLASS,
                    "%s-%d" % (EDITOR_SWATCH_CLASS, position),
                ) + ((EDITOR_SWATCH_ACTIVE_CLASS,) if position == active else ()):
                    try:
                        button.add_css_class(css_class)
                    except Exception:
                        LOGGER.debug("cannot style a swatch button")
                button.connect(
                    "clicked",
                    lambda _button, i=index, p=position: self._on_swatch(i, p),
                )
                swatches.append(button)
                buttons.append(button)
            row.append(swatches)
            label = Gtk.Label(xalign=0)
            label.set_text("%s  %s  %s" % (source, PAIR_ARROW, target))
            try:
                from gi.repository import Pango

                label.set_ellipsize(Pango.EllipsizeMode.END)
                label.set_max_width_chars(30)
            except Exception:
                LOGGER.debug("cannot ellipsize a pair label")
            row.append(label)
            box.append(row)
            self.swatch_rows.append(
                {
                    "index": index,
                    "source": source,
                    "target": target,
                    "active": active,
                    "active_colour": colors[active],
                    "buttons": buttons,
                }
            )

    def _on_swatch(self, index: int, palette_index: int) -> None:
        """Assign one palette colour to one pair index."""
        try:
            self.pair_choices[int(index)] = int(palette_index)
        except (TypeError, ValueError):
            return
        self._rebuild_colour_rows()
        self._update_preview()

    def _on_reset_colours(self, *_args) -> None:
        """Restore the palette order (pair index -> palette index)."""
        self.pair_choices.clear()
        self._rebuild_colour_rows()
        self._update_preview()

    # -- actions -----------------------------------------------------------
    def _on_ai(self, *_args) -> None:
        from . import ai

        if not ai.available(self.config):
            self._set_status("AI disabled: enable ai and set ai.apiKeyFile")
            return
        self._set_status("AI translation\u2026")
        self.ai_button.set_sensitive(False)
        target = self.target
        thread = threading.Thread(
            target=self._ai_worker,
            args=(target,),
            name="lexipop-editor-ai",
            daemon=True,
        )
        thread.start()

    def _ai_worker(self, target: str) -> None:
        from . import ai

        result = None
        error = None
        try:
            result = ai.ai_translate(
                self.config,
                self._input_text(self.front_entry) or self.text,
                target=target,
                source=self.lang,
            )
        except Exception as exc:
            error = str(exc) or exc.__class__.__name__
            LOGGER.warning("AI translation failed: %s", error)
        self.gtk.GLib.idle_add(self._finish_ai, result, error)

    def _finish_ai(self, result, error: Optional[str]) -> bool:
        self.ai_button.set_sensitive(True)
        if error is not None:
            self._set_status("AI failed: %s" % error)
            return False
        self.ai_result = result
        # A new AI result resets the pair choices to the palette order.
        self.pair_choices = {}
        translation = getattr(result, "translation", None)
        if translation:
            self.translation = translation
            self._set_input_text(self.back_entry, translation)
        self._rebuild_colour_rows()
        self._update_preview()
        self._set_status("AI translation ready (coloured)")
        return False

    def _on_save(self, *_args) -> None:
        from .anki import AnkiClient
        from .notes import build_note_request

        front_text = self._input_text(self.front_entry)
        back_text = self._input_text(self.back_entry)
        deck = self._selected_deck().strip()
        if not front_text.strip():
            self._set_status("Front is empty")
            return
        if not deck:
            self._set_status("Deck is empty")
            return
        # The colours chosen in the Colours section are what gets saved.
        front_html, back_html = self._render()
        self._set_status("saving\u2026")
        config = self.config

        def worker() -> None:
            try:
                client = AnkiClient(str(_cfg_get(config, "ankiConnectUrl", "") or ""))
                request = build_note_request(config, deck, front_html, back_html)
                note_id = client.add_note(
                    request["deckName"],
                    request["modelName"],
                    request["fields"],
                    request.get("tags"),
                )
            except Exception as exc:
                message = str(exc) or exc.__class__.__name__
                LOGGER.warning("could not add the note: %s", message)
                self.gtk.GLib.idle_add(self._save_failed, message)
            else:
                self.gtk.GLib.idle_add(self._save_done, note_id)

        threading.Thread(target=worker, name="lexipop-editor-save", daemon=True).start()

    def _save_failed(self, message: str) -> bool:
        self._set_status("AnkiConnect: %s" % message)
        return False

    def _save_done(self, note_id) -> bool:
        self._set_status("saved (note %s)" % note_id)
        if callable(self.on_saved):
            try:
                self.on_saved(note_id)
            except Exception:
                LOGGER.exception("saved callback failed")
        self.gtk.GLib.timeout_add(800, self._close)
        return False

    def _close(self) -> bool:
        try:
            self.window.close()
        except Exception:
            LOGGER.debug("could not close the editor window")
        return False


# entry points
# --------------------------------------------------------------------------
def _install_signal_handlers(gtk: _Gtk, app) -> None:
    def quit_app(*_args) -> bool:
        try:
            app.quit()
        except Exception:
            LOGGER.exception("could not quit the application")
        return True

    for signum in (signal.SIGINT, signal.SIGTERM):
        try:
            gtk.GLib.unix_signal_add(gtk.GLib.PRIORITY_DEFAULT, int(signum), quit_app)
        except Exception:
            LOGGER.debug("signal handler for %s unavailable", signum)


# --------------------------------------------------------------------------
# daemon singleton (exclusive flock)
# --------------------------------------------------------------------------
#: Sentinel returned by :func:`_acquire_daemon_lock` when the lock is held.
LOCK_HELD = object()


def _daemon_lock_path() -> str:
    """Lock file for the daemon singleton: XDG runtime dir, else cache dir."""
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if runtime:
        return os.path.join(runtime, "lexipop", "daemon.lock")
    cache = os.environ.get("XDG_CACHE_HOME") or os.path.join(
        os.path.expanduser("~"), ".cache"
    )
    return os.path.join(cache, "lexipop", "daemon.lock")


def _acquire_daemon_lock() -> tuple[Any, str]:
    """Take an exclusive ``flock`` on the daemon lock file.

    Returns ``(fd, path)`` where *fd* is an open file descriptor, ``None`` when
    locking is unavailable (flock missing, directory not writable: fail open) or
    :data:`LOCK_HELD` when another daemon already owns the lock.  The lock FILE
    is never removed: ``flock`` owns it.
    """
    path = _daemon_lock_path()
    if fcntl is None:
        LOGGER.warning("fcntl is unavailable, running without a daemon singleton")
        return None, path
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        fd = os.open(path, os.O_RDWR | os.O_CREAT | os.O_CLOEXEC, 0o600)
    except OSError as exc:
        LOGGER.warning("cannot open the daemon lock %s: %s", path, exc)
        return None, path
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        try:
            os.close(fd)
        except OSError:
            pass
        return LOCK_HELD, path
    try:
        os.ftruncate(fd, 0)
        os.write(fd, ("%d\n" % os.getpid()).encode("utf-8"))
    except OSError:
        LOGGER.debug("could not write the daemon lock owner", exc_info=True)
    LOGGER.debug("daemon lock acquired: %s", path)
    return fd, path


def _release_daemon_lock(fd: Any, path: str) -> None:
    """Release the daemon lock and close its descriptor on every exit path."""
    if fd is None or fd is LOCK_HELD:
        return
    if fcntl is not None:
        try:
            fcntl.flock(fd, fcntl.LOCK_UN)
        except OSError:
            LOGGER.debug("could not unlock %s", path, exc_info=True)
    try:
        os.close(fd)
    except OSError:
        LOGGER.debug("could not close the daemon lock descriptor")


def run_daemon(config: Any) -> int:
    """Run the GTK4 daemon, but only one at a time (exclusive flock)."""
    lock_fd, lock_path = _acquire_daemon_lock()
    if lock_fd is LOCK_HELD:
        LOGGER.info("another lexipop daemon is already running")
        return 0
    try:
        return _run_daemon_locked(config)
    finally:
        _release_daemon_lock(lock_fd, lock_path)


def _run_daemon_locked(config: Any) -> int:
    """Daemon body; the singleton lock is held for the whole call."""
    if not _display_available():
        LOGGER.error("no Wayland/X display available, cannot start the daemon")
        return 1
    try:
        gtk = _load_gtk()
    except Exception as exc:
        LOGGER.error("cannot load GTK4: %s", exc)
        return 1

    controller = _DaemonController(gtk, config)
    try:
        app = gtk.Gtk.Application(
            application_id=DAEMON_APP_ID, flags=gtk.Gio.ApplicationFlags.NON_UNIQUE
        )
    except Exception:
        LOGGER.exception("cannot create the GTK application")
        return 1

    def on_activate(*_args) -> None:
        LOGGER.debug("lexipop daemon activated")
        if controller.watcher is not None:
            controller.watcher.start()

    def on_shutdown(*_args) -> None:
        controller.shutdown()

    app.connect("activate", on_activate)
    app.connect("shutdown", on_shutdown)
    app.hold()  # the daemon lives without a visible window
    _install_signal_handlers(gtk, app)
    try:
        controller.attach(app)
        LOGGER.info("lexipop daemon running")
        status = app.run([])
    except Exception:
        LOGGER.exception("the GTK main loop failed")
        status = 1
    finally:
        controller.shutdown()
    return int(status or 0)


def run_editor(
    config: Any,
    *,
    text: str,
    lang: Optional[str] = None,
    kind: Optional[str] = None,
    deck: Optional[str] = None,
) -> int:
    """Open the mini editor once, for the given selection."""
    text = (text or "").strip()
    if not text:
        LOGGER.error("editor needs a non-empty --text")
        return 2
    if not _display_available():
        LOGGER.error("no Wayland/X display available, cannot open the editor")
        return 1
    try:
        gtk = _load_gtk()
    except Exception as exc:
        LOGGER.error("cannot load GTK4: %s", exc)
        return 1

    holder: dict = {}
    try:
        app = gtk.Gtk.Application(
            application_id=EDITOR_APP_ID, flags=gtk.Gio.ApplicationFlags.NON_UNIQUE
        )
    except Exception:
        LOGGER.exception("cannot create the GTK application")
        return 1

    def on_activate(*_args) -> None:
        if holder.get("window") is not None:
            holder["window"].present()
            return
        editor = _EditorWindow(
            gtk, config, text=text, lang=lang, kind=kind, deck=deck, application=app
        )
        holder["window"] = editor
        editor.present()

    app.connect("activate", on_activate)
    try:
        status = app.run([])
    except Exception:
        LOGGER.exception("the GTK main loop failed")
        return 1
    return int(status or 0)
