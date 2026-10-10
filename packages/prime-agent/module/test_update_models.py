"""Tests for Rust models.json catalog generation (synthetic data only)."""

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("prime_model_updater", Path(__file__).with_name("update-models.py"))
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


class ModelUpdaterTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.target = Path(self.tmp.name) / "models.json"
        self.provider = {
            "name": "NanoGPT", "baseUrl": "https://example.invalid/v1",
            "api": "openai-completions", "modelsUrl": None, "detailed": True,
            "requiredEndpoints": [], "visionMarkers": [],
            "defaultContextWindow": 128000, "defaultMaxTokens": 16384,
            "compat": {}, "keyFile": "/run/user/1000/fake-secret", "apiKey": None,
        }

    def config(self):
        return {"target": str(self.target), "providers": {"nano-gpt": self.provider}}

    def test_generates_rust_models_with_runtime_key_reference(self):
        catalog = [{"id": "example-model", "name": "Example", "capabilities": {
            "tool_calling": True, "reasoning": True}, "architecture": {
            "input_modalities": ["text", "image"]}, "context_length": 64000}]
        with patch.object(updater, "fetch_models", return_value=[updater.model_definition(m, self.provider) for m in catalog]):
            updater.update(self.config())
        data = json.loads(self.target.read_text())
        provider = data["providers"]["nano-gpt"]
        self.assertEqual(provider["apiKey"], "!cat /run/user/1000/fake-secret")
        self.assertEqual(provider["models"][0]["id"], "example-model")
        self.assertEqual(provider["models"][0]["input"], ["text", "image"])
        self.assertEqual(provider["compat"]["maxTokensField"], "max_tokens")
        self.assertEqual(self.target.stat().st_mode & 0o777, 0o600)

    def test_failed_catalog_preserves_existing_models(self):
        with patch.object(updater, "fetch_models", return_value=[{"id": "previous"}]):
            updater.update(self.config())
        with patch.object(updater, "fetch_models", side_effect=OSError("offline")):
            updater.update(self.config())
        self.assertEqual(json.loads(self.target.read_text())["providers"]["nano-gpt"]["models"], [{"id": "previous"}])


if __name__ == "__main__":
    unittest.main()
