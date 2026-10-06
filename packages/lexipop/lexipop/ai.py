"""Optional AI translation with word alignment (OpenAI-compatible).

The module talks to any OpenAI-compatible ``{endpoint}/chat/completions``
endpoint configured through ``cfg.ai``, asks the model for a strict JSON
answer and colours both language sides with the shared ``notes`` helpers.

The API key is read from ``cfg.ai.apiKeyFile``.  It is never logged, never
placed in an exception message and never embedded in a result.
"""

from __future__ import annotations

import json
import logging
import os
import re
from dataclasses import dataclass
from typing import Any

import requests

from .notes import DEFAULT_PALETTE, colored_html, pair_ranges

log = logging.getLogger(__name__)

__all__ = [
    "AIError",
    "AIResult",
    "SYSTEM_PROMPT",
    "DEFAULT_TARGET",
    "resolve_api_key",
    "available",
    "build_request",
    "recover_json",
    "parse_model_output",
    "ai_translate",
]

#: Fallback target language when ``cfg.translationTarget`` is unset.
DEFAULT_TARGET = "tr"

#: Prompt asking for machine-readable JSON only.
SYSTEM_PROMPT = (
    "You are a translation and word-alignment engine.\n"
    "Answer with ONE JSON object and nothing else: no prose, no markdown, "
    "no code fences, no comments.\n"
    'JSON schema: {"translation": "<full translation>", '
    '"pairs": [{"source": "<snippet>", "target": "<snippet>"}]}\n'
    "Rules:\n"
    '- "translation" is the complete translation of the user text.\n'
    '- "pairs" holds 1-8 aligned source/target snippets (words or short phrases).\n'
    "- Every snippet must appear verbatim in the source text or in the "
    "translation.\n"
    "- Snippets must not overlap.\n"
    '- Use an empty "pairs" list when no alignment is possible.'
)

#: Longest body/traceback fragment kept inside an error message.
_SNIPPET_MAX = 300

#: Up to how many aligned pairs are accepted from the model.
_MAX_PAIRS = 12

_FENCE_RE = re.compile(r"```[ \t]*(?:json|JSON)?[ \t]*\r?\n?(.*?)```", re.DOTALL)


class AIError(RuntimeError):
    """Raised when an AI translation cannot be produced."""


@dataclass
class AIResult:
    """Outcome of one AI translation call."""

    translation: str
    pairs: list[tuple[str, str]]
    front_html: str
    back_html: str
    raw: str | None = None


# --------------------------------------------------------------------------
# config helpers
# --------------------------------------------------------------------------


def _cfg_get(obj: Any, key: str, default: Any = None) -> Any:
    """Read ``key`` from a Config object, a plain dict or any object."""
    if obj is None:
        return default
    if isinstance(obj, dict):
        return obj.get(key, default)
    try:
        return getattr(obj, key)
    except AttributeError:
        pass
    getter = getattr(obj, "get", None)
    if callable(getter):
        try:
            value = getter(key, default)
        except TypeError:
            value = getter(key)
        if value is not None:
            return value
    return default


def _ai_cfg(cfg: Any) -> Any:
    return _cfg_get(cfg, "ai")


def resolve_api_key(cfg: Any) -> str | None:
    """Return the trimmed API key from ``cfg.ai.apiKeyFile``.

    ``None`` is returned when no file is configured, the file cannot be read
    or it is empty.  The key value and the file path are never logged.
    """
    path = _cfg_get(_ai_cfg(cfg), "apiKeyFile")
    if not path or not isinstance(path, str):
        return None
    try:
        with open(os.path.expanduser(path.strip()), "r", encoding="utf-8") as handle:
            value = handle.read().strip()
    except OSError as exc:
        log.warning("cannot read the configured AI API key file (%s)", type(exc).__name__)
        return None
    if not value:
        log.warning("the configured AI API key file is empty")
        return None
    return value


