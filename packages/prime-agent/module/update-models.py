#!/usr/bin/env python3
"""Refresh Prime Agent Rust's models.json from public provider catalogs.

The JSON configuration contains catalog URLs and sops key *paths*, never keys.
Failed catalog requests preserve the last working models.json.
"""

import json
import os
import sys
import tempfile
import urllib.request
from pathlib import Path


def thinking_map(efforts):
    if not efforts:
        return None
    supports = set(efforts)

    def pick(*levels):
        return next((level for level in levels if level in supports), None)

    return {
        "off": pick("none"),
        "minimal": pick("minimal", "low"),
        "low": pick("low", "medium"),
        "medium": pick("medium", "high"),
        "high": pick("high", "xhigh"),
        "xhigh": pick("xhigh", "max"),
        "max": pick("max", "xhigh"),
    }


def input_modalities(model_id, markers):
    lower = model_id.lower()
    vision = any(marker in lower for marker in markers) or ("gpt-5" in lower and "codex" not in lower)
    return ["text", "image"] if vision else ["text"]


def model_definition(model, provider):
    model_id = model["id"]
    if provider["detailed"]:
        pricing = model.get("pricing") or {}
        caps = model.get("capabilities") or {}
        result = {
            "id": model_id,
            "name": model.get("name") or model_id,
            "reasoning": caps.get("reasoning") is True,
            "input": ["text", "image"] if "image" in (model.get("architecture") or {}).get("input_modalities", []) else ["text"],
            "cost": {
                "input": pricing.get("prompt") or 0,
                "output": pricing.get("completion") or 0,
                "cacheRead": (pricing.get("cacheReadInputPer1kTokens") or 0) * 1000,
                "cacheWrite": 0,
            },
            "contextWindow": model.get("context_length") or provider["defaultContextWindow"],
            "maxTokens": model.get("max_output_tokens") or provider["defaultMaxTokens"],
        }
        levels = thinking_map(model.get("reasoning_efforts"))
        if levels:
            result["thinkingLevelMap"] = levels
        return result
    return {
        "id": model_id,
        "name": model_id.split("/")[-1],
        "reasoning": any(marker in model_id.lower() for marker in ("r1", "reasoning")),
        "input": input_modalities(model_id, provider["visionMarkers"]),
        "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0},
        "contextWindow": model.get("context_length") or provider["defaultContextWindow"],
        "maxTokens": provider["defaultMaxTokens"],
    }


def fetch_models(provider):
    url = provider["modelsUrl"] or provider["baseUrl"].rstrip("/") + "/models"
    if provider["modelsUrl"] is None and provider["detailed"]:
        url += "?detailed=true"
    request = urllib.request.Request(url, headers={"User-Agent": "prime-agent-model-sync/1.0"})
    with urllib.request.urlopen(request, timeout=15) as response:
        data = json.load(response)["data"]
    if not isinstance(data, list):
        raise ValueError("catalog data is not a list")
    endpoints = set(provider["requiredEndpoints"])
    if endpoints:
        selected = [m for m in data if endpoints.intersection(m.get("supported_endpoints") or [])]
    else:
        selected = [m for m in data if (m.get("capabilities") or {}).get("tool_calling") is not False]
    if not selected:
        raise ValueError("catalog contains no matching models")
    models = [model_definition(m, provider) for m in selected]
    if len({m["id"] for m in models}) != len(models):
        raise ValueError("catalog contains duplicate model IDs")
    return models


def update(config):
    target = Path(config["target"])
    try:
        previous = json.loads(target.read_text()) if target.exists() else {"providers": {}}
    except (OSError, ValueError):
        previous = {"providers": {}}
    old_providers = previous.get("providers") or {}
    providers = {name: value for name, value in old_providers.items() if name not in config["providers"]}
    for name, provider in config["providers"].items():
        key_path = provider["keyFile"]
        if key_path:
            api_key = "!cat " + key_path
        else:
            api_key = provider["apiKey"]
        if not api_key:
            raise ValueError(f"{name}: no API key source configured")
        try:
            models = fetch_models(provider)
        except (OSError, ValueError, KeyError) as error:
            if name not in old_providers or not old_providers[name].get("models"):
                raise RuntimeError(f"{name}: catalog unavailable and no previous models.json") from error
            print(f"{name}: catalog unavailable; keeping last working models", file=sys.stderr)
            models = old_providers[name]["models"]
        providers[name] = {
            "name": provider["name"],
            "baseUrl": provider["baseUrl"],
            "api": provider["api"],
            "apiKey": api_key,
            "compat": {"supportsDeveloperRole": False, "maxTokensField": "max_tokens"} | provider["compat"],
            "models": models,
        }
    target.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".models.json-", dir=target.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump({"providers": providers}, stream, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, 0o600)
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print("prime-agent: refreshed models.json for " + ", ".join(providers))


if __name__ == "__main__":
    update(json.loads(Path(sys.argv[1]).read_text()))
