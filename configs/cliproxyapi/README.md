# CLIProxyAPI Configuration and Management Guide

## Overview
CLIProxyAPI is a proxy server that wraps various AI services (OpenAI, Claude, Qwen, etc.) and presents them as an OpenAI-compatible API service. It allows you to manage multiple API keys, route requests to different providers, and provides features like authentication, rate limiting, and model aliasing.

## Configuration Files
- Main configuration: `~/.config/cliproxyapi/config.yaml`
- Runtime data: `~/.local/share/cli-proxy-api/`
- Service logs: System logs (use macOS Console.app)

## Management Commands
The CLIProxyAPI service can be managed using the `cliproxyapi-manager` script:

### Basic Operations
- `cliproxyapi-manager start` - Start the service
- `cliproxyapi-manager stop` - Stop the service
- `cliproxyapi-manager restart` - Restart the service
- `cliproxyapi-manager status` - Check if the service is running

### Configuration Management
- `cliproxyapi-manager edit-config` - Edit the configuration file
- `cliproxyapi-manager config-validate` - Validate the configuration file syntax
- `cliproxyapi-manager config-full-validate` - Perform comprehensive configuration validation
- `cliproxyapi-manager templates` - Manage configuration templates

### Service Monitoring
- `cliproxyapi-manager test` - Test if the service is responding
- `cliproxyapi-manager health` - Check the health status of the service
- `cliproxyapi-manager health-full` - Perform comprehensive health check
- `cliproxyapi-manager performance` - Monitor performance metrics

### Security & Maintenance
- `cliproxyapi-manager security-setup` - Set up security permissions
- `cliproxyapi-manager backup` - Manage backups and recovery
- `cliproxyapi-manager runtime-info` - Show information about runtime directory

### Integration & Updates
- `cliproxyapi-manager integration` - Manage service integrations
- `cliproxyapi-manager update` - Manage updates and version info

### Logging
- `cliproxyapi-manager logs` - View service logs from system log
- Note: CLIProxyAPI now logs to system log instead of file

## API Endpoints
Once running, CLIProxyAPI provides the following endpoints:
- `/v1/models` - List available models
- `/v1/chat/completions` - Chat completions API
- `/v1/completions` - Completions API
- `/v1/embeddings` - Embeddings API
- `/health` - Health check endpoint

## Configuration Templates
The system includes templates for different environments:
- `development.yaml` - Optimized for development with more verbose logging
- `production.yaml` - Optimized for production with performance-focused settings

## Security Features
- Runtime data stored in `~/.local/share/cli-proxy-api` with proper permissions (700)
- Configuration files secured with proper permissions (600)
- Authentication directory secured with proper permissions (700)
- API keys stored securely in configuration

## Backup and Recovery
- Backups are stored in `~/.local/share/cli-proxy-api/backups/`
- Use `cliproxyapi-manager backup create` to create a backup
- Use `cliproxyapi-manager backup list` to list available backups
- Use `cliproxyapi-manager backup restore <backup-name>` to restore from a backup

## Integration with Opencode
CLIProxyAPI can be integrated with Opencode for unified AI access:
- The integration manager can set up Opencode to use CLIProxyAPI as a backend
- This allows Opencode to access multiple AI services through a single endpoint

## Performance Monitoring
The system includes performance monitoring capabilities:
- Process resource usage (memory, CPU)
- Response time measurement
- Health status checking
- System resource utilization

## Update Management
- Version information can be checked with `cliproxyapi-manager update`
- The binary is managed through the Nix package manager
- Updates are handled by updating the flake.lock in your Nix configuration

## Troubleshooting
If you encounter issues:
1. Check if the service is running: `cliproxyapi-manager status`
2. Validate your configuration: `cliproxyapi-manager config-validate`
3. Check the logs: `cliproxyapi-manager logs`
4. Test the service: `cliproxyapi-manager test`
5. Check the health: `cliproxyapi-manager health`