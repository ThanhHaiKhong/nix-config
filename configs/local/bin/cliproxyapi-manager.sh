#!/usr/bin/env bash

# CLIProxyAPI management script

CONFIG_DIR="$HOME/.config/cliproxyapi"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"
LAUNCHCTL_ID="local.cliproxyapi"
DEFAULT_HOST="127.0.0.1"
DEFAULT_PORT="8317"

# Function to get the actual host and port from config
get_config_values() {
    if command -v yq >/dev/null 2>&1; then
        HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_HOST")
        PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_PORT")
    else
        # Fallback to default values if yq is not available
        HOST="$DEFAULT_HOST"
        PORT="$DEFAULT_PORT"
    fi
}

case "$1" in
  start)
    echo "Starting CLIProxyAPI..."
    launchctl kickstart -k "gui/$(id -u)/$LAUNCHCTL_ID"
    get_config_values
    echo "CLIProxyAPI should now be running on http://$HOST:$PORT"
    ;;
  stop)
    echo "Stopping CLIProxyAPI..."
    launchctl bootout "gui/$(id -u)/$LAUNCHCTL_ID"
    ;;
  restart)
    echo "Restarting CLIProxyAPI..."
    launchctl bootout "gui/$(id -u)/$LAUNCHCTL_ID" 2>/dev/null
    sleep 2
    launchctl kickstart -k "gui/$(id -u)/$LAUNCHCTL_ID"
    get_config_values
    echo "CLIProxyAPI restarted and should be running on http://$HOST:$PORT"
    ;;
  status)
    echo "Checking CLIProxyAPI status..."
    if launchctl list | grep -q "$LAUNCHCTL_ID"; then
      get_config_values
      echo "CLIProxyAPI is running"
      echo "Access it at: http://$HOST:$PORT"
    else
      echo "CLIProxyAPI is not running"
    fi
    ;;
  edit-config)
    echo "Opening CLIProxyAPI configuration file..."
    ${EDITOR:-nano} "$CONFIG_FILE"
    echo "After saving changes, restart the service for changes to take effect: cliproxyapi-manager restart"
    ;;
  logs)
    echo "Displaying CLIProxyAPI logs from system log..."
    echo "Note: CLIProxyAPI now logs to system log instead of file"
    echo "To view logs, use: log show --predicate 'process == \"cliproxyapi\"' --last 1h"
    echo "Or check Console.app for messages from cliproxyapi"
    ;;
  runtime-info)
    echo "CLIProxyAPI Runtime Information:"
    echo "  Runtime directory: $RUNTIME_DIR"
    if [ -d "$RUNTIME_DIR" ]; then
      echo "  Directory exists with $(ls -1 "$RUNTIME_DIR" | wc -l) files"
      du -sh "$RUNTIME_DIR"
    else
      echo "  Directory does not exist yet"
    fi
    ;;
  test)
    echo "Testing CLIProxyAPI connection..."
    get_config_values
    if curl -sf http://$HOST:$PORT/v1/models >/dev/null 2>&1; then
      echo "CLIProxyAPI is accessible at http://$HOST:$PORT"
      echo "Available models:"
      curl -s http://$HOST:$PORT/v1/models | jq -r '.data[].id' 2>/dev/null || echo "(Install 'jq' to see formatted output)"
    else
      echo "CLIProxyAPI is not responding at http://$HOST:$PORT"
      echo "Make sure the service is running: cliproxyapi-manager status"
    fi
    ;;
  health)
    echo "Checking CLIProxyAPI health..."
    get_config_values
    if curl -sf http://$HOST:$PORT/health >/dev/null 2>&1; then
      curl -s http://$HOST:$PORT/health | jq '.' 2>/dev/null || cat <(curl -s http://$HOST:$PORT/health)
    else
      echo "Health check failed. Service may not be running."
    fi
    ;;
  config-validate)
    echo "Validating CLIProxyAPI configuration..."
    if command -v yq >/dev/null 2>&1; then
      if yq '.' "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "Configuration file is valid YAML"
        echo "Current configuration summary:"
        echo "  Host: $(yq '.host' "$CONFIG_FILE" 2>/dev/null || echo "Not set")"
        echo "  Port: $(yq '.port' "$CONFIG_FILE" 2>/dev/null || echo "Not set")"
        echo "  API Keys configured: $(yq '.api-keys | length' "$CONFIG_FILE" 2>/dev/null || echo "0")"
        echo "  Debug mode: $(yq '.debug' "$CONFIG_FILE" 2>/dev/null || echo "false")"
      else
        echo "Configuration file has YAML syntax errors!"
        exit 1
      fi
    else
      echo "yq command not found. Install yq to validate configuration."
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|edit-config|logs|runtime-info|test|health|config-validate}"
    echo "  start            - Start the CLIProxyAPI service"
    echo "  stop             - Stop the CLIProxyAPI service"
    echo "  restart          - Restart the CLIProxyAPI service"
    echo "  status           - Check if CLIProxyAPI is running"
    echo "  edit-config      - Edit the configuration file"
    echo "  logs             - View service logs from system log"
    echo "  runtime-info     - Show information about runtime directory"
    echo "  test             - Test if the service is responding and list available models"
    echo "  health           - Check the health status of the service"
    echo "  config-validate  - Validate the configuration file syntax and show summary"
    exit 1
    ;;
esac