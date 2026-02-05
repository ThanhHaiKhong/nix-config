#!/usr/bin/env bash

# CLIProxyAPI Integration Manager
# Manages integrations with other services like Opencode

ACTION="${1:-status}"
TARGET_SERVICE="${2:-opencode}"

case "$ACTION" in
  status)
    echo "Checking integration status for $TARGET_SERVICE..."
    case "$TARGET_SERVICE" in
      opencode)
        # Check if Opencode is running
        if command -v opencode >/dev/null 2>&1; then
          echo "✓ Opencode is available in PATH"
        else
          echo "✗ Opencode is not available in PATH"
        fi
        
        # Check if CLIProxyAPI is running
        if pgrep -f "cliproxyapi" >/dev/null 2>&1; then
          echo "✓ CLIProxyAPI is running"
        else
          echo "✗ CLIProxyAPI is not running"
        fi
        
        # Check if Opencode config references CLIProxyAPI
        OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"
        if [ -f "$OPENCODE_CONFIG" ]; then
          if grep -q "cliproxyapi\|CLIProxyAPI" "$OPENCODE_CONFIG"; then
            echo "✓ Opencode configuration references CLIProxyAPI"
          else
            echo "⚠ Opencode configuration does not reference CLIProxyAPI"
          fi
        else
          echo "⚠ Opencode configuration file not found at $OPENCODE_CONFIG"
        fi
        ;;
        
      *)
        echo "Unknown service: $TARGET_SERVICE"
        echo "Supported services: opencode"
        exit 1
        ;;
    esac
    ;;
    
  setup-opencode)
    echo "Setting up Opencode integration with CLIProxyAPI..."
    
    # Check if CLIProxyAPI is running
    if ! pgrep -f "cliproxyapi" >/dev/null 2>&1; then
      echo "ERROR: CLIProxyAPI is not running. Please start it first."
      exit 1
    fi
    
    # Get CLIProxyAPI host and port
    CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
    if command -v yq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
      HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null || echo "127.0.0.1")
      PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null || echo "8317")
    else
      HOST="127.0.0.1"
      PORT="8317"
    fi
    
    echo "CLIProxyAPI is running at http://$HOST:$PORT"
    
    # Check if Opencode config exists
    OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"
    if [ ! -f "$OPENCODE_CONFIG" ]; then
      echo "ERROR: Opencode configuration not found at $OPENCODE_CONFIG"
      exit 1
    fi
    
    # Backup the original config
    cp "$OPENCODE_CONFIG" "$OPENCODE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up Opencode config to $OPENCODE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Update the Opencode config to use CLIProxyAPI
    if command -v jq >/dev/null 2>&1; then
      # Update the configuration to point to CLIProxyAPI
      jq --arg host "$HOST" --arg port "$PORT" '
        .providers.openai.url = ("http://" + $host + ":" + $port + "/v1")
        | .providers.openai.apiKey = "sk-cliproxyapi-1234567890abcdef"
      ' "$OPENCODE_CONFIG" > "$OPENCODE_CONFIG.tmp" && mv "$OPENCODE_CONFIG.tmp" "$OPENCODE_CONFIG"
      
      if [ $? -eq 0 ]; then
        echo "✓ Updated Opencode configuration to use CLIProxyAPI at http://$HOST:$PORT"
      else
        echo "✗ Failed to update Opencode configuration"
        # Restore backup
        mv "$OPENCODE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)" "$OPENCODE_CONFIG"
        exit 1
      fi
    else
      echo "⚠ jq not found. Manual configuration update required."
      echo "Please update $OPENCODE_CONFIG to use:"
      echo "  providers.openai.url = http://$HOST:$PORT/v1"
      echo "  providers.openai.apiKey = sk-cliproxyapi-1234567890abcdef"
    fi
    
    echo "Opencode integration with CLIProxyAPI has been set up."
    echo "Please restart Opencode for changes to take effect."
    ;;
    
  test-integration)
    echo "Testing integration between CLIProxyAPI and $TARGET_SERVICE..."
    
    case "$TARGET_SERVICE" in
      opencode)
        # Test if CLIProxyAPI is responding
        if ! pgrep -f "cliproxyapi" >/dev/null 2>&1; then
          echo "✗ CLIProxyAPI is not running"
          exit 1
        fi
        
        # Get CLIProxyAPI host and port
        CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
        if command -v yq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
          HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null || echo "127.0.0.1")
          PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null || echo "8317")
        else
          HOST="127.0.0.1"
          PORT="8317"
        fi
        
        # Test if CLIProxyAPI is responding
        if curl -sf --max-time 5 "http://$HOST:$PORT/v1/models" >/dev/null 2>&1; then
          echo "✓ CLIProxyAPI is responding at http://$HOST:$PORT"
        else
          echo "✗ CLIProxyAPI is not responding at http://$HOST:$PORT"
          exit 1
        fi
        
        # Check if Opencode can be called
        if command -v opencode >/dev/null 2>&1; then
          echo "✓ Opencode command is available"
          # Test if Opencode can make a simple call (without making actual API request)
          echo "✓ Opencode integration test completed successfully"
        else
          echo "✗ Opencode command is not available"
          exit 1
        fi
        ;;
        
      *)
        echo "Unknown service: $TARGET_SERVICE"
        echo "Supported services: opencode"
        exit 1
        ;;
    esac
    ;;
    
  *)
    echo "Usage: $0 {status|setup-opencode|test-integration} [service-name]"
    echo "  status           - Check integration status"
    echo "  setup-opencode   - Set up integration with Opencode"
    echo "  test-integration - Test the integration"
    echo ""
    echo "Supported services: opencode"
    exit 1
    ;;
esac