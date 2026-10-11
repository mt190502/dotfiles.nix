"""Translation and language detection via translate-shell (``trans``).

This module is intentionally self-contained: it must not import any other
lexipop module.  It exchanges only plain values (``str``, ``dict``).
"""

from __future__ import annotations

import re
import shutil
import subprocess

__all__ = [
    "TransError",
    "identify",
    "detect_language",
    "translate",
    "available",
]

DEFAULT_IDENTIFY_TIMEOUT = 10.0
DEFAULT_TRANSLATE_TIMEOUT = 20.0


class TransError(RuntimeError):
    """Raised when ``trans`` cannot produce a usable result."""


def available(trans_bin: str = "trans") -> bool:
    """Return ``True`` when the ``trans`` executable can be found on PATH."""
    return shutil.which(trans_bin) is not None


def _run(argv: list[str], timeout: float) -> subprocess.CompletedProcess:
    """Run ``argv`` without a shell and return the completed process."""
    try:
        return subprocess.run(
            argv,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise TransError(f"failed to run {argv[0]!r}: {exc}") from exc


def _parse_identify(output: str) -> dict | None:
    """Parse a tolerate-alot ``trans -identify`` report.

    Real output looks like::

        Deutsch
        Name                  German
        Family                Indo-European
        Writing system        Latin
        Code                  de
        ISO 639-3             deu
        ...

    Extra lines, blank lines and missing sections are ignored.
    """
    code: str | None = None
    name: str | None = None
    confidence: float | None = None
    for line in output.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        parts = stripped.split(None, 1)
        key = parts[0].lower()
        value = parts[1].strip() if len(parts) > 1 else ""
        if key == "code":
            code = value or None
        elif key == "name":
            name = value or None
        elif key == "confidence":
            try:
                confidence = float(value)
            except ValueError:
                confidence = None
    if not code:
        return None
    return {"code": code, "name": name or code, "confidence": confidence}


def identify(
    text: str,
    *,
    trans_bin: str = "trans",
    timeout: float = DEFAULT_IDENTIFY_TIMEOUT,
) -> dict | None:
    """Detect the language of ``text`` with ``trans -identify``.

    Returns ``{"code": <iso>, "name": <name>, "confidence": <float|None>}`` or
    ``None`` when the language could not be determined or ``trans`` failed.
    """
    if not text or not text.strip():
        return None
    argv = [trans_bin, "-identify", "-no-ansi", "-no-browser", text]
    try:
        proc = _run(argv, timeout)
    except TransError:
        return None
    if proc.returncode != 0:
        return None
    return _parse_identify(proc.stdout or "")


def detect_language(text: str, **kw) -> str | None:
    """Return only the ISO code from :func:`identify` (or ``None``)."""
    info = identify(text, **kw)
    if not info:
        return None
    return info.get("code")


def translate(
    text: str,
    *,
    target: str = "tr",
    source: str | None = None,
    trans_bin: str = "trans",
    timeout: float = DEFAULT_TRANSLATE_TIMEOUT,
) -> str:
    """Translate ``text`` into ``target`` using ``trans -brief``.

    Raises :class:`TransError` on a non-zero exit, an empty result, or a
    timeout.  The text is always passed as a single argv item, never through a
    shell.
    """
    if not text or not text.strip():
        raise TransError("cannot translate empty text")
    argv = [trans_bin, "-brief", "-no-ansi", "-no-browser"]
    if source:
        argv += ["-s", source]
    argv += [f":{target}", text]
    proc = _run(argv, timeout)
    if proc.returncode != 0:
        detail = (proc.stderr or "").strip() or f"exit code {proc.returncode}"
        raise TransError(f"trans failed: {detail}")
    result = (proc.stdout or "").strip()
    if not result:
        raise TransError("trans returned an empty translation")
    return result
