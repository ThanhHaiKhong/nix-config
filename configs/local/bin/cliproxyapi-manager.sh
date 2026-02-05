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
  graceful-stop)
    echo "Gracefully stopping CLIProxyAPI..."
    get_config_values
    # Try to send a shutdown signal via API if available
    if curl -sf --max-time 5 -X POST http://$HOST:$PORT/shutdown >/dev/null 2>&1; then
      echo "Shutdown signal sent via API"
    else
      echo "API shutdown endpoint not available, using launchctl"
    fi
    sleep 2
    # Check if process is still running and use launchctl if needed
    if launchctl list | grep -q "$LAUNCHCTL_ID"; then
      launchctl bootout "gui/$(id -u)/$LAUNCHCTL_ID"
    fi
    echo "CLIProxyAPI stopped gracefully"
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
  templates)
    echo "Managing CLIProxyAPI configuration templates..."
    $HOME/.config/cliproxyapi/template-manager.sh "${@:2}"
    ;;
  security-setup)
    echo "Setting up security for CLIProxyAPI..."
    $HOME/.config/cliproxyapi/security-setup.sh
    ;;
  backup)
    echo "Managing CLIProxyAPI backups..."
    $HOME/.config/cliproxyapi/backup-manager.sh "${@:2}"
    ;;
  performance)
    echo "Monitoring CLIProxyAPI performance..."
    $HOME/.config/cliproxyapi/performance-monitor.sh
    ;;
  integration)
    echo "Managing CLIProxyAPI integrations..."
    $HOME/.config/cliproxyapi/integration-manager.sh "${@:2}"
    ;;
  update)
    echo "Managing CLIProxyAPI updates..."
    $HOME/.config/cliproxyapi/enhanced-update-manager.sh "${@:2}"
    ;;
  ensure-ready)
    echo "Ensuring CLIProxyAPI is running and logged in..."
    $HOME/.config/cliproxyapi/ensure-ready.sh
    ;;
  discover)
    echo "Discovering CLIProxyAPI configuration and capabilities..."
    echo "For detailed documentation, see: $HOME/.config/cliproxyapi/README.md"
    echo ""
    echo "=== CLIProxyAPI Discovery ==="
    echo "Service Status:"
    if pgrep -f "cliproxyapi" >/dev/null 2>&1; then
      echo "  Status: Running"
      # Get host and port
      if command -v yq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
        HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null || echo "127.0.0.1")
        PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null || echo "8317")
        echo "  Endpoint: http://$HOST:$PORT"
      fi
    else
      echo "  Status: Not running"
    fi
    echo ""
    echo "Configuration:"
    echo "  Config file: $CONFIG_FILE"
    echo "  Runtime dir: $RUNTIME_DIR"
    echo "  Launchd ID: $LAUNCHCTL_ID"
    echo ""
    echo "Available Commands:"
    echo "  Use 'cliproxyapi-manager' without arguments to see all commands"
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
  health-full)
    echo "Performing comprehensive health check..."
    $HOME/.config/cliproxyapi/health-check.sh
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
  config-full-validate)
    echo "Performing full configuration validation..."
    $HOME/.config/cliproxyapi/validate-config.sh "$CONFIG_FILE"
    ;;
  *)
    echo "Usage: $0 {start|stop|graceful-stop|restart|status|edit-config|templates|security-setup|backup|performance|integration|update|ensure-ready|discover|logs|runtime-info|test|health|health-full|config-validate|config-full-validate}"
    echo "  start              - Start the CLIProxyAPI service"
    echo "  stop               - Stop the CLIProxyAPI service"
    echo "  graceful-stop      - Gracefully stop the CLIProxyAPI service"
    echo "  restart            - Restart the CLIProxyAPI service"
    echo "  status             - Check if CLIProxyAPI is running"
    echo "  edit-config        - Edit the configuration file"
    echo "  templates          - Manage configuration templates"
    echo "  security-setup     - Set up security permissions"
    echo "  backup             - Manage backups and recovery"
    echo "  performance        - Monitor performance metrics"
    echo "  integration        - Manage service integrations"
    echo "  update             - Manage updates and version info"
    echo "  ensure-ready       - Ensure CLIProxyAPI is running and logged in"
    echo "  discover           - Discover configuration and capabilities"
    echo "  logs               - View service logs from system log"
    echo "  runtime-info       - Show information about runtime directory"
    echo "  test               - Test if the service is responding and list available models"
    echo "  health             - Check the health status of the service"
    echo "  health-full        - Perform comprehensive health check"
    echo "  config-validate    - Validate the configuration file syntax and show summary"
    echo "  config-full-validate - Perform comprehensive configuration validation"
    exit 1
    ;;
esac