#!/usr/bin/env bash

# CLIProxyAPI management script

CONFIG_DIR="$HOME/.config/cliproxyapi"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
LAUNCHCTL_ID="local.cliproxyapi"

case "$1" in
  start)
    echo "Starting CLIProxyAPI..."
    launchctl kickstart -k "gui/$(id -u)/$LAUNCHCTL_ID"
    echo "CLIProxyAPI should now be running on http://127.0.0.1:8317"
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
    echo "CLIProxyAPI restarted and should be running on http://127.0.0.1:8317"
    ;;
  status)
    echo "Checking CLIProxyAPI status..."
    if launchctl list | grep -q "$LAUNCHCTL_ID"; then
      echo "CLIProxyAPI is running"
      echo "Access it at: http://127.0.0.1:8317"
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
    echo "Displaying CLIProxyAPI logs..."
    tail -f /tmp/cliproxyapi.log
    ;;
  test)
    echo "Testing CLIProxyAPI connection..."
    if curl -sf http://127.0.0.1:8317/ >/dev/null 2>&1; then
      echo "CLIProxyAPI is accessible at http://127.0.0.1:8317"
    else
      echo "CLIProxyAPI is not responding at http://127.0.0.1:8317"
      echo "Make sure the service is running: cliproxyapi-manager status"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|edit-config|logs|test}"
    echo "  start        - Start the CLIProxyAPI service"
    echo "  stop         - Stop the CLIProxyAPI service"
    echo "  restart      - Restart the CLIProxyAPI service"
    echo "  status       - Check if CLIProxyAPI is running"
    echo "  edit-config  - Edit the configuration file"
    echo "  logs         - View service logs"
    echo "  test         - Test if the service is responding"
    exit 1
    ;;
esac