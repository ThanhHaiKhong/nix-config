#!/usr/bin/env bash

# Script to update CLIProxyAPI config with decrypted API keys from sops-nix

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
SECRETS_FILE="$HOME/.local/share/cliproxyapi-api-keys/secret"
TEMP_CONFIG="/tmp/cliproxyapi-config-with-keys.yaml"

# Check if the secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: Secrets file not found at $SECRETS_FILE"
    echo "Make sure sops-nix has properly decrypted the secrets"
    exit 1
fi

# Create a temporary config file based on the original
cp "$CONFIG_FILE" "$TEMP_CONFIG"

# Remove the existing api-keys section if it exists
sed -i '' '/^api-keys:/,/^\([a-zA-Z][a-zA-Z0-9_-]*:\|---\|$\)/{
  /^api-keys:/!{
    /^[[:space:]]*$/!d
  }
}' "$TEMP_CONFIG"

# Insert the API keys from the sops-nix managed file
# We'll append the api-keys section to the config
cat >> "$TEMP_CONFIG" << 'EOF'

# API Keys (managed by sops-nix)
api-keys:
EOF

# Add each API key from the secrets file
while IFS= read -r key; do
  # Skip empty lines
  if [ -n "$key" ]; then
    echo "  - \"$key\"" >> "$TEMP_CONFIG"
  fi
done < "$SECRETS_FILE"

# Replace the original config file with the updated one
cp "$TEMP_CONFIG" "$CONFIG_FILE"

# Clean up
rm "$TEMP_CONFIG"

echo "CLIProxyAPI config updated with API keys from sops-nix"