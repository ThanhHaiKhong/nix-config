#!/usr/bin/env bash

# CLIProxyAPI Update Manager
# Manages updates and version management for CLIProxyAPI

ACTION="${1:-check}"
VERSION="${2:-latest}"

# Get current version from the binary
CURRENT_VERSION=$(cliproxyapi --version 2>/dev/null | head -n1 | cut -d' ' -f3-)

case "$ACTION" in
  check)
    echo "Checking for CLIProxyAPI updates..."
    echo "Current version: ${CURRENT_VERSION:-unknown}"
    
    # Check the latest version from GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/router-for-me/CLIProxyAPI/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -n "$LATEST_VERSION" ]; then
      echo "Latest version: $LATEST_VERSION"
      
      if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo "✓ You are running the latest version"
      else
        echo "⚠ New version available: $LATEST_VERSION"
        echo ""
        echo "To update, you'll need to update your Nix configuration."
        echo "The binary is managed through your Nix flake configuration."
      fi
    else
      echo "✗ Could not check for updates. Please check your internet connection."
    fi
    ;;
    
  info)
    echo "=== CLIProxyAPI Version Information ==="
    echo "Current version: ${CURRENT_VERSION:-unknown}"
    echo "Binary location: $(which cliproxyapi 2>/dev/null || echo 'Not found in PATH')"
    echo "Configuration: $HOME/.config/cliproxyapi/config.yaml"
    echo "Runtime data: $HOME/.local/share/cli-proxy-api"
    echo ""
    
    # Show recent releases
    echo "Recent releases:"
    curl -s https://api.github.com/repos/router-for-me/CLIProxyAPI/releases | \
      grep '"tag_name":' | \
      head -n 5 | \
      sed 's/^[[:space:]]*//' | \
      sed 's/^"tag_name": "//' | \
      sed 's/",$//'
    ;;
    
  status)
    echo "=== CLIProxyAPI Update Status ==="
    echo "Version: ${CURRENT_VERSION:-unknown}"
    echo "Managed by: Nix package manager"
    echo "Update method: Update flake.lock in your Nix configuration"
    echo ""
    
    # Check if service is running
    if pgrep -f "cliproxyapi" >/dev/null 2>&1; then
      echo "Status: ✓ Running"
    else
      echo "Status: ✗ Not running"
    fi
    
    # Check if config is valid
    if [ -f "$HOME/.config/cliproxyapi/config.yaml" ]; then
      if command -v yq >/dev/null 2>&1; then
        if yq '.' "$HOME/.config/cliproxyapi/config.yaml" >/dev/null 2>&1; then
          echo "Config: ✓ Valid"
        else
          echo "Config: ✗ Invalid YAML"
        fi
      else
        echo "Config: ✓ Exists (validation skipped - yq not found)"
      fi
    else
      echo "Config: ✗ Not found"
    fi
    ;;
    
  *)
    echo "Usage: $0 {check|info|status}"
    echo "  check  - Check for available updates"
    echo "  info   - Show version information"
    echo "  status - Show update status"
    exit 1
    ;;
esac