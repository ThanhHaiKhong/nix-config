#!/usr/bin/env bash

# CLIProxyAPI Health Check Script
# Performs health checks on the CLIProxyAPI service

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
LOG_FILE="/tmp/cliproxyapi-health-check.log"

# Load configuration values
if command -v yq >/dev/null 2>&1; then
    HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null || echo "127.0.0.1")
    PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null || echo "8317")
else
    # Fallback to grep if yq is not available
    HOST=$(grep "^host:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs)
    PORT=$(grep "^port:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs)
    
    # If values are still empty, use defaults
    HOST=${HOST:-"127.0.0.1"}
    PORT=${PORT:-"8317"}
fi

HEALTH_URL="http://$HOST:$PORT/health"

# Log timestamp
echo "$(date): Checking health at $HEALTH_URL" >> "$LOG_FILE"

# Check if the service is responding
if curl -sf --max-time 10 "$HEALTH_URL" >/dev/null 2>&1; then
    echo "$(date): SUCCESS - CLIProxyAPI is healthy" >> "$LOG_FILE"
    echo "healthy"
    exit 0
else
    # Try the default endpoint as fallback
    DEFAULT_URL="http://$HOST:$PORT/v1/models"
    if curl -sf --max-time 10 "$DEFAULT_URL" >/dev/null 2>&1; then
        echo "$(date): SUCCESS - CLIProxyAPI is responding" >> "$LOG_FILE"
        echo "running"
        exit 0
    else
        echo "$(date): ERROR - CLIProxyAPI is not responding at $HOST:$PORT" >> "$LOG_FILE"
        echo "unhealthy"
        exit 1
    fi
fi