def available(cfg: Any) -> bool:
    """True when AI mode is enabled and an API key can be read."""
    ai = _ai_cfg(cfg)
    if not bool(_cfg_get(ai, "enable", False)):
        return False
    return resolve_api_key(cfg) is not None


# --------------------------------------------------------------------------
# request building
# --------------------------------------------------------------------------


def build_request(
    cfg: Any,
    text: str,
    *,
    target: str | None = None,
    source: str | None = None,
) -> tuple[str, dict]:
    """Build ``(url, payload)`` for the chat-completions call.

    The payload has exactly the contract shape:
    ``{"model": ..., "messages": [...], "temperature": 0}``.
    Raises :class:`AIError` when the endpoint or the model is missing.
    """
    ai = _ai_cfg(cfg)
    endpoint = _cfg_get(ai, "endpoint") or ""
    if not isinstance(endpoint, str) or not endpoint.strip():
        raise AIError("AI endpoint is not configured (set ai.endpoint)")
    model = _cfg_get(ai, "model") or ""
    if not isinstance(model, str) or not model.strip():
        raise AIError("AI model is not configured (set ai.model)")

    user = "\n".join(
        (
            f"Source language: {source or 'auto-detect'}",
            f"Target language: {target or DEFAULT_TARGET}",
            "Text:",
            text,
        )
    )
    payload = {
        "model": model.strip(),
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user},
        ],
        "temperature": 0,
    }
    return endpoint.strip().rstrip("/") + "/chat/completions", payload


