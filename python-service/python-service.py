#!/usr/bin/env python3

import http.server
import socketserver

PORT = 9900  # You can change the port if needed

from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
def run(server_class=ThreadingHTTPServer, handler_class=SimpleHTTPRequestHandler):
    server_address = ('', PORT)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()


if __name__ == "__main__":
    run()    