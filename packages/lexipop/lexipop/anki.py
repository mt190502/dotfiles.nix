"""AnkiConnect v6 client.

Thin, dependency-light wrapper around the AnkiConnect HTTP API
(https://foosoft.net/projects/anki-connect/). Every action is sent as

    POST <url>  {"action": ..., "version": 6, "params": {...}}

and answered with ``{"result": ..., "error": ...}``. An answer carrying a
non-null ``error`` becomes an :class:`AnkiError`, so callers such as the editor
window can show duplicate-note or duplicate-deck failures to the user instead
of silently losing the note.

This module is deliberately self-contained: it imports no other ``lexipop``
module and takes plain strings/dicts, which keeps it usable from tests and from
the CLI without a config object.
"""

from __future__ import annotations

from typing import Any

import requests

DEFAULT_URL = "http://127.0.0.1:8765"
DEFAULT_TIMEOUT = 5.0
API_VERSION = 6


class AnkiError(RuntimeError):
    """Raised when AnkiConnect is unreachable, misbehaves or reports an error."""


class AnkiClient:
    """Minimal AnkiConnect client.

    Args:
        url: Base AnkiConnect URL, for example ``http://127.0.0.1:8765``.
        timeout: Per-request timeout in seconds.
    """

    def __init__(self, url: str = DEFAULT_URL, timeout: float = DEFAULT_TIMEOUT) -> None:
        self.url = url
        self.timeout = timeout
        self._session = requests.Session()

    def __repr__(self) -> str:  # pragma: no cover - debugging aid
        return f"{type(self).__name__}(url={self.url!r}, timeout={self.timeout!r})"

    # -- transport ---------------------------------------------------------

    def invoke(self, action: str, **params: Any) -> Any:
        """Send one raw AnkiConnect action and return its ``result``.

        Raises:
            AnkiError: on transport failure, non-JSON reply, or when the reply
                carries a non-null ``error`` string.
        """
        payload = {"action": action, "version": API_VERSION, "params": params}
        try:
            response = self._session.post(self.url, json=payload, timeout=self.timeout)
            response.raise_for_status()
            data = response.json()
        except requests.RequestException as exc:
            raise AnkiError(f"AnkiConnect request failed: {exc}") from exc
        except ValueError as exc:  # includes json.JSONDecodeError
            raise AnkiError(f"AnkiConnect returned invalid JSON: {exc}") from exc

        if not isinstance(data, dict):
            raise AnkiError(f"AnkiConnect returned unexpected payload: {data!r}")

        error = data.get("error")
        if error:
            raise AnkiError(str(error))
        return data.get("result")

    # -- probes ------------------------------------------------------------

    def version(self) -> int | None:
        """Return the AnkiConnect API version, or ``None`` when unreachable."""
        try:
            result = self.invoke("version")
        except AnkiError:
            return None
        if isinstance(result, bool):
            return None
        if isinstance(result, int):
            return result
        if isinstance(result, str):
            try:
                return int(result.strip())
            except ValueError:
                return None
        return None

    def is_available(self) -> bool:
        """Return ``True`` when Anki is running and AnkiConnect answers."""
        return self.version() is not None

    def deck_names(self) -> list[str]:
        """Return all deck names, including nested ones such as ``A::B``."""
        result = self.invoke("deckNames")
        return _as_str_list(result, "deckNames")

    def model_names(self) -> list[str]:
        """Return all note-type (model) names."""
        result = self.invoke("modelNames")
        return _as_str_list(result, "modelNames")

    def find_notes(self, query: str) -> list[int]:
        """Return note ids matching an Anki search ``query``."""
        result = self.invoke("findNotes", query=query)
        if result is None:
            return []
        if not isinstance(result, list):
            raise AnkiError(f"findNotes returned unexpected result: {result!r}")
        return [int(note_id) for note_id in result]

    # -- writes ------------------------------------------------------------

    def add_note(
        self,
        deck: str,
        model: str,
        fields: dict[str, str],
        tags: list[str] | None = None,
        allow_duplicate: bool = False,
        duplicate_scope: str | None = None,
    ) -> int:
        """Create one note and return its note id.

        Args:
            deck: Target deck name (``A::B`` nested names are valid).
            model: Note type name, for example ``Basic``.
            fields: Field name -> HTML value, for example
                ``{"Front": "word", "Back": "kelime"}``.
            tags: Tags to attach.
            allow_duplicate: AnkiConnect ``options.allowDuplicate``. Left
                ``False`` so a repeated selection is reported, not stored twice.
            duplicate_scope: Optional AnkiConnect ``options.duplicateScope``
                (``"deck"``, ``"collection"``, ...).

        Raises:
            AnkiError: unreachable Anki, or an AnkiConnect error such as a
                duplicate note. The AnkiConnect error text is preserved.
        """
        options: dict[str, Any] = {"allowDuplicate": bool(allow_duplicate)}
        if duplicate_scope:
            options["duplicateScope"] = duplicate_scope

        note = {"deckName": deck, "modelName": model, "fields": dict(fields)}
        if tags:
            note["tags"] = list(tags)
        note["options"] = options

        result = self.invoke("addNote", note=note)
        if isinstance(result, bool) or not isinstance(result, int):
            if isinstance(result, str) and result.strip().isdigit():
                return int(result.strip())
            raise AnkiError(f"addNote did not return a note id: {result!r}")
        return result


def _as_str_list(result: Any, action: str) -> list[str]:
    """Coerce an AnkiConnect list reply to ``list[str]``."""
    if result is None:
        return []
    if not isinstance(result, list):
        raise AnkiError(f"{action} returned unexpected result: {result!r}")
    return [str(item) for item in result]
