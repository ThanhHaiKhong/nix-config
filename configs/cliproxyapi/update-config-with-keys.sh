#!/usr/bin/env bash

# Script to update CLIProxyAPI config with decrypted API keys from sops-nix

CONFIG_WITH_KEYS_FILE="$HOME/.config/cliproxyapi/config-with-keys.yaml"
SECRETS_FILE="$HOME/.local/share/cliproxyapi-api-keys/secret"

# Check if the secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: Secrets file not found at $SECRETS_FILE"
    echo "Make sure sops-nix has properly decrypted the secrets"
    exit 1
fi

# Create a new config file based on the original config
# We'll read the original config and insert the API keys at the right place
ORIGINAL_CONFIG="$HOME/.config/cliproxyapi/config.yaml"

# Copy the original config to the new file
cp "$ORIGINAL_CONFIG" "$CONFIG_WITH_KEYS_FILE"

# Remove the existing api-keys section if it exists
# Use pure bash to remove the api-keys section
# First, find the line number of api-keys
api_keys_line=$(grep -n "^api-keys:" "$CONFIG_WITH_KEYS_FILE" | cut -d: -f1)

if [ -n "$api_keys_line" ]; then
    # Calculate the end of the api-keys section by finding the next top-level key
    total_lines=$(wc -l < "$CONFIG_WITH_KEYS_FILE")
    end_line=$total_lines
    
    # Look for the next top-level key after api-keys
    current_line=$((api_keys_line + 1))
    while [ $current_line -le $total_lines ]; do
        line_content=$(sed -n "${current_line}p" "$CONFIG_WITH_KEYS_FILE")
        # Check if this is a top-level key (starts with non-whitespace character and ends with colon)
        if [[ $line_content =~ ^[a-zA-Z].*: ]]; then
            # This is the next top-level key, so end the deletion here
            end_line=$((current_line - 1))
            break
        fi
        current_line=$((current_line + 1))
    done
    
    # Create a new file without the api-keys section
    sed -n "1,$((api_keys_line-1))p;$((end_line+1)),$ p" "$CONFIG_WITH_KEYS_FILE" > "$CONFIG_WITH_KEYS_FILE.tmp"
    mv "$CONFIG_WITH_KEYS_FILE.tmp" "$CONFIG_WITH_KEYS_FILE"
fi

# Add the API keys section with the decrypted keys
{
    echo "";
    echo "# API Keys (managed by sops-nix)";
    echo "api-keys:";
    
    # Extract and add each API key from the secrets file
    if command -v jq >/dev/null 2>&1; then
        jq -r '.[]' "$SECRETS_FILE" 2>/dev/null | while read -r key; do
            if [ -n "$key" ] && [ "$key" != "null" ]; then
                echo "  - $key";
            fi
        done
    else
        # Fallback to yq if jq is not available
        yq -r '.[]' "$SECRETS_FILE" 2>/dev/null | while read -r key; do
            if [ -n "$key" ] && [ "$key" != "null" ]; then
                echo "  - $key";
            fi
        done
    fi
} >> "$CONFIG_WITH_KEYS_FILE"

echo "CLIProxyAPI config updated with API keys from sops-nix at $CONFIG_WITH_KEYS_FILE"