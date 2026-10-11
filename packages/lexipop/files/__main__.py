"""Command line entry point: ``python -m lexipop`` / ``lexipop``.

Commands:

    lexipop [--config PATH] <command>

      version     print the package version
      daemon      run the GTK4 selection popup daemon
      editor      open the editor window for a given text
      translate   translate a text with ``trans``
      classify    classify a text as word or sentence
      save        translate (unless given) and add an Anki note
      ocr         OCR a screen region and feed it to the popup/editor

Exit codes: 0 ok, 1 runtime error, 2 usage error.  ``--json`` prints a single
JSON object on stdout.
"""

from __future__ import annotations

import argparse
import json
import logging
import sys
from typing import Any

from . import __version__
from . import config as config_module

__all__ = ["main", "build_parser"]

EXIT_OK = 0
EXIT_ERROR = 1
EXIT_USAGE = 2


def _word_limit(cfg: config_module.Config) -> int:
    """Return the configured word-token limit as a positive int."""
    try:
        limit = int(cfg.get("wordTokenLimit", 1))
    except (TypeError, ValueError):
        return 1
    return limit if limit > 0 else 1


def _print_json(payload: dict) -> None:
    print(json.dumps(payload, ensure_ascii=False))


# --------------------------------------------------------------------------
# command handlers
# --------------------------------------------------------------------------


def cmd_version(cfg: config_module.Config | None, args: argparse.Namespace) -> int:
    """Print ``lexipop <version>``."""
    print(f"lexipop {__version__}")
    return EXIT_OK


def cmd_daemon(cfg: config_module.Config, args: argparse.Namespace) -> int:
    """Run the selection popup daemon (imports GTK lazily)."""
    from .app import run_daemon

    return int(run_daemon(cfg))


def cmd_editor(cfg: config_module.Config, args: argparse.Namespace) -> int:
    """Open the editor window (imports GTK lazily)."""
    from .app import run_editor

    return int(
        run_editor(
            cfg,
            text=args.text,
            lang=args.lang,
            kind=args.kind,
            deck=args.deck,
        )
    )


def cmd_translate(cfg: config_module.Config, args: argparse.Namespace) -> int:
    """Translate a text into the configured/target language."""
    from . import translate as translate_module

    text = args.text
    target = args.target or cfg.get("translationTarget") or "tr"
    source = translate_module.detect_language(text)
    translation = translate_module.translate(text, target=target, source=source)
    if args.json:
        _print_json(
            {
                "text": text,
                "target": target,
                "source": source,
                "translation": translation,
            }
        )
    else:
        print(translation)
    return EXIT_OK


def cmd_classify(cfg: config_module.Config, args: argparse.Namespace) -> int:
    """Classify a text as word or sentence."""
    from . import classify as classify_module

    text = args.text
    kind = classify_module.classify(text, _word_limit(cfg))
    if args.json:
        _print_json(
            {
                "text": text,
                "kind": kind,
                "tokens": classify_module.tokenize(text),
            }
        )
    else:
        print(kind)
    return EXIT_OK


def cmd_ocr(cfg: config_module.Config, args: argparse.Namespace) -> int:
    """OCR a screen region (or the whole screen) and deliver the text.

    With ``--print``/``--json`` the text is printed and the daemon is never
    touched.  Otherwise the text is sent to the running daemon; when no daemon
    answers, the editor window opens with that text.
    """
    from . import ocr as ocr_module

    try:
        text = ocr_module.ocr_from_region(cfg, full=bool(args.full))
    except ocr_module.OcrError as exc:
        print(f"lexipop: {exc}", file=sys.stderr)
        return EXIT_ERROR

    if not text:
        # Cancelled selection (or nothing recognised): silent success.
        return EXIT_OK

    if args.print_text or args.json:
        if args.json:
            _print_json({"text": text, "chars": len(text)})
        else:
            print(text)
        return EXIT_OK

    if not ocr_module.deliver_to_daemon(text, source="ocr"):
        from .app import run_editor

        return int(run_editor(cfg, text=text, lang=None, kind=None))
    return EXIT_OK


