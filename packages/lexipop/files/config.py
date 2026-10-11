"""Configuration loading for lexipop.

``module/home.nix`` renders a small JSON document (see the interface contract)
and links it at ``~/.config/lexipop/config.json``.  This module reads it, deep
merges the user values over :data:`DEFAULTS` and exposes the result through the
attribute-style :class:`Config` wrapper.

A missing or invalid file is never fatal: the defaults are used and a warning
is logged.
"""

from __future__ import annotations

import copy
import json
import logging
import os
from typing import Any

__all__ = ["DEFAULT_PATH", "DEFAULTS", "Config", "load"]

log = logging.getLogger(__name__)

#: Default config location, expanded with :func:`os.path.expanduser` at load.
DEFAULT_PATH = "~/.config/lexipop/config.json"

#: Fallback document, used when no user config is available or readable.
DEFAULTS: dict[str, Any] = {
    "ankiConnectUrl": "http://127.0.0.1:8765",
    "noteModel": "Basic",
    "frontField": "Front",
    "backField": "Back",
    "tags": ["lexipop"],
    "palette": [
        "rgb(170, 0, 0)",
        "rgb(0, 110, 170)",
        "rgb(0, 130, 0)",
        "rgb(170, 90, 0)",
        "rgb(130, 0, 170)",
        "rgb(0, 130, 130)",
        "rgb(150, 100, 0)",
    ],
    "translationTarget": "tr",
    "translationTargets": [],
    "excludeApps": [],
    "languages": {},
    "fallbackDeck": None,
    "wordTokenLimit": 1,
    "popup": {
        "enabled": True,
        "onEverySelection": True,
        "hideWhenFocusChanges": True,
        "hideWhenSelectionCleared": True,
        "closeOnOutsideClick": True,
        "hideAfterSeconds": 0,
        "settleMs": 250,
        "pollSelectionMs": 300,
        "labels": {
            "detected": "(detected)",
            "translation": "Translation",
            "close": "Close",
            "ai": "AI Translate",
            "saveAs": "Save as",
            "edit": "Edit…",
            "word": "Word",
            "sentence": "Sentence",
            "targetLanguage": "Target language",
            "front": "Front",
            "back": "Back (translation)",
            "deck": "Deck",
            "colours": "Colours",
            "preview": "Preview",
            "reset": "Reset",
            "coloursHint": "Colours appear after an AI translation.",
        },
    },
    "languageNames": {},
    "ai": {
        "enable": False,
        "endpoint": "https://api.nano-gpt.com/api/v1",
        "model": "",
        "apiKeyFile": None,
    },
}

#: Maps a classification kind to the language-config key holding its deck.
_DECK_KEY = {"word": "words", "sentence": "sentences"}


class Config:
    """Read-only, attribute-accessible view over a config mapping.

    Nested dicts are wrapped lazily, so ``cfg.ai.model`` and
    ``cfg.languages.en.words`` work while the underlying data stays a plain
    ``dict`` (:meth:`as_dict`).
    """

    def __init__(self, raw: dict) -> None:
        if not isinstance(raw, dict):
            raise TypeError("Config expects a mapping")
        object.__setattr__(self, "raw", dict(raw))

    # -- wrapping ----------------------------------------------------------

    @staticmethod
    def _wrap(value: Any) -> Any:
        if isinstance(value, dict) and not isinstance(value, Config):
            return Config(value)
        return value

    # -- mapping-like access ----------------------------------------------

    def __getattr__(self, name: str) -> Any:
        # Only called when normal attribute lookup fails.
        raw = object.__getattribute__(self, "raw")
        if name in raw:
            return self._wrap(raw[name])
        raise AttributeError(name)

    def __getitem__(self, key: str) -> Any:
        return self._wrap(self.raw[key])

    def __contains__(self, key: str) -> bool:
        return key in self.raw

    def get(self, key: str, default: Any = None) -> Any:
        """Return ``key`` or ``default`` (``None`` when absent)."""
        if key in self.raw:
            return self._wrap(self.raw[key])
        return default

    def as_dict(self) -> dict:
        """Return a deep copy of the raw mapping."""
        return copy.deepcopy(self.raw)

    def __repr__(self) -> str:  # pragma: no cover - debugging aid
        return f"Config({self.raw!r})"

    # -- domain helpers ----------------------------------------------------

    def language(self, code: str | None) -> "Config | None":
        """Return the ``languages`` entry for ``code``, or ``None``."""
        languages = self.raw.get("languages")
        if not code or not isinstance(languages, dict):
            return None
        entry = languages.get(code)
        if entry is None:
            lowered = code.lower()
            for key, value in languages.items():
                if isinstance(key, str) and key.lower() == lowered:
                    entry = value
                    break
        if entry is None:
            return None
        return self._wrap(entry)

    def deck_for(self, code: str | None, kind: str) -> str | None:
        """Pick the deck for a language ``code`` and a classification ``kind``.

        Falls back to ``fallbackDeck`` for unknown languages or missing entries.
        """
        fallback = self.raw.get("fallbackDeck")
        fallback = fallback if isinstance(fallback, str) and fallback else None
        key = _DECK_KEY.get(kind)
        if not key:
            return fallback
        language = self.language(code)
        if language is not None:
            deck = language.get(key)
            if isinstance(deck, str) and deck:
                return deck
        return fallback


def _deep_merge(base: dict, override: dict) -> dict:
    """Recursively merge ``override`` over ``base`` and return a new dict."""
    result = copy.deepcopy(base)
    for key, value in override.items():
        current = result.get(key)
        if isinstance(value, dict) and isinstance(current, dict):
            result[key] = _deep_merge(current, value)
        else:
            result[key] = copy.deepcopy(value)
    return result


def load(path: str | None = None) -> Config:
    """Load the config.

    Precedence: the ``path`` argument, then ``$LEXIPOP_CONFIG``, then
    :data:`DEFAULT_PATH`.  A missing file or invalid JSON falls back to
    :data:`DEFAULTS` with a warning instead of raising.
    """
    target = path or os.environ.get("LEXIPOP_CONFIG") or DEFAULT_PATH
    expanded = os.path.expanduser(target)
    raw: dict = {}
    try:
        with open(expanded, encoding="utf-8") as handle:
            data = json.load(handle)
    except FileNotFoundError:
        log.warning("lexipop config %s not found; using defaults", expanded)
    except (OSError, ValueError) as exc:
        log.warning("cannot read lexipop config %s (%s); using defaults", expanded, exc)
    else:
        if isinstance(data, dict):
            raw = data
        else:
            log.warning("lexipop config %s is not a JSON object; using defaults", expanded)
    return Config(_deep_merge(DEFAULTS, raw))
