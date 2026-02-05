#!/usr/bin/env bash

# Script to update CLIProxyAPI config with decrypted API keys from sops

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
TEMP_CONFIG="/tmp/cliproxyapi-config-with-keys.yaml"

# Create a temporary config file based on the original
cp "$CONFIG_FILE" "$TEMP_CONFIG"

# Insert the API keys from the sops-managed file
# We'll append the api-keys section to the config
cat >> "$TEMP_CONFIG" << 'EOF'

# API Keys (managed by sops-nix)
api-keys:
EOF

# Add each API key from the secrets file
while IFS= read -r key; do
  echo "  - \"$key\"" >> "$TEMP_CONFIG"
done < <(yq '.apiKeys[]' "$HOME/.config/cliproxyapi/api-keys.json" 2>/dev/null || echo "")

# Replace the original config file with the updated one
cp "$TEMP_CONFIG" "$CONFIG_FILE"

# Clean up
rm "$TEMP_CONFIG"

echo "CLIProxyAPI config updated with API keys from sops"