#!/usr/bin/env python3
"""commandcode-proxy: Zero-config OpenAI-compatible proxy for command-code.

Just set your command-code API key in opencode and it works.
The proxy reads it from the Authorization header opencode sends.

Usage:
    python3 commandcode-proxy.py

    # Or specify port:
    python3 commandcode-proxy.py --port 9000

Configure opencode (opencode.json):
    {
      "provider": {
        "command-code": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Command Code",
          "options": { "baseURL": "http://127.0.0.1:8082/v1" },
          "models": {
            "anthropic:claude-sonnet-4-6": { "name": "Claude Sonnet 4.6" },
            "anthropic:claude-opus-4-7": { "name": "Claude Opus 4.7" },
            "openai:gpt-5.5": { "name": "GPT-5.5" }
          }
        }
      }
    }

Then run /connect in opencode, pick "Command Code" or any provider,
and paste your command-code API key. The proxy forwards it automatically.
"""

import json
import os
import sys
import uuid
from http.client import HTTPSConnection
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler

CC_HOST = "api.commandcode.ai"
CC_PATH = "/alpha/generate"
VERSION = "0.28.1"
# All models available through command-code's API.
# Key = model ID sent to /alpha/generate, value = metadata for /v1/models.
MODELS = {
    # Anthropic
    "anthropic:claude-sonnet-4-20250514": {"name": "Claude Sonnet 4 (2025-05-14)", "context": 1_000_000},
    "anthropic:claude-sonnet-4-5-20250929": {"name": "Claude Sonnet 4.5", "context": 1_000_000},
    "anthropic:claude-sonnet-4-6": {"name": "Claude Sonnet 4.6", "context": 1_000_000},
    "anthropic:claude-opus-4-5-20251101": {"name": "Claude Opus 4.5", "context": 1_000_000},
    "anthropic:claude-opus-4-6": {"name": "Claude Opus 4.6", "context": 1_000_000},
    "anthropic:claude-opus-4-7": {"name": "Claude Opus 4.7", "context": 1_000_000},
    "anthropic:claude-haiku-4-5-20251001": {"name": "Claude Haiku 4.5", "context": 200_000},
    # OpenAI
    "openai:gpt-5.3-codex": {"name": "GPT-5.3 Codex", "context": 400_000},
    "openai:gpt-5.4": {"name": "GPT-5.4", "context": 400_000},
    "openai:gpt-5.4-mini": {"name": "GPT-5.4 Mini", "context": 400_000},
    "openai:gpt-5.5": {"name": "GPT-5.5"},
    # Baseten / open-source
    "baseten:moonshotai/Kimi-K2.5": {"name": "Kimi K2.5", "context": 256_000},
    "baseten:moonshotai/Kimi-K2.6": {"name": "Kimi K2.6", "context": 256_000},
    "baseten:zai-org/GLM-5": {"name": "GLM-5", "context": 200_000},
    "baseten:zai-org/GLM-5.1": {"name": "GLM-5.1"},
    "baseten:MiniMaxAI/MiniMax-M2.5": {"name": "MiniMax M2.5", "context": 200_000},
    "baseten:MiniMaxAI/MiniMax-M2.7": {"name": "MiniMax M2.7"},
    "baseten:MiniMaxAI/MiniMax-M3": {"name": "MiniMax M3", "context": 1_000_000},
    "baseten:deepseek/deepseek-v4-pro": {"name": "DeepSeek V4 Pro", "context": 1_000_000},
    "baseten:deepseek/deepseek-v4-flash": {"name": "DeepSeek V4 Flash", "context": 1_000_000},
    "baseten:Qwen/Qwen3.6-Max-Preview": {"name": "Qwen 3.6 Max Preview"},
    "baseten:Qwen/Qwen3.6-Plus": {"name": "Qwen 3.6 Plus"},
    "baseten:Qwen/Qwen3.7-Max": {"name": "Qwen 3.7 Max", "context": 1_000_000},
    "baseten:stepfun/Step-3.5-Flash": {"name": "Step 3.5 Flash", "context": 1_000_000},
    "baseten:xiaomi/mimo-v2.5": {"name": "MiMo V2.5", "context": 1_000_000},
    "baseten:xiaomi/mimo-v2.5-pro": {"name": "MiMo V2.5 Pro", "context": 1_000_000},
    # Google
    "google/gemini-3.5-flash": {"name": "Gemini 3.5 Flash", "context": 1_000_000},
    "google/gemini-3.1-flash-lite": {"name": "Gemini 3.1 Flash Lite", "context": 1_000_000},
}

