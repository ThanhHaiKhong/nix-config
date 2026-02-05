#!/usr/bin/env bash

# Enhanced CLIProxyAPI Pre-check Script for Opencode
# This script ensures CLIProxyAPI is running and logged in before running Opencode

echo "Checking CLIProxyAPI status..."

# Check if CLIProxyAPI is running
if ! pgrep -f "cliproxyapi.*config" >/dev/null; then
    echo "CLIProxyAPI is not running. Starting it now..."

    # Start CLIProxyAPI using the management script
    ~/.local/bin/cliproxyapi-manager start

    # Wait a moment for the service to start
    sleep 5

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

# Wait a moment to ensure the service is fully ready
sleep 2

# Check if we need to run login commands
# This is a simplified check - in practice, you might want to check for specific auth files
CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
if command -v yq >/dev/null 2>&1; then
    AUTH_DIR=$(yq '.auth-dir' "$CONFIG_FILE" 2>/dev/null | sed 's|~|'"$HOME"'|')
else
    # Fallback to grep if yq is not available
    AUTH_DIR=$(grep "auth-dir:" "$CONFIG_FILE" | cut -d'"' -f2 | sed 's|~|'"$HOME"'|')
fi

# Check if auth directory exists and has authentication files
if [ ! -d "$AUTH_DIR" ] || [ -z "$(find "$AUTH_DIR" -name "*.json" -o -name "*.txt" 2>/dev/null)" ]; then
    echo "Authentication files not found. Running login commands..."

    # Run login commands to ensure services are authenticated
    echo "Running Qwen login..."
    cliproxyapi --config ~/.config/cliproxyapi/config.yaml -qwen-login 2>/dev/null || echo "Qwen login completed or not needed"

    # Add other login commands as needed
    # cliproxyapi --config ~/.config/cliproxyapi/config.yaml -claude-login
    # cliproxyapi --config ~/.config/cliproxyapi/config.yaml -login  # Google

    echo "Login commands completed."
else
    echo "Authentication files found. Skipping login."
fi

# Test API connectivity before launching Opencode
echo "Testing API connectivity..."
if command -v curl >/dev/null 2>&1; then
    if ! curl -sf --max-time 10 http://127.0.0.1:8317/v1/models >/dev/null 2>&1; then
        echo "Warning: CLIProxyAPI is running but API endpoint is not responding."
        echo "This may cause issues with Opencode."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo "API connectivity verified."
    fi
else
    echo "Warning: curl not found, skipping API connectivity test."
fi

# Now run the original opencode command with all its arguments
echo "Starting Opencode..."
exec command /etc/profiles/per-user/thanhhaikhong/bin/opencode "$@"