def _auth_headers(key: str) -> dict[str, str]:
    """Headers for the request.  Never logged."""
    return {
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


# --------------------------------------------------------------------------
# tolerant JSON recovery
# --------------------------------------------------------------------------


def _snippet(value: Any) -> str:
    text = value if isinstance(value, str) else str(value)
    text = " ".join(text.split())
    if len(text) > _SNIPPET_MAX:
        text = text[:_SNIPPET_MAX] + "..."
    return text


def recover_json(raw: str) -> Any:
    """Return the first JSON value found in ``raw``.

    Tolerates ```json fences, leading/trailing prose and BOM characters.
    Raises :class:`AIError` when nothing parses.
    """
    if raw is None:
        raise AIError("the AI endpoint returned an empty response")
    text = raw.lstrip("\ufeff").strip()
    if not text:
        raise AIError("the AI endpoint returned an empty response")

    candidates: list[str] = []
    for match in _FENCE_RE.finditer(text):
        candidates.append(match.group(1).strip())
    candidates.append(text)

    decoder = json.JSONDecoder()
    found: Any = None
    for candidate in candidates:
        if not candidate:
            continue
        try:
            found = json.loads(candidate)
            break
        except ValueError:
            pass
        best = None
        for index, char in enumerate(candidate):
            if char not in "{[":
                continue
            try:
                value, _end = decoder.raw_decode(candidate[index:])
            except ValueError:
                continue
            if isinstance(value, dict) and "translation" in value:
                found = value
                break
            if best is None:
                best = value
        if found is None and best is not None:
            found = best
        if found is not None:
            break

    if found is None:
        raise AIError(f"could not recover JSON from the AI response: {_snippet(text)}")
    return found


def _coerce_pairs(value: Any) -> list[tuple[str, str]]:
    if not isinstance(value, list):
        return []
    pairs: list[tuple[str, str]] = []
    for item in value:
        source: Any = None
        target: Any = None
        if isinstance(item, dict):
            for key, raw_value in item.items():
                lowered = str(key).strip().lower()
                if lowered in ("source", "src", "a", "from"):
                    source = raw_value
                elif lowered in ("target", "tgt", "b", "to", "translation"):
                    target = raw_value
        elif isinstance(item, (list, tuple)) and len(item) >= 2:
            source, target = item[0], item[1]
        if not isinstance(source, str) or not isinstance(target, str):
            continue
        source, target = source.strip(), target.strip()
        if source and target:
            pairs.append((source, target))
        if len(pairs) >= _MAX_PAIRS:
            break
    return pairs


def parse_model_output(raw: str) -> tuple[str, list[tuple[str, str]]]:
    """Turn raw model output into ``(translation, pairs)``.

    Raises :class:`AIError` when no JSON object and no usable translation can
    be recovered.
    """
    data = recover_json(raw)
    if not isinstance(data, dict):
        raise AIError("the AI response JSON is not an object")
    translation = data.get("translation")
    if translation is None:
        for key, value in data.items():
            if str(key).strip().lower() in ("translation", "translated", "output", "text"):
                translation = value
                break
    if translation is None:
        raise AIError('the AI response JSON has no "translation" field')
    if not isinstance(translation, str):
        translation = str(translation)
    translation = translation.strip()
    if not translation:
        raise AIError("the AI response contains an empty translation")
    return translation, _coerce_pairs(data.get("pairs"))


def _extract_content(data: Any) -> str:
    """Pull the assistant text out of an OpenAI-compatible response body."""
    if not isinstance(data, dict):
        raise AIError("the AI endpoint returned an unexpected response body")
    error = data.get("error")
    if error:
        message = error.get("message") if isinstance(error, dict) else error
        raise AIError(f"the AI endpoint reported an error: {_snippet(message)}")
    choices = data.get("choices")
    if not isinstance(choices, list) or not choices:
        raise AIError("the AI endpoint response has no choices")
    first = choices[0]
    if not isinstance(first, dict):
        raise AIError("the AI endpoint response has a malformed choice")
    message = first.get("message")
    content = None
    if isinstance(message, dict):
        content = message.get("content")
    if content is None:
        content = first.get("text")
    if isinstance(content, list):
        parts = []
        for part in content:
            if isinstance(part, dict) and isinstance(part.get("text"), str):
                parts.append(part["text"])
        content = "".join(parts)
    if not isinstance(content, str) or not content.strip():
        raise AIError("the AI endpoint returned an empty message")
    return content


# --------------------------------------------------------------------------
# main entry point
# --------------------------------------------------------------------------


def ai_translate(
    cfg: Any,
    text: str,
    *,
    target: str | None = None,
    source: str | None = None,
    timeout: float = 60.0,
) -> AIResult:
    """Translate ``text`` with the configured AI endpoint.

    Returns an :class:`AIResult` with the translation, the aligned snippets and
    the coloured front/back HTML.  Raises :class:`AIError` on any failure.
    """
    text = (text or "").strip()
    if not text:
        raise AIError("nothing to translate: the input text is empty")

    key = resolve_api_key(cfg)
    if not key:
        raise AIError(
            "AI translation is enabled but no API key could be read "
            "from ai.apiKeyFile"
        )

    target = target or _cfg_get(cfg, "translationTarget") or DEFAULT_TARGET
    url, payload = build_request(cfg, text, target=target, source=source)

    try:
        response = requests.post(
            url, json=payload, headers=_auth_headers(key), timeout=timeout
        )
    except requests.RequestException as exc:
        raise AIError(f"AI request failed: {type(exc).__name__}: {_snippet(exc)}") from None
    except Exception as exc:  # pragma: no cover - defensive, keep traceback clean
        raise AIError(f"AI request failed: {type(exc).__name__}") from None

    if response.status_code != 200:
        raise AIError(
            f"AI endpoint returned HTTP {response.status_code}: {_snippet(response.text)}"
        )
    try:
        body = response.json()
    except ValueError:
        raise AIError(
            f"AI endpoint returned a non-JSON body: {_snippet(response.text)}"
        ) from None

    raw = _extract_content(body)
    translation, pairs = parse_model_output(raw)
    source_ranges, target_ranges = pair_ranges(text, translation, pairs)
    return AIResult(
        translation=translation,
        pairs=pairs,
        front_html=colored_html(text, source_ranges, DEFAULT_PALETTE),
        back_html=colored_html(translation, target_ranges, DEFAULT_PALETTE),
        raw=raw,
    )
