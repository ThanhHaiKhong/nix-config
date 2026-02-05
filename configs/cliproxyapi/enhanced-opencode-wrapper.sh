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
CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
if command -v yq >/dev/null 2>&1; then
    AUTH_DIR=$(yq '.auth-dir' "$CONFIG_FILE" 2>/dev/null | sed 's|~|'"$HOME"'|')
else
    # Fallback to grep if yq is not available
    AUTH_DIR=$(grep "auth-dir:" "$CONFIG_FILE" | cut -d'"' -f2 | sed 's|~|'"$HOME"'|')
fi

# Check if Qwen authentication is needed by looking for Qwen auth files
QWEN_AUTH_FILE=""
if [ -d "$AUTH_DIR" ]; then
    # Look for Qwen-specific auth files (they usually contain 'qwen' or 'code' in the name)
    QWEN_AUTH_FILE=$(find "$AUTH_DIR" -name "*qwen*" -o -name "*code*" -o -name "*ThanhHaiKhong*" 2>/dev/null | head -n1)
fi

if [ -z "$QWEN_AUTH_FILE" ] || [ ! -f "$QWEN_AUTH_FILE" ]; then
    echo "Qwen authentication not found. Running Qwen login..."

    # Run Qwen login command
    if command -v cliproxyapi >/dev/null 2>&1; then
        # Run the login command - this will open a browser for authentication
        echo "Opening browser for Qwen authentication..."
        cliproxyapi --config ~/.config/cliproxyapi/config.yaml -qwen-login

        # Wait a bit for the authentication to complete
        echo "Please complete the authentication in the browser."
        echo "Waiting for authentication file to appear..."

        # Poll for the auth file to appear (wait up to 2 minutes)
        COUNT=0
        MAX_COUNT=24  # 2 minutes with 5-second intervals
        while [ $COUNT -lt $MAX_COUNT ]; do
            # Look for Qwen auth file again
            QWEN_AUTH_FILE=$(find "$AUTH_DIR" -name "*qwen*" -o -name "*code*" -o -name "*ThanhHaiKhong*" 2>/dev/null | head -n1)
            if [ -n "$QWEN_AUTH_FILE" ] && [ -f "$QWEN_AUTH_FILE" ]; then
                echo "Qwen authentication file found: $(basename "$QWEN_AUTH_FILE")"
                break
            fi
            sleep 5
            COUNT=$((COUNT + 1))
            echo "Still waiting... ($COUNT/24)"
        done

        if [ $COUNT -ge $MAX_COUNT ]; then
            echo "Warning: Timed out waiting for Qwen authentication. Continuing anyway."
        fi
    else
        echo "cliproxyapi command not found, skipping login."
    fi
else
    echo "Qwen authentication appears to be set up. Skipping login."
fi

# Test API connectivity before launching Opencode
echo "Testing API connectivity..."
if command -v curl >/dev/null 2>&1; then
    # Get the API key for authentication
    if command -v yq >/dev/null 2>&1; then
        API_KEY=$(yq '.["api-keys"][0]' "$CONFIG_FILE" 2>/dev/null | tr -d '"')
    else
        API_KEY=$(grep -A 10 "api-keys:" "$CONFIG_FILE" | grep "- " | head -n1 | sed 's/.*"\(.*\)".*/\1/')
    fi

    if ! curl -sf --max-time 10 -H "Authorization: Bearer $API_KEY" http://127.0.0.1:8317/v1/models >/dev/null 2>&1; then
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