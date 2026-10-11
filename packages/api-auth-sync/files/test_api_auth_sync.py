"""Offline regression tests for rotating provider credentials."""

import importlib.util
import json
import sys
import tempfile
import time
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("api_auth_sync", Path(__file__).with_name("api-auth-sync.py"))
sync = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = sync
spec.loader.exec_module(sync)


class SyncTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        sync.STATE_DIR = self.root / "state"
        sync.BACKUP_DIR = sync.STATE_DIR / "backup"
        sync.ensure_dirs()
        self.live = self.root / "auth.json"
        self.entries = [
            sync.Entry("prime-agent", self.live, "openai-codex"),
            sync.Entry("prime-agent-anthropic", self.live, "anthropic", "anthropic", True),
        ]
        sync.ENTRIES = self.entries
        sync.doc_key.clear()
        self.expiry = int(time.time() * 1000 + 7 * 86400_000)

    def oauth(self, tag, expiry=None):
        return {"type": "oauth", "access": f"access-{tag}", "refresh": f"refresh-{tag}",
                "expires": expiry or self.expiry}

    def test_migrate_merges_per_provider_and_preserves_other_keys(self):
        live = {"openai-codex": self.oauth("old", self.expiry - 20000),
                "anthropic": self.oauth("new"), "other": {"type": "api", "key": "sentinel"}}
        sync.write_json_atomic(self.live, live)
        sync.write_json_atomic(sync.BACKUP_DIR / "prime-agent.json",
                               {"openai-codex": self.oauth("new"),
                                "anthropic": self.oauth("old", self.expiry - 20000)})
        self.assertEqual(sync.cmd_migrate(None), 0)
        result = json.loads(self.live.read_text())
        self.assertEqual(result["openai-codex"], self.oauth("new"))
        self.assertEqual(result["anthropic"], self.oauth("new"))
        self.assertEqual(result["other"], live["other"])
        self.assertFalse(self.live.is_symlink())
        self.assertEqual(self.live.stat().st_mode & 0o777, 0o600)

    def test_refresh_preserves_both_providers_and_other_keys(self):
        live = {"openai-codex": self.oauth("codex", self.expiry - 20 * 86400_000),
                "anthropic": self.oauth("claude", self.expiry - 20 * 86400_000),
                "other": {"type": "api", "key": "sentinel"}}
        sync.write_json_atomic(self.live, live)
        calls = []

        def refresh(provider, token):
            calls.append((provider, token))
            return {"access_token": f"new-{provider}", "refresh_token": f"rotated-{provider}",
                    "expires_in": 3600}

        with patch.object(sync, "http_refresh", side_effect=refresh):
            self.assertEqual(sync.cmd_refresh(None), 0)
        result = json.loads(self.live.read_text())
        self.assertEqual(len(calls), 2)
        self.assertEqual({provider for provider, _ in calls}, {"openai", "anthropic"})
        self.assertEqual(result["openai-codex"]["refresh"], "rotated-openai")
        self.assertEqual(result["anthropic"]["refresh"], "rotated-anthropic")
        self.assertEqual(result["other"], live["other"])

    def test_missing_optional_anthropic_does_not_block_codex(self):
        sync.write_json_atomic(self.live, {"openai-codex": self.oauth("codex")})
        self.assertEqual(sync.cmd_migrate(None), 0)
        self.assertEqual(sync.cmd_refresh(None), 0)
        self.assertNotIn("anthropic", json.loads(self.live.read_text()))


if __name__ == "__main__":
    unittest.main()
