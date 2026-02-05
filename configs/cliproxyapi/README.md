# CLIProxyAPI Configuration

This directory contains the configuration files for CLIProxyAPI, a proxy server for various AI model APIs.

## Files

- `config.yaml`: Main configuration file for CLIProxyAPI
- `../local/bin/cliproxyapi-manager.sh`: Management script for controlling the service
- `../local/Library/LaunchAgents/local.cliproxyapi.plist`: Launchd service configuration

## Configuration Details

### Runtime Directory
- **Location**: `~/.local/share/cli-proxy-api`
- **Purpose**: Stores authentication files and runtime data
- **Note**: This directory is automatically created when the service starts

### Logging
- **Method**: System logging (macOS Console.app)
- **Alternative**: Use `log show --predicate 'process == "cliproxyapi"' --last 1h` to view logs

### Service Management
Use the `cliproxyapi-manager` script to control the service:
- `cliproxyapi-manager start` - Start the service
- `cliproxyapi-manager stop` - Stop the service
- `cliproxyapi-manager restart` - Restart the service
- `cliproxyapi-manager status` - Check service status
- `cliproxyapi-manager logs` - View system logs
- `cliproxyapi-manager runtime-info` - Show runtime directory info
- `cliproxyapi-manager test` - Test the service
- `cliproxyapi-manager health` - Check service health
- `cliproxyapi-manager config-validate` - Validate configuration

## Security
- The service binds to localhost only by default (127.0.0.1:8317)
- Authentication is required using API keys defined in the config
- Remote management is disabled by default for security