VERBOSE = False


def log(msg):
    if VERBOSE:
        print(f"[commandcode-proxy] {msg}", file=sys.stderr, flush=True)


def translate_tools(tools):
    """Convert OpenAI tool format → command-code flat format."""
    if not tools:
        return []
    return [
        {
            "type": "function",
            "name": t.get("function", {}).get("name", "unknown"),
            "description": t.get("function", {}).get("description", ""),
            "input_schema": t.get("function", {}).get("parameters", {}),
        }
        for t in tools
    ]


def translate_messages(messages):
    """OpenAI messages → command-code (system as string, flat messages list)."""
    system, result = [], []
    for m in messages:
        role = m.get("role", "")
        if role == "system":
            system.append(m.get("content", ""))
        elif role == "tool":
            result.append({
                "role": "tool",
                "content": [{
                    "type": "tool-result",
                    "toolCallId": m.get("tool_call_id", ""),
                    "toolName": m.get("name", ""),
                    "output": {"type": "text", "value": m.get("content", "")},
                }],
            })
        elif role == "assistant" and m.get("tool_calls"):
            parts = []
            if m.get("content"):
                parts.append({"type": "text", "text": m["content"]})
            for tc in m["tool_calls"]:
                fn = tc.get("function", {})
                args = fn.get("arguments", "{}")
                if isinstance(args, str):
                    try:
                        args = json.loads(args)
                    except Exception:
                        args = {}
                parts.append({
                    "type": "tool-call",
                    "toolCallId": tc.get("id", str(uuid.uuid4())),
                    "toolName": fn.get("name", ""),
                    "input": args,
                })
            result.append({"role": "assistant", "content": parts})
        else:
            result.append({"role": role, "content": m.get("content", "")})
    return "\n\n".join(system) or None, result


def build_request(body):
    """Convert OpenAI chat completion request → command-code /alpha/generate body."""
    model = body.get("model", "xiaomi/mimo-v2.5")
    # Strip provider prefix — API uses bare IDs like "claude-sonnet-4-6", not "anthropic:claude-sonnet-4-6"
    if ":" in model:
        model = model.split(":", 1)[1]

    # Models not on your plan get mapped to default
    DEFAULT = "xiaomi/mimo-v2.5"
    ALLOWED = {
        "xiaomi/mimo-v2.5", "xiaomi/mimo-v2.5-pro",
        "deepseek/deepseek-v4-pro", "deepseek/deepseek-v4-flash",
        "moonshotai/Kimi-K2.5", "moonshotai/Kimi-K2.6",
        "MiniMaxAI/MiniMax-M2.5", "MiniMaxAI/MiniMax-M2.7",
        "zai-org/GLM-5", "zai-org/GLM-5.1",
        "Qwen/Qwen3.7-Max", "stepfun/Step-3.5-Flash",
        "google/gemini-3.5-flash", "google/gemini-3.1-flash-lite",
        "claude-sonnet-4-6", "claude-opus-4-7",
        "gpt-5.5", "gpt-5.4", "gpt-5.4-mini", "gpt-5.3-codex",
    }
    if model not in ALLOWED:
        log(f"Model '{model}' not in allowed list, mapping to {DEFAULT}")
        model = DEFAULT

    system, messages = translate_messages(body.get("messages", []))

    params = {
        "model": model,
        "messages": messages,
        "tools": translate_tools(body.get("tools")),
        "system": system or "",
        "max_tokens": body.get("max_tokens", 64000),
        "temperature": body.get("temperature", 0.3),
        "stream": True,
    }
    if "reasoning_effort" in body:
        params["reasoning_effort"] = body["reasoning_effort"]

    # Deterministic threadId from first user message — upstream needs stable
    # threadId across multi-turn requests to correlate tool calls ↔ results.
    first_user_content = None
    for m in body.get("messages", []):
        if m.get("role") == "user":
            first_user_content = m.get("content", "")
            break
    if first_user_content:
        raw = first_user_content if isinstance(first_user_content, str) else json.dumps(first_user_content, sort_keys=True)
        threadId = str(uuid.uuid5(uuid.NAMESPACE_DNS, raw))
    else:
        threadId = str(uuid.uuid4())

    return {
        "config": {
            "os": sys.platform,
            "cwd": os.getcwd(),
            "workingDir": os.getcwd(),
            "date": __import__("datetime").datetime.now().strftime("%Y-%m-%d"),
            "environment": f"python/{sys.version.split()[0]} commandcode-proxy/{VERSION}",
            "structure": [],
            "isGitRepo": False,
            "currentBranch": "",
            "mainBranch": "",
            "gitStatus": "",
            "recentCommits": [],
        },
        "memory": "",
        "taste": "",
        "skills": "",
        "mode": "agent",
        "params": params,
        "threadId": threadId,
    }


