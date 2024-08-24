#!/usr/bin/env python3

import http.server
import socketserver

PORT = 9900  # You can change the port if needed

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()