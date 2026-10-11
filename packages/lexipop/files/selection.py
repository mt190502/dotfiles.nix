"""Primary-selection watcher for lexipop.

The watcher follows the Wayland primary selection through the child process
``wl-paste --watch --primary``.  Every new, non-empty selection is passed to a
callback.  Repeated text is never emitted twice, events are ignored while the
watcher is suppressed (loop protection while a lexipop window has focus) and a
dead child process is restarted.
"""

from __future__ import annotations

import logging
import os
import select
import shutil
import subprocess
import threading
import time
from typing import Callable, Optional

LOGGER = logging.getLogger(__name__)

#: How often a dead ``wl-paste`` child is restarted before giving up.
MAX_RESTARTS = 5

#: Granularity used while draining a paste that arrives in several chunks.
DRAIN_CHUNK = 65536

#: ``wl-clipboard`` >= 2.2 needs a command after ``--watch``.  The command gets
#: the new selection on stdin, so ``cat`` forwards it on stdout; ``echo`` adds a
#: newline boundary, which is the only way to see a cleared selection (there the
#: command runs with empty input and ``cat`` alone would write nothing at all).
WATCH_COMMAND = "cat; echo"


def _clean(text: str) -> str:
    """Normalise newlines and drop surrounding whitespace."""
    if not text:
        return ""
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    return text.strip()


def _resolve(binary: str) -> Optional[str]:
    """Return an absolute path for *binary*, or None when it cannot be run."""
    if not binary:
        return None
    if os.sep in binary:
        return binary if os.access(binary, os.X_OK) else None
    return shutil.which(binary)


def read_primary(wl_paste_bin: str = "wl-paste") -> Optional[str]:
    """Return the current primary selection, or None when empty/unavailable."""
    binary = _resolve(wl_paste_bin)
    if binary is None:
        LOGGER.debug("wl-paste binary %r not found", wl_paste_bin)
        return None
    for args in (["--primary", "--no-newline"], ["--primary"]):
        try:
            proc = subprocess.run(
                [binary, *args], capture_output=True, timeout=5.0, check=False
            )
        except (OSError, subprocess.SubprocessError) as exc:
            LOGGER.debug("wl-paste failed: %s", exc)
            return None
        if proc.returncode == 0:
            return _clean(proc.stdout.decode("utf-8", "replace")) or None
    return None