def sse_to_openai(line, tool_ctx):
    """Convert one command-code JSONL line → list of OpenAI SSE data strings.
    tool_ctx = [current_index] — mutable list to track tool call indices."""
    try:
        ev = json.loads(line)
    except json.JSONDecodeError:
        return []

    t = ev.get("type", "")
    cid = f"chatcmpl-{uuid.uuid4().hex[:24]}"

    if t == "text-delta":
        text = ev.get("text", "")
        if not text:
            return []
        return [json.dumps({
            "id": cid, "object": "chat.completion.chunk",
            "choices": [{"index": 0, "delta": {"content": text}, "finish_reason": None}],
        })]

    if t == "reasoning-delta":
        text = ev.get("text", "")
        if not text:
            return []
        return [json.dumps({
            "id": cid, "object": "chat.completion.chunk",
            "choices": [{"index": 0, "delta": {"reasoning_content": text}, "finish_reason": None}],
        })]

    if t == "tool-input-start":
        idx = tool_ctx[0]
        tool_ctx[0] += 1
        return [json.dumps({
            "id": cid, "object": "chat.completion.chunk",
            "choices": [{"index": 0, "delta": {"tool_calls": [{
                "index": idx,
                "id": ev.get("id", str(uuid.uuid4())),
                "type": "function",
                "function": {"name": ev.get("toolName", ""), "arguments": ""},
            }]}, "finish_reason": None}],
        })]

    if t == "tool-input-delta":
        text = ev.get("delta", "")
        if not text:
            return []
        return [json.dumps({
            "id": cid, "object": "chat.completion.chunk",
            "choices": [{"index": 0, "delta": {"tool_calls": [{
                "index": tool_ctx[0] - 1,
                "function": {"arguments": text},
            }]}, "finish_reason": None}],
        })]

    if t == "tool-input-end":
        return []

    if t == "tool-call":
        return []

    if t == "finish":
        usage = ev.get("totalUsage", {})
        reason = ev.get("finishReason", "stop")
        if reason == "tool-calls":
            reason = "tool_calls"
        elif reason == "end_turn":
            reason = "stop"
        inp = usage.get("inputTokens", 0)
        out = usage.get("outputTokens", 0)
        return [json.dumps({
            "id": cid, "object": "chat.completion.chunk",
            "choices": [{"index": 0, "delta": {}, "finish_reason": reason}],
            "usage": {"prompt_tokens": inp, "completion_tokens": out, "total_tokens": inp + out},
        })]

    if t == "error":
        err = ev.get("error", {})
        msg = err.get("message", str(err)) if isinstance(err, dict) else str(err)
        return [
            json.dumps({"id": cid, "object": "chat.completion.chunk",
                         "choices": [{"index": 0, "delta": {"content": f"[Error: {msg}]"}, "finish_reason": None}]}),
            json.dumps({"id": cid, "object": "chat.completion.chunk",
                         "choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}]}),
        ]

    return []


def iter_lines(resp):
    """Yield non-empty lines from HTTP response."""
    while True:
        try:
            line = resp.readline()
        except Exception:
            break
        if not line:
            break
        s = line.decode(errors="replace").strip()
        if s:
            yield s


class Handler(BaseHTTPRequestHandler):
    _req_count = 0

    def log_message(self, fmt, *args):
        if VERBOSE:
            super().log_message(fmt, *args)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()

    def do_GET(self):
        if self.path == "/v1/models":
            log(f"GET /v1/models — proxying to upstream")
            try:
                conn = HTTPSConnection("api.commandcode.ai", timeout=15)
                conn.request("GET", "/provider/v1/models",
                             headers={"User-Agent": f"commandcode-proxy/{VERSION}"})
                r1 = conn.getresponse()
                raw = json.loads(r1.read())
                for m in raw.get("data", []):
                    m.pop("created", None)
                body = json.dumps(raw).encode()
                count = len(raw.get("data", []))
                log(f"GET /v1/models — upstream {r1.status}, {count} models")
                self.send_response(r1.status)
                self.send_header("Content-Type", "application/json")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(body)
            except Exception as e:
                print(f"[commandcode-proxy] Error fetching upstream models: {e}")
                # Fall back to hardcoded list
                data = {
                    "object": "list",
                    "data": [
                        {"id": mid, "object": "model", "created": 0, "owned_by": "command-code",
                         "name": info.get("name", mid), "context_window": info.get("context")}
                        for mid, info in MODELS.items()
                    ],
                }
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(data).encode())
        else:
            self.send_error(404)

    def do_POST(self):
        Handler._req_count += 1
        req_id = Handler._req_count
        log(f"[{req_id}] ← POST")
        if self.path != "/v1/chat/completions":
            self.send_error(404)
            return

        body_len = int(self.headers.get("Content-Length", 0))
        try:
            body = json.loads(self.rfile.read(body_len))
        except Exception:
            self.send_error(400, "Invalid JSON")
            return

        # Extract API key from the Authorization header opencode sends
        auth = self.headers.get("Authorization", "")
        api_key = auth.removeprefix("Bearer ").strip() if auth else ""

        msgs = body.get("messages", [])
        log(f"← POST msgs={len(msgs)} model={body.get('model')} tools={len(body.get('tools', []))} key={'yes' if api_key else 'no'}")
        # Show last message role for debugging multi-turn
        if msgs:
            last = msgs[-1]
            role = last.get("role", "?")
            tc = "tool_calls" if last.get("tool_calls") else ""
            tid = last.get("tool_call_id", "")
            log(f"  last msg: role={role} {'tool_calls' if tc else ''} {'tool_call_id='+tid if tid else ''}")

        if not api_key:
            self.send_error(401, "No API key in Authorization header")
            return

        cc_body = build_request(body)
        stream = body.get("stream", True)

        log(f"→ {body.get('model', '?')} stream={stream} tools={len(body.get('tools', []))} msgs={len(body.get('messages', []))}")
        if VERBOSE:
            log(f"  body keys: {list(cc_body.keys())}")
            log(f"  params keys: {list(cc_body.get('params', {}).keys())}")
            log(f"  tools: {json.dumps(cc_body.get('params', {}).get('tools', []), indent=2)[:2000]}")
            log(f"  messages: {json.dumps(cc_body.get('params', {}).get('messages', []), indent=2)[:2000]}")

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
            "x-command-code-version": VERSION,
            "x-cli-environment": "production",
            "x-project-slug": os.path.basename(os.getcwd()),
            "x-taste-learning": "false",
            "x-co-flag": "false",
        }

        try:
            conn = HTTPSConnection(CC_HOST, timeout=120)
            conn.request("POST", CC_PATH, body=json.dumps(cc_body).encode(), headers=headers)
            resp = conn.getresponse()
        except Exception as e:
            self.send_error(502, f"Upstream error: {e}")
            return

        if resp.status != 200:
            err = resp.read().decode(errors="replace")[:1000]
            print(f"[commandcode-proxy] Upstream {resp.status}: {err}")
            self.send_response(resp.status)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": {"message": f"Upstream {resp.status}: {err}", "code": resp.status}}).encode())
            return

        if not stream:
            # Non-streaming: collect and return single response
            content, tool_calls, finish_reason = [], [], "stop"
            usage = {"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0}
            tool_ctx = [0]
            for line in iter_lines(resp):
                for oi in sse_to_openai(line, tool_ctx):
                    c = json.loads(oi)
                    d = c.get("choices", [{}])[0].get("delta", {})
                    if d.get("content"):
                        content.append(d["content"])
                    if d.get("tool_calls"):
                        for tc in d["tool_calls"]:
                            idx = tc.get("index", 0)
                            while len(tool_calls) <= idx:
                                tool_calls.append({"id": "", "type": "function", "function": {"name": "", "arguments": ""}})
                            if tc.get("id"):
                                tool_calls[idx]["id"] = tc["id"]
                            fn = tc.get("function", {})
                            if fn.get("name"):
                                tool_calls[idx]["function"]["name"] = fn["name"]
                            if fn.get("arguments"):
                                tool_calls[idx]["function"]["arguments"] += fn["arguments"]
                    fr = c.get("choices", [{}])[0].get("finish_reason")
                    if fr:
                        finish_reason = fr
                    if "usage" in c:
                        usage = c["usage"]
            msg = {"role": "assistant", "content": "".join(content) or None}
            if tool_calls:
                msg["tool_calls"] = tool_calls
            out = {"id": f"chatcmpl-{uuid.uuid4().hex[:24]}", "object": "chat.completion",
                   "choices": [{"index": 0, "message": msg, "finish_reason": finish_reason}], "usage": usage}
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(out).encode())
            return

        # Streaming
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Connection", "close")
        self.end_headers()

        try:
            tool_ctx = [0]
            for line in iter_lines(resp):
                if VERBOSE:
                    print(f"[commandcode-proxy] RAW: {line[:500]}")
                events = sse_to_openai(line, tool_ctx)
                if VERBOSE:
                    print(f"[commandcode-proxy] SSE→{len(events)} chunks")
                for oi in events:
                    s = f"data: {oi}\n\n"
                    log(f"SSE SEND: {s.rstrip()}")
                    self.wfile.write(s.encode())
                    self.wfile.flush()
            log("SSE SEND: data: [DONE]")
            self.wfile.write(b"data: [DONE]\n\n")
            self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            log("Client disconnected")
        finally:
            conn.close()


def main():
    import argparse
    p = argparse.ArgumentParser(description="commandcode-proxy: OpenAI→command-code proxy")
    p.add_argument("--port", "-p", type=int, default=8082)
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--verbose", "-v", action="store_true")
    args = p.parse_args()

    global VERBOSE
    VERBOSE = args.verbose

    srv = ThreadingHTTPServer((args.host, args.port), Handler)
    srv.allow_reuse_address = True
    print(f"commandcode-proxy v{VERSION} on http://{args.host}:{args.port}")
    print(f"Models: {len(MODELS)} available ({sum(1 for m in MODELS.values() if 'context' in m)} with context limits)")
    print()
    print("opencode config:")
    print(f'  "baseURL": "http://{args.host}:{args.port}/v1"')
    print()
    print("Then /connect in opencode, pick any provider, paste your command-code API key.")
    print("Ctrl+C to stop.\n")

    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\nBye")
        srv.shutdown()


if __name__ == "__main__":
    main()