def cmd_save(cfg: config_module.Config, args: argparse.Namespace) -> int:
    """Translate (unless provided) and add one Anki note."""
    from . import anki as anki_module
    from . import classify as classify_module
    from . import notes as notes_module
    from . import translate as translate_module

    text = args.text
    kind = args.kind or classify_module.classify(text, _word_limit(cfg))
    lang = args.lang or translate_module.detect_language(text)
    deck = args.deck or cfg.deck_for(lang, kind)
    if not deck:
        print("lexipop: no deck configured for this language", file=sys.stderr)
        return EXIT_ERROR

    front_text = args.front if args.front is not None else text
    if args.back is not None:
        back_text = args.back
    else:
        back_text = translate_module.translate(
            text,
            target=cfg.get("translationTarget") or "tr",
            source=lang,
        )

    front_html = classify_module.text_to_html(front_text)
    back_html = classify_module.text_to_html(back_text)
    request = notes_module.build_note_request(cfg, deck, front_html, back_html)

    client = anki_module.AnkiClient(cfg.get("ankiConnectUrl"))
    note_id = client.add_note(
        request["deckName"],
        request["modelName"],
        request["fields"],
        request["tags"],
        allow_duplicate=request["options"]["allowDuplicate"],
    )

    if args.json:
        _print_json(
            {
                "noteId": note_id,
                "deck": deck,
                "kind": kind,
                "lang": lang,
                "front": front_html,
                "back": back_html,
            }
        )
    else:
        print(note_id)
    return EXIT_OK


_HANDLERS = {
    "version": cmd_version,
    "daemon": cmd_daemon,
    "editor": cmd_editor,
    "translate": cmd_translate,
    "classify": cmd_classify,
    "save": cmd_save,
    "ocr": cmd_ocr,
}

#: Commands that need a loaded config; ``version`` must work without one.
_CONFIG_COMMANDS = frozenset({"daemon", "editor", "translate", "classify", "save", "ocr"})


# --------------------------------------------------------------------------
# argument parsing
# --------------------------------------------------------------------------


def _add_json(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--json",
        action="store_true",
        help="print a single JSON object on stdout",
    )


def build_parser() -> argparse.ArgumentParser:
    """Build the ``lexipop`` argument parser."""
    parser = argparse.ArgumentParser(
        prog="lexipop",
        description="Capture a selection, translate it and save it as an Anki note.",
    )
    parser.add_argument(
        "--config",
        metavar="PATH",
        default=None,
        help="config file to use (default: $LEXIPOP_CONFIG or ~/.config/lexipop/config.json)",
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"lexipop {__version__}",
    )

    subparsers = parser.add_subparsers(dest="command", metavar="<command>")
    subparsers.required = True

    subparsers.add_parser("version", help="print the package version")

    subparsers.add_parser("daemon", help="run the selection popup daemon")

    editor = subparsers.add_parser("editor", help="open the editor window")
    editor.add_argument("--text", required=True, help="text to edit")
    editor.add_argument("--lang", default=None, help="source language code")
    editor.add_argument(
        "--kind",
        choices=("word", "sentence"),
        default=None,
        help="force the word/sentence classification",
    )
    editor.add_argument("--deck", default=None, help="pre-select a deck")

    translate = subparsers.add_parser("translate", help="translate a text with trans")
    translate.add_argument("--text", required=True, help="text to translate")
    translate.add_argument("--target", default=None, help="target language code")
    _add_json(translate)

    classify = subparsers.add_parser("classify", help="classify a text as word or sentence")
    classify.add_argument("--text", required=True, help="text to classify")
    _add_json(classify)

    save = subparsers.add_parser("save", help="translate (unless given) and add an Anki note")
    save.add_argument("--text", required=True, help="text to save")
    save.add_argument("--deck", default=None, help="target deck")
    save.add_argument("--front", default=None, help="front field text (default: the input text)")
    save.add_argument("--back", default=None, help="back field text (default: the translation)")
    save.add_argument("--lang", default=None, help="source language code")
    save.add_argument(
        "--kind",
        choices=("word", "sentence"),
        default=None,
        help="force the word/sentence classification",
    )
    _add_json(save)

    ocr = subparsers.add_parser("ocr", help="OCR a screen region and show it in the popup")
    ocr.add_argument(
        "--full",
        action="store_true",
        help="capture the whole screen instead of letting the user drag a region",
    )
    ocr.add_argument(
        "--print",
        dest="print_text",
        action="store_true",
        help="print the recognised text on stdout and do not contact the daemon",
    )
    _add_json(ocr)

    return parser


def main(argv: list[str] | None = None) -> int:
    """Run the CLI and return an exit code (0 ok, 1 runtime error)."""
    parser = build_parser()
    args = parser.parse_args(argv)

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    cfg: config_module.Config | None = None
    if args.command in _CONFIG_COMMANDS:
        cfg = config_module.load(args.config)

    handler = _HANDLERS[args.command]
    try:
        return int(handler(cfg, args) or EXIT_OK)  # type: ignore[arg-type]
    except KeyboardInterrupt:
        print("lexipop: interrupted", file=sys.stderr)
        return EXIT_ERROR
    except RuntimeError as exc:
        print(f"lexipop: {exc}", file=sys.stderr)
        return EXIT_ERROR


if __name__ == "__main__":
    sys.exit(main())
