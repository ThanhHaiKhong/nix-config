#!/usr/bin/env bash

# Check if CLIProxyAPI is running
if ! pgrep -f "cliproxyapi.*config" >/dev/null; then
    echo "CLIProxyAPI is not running. Starting it now..."
    
    # Start CLIProxyAPI using the management script
    ~/.local/bin/cliproxyapi-manager start
    
    # Wait a moment for the service to start
    sleep 3
    
    # Verify it's running
    if pgrep -f "cliproxyapi.*config" >/dev/null; then
        echo "CLIProxyAPI started successfully."
    else
        echo "Failed to start CLIProxyAPI."
        exit 1
    fi
else
    echo "CLIProxyAPI is already running."
fi

# Now run the original command (Opencode or whatever was called)
exec "$@"