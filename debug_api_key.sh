#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
ENDPOINT="http://127.0.0.1:8317"

# Get the first API key from the config file for testing
if command -v yq >/dev/null 2>&1; then
    API_KEY=$(yq '.api-keys[0]' "$CONFIG_FILE" 2>/dev/null | tr -d '"')
    echo "Using yq: API_KEY=$API_KEY"
else
    # Fallback to grep and sed to extract the first API key
    API_KEY=$(grep -A 10 "api-keys:" "$CONFIG_FILE" | grep "- " | head -n1 | sed 's/.*"\(.*\)".*/\1/')
    echo "Using grep/sed: API_KEY=$API_KEY"
fi

echo "Testing API endpoint with key..."
curl -v --max-time 5 -H "Authorization: Bearer $API_KEY" "$ENDPOINT/v1/models"
RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo "Success: API endpoint is responding"
else
    echo "Failure: API endpoint is not responding"
fi