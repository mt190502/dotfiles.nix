"""Note field HTML formatting and Anki note request building.

This module is self-contained: it must not import any other lexipop module.
"""

from __future__ import annotations

import html

__all__ = [
    "DEFAULT_PALETTE",
    "colored_html",
    "pair_ranges",
    "build_fields",
    "build_note_request",
]

#: Fixed, distinguishable colours.  Written exactly as ``rgb(r, g, b)`` so the
#: generated HTML matches the existing Anki cards in this collection.
DEFAULT_PALETTE = [
    "rgb(170, 0, 0)",
    "rgb(0, 110, 170)",
    "rgb(0, 130, 0)",
    "rgb(170, 90, 0)",
    "rgb(130, 0, 170)",
    "rgb(0, 130, 130)",
    "rgb(150, 100, 0)",
]

Range = tuple[int, int, int]


def _escape(text: str) -> str:
    """Escape ``text`` for safe embedding in a note field."""
    return html.escape(text or "", quote=False)


def _color(value) -> str:
    """Normalise a palette entry to a ``rgb(r, g, b)`` CSS colour string."""
    if isinstance(value, (tuple, list)) and len(value) == 3:
        return "rgb({}, {}, {})".format(*(int(c) for c in value))
    return str(value)


def colored_html(
    text: str,
    ranges: list[Range] | None,
    palette: list[str] | None = None,
) -> str:
    """Return escaped HTML for ``text`` with each range wrapped in a colour.

    ``ranges`` entries are ``(start, end, palette_index)`` with character
    offsets into the original ``text``.  Ranges may be given in any order; they
    are sorted and clamped to the text.  Invalid or overlapping ranges are
    dropped.  ``ranges`` empty/None yields plain escaped HTML.
    """
    if not ranges:
        return _escape(text)
    colors = list(palette) if palette else list(DEFAULT_PALETTE)
    if not colors:
        return _escape(text)
    text = text or ""
    ordered = sorted(
        (int(start), int(end), int(index)) for start, end, index in ranges
    )
    parts: list[str] = []
    cursor = 0
    for start, end, index in ordered:
        start = max(0, start)
        end = min(len(text), end)
        if end <= start or start < cursor:
            continue
        parts.append(_escape(text[cursor:start]))
        color = _color(colors[index % len(colors)])
        parts.append(
            '<span style="color: {};">{}</span>'.format(
                color, _escape(text[start:end])
            )
        )
        cursor = end
    parts.append(_escape(text[cursor:]))
    return "".join(parts)


def _find_occurrence(text: str, needle: str, used: list[bool]) -> tuple[int, int] | None:
    """Find the first occurrence of ``needle`` not overlapping ``used``."""
    if not needle or not text:
        return None
    for case_sensitive in (True, False):
        haystack = text if case_sensitive else text.lower()
        target = needle if case_sensitive else needle.lower()
        start = 0
        while True:
            index = haystack.find(target, start)
            if index < 0:
                break
            end = index + len(needle)
            if not any(used[index:end]):
                return index, end
            start = index + 1
    return None


def pair_ranges(
    source: str,
    target: str,
    pairs: list[tuple[str, str]],
) -> tuple[list[Range], list[Range]]:
    """Locate aligned ``pairs`` inside ``source`` and ``target``.

    Each pair is looked up on both sides independently: the first unused
    occurrence, exact match first, then a case-insensitive fallback.  A snippet
    that is not found is skipped.  Duplicated text is consumed only once.
    Pairs keep their index, so both sides share the same palette colour.
    """
    source = source or ""
    target = target or ""
    source_used = [False] * len(source)
    target_used = [False] * len(target)
    source_ranges: list[Range] = []
    target_ranges: list[Range] = []
    for index, pair in enumerate(pairs or []):
        try:
            source_snippet, target_snippet = pair
        except (TypeError, ValueError):
            continue
        found = _find_occurrence(source, source_snippet or "", source_used)
        if found is not None:
            for position in range(found[0], found[1]):
                source_used[position] = True
            source_ranges.append((found[0], found[1], index))
        found = _find_occurrence(target, target_snippet or "", target_used)
        if found is not None:
            for position in range(found[0], found[1]):
                target_used[position] = True
            target_ranges.append((found[0], found[1], index))
    return source_ranges, target_ranges


def _attr(cfg, name: str, default=None):
    """Read ``name`` from a ``Config``-like object or a plain dict."""
    if cfg is None:
        return default
    if isinstance(cfg, dict):
        value = cfg.get(name, default)
    else:
        value = getattr(cfg, name, default)
    return default if value is None else value


def build_fields(cfg, front_html: str, back_html: str) -> dict[str, str]:
    """Build the Anki ``fields`` mapping for a note."""
    front_field = _attr(cfg, "frontField", "Front")
    back_field = _attr(cfg, "backField", "Back")
    return {front_field: front_html, back_field: back_html}


def build_note_request(
    cfg,
    deck: str,
    front_html: str,
    back_html: str,
    extra_tags: list[str] | None = None,
) -> dict:
    """Build an AnkiConnect ``addNote`` request body."""
    tags = list(_attr(cfg, "tags", []) or [])
    if extra_tags:
        tags += list(extra_tags)
    return {
        "deckName": deck,
        "modelName": _attr(cfg, "noteModel", "Basic"),
        "fields": build_fields(cfg, front_html, back_html),
        "tags": tags,
        "options": {"allowDuplicate": False},
    }
