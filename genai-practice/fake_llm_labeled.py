import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(sys.argv[1])
NAME = sys.argv[2]


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        size = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(size) or b"{}")
        text = body.get("messages", [{}])[-1].get("content", "")
        reply = {
            "id": "fake-" + NAME,
            "object": "chat.completion",
            "created": 0,
            "model": body.get("model", "fake"),
            "choices": [{
                "index": 0,
                "finish_reason": "stop",
                "message": {"role": "assistant", "content": "[" + NAME + "] FAKE reply to: " + text},
            }],
            "usage": {"prompt_tokens": 5, "completion_tokens": 5, "total_tokens": 10},
        }
        data = json.dumps(reply).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *args):
        print("backend " + NAME + " got a request", flush=True)


HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
