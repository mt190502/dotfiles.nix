"""Pointer position lookup for lexipop.

Wayland does not expose the global pointer position to clients.  Under Sway the
XWayland pointer is tracked, so ``xdotool getmouselocation --shell`` yields
usable screen coordinates.  Every failure returns None; the caller is expected
to fall back to a fixed popup position.
"""

from __future__ import annotations

import logging
import os
import shutil
import subprocess
from typing import Optional

LOGGER = logging.getLogger(__name__)


def available(xdotool_bin: str = "xdotool") -> bool:
    """True when the xdotool binary can be executed."""
    if not xdotool_bin:
        return False
    if os.sep in xdotool_bin:
        return os.access(xdotool_bin, os.X_OK)
    return shutil.which(xdotool_bin) is not None


def _to_int(value: str) -> Optional[int]:
    try:
        return int(value.strip())
    except (TypeError, ValueError):
        return None


def cursor_position(xdotool_bin: str = "xdotool") -> Optional[tuple[int, int]]:
    """Return the global pointer position as ``(x, y)``, or None on failure."""
    if not xdotool_bin:
        return None
    try:
        proc = subprocess.run(
            [xdotool_bin, "getmouselocation", "--shell"],
            capture_output=True,
            timeout=2.0,
            check=False,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        LOGGER.debug("xdotool failed: %s", exc)
        return None
    if proc.returncode != 0:
        LOGGER.debug(
            "xdotool getmouselocation exited with %d: %s",
            proc.returncode,
            proc.stderr.decode("utf-8", "replace").strip(),
        )
        return None
    x: Optional[int] = None
    y: Optional[int] = None
    for line in proc.stdout.decode("utf-8", "replace").splitlines():
        key, _, value = line.partition("=")
        key = key.strip()
        if key == "X":
            x = _to_int(value)
        elif key == "Y":
            y = _to_int(value)
    if x is None or y is None:
        LOGGER.debug("xdotool output had no usable coordinates")
        return None
    return (x, y)
