"""Word/sentence classification and deck selection (language agnostic).

This module is self-contained: it must not import any other lexipop module.
"""

from __future__ import annotations

import html
import re

__all__ = [
    "WORD",
    "SENTENCE",
    "tokenize",
    "classify",
    "select_deck",
    "html_escape",
    "text_to_html",
]

WORD = "word"
SENTENCE = "sentence"

#: Characters that mark the end of a sentence.
_SENTENCE_FINAL = re.compile(r"[.!?\u2026\u3002]")

#: Maps a classification kind to the language-config key that holds the deck.
_DECK_KEY = {WORD: "words", SENTENCE: "sentences"}


def tokenize(text: str) -> list[str]:
    """Split ``text`` into whitespace-separated tokens."""
    if not text:
        return []
    return [tok for tok in re.split(r"\s+", text.strip()) if tok]


def classify(text: str, word_limit: int = 1) -> str:
    """Return :data:`WORD` or :data:`SENTENCE` for ``text``.

    A text is a word when it has ``<= word_limit`` tokens, contains no
    sentence-final punctuation (``. ! ? ... 。``) and no newline.  Everything
    else is a sentence.
    """
    if text is None:
        return SENTENCE
    if "\n" in text or "\r" in text:
        return SENTENCE
    tokens = tokenize(text)
    if len(tokens) > word_limit:
        return SENTENCE
    if _SENTENCE_FINAL.search(text):
        return SENTENCE
    return WORD


def select_deck(
    lang_code: str | None,
    kind: str,
    languages: dict,
    fallback: str | None = None,
) -> str | None:
    """Pick the deck for ``lang_code`` and ``kind`` from a raw config dict.

    ``languages`` is the raw ``{"en": {"words": ..., "sentences": ...}}`` map.
    Unknown language codes, missing keys and missing entries fall back to
    ``fallback`` (which may be ``None``).
    """
    key = _DECK_KEY.get(kind)
    if not lang_code or not key or not isinstance(languages, dict):
        return fallback
    entry = languages.get(lang_code)
    if entry is None:
        lowered = lang_code.lower()
        for candidate, value in languages.items():
            if isinstance(candidate, str) and candidate.lower() == lowered:
                entry = value
                break
    if not isinstance(entry, dict):
        return fallback
    deck = entry.get(key)
    if isinstance(deck, str) and deck:
        return deck
    return fallback


def html_escape(text: str) -> str:
    """HTML-escape ``text`` (including quotes)."""
    return html.escape(text or "", quote=True)


def text_to_html(text: str) -> str:
    """Escape ``text`` and convert newlines to ``<br>``."""
    escaped = html_escape(text or "")
    escaped = escaped.replace("\r\n", "<br>").replace("\n", "<br>")
    return escaped.replace("\r", "<br>")