class SelectionWatcher:
    """Watch the primary selection and report new texts to ``on_selection``.

    ``on_clear`` (optional) is called when a watch event carries empty or
    whitespace-only text, so the caller can close a popup that is no longer
    wanted.  It is not called for the report wl-paste makes at start-up.

    ``interval`` is used as a debounce window: bytes that arrive within that
    window are joined, so a multi-line selection becomes one event.

    ``settle_ms`` is a second, longer debounce in milliseconds: a selection is
    reported only after the text stayed UNCHANGED for that long, so a selection
    that some applications update on every keystroke does not pop up the window
    while the user is still typing.  A newer text cancels the pending report.
    ``0`` disables the settle window (the old immediate behaviour).
    """

    def __init__(
        self,
        on_selection: Callable[[str], None],
        *,
        wl_paste_bin: str = "wl-paste",
        interval: float = 0.15,
        min_length: int = 1,
        initial: bool = False,
        on_clear: Optional[Callable[[], None]] = None,
        settle_ms: float = 0.0,
    ) -> None:
        self.on_selection = on_selection
        self.on_clear = on_clear
        self.wl_paste_bin = wl_paste_bin
        self.interval = max(0.0, float(interval))
        self.min_length = max(0, int(min_length))
        self.initial = bool(initial)
        #: Settle (typing) debounce in seconds; 0 disables it.
        try:
            self.settle_seconds = max(0.0, float(settle_ms or 0.0) / 1000.0)
        except (TypeError, ValueError):
            self.settle_seconds = 0.0

        self._lock = threading.Lock()
        self._stop = threading.Event()
        self._proc: Optional[subprocess.Popen[bytes]] = None
        self._thread: Optional[threading.Thread] = None
        self._last: Optional[str] = None
        self._suppress_until = 0.0
        self._startup_pending = False
        #: Text waiting for the settle window and the timer that will report it.
        self._pending: Optional[str] = None
        self._settle_timer: Optional[threading.Timer] = None

    # -- lifecycle ---------------------------------------------------------
    def start(self) -> None:
        """Spawn ``wl-paste --primary --watch sh -c 'cat; echo'`` and the reader."""
        with self._lock:
            if self._thread is not None and self._thread.is_alive():
                return
            self._stop.clear()
            # wl-paste runs its watch command once at start-up with the current
            # selection.  Unless ``initial`` is set, seed the duplicate check
            # with that text so the start-up report stays silent.
            self._last = None if self.initial else read_primary(self.wl_paste_bin)
            if not self._spawn():
                return
            self._thread = threading.Thread(
                target=self._run, name="lexipop-selection", daemon=True
            )
            self._thread.start()
        if self.initial:
            threading.Thread(
                target=self._emit_initial, name="lexipop-selection-initial", daemon=True
            ).start()

    def stop(self) -> None:
        """Stop the reader thread and terminate the child process."""
        self._stop.set()
        self._cancel_settle()
        proc = self._proc
        if proc is not None and proc.poll() is None:
            try:
                proc.terminate()
            except OSError:
                pass
            try:
                proc.wait(timeout=2.0)
            except subprocess.TimeoutExpired:
                try:
                    proc.kill()
                    proc.wait(timeout=2.0)
                except (OSError, subprocess.TimeoutExpired):
                    LOGGER.debug("could not kill the wl-paste child")
        if proc is not None and proc.stdout is not None:
            try:
                proc.stdout.close()
            except OSError:
                pass
        with self._lock:
            thread = self._thread
        if thread is not None and thread.is_alive():
            thread.join(timeout=2.0)
        with self._lock:
            self._proc = None
            self._thread = None

    @property
    def running(self) -> bool:
        """True while the reader thread is alive.

        The thread owns the ``wl-paste`` child and restarts it when it dies, so
        a short gap between two child processes still counts as running.
        """
        with self._lock:
            thread = self._thread
        return bool(thread is not None and thread.is_alive())

    # -- loop protection ---------------------------------------------------
    def suppress(self, seconds: float = 1.0) -> None:
        """Ignore selection events for *seconds* (windows of lexipop focused)."""
        deadline = time.monotonic() + max(0.0, float(seconds))
        with self._lock:
            self._suppress_until = max(self._suppress_until, deadline)

    def reset(self) -> None:
        """Forget the last text so the same selection can be emitted again."""
        with self._lock:
            self._last = None

    # -- internals ---------------------------------------------------------
    def _spawn(self) -> bool:
        shell = shutil.which("sh")
        if shell is None and os.path.exists("/bin/sh"):
            shell = "/bin/sh"
        if shell is None:
            LOGGER.error("no POSIX shell available for the wl-paste --watch command")
            return False
        try:
            self._proc = subprocess.Popen(
                [self.wl_paste_bin, "--primary", "--watch", shell, "-c", WATCH_COMMAND],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.DEVNULL,
            )
        except OSError as exc:
            LOGGER.error(
                "cannot start the %s --primary --watch watcher (%s): %s",
                self.wl_paste_bin,
                WATCH_COMMAND,
                exc,
            )
            self._proc = None
            return False
        # wl-paste runs its watch command once at start-up; that report is not
        # a real "selection was cleared" event.
        self._startup_pending = True
        LOGGER.info(
            "watching the primary selection with %s (watch command: %s)",
            self.wl_paste_bin,
            WATCH_COMMAND,
        )
        return True

    def _restart(self, restarts: int) -> bool:
        if restarts >= MAX_RESTARTS:
            LOGGER.error("wl-paste --watch died %d times, giving up", restarts)
            return False
        if self._stop.wait(max(self.interval, 0.2)):
            return False
        LOGGER.warning("wl-paste --watch died, restarting (attempt %d)", restarts + 1)
        return self._spawn()

    def _emit_initial(self) -> None:
        text = read_primary(self.wl_paste_bin)
        if text:
            self._dispatch(text)

    def _run(self) -> None:
        restarts = 0
        while not self._stop.is_set():
            proc = self._proc
            if proc is None or proc.stdout is None:
                break
            fd = proc.stdout.fileno()
            try:
                chunk = os.read(fd, DRAIN_CHUNK)
            except (OSError, ValueError):
                chunk = b""
            if not chunk:
                if self._stop.is_set():
                    break
                if not self._restart(restarts):
                    break
                restarts += 1
                continue
            restarts = 0
            data = chunk
            deadline = time.monotonic() + self.interval
            while not self._stop.is_set():
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    break
                try:
                    ready, _, _ = select.select([fd], [], [], remaining)
                except (OSError, ValueError):
                    break
                if not ready:
                    break
                try:
                    more = os.read(fd, DRAIN_CHUNK)
                except (OSError, ValueError):
                    break
                if not more:
                    break
                data += more
            self._dispatch(data.decode("utf-8", "replace"))
        LOGGER.debug("selection watcher thread finished")

    def _emit_clear(self) -> None:
        """Report that the primary selection became empty."""
        callback = self.on_clear
        with self._lock:
            self._last = None
        if callback is None:
            return
        try:
            callback()
        except Exception:  # never kill the reader thread
            LOGGER.exception("clear callback failed")

    def _dispatch(self, raw: str) -> None:
        text = _clean(raw)
        now = time.monotonic()
        with self._lock:
            startup = self._startup_pending
            self._startup_pending = False
            suppressed = now < self._suppress_until
        if not text:
            # A cleared selection also cancels a text that was still waiting for
            # its settle window.
            self._cancel_settle()
            if not startup and not suppressed:
                self._emit_clear()
            else:
                LOGGER.debug("empty selection ignored (start-up or suppressed)")
            return
        with self._lock:
            if suppressed:
                # Remember our own selection so it is not reported later.
                self._last = text
                LOGGER.debug("selection ignored while suppressed")
                return
            if len(text) < self.min_length:
                LOGGER.debug("selection shorter than min_length, ignored")
                return
            if text == self._last:
                LOGGER.debug("selection unchanged, ignored")
                return
        # Do not report yet: wait until the text stops changing (typing).
        self._schedule(text)

    def _schedule(self, text: str) -> None:
        """Report *text* after the settle window; a newer text cancels it."""
        if self.settle_seconds <= 0:
            self._accept(text)
            return
        timer = threading.Timer(self.settle_seconds, self._settle_fire, args=(text,))
        timer.daemon = True
        with self._lock:
            previous = self._settle_timer
            self._settle_timer = timer
            self._pending = text
        if previous is not None:
            previous.cancel()
        timer.start()

    def _settle_fire(self, text: str) -> None:
        """Timer callback: accept *text* only when it is still the pending one."""
        with self._lock:
            if self._stop.is_set() or self._pending != text:
                return
            self._pending = None
            self._settle_timer = None
        self._accept(text)

    def _accept(self, text: str) -> None:
        """Report *text* if it differs from the last accepted selection."""
        with self._lock:
            if text == self._last:
                LOGGER.debug("selection unchanged, ignored")
                return
            self._last = text
        try:
            self.on_selection(text)
        except Exception:  # never kill the reader thread
            LOGGER.exception("selection callback failed")

    def _cancel_settle(self) -> None:
        """Forget a pending selection that has not settled yet."""
        with self._lock:
            timer = self._settle_timer
            self._settle_timer = None
            self._pending = None
        if timer is not None:
            timer.cancel()
