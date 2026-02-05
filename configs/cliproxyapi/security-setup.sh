#!/usr/bin/env bash

# CLIProxyAPI Security Setup Script
# Sets up proper security configurations for CLIProxyAPI

RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"
CONFIG_DIR="$HOME/.config/cliproxyapi"

# Create directories with proper permissions
mkdir -p "$RUNTIME_DIR"
mkdir -p "$CONFIG_DIR"

# Set proper permissions for runtime directory
chmod 700 "$RUNTIME_DIR"  # Only owner can read/write/execute

# Set proper permissions for config directory
chmod 700 "$CONFIG_DIR"   # Only owner can read/write/execute

# If there are authentication files, secure them
AUTH_DIR="$RUNTIME_DIR/auths"
if [ -d "$AUTH_DIR" ]; then
    chmod 700 "$AUTH_DIR"  # Only owner can access auth files
    # Secure any auth files
    find "$AUTH_DIR" -type f -exec chmod 600 {} \;  # Only owner can read/write
fi

# Secure the main config file
CONFIG_FILE="$CONFIG_DIR/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    chmod 600 "$CONFIG_FILE"  # Only owner can read/write config
fi

echo "Security permissions set for CLIProxyAPI directories and files"
echo "Runtime directory: $RUNTIME_DIR (permissions: 700)"
echo "Config directory: $CONFIG_DIR (permissions: 700)"

if [ -d "$AUTH_DIR" ]; then
    echo "Auth directory: $AUTH_DIR (permissions: 700)"
    echo "Auth files: $(find "$AUTH_DIR" -type f | wc -l) files secured (permissions: 600)"
fi

if [ -f "$CONFIG_FILE" ]; then
    echo "Config file: $CONFIG_FILE (permissions: 600)"
fi