import http.server
import socketserver

PORT = 3001

class RedirectHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        target = f"http://localhost:3000{self.path}"
        self.send_response(302)
        self.send_header("Location", target)
        self.end_headers()
        self.wfile.write(f"Redirecting to {target}...".encode())

    def do_POST(self):
        target = f"http://localhost:3000{self.path}"
        self.send_response(307)
        self.send_header("Location", target)
        self.end_headers()

    def do_HEAD(self):
        self.send_response(302)
        self.send_header("Location", f"http://localhost:3000{self.path}")
        self.end_headers()

    def log_message(self, format, *args):
        pass  # Quiet logging

if __name__ == "__main__":
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), RedirectHandler) as httpd:
        print(f"Port 3001 redirector active -> forwards to http://localhost:3000")
        httpd.serve_forever()
