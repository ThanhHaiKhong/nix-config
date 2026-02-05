#!/usr/bin/env bash

# Script to start the CLIProxyAPI dashboard server

DASHBOARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dashboard"
SERVER_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dashboard-server.py"
PORT="${1:-8080}"

echo "Starting CLIProxyAPI dashboard server on port $PORT..."
echo "Dashboard available at: http://localhost:$PORT"
echo "Press Ctrl+C to stop the server"

cd "$DASHBOARD_DIR" && python3 "$SERVER_SCRIPT" "$PORT"