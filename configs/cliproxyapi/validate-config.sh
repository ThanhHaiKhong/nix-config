#!/usr/bin/env bash

# CLIProxyAPI Configuration Validator
# Validates the CLIProxyAPI configuration file

CONFIG_FILE="${1:-$HOME/.config/cliproxyapi/config.yaml}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Check if yaml is valid
if command -v yq >/dev/null 2>&1; then
    if ! yq '.' "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "ERROR: Invalid YAML syntax in $CONFIG_FILE"
        exit 1
    elif ! yq 'has("host")' "$CONFIG_FILE" >/dev/null 2>&1 || [ "$(yq 'has("host")' "$CONFIG_FILE")" = "false" ]; then
        echo "ERROR: Missing 'host' field in $CONFIG_FILE"
        exit 1
    elif ! yq 'has("port")' "$CONFIG_FILE" >/dev/null 2>&1 || [ "$(yq 'has("port")' "$CONFIG_FILE")" = "false" ]; then
        echo "ERROR: Missing 'port' field in $CONFIG_FILE"
        exit 1
    else
        echo "SUCCESS: Configuration file is valid"
        echo "Host: $(yq '.host' "$CONFIG_FILE")"
        echo "Port: $(yq '.port' "$CONFIG_FILE")"
        exit 0
    fi
else
    # Fallback to basic validation if yq is not available
    echo "INFO: yq not found, performing basic validation..."
    if grep -q "host:" "$CONFIG_FILE" && grep -q "port:" "$CONFIG_FILE"; then
        echo "SUCCESS: Basic validation passed - host and port fields found"
        host_value=$(grep "^host:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs)
        port_value=$(grep "^port:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs)
        echo "Host: $host_value"
        echo "Port: $port_value"
        exit 0
    else
        echo "ERROR: Missing required fields (host or port) in $CONFIG_FILE"
        exit 1
    fi
fi