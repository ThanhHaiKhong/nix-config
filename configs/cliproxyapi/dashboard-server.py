#!/usr/bin/env python3

"""
Simple HTTP server for CLIProxyAPI dashboard
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

def main(port=8080):
    # Change to the dashboard directory
    dashboard_dir = Path(__file__).parent
    os.chdir(dashboard_dir)
    
    print(f"Serving CLIProxyAPI dashboard at http://localhost:{port}")
    print(f"Dashboard directory: {dashboard_dir}")
    print("Press Ctrl+C to stop the server")
    
    # Create the handler
    handler = http.server.SimpleHTTPRequestHandler
    
    # Start the server
    with socketserver.TCPServer(("", port), handler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
            sys.exit(0)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    main(port)