"""Screen capture and OCR for lexipop (the ``lexipop ocr`` command).

This module is deliberately self-contained: it only uses the standard library
and never imports another lexipop module, so it can be imported by the CLI, the
daemon and by tests without pulling in GTK.

Pipeline::

    slurp (region)  ->  grim -g <geometry> -   ->  tesseract stdin stdout
    grim -          ->  tesseract stdin stdout           (--full)
    raw text        ->  normalise_text(...)               (cleanup)

The screenshot never touches a fixed path in ``$HOME``: it travels through an
in-memory pipe from ``grim``'s stdout straight into ``tesseract``'s stdin.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import socket
import subprocess
from typing import Any, Iterable, Optional

__all__ = [
    "OcrError",
    "capture_region",
    "capture_full",
    "run_tesseract",
    "normalise_text",
    "ocr_from_region",
    "ocr_options",
    "control_socket_path",
    "deliver_to_daemon",
]

#: Characters that end a sentence; a line ending with one is never joined to
#: the following line.
_SENTENCE_END = (".", "!", "?", ":", ";")

#: Runs of horizontal whitespace inside one line are collapsed to one space.
_SPACE_RE = re.compile(r"[ \t\f\v]+")

#: Default control-socket name, shared with ``app.py``.
CONTROL_SOCKET_NAME = "control.sock"


class OcrError(RuntimeError):
    """Raised when a tool is missing, a capture fails or tesseract errors."""


# --------------------------------------------------------------------------
# binary resolution / subprocess plumbing
# --------------------------------------------------------------------------
def _resolve(binary: str) -> str:
    """Return the absolute path of *binary* or raise :class:`OcrError`."""
    path = shutil.which(binary)
    if not path:
        raise OcrError(
            "cannot find %r: install it or add it to PATH" % binary
        )
    return path


def _run(cmd: list[str], *, timeout: float, stdin: Optional[bytes] = None) -> subprocess.CompletedProcess:
    """Run *cmd* with a timeout, turning tool failures into :class:`OcrError`."""
    try:
        proc = subprocess.run(
            cmd,
            input=stdin if stdin is not None else b"",
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raise OcrError("%s timed out after %.1fs" % (cmd[0], timeout)) from exc
    except OSError as exc:
        raise OcrError("cannot run %s: %s" % (cmd[0], exc)) from exc
    return proc


def _stderr_text(proc: subprocess.CompletedProcess) -> str:
    try:
        return (proc.stderr or b"").decode("utf-8", "replace").strip()
    except Exception:  # pragma: no cover - defensive
        return ""


# --------------------------------------------------------------------------
# capture
# --------------------------------------------------------------------------
def capture_region(
    *,
    slurp_bin: str = "slurp",
    grim_bin: str = "grim",
    timeout: float = 60.0,
) -> Optional[bytes]:
    """Let the user drag a region and return the PNG bytes.

    Returns ``None`` when the user cancels (slurp exits non-zero, or prints an
    empty/whitespace geometry).  Raises :class:`OcrError` for a missing tool or
    a grim failure.
    """
    slurp = _resolve(slurp_bin)
    grim = _resolve(grim_bin)

    slurp_proc = _run([slurp], timeout=timeout)
    geometry = (slurp_proc.stdout or b"").decode("utf-8", "replace").strip()
    if slurp_proc.returncode != 0 or not geometry:
        # Escape / right-click cancels the slurp selection: not an error.
        return None

    grim_proc = _run([grim, "-g", geometry, "-"], timeout=timeout)
    if grim_proc.returncode != 0:
        detail = _stderr_text(grim_proc) or "exit code %d" % grim_proc.returncode
        raise OcrError("grim failed: %s" % detail)
    if not grim_proc.stdout:
        raise OcrError("grim returned an empty screenshot")
    return grim_proc.stdout


def capture_full(*, grim_bin: str = "grim", timeout: float = 30.0) -> bytes:
    """Capture the whole screen and return the PNG bytes."""
    grim = _resolve(grim_bin)
    grim_proc = _run([grim, "-"], timeout=timeout)
    if grim_proc.returncode != 0:
        detail = _stderr_text(grim_proc) or "exit code %d" % grim_proc.returncode
        raise OcrError("grim failed: %s" % detail)
    if not grim_proc.stdout:
        raise OcrError("grim returned an empty screenshot")
    return grim_proc.stdout


# --------------------------------------------------------------------------
# OCR
# --------------------------------------------------------------------------
def run_tesseract(
    png: bytes,
    *,
    languages: Iterable[str] = ("eng",),
    psm: int = 6,
    tesseract_bin: str = "tesseract",
    timeout: float = 60.0,
) -> str:
    """OCR the PNG bytes and return tesseract's stdout.

    ``tesseract stdin stdout`` reads the image from stdin, so nothing is
    written to disk.
    """
    tesseract = _resolve(tesseract_bin)
    if isinstance(languages, str):
        langs = languages.strip()
    else:
        langs = "+".join(str(item).strip() for item in languages if str(item).strip())
    if not langs:
        langs = "eng"
    try:
        psm_value = int(psm)
    except (TypeError, ValueError) as exc:
        raise OcrError("invalid psm value: %r" % (psm,)) from exc

    cmd = [tesseract, "stdin", "stdout", "-l", langs, "--psm", str(psm_value)]
    proc = _run(cmd, timeout=timeout, stdin=png or b"")
    if proc.returncode != 0:
        detail = _stderr_text(proc) or "exit code %d" % proc.returncode
        raise OcrError("tesseract failed: %s" % detail)
    return (proc.stdout or b"").decode("utf-8", "replace")


# --------------------------------------------------------------------------
# text cleanup
# --------------------------------------------------------------------------
def normalise_text(text: str, *, join_lines: bool = True) -> str:
    """Clean up OCR output.

    * leading/trailing whitespace is stripped and runs of spaces collapse;
    * with ``join_lines`` a line is joined to the next one when it does not end
      with sentence-final punctuation and the next line starts lowercase;
    * blank lines are paragraph breaks, collapsed to at most one blank line;
    * without ``join_lines`` the lines are kept but empty ones are dropped.

    The result never ends with a space.
    """
    if not text:
        return ""

    raw_lines = str(text).replace("\r\n", "\n").replace("\r", "\n").split("\n")
    lines = [_SPACE_RE.sub(" ", line).strip() for line in raw_lines]

    if not join_lines:
        return "\n".join(line for line in lines if line).strip()

    out: list[str] = []
    for line in lines:
        if not line:
            # Paragraph break: one blank line at most.
            if out and out[-1] != "":
                out.append("")
            continue
        if out and out[-1] != "":
            previous = out[-1]
            if not previous.endswith(_SENTENCE_END) and line[:1].islower():
                out[-1] = previous + " " + line
                continue
        out.append(line)

    while out and out[-1] == "":
        out.pop()
    return "\n".join(out).strip()


# --------------------------------------------------------------------------
# configuration (read defensively: worker A adds the keys in parallel)
# --------------------------------------------------------------------------
def _config_node(config: Any, key: str, default: Any) -> Any:
    """Read ``config[key]`` from a Config, a Config-like object or a dict."""
    if config is None:
        return default
    getter = getattr(config, "get", None)
    if callable(getter):
        try:
            value = getter(key, default)
        except Exception:
            return default
    elif isinstance(config, dict):
        value = config.get(key, default)
    else:
        return default
    if value is None:
        return default
    return value


def _plain_dict(value: Any) -> dict:
    """Best-effort conversion of a config node to a plain dict."""
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


def ocr_options(config: Any) -> tuple[tuple[str, ...], int, bool]:
    """Return ``(languages, psm, join_lines)`` with the spec defaults."""
    section = _plain_dict(_config_node(config, "ocr", {}))

    raw_languages = section.get("languages", ["eng"])
    if isinstance(raw_languages, str):
        raw_languages = [raw_languages]
    if isinstance(raw_languages, (list, tuple)):
        languages = tuple(
            str(item).strip() for item in raw_languages if str(item).strip()
        )
    else:
        languages = ()
    if not languages:
        languages = ("eng",)

    try:
        psm = int(section.get("psm", 6))
    except (TypeError, ValueError):
        psm = 6

    join_raw = section.get("joinLines", True)
    join_lines = True if join_raw is None else bool(join_raw)

    return languages, psm, join_lines


# --------------------------------------------------------------------------
# end-to-end
# --------------------------------------------------------------------------
def ocr_from_region(config: Any, *, full: bool = False) -> Optional[str]:
    """Capture (region or full screen), OCR and normalise.

    Returns the recognised text, or ``None`` when the user cancelled the region
    selection.
    """
    languages, psm, join_lines = ocr_options(config)
    if full:
        png = capture_full()
    else:
        png = capture_region()
        if png is None:
            return None
    text = run_tesseract(png, languages=languages, psm=psm)
    return normalise_text(text, join_lines=join_lines)


# --------------------------------------------------------------------------
# daemon control socket (client side)
# --------------------------------------------------------------------------
def control_socket_path() -> str:
    """Path of the daemon control socket.

    ``$XDG_RUNTIME_DIR/lexipop/control.sock``, falling back to
    ``${XDG_CACHE_HOME:-~/.cache}/lexipop/control.sock``.
    """
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if runtime:
        base = os.path.join(runtime, "lexipop")
    else:
        cache = os.environ.get("XDG_CACHE_HOME") or os.path.join(
            os.path.expanduser("~"), ".cache"
        )
        base = os.path.join(cache, "lexipop")
    return os.path.join(base, CONTROL_SOCKET_NAME)


def deliver_to_daemon(
    text: str,
    *,
    source: str = "ocr",
    timeout: float = 5.0,
    path: Optional[str] = None,
) -> bool:
    """Send *text* to the running daemon.

    Returns ``True`` when a daemon answered ``{"ok": true, ...}``; ``False`` on
    any connection, timeout or protocol problem so the caller can fall back to
    the editor window.
    """
    target = path or control_socket_path()
    request = json.dumps({"text": str(text), "source": str(source)}).encode("utf-8") + b"\n"
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.settimeout(timeout)
            client.connect(target)
            client.sendall(request)
            data = b""
            while b"\n" not in data and len(data) < 1_000_000:
                chunk = client.recv(65536)
                if not chunk:
                    break
                data += chunk
    except OSError:
        return False

    line = data.split(b"\n", 1)[0]
    try:
        reply = json.loads(line.decode("utf-8", "replace"))
    except ValueError:
        return False
    return bool(isinstance(reply, dict) and reply.get("ok"))
