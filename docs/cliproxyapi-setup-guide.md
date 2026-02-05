# CLIProxyAPI Comprehensive Setup Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Management Commands](#management-commands)
6. [Security](#security)
7. [Performance Tuning](#performance-tuning)
8. [Monitoring & Dashboard](#monitoring--dashboard)
9. [Backup & Recovery](#backup--recovery)
10. [Troubleshooting](#troubleshooting)
11. [Advanced Topics](#advanced-topics)

## Overview

CLIProxyAPI is a proxy server that wraps various AI services (OpenAI, Claude, Qwen, etc.) and presents them as an OpenAI-compatible API service. It allows you to manage multiple API keys, route requests to different providers, and provides features like authentication, rate limiting, and model aliasing.

This guide covers the complete setup, configuration, and management of CLIProxyAPI using the enhanced configuration system.

## Prerequisites

Before installing CLIProxyAPI, ensure your system meets the following requirements:

- macOS (Darwin) system
- Nix package manager installed
- Home Manager configured
- At least 2GB of free disk space
- At least 1GB of RAM available

## Installation

The CLIProxyAPI is managed through the nix-config repository. To install:

1. Clone the nix-config repository:
   ```bash
   git clone https://github.com/your-username/nix-config.git
   cd nix-config
   ```

2. Build and activate the configuration:
   ```bash
   just switch [hostname]
   ```
   
   Or for the default configuration:
   ```bash
   just
   ```

3. The CLIProxyAPI service will be automatically installed and started.

## Configuration

### Basic Configuration

The main configuration file is located at `~/.config/cliproxyapi/config.yaml`. This file contains all the settings for the CLIProxyAPI service.

Key configuration options include:
- `host`: The IP address to bind to (default: 127.0.0.1)
- `port`: The port to listen on (default: 8317)
- `api-keys`: List of API keys for authenticating requests
- `auth-dir`: Directory for storing authentication files
- `debug`: Enable debug logging (default: false)

### Secure Configuration with SOPS

For enhanced security, API keys should be managed using SOPS (Secrets OPerationS). The configuration supports encrypted secrets that are decrypted at runtime.

To set up SOPS encryption:
1. Generate an age key:
   ```bash
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. Add your API keys to the encrypted secrets file
3. Update the configuration to reference the encrypted values

## Management Commands

The CLIProxyAPI provides a comprehensive management interface through the `cliproxyapi-manager` command.

### Basic Service Management

- `cliproxyapi-manager start` - Start the service
- `cliproxyapi-manager stop` - Stop the service
- `cliproxyapi-manager restart` - Restart the service
- `cliproxyapi-manager status` - Check if the service is running
- `cliproxyapi-manager graceful-stop` - Gracefully stop the service

### Configuration Management

- `cliproxyapi-manager edit-config` - Edit the configuration file
- `cliproxyapi-manager config-validate` - Validate the configuration file syntax
- `cliproxyapi-manager config-full-validate` - Perform comprehensive configuration validation
- `cliproxyapi-manager templates` - Manage configuration templates

### Service Monitoring

- `cliproxyapi-manager test` - Test if the service is responding
- `cliproxyapi-manager health` - Check the health status of the service
- `cliproxyapi-manager performance` - Monitor performance metrics
- `cliproxyapi-manager logs` - View service logs from system log

### Security & Maintenance

- `cliproxyapi-manager security-setup` - Set up security permissions
- `cliproxyapi-manager harden` - Harden security and audit events
- `cliproxyapi-manager backup` - Manage backups and recovery
- `cliproxyapi-manager runtime-info` - Show information about runtime directory

### Integration & Updates

- `cliproxyapi-manager integration` - Manage service integrations
- `cliproxyapi-manager update` - Manage updates and version info
- `cliproxyapi-manager deploy` - Manage deployments and rollbacks
- `cliproxyapi-manager tune` - Tune performance and optimize configuration
- `cliproxyapi-manager dashboard` - Start the web dashboard for monitoring

## Security

### Security Best Practices

1. **API Key Management**: Use SOPS to encrypt API keys and avoid storing them in plain text
2. **File Permissions**: Ensure configuration files have appropriate permissions (600 for config files, 700 for directories)
3. **Network Security**: Bind to localhost (127.0.0.1) only unless external access is required
4. **Regular Audits**: Use the security hardening tools to regularly audit your setup

### Security Hardening

Run the security hardening command to apply security best practices:

```bash
cliproxyapi-manager harden
```

This will:
- Set appropriate file permissions
- Enable security-relevant configuration options
- Generate a security report

### Security Scanning

Scan for security issues with:

```bash
cliproxyapi-manager harden scan
```

## Performance Tuning

### Performance Monitoring

Monitor performance with:

```bash
cliproxyapi-manager performance
```

For different report types:
- `cliproxyapi-manager performance quick` - Quick performance check
- `cliproxyapi-manager performance detailed` - Detailed performance analysis

### Performance Optimization

Tune performance with:

```bash
cliproxyapi-manager tune
```

This will:
- Analyze current performance metrics
- Generate optimization recommendations
- Optionally apply configuration optimizations

Run stress tests with:

```bash
cliproxyapi-manager tune stress-test
```

## Monitoring & Dashboard

### Command Line Monitoring

Use the enhanced monitoring system:

```bash
cliproxyapi-manager performance
```

### Web Dashboard

Start the web-based monitoring dashboard:

```bash
cliproxyapi-manager dashboard [port]
```

The dashboard will be available at `http://localhost:[port]` (default port 8080) and provides:
- Real-time service status
- Performance metrics
- System resource usage
- Recent logs
- Configuration information

### Automated Monitoring

The system includes automated monitoring via launchd. To enable:

```bash
# This is configured automatically in the Nix configuration
```

## Backup & Recovery

### Creating Backups

Create a backup with:

```bash
cliproxyapi-manager backup create [backup-name]
```

If no name is provided, a timestamp will be used.

### Listing Backups

View available backups:

```bash
cliproxyapi-manager backup list
```

### Restoring from Backup

Restore from a backup:

```bash
cliproxyapi-manager backup restore [backup-name]
```

### Backup Verification

Verify a backup's integrity:

```bash
cliproxyapi-manager backup verify [backup-name]
```

### Scheduled Backups

Set up automatic backups:

```bash
cliproxyapi-manager backup schedule
```

This will add cron jobs for daily backups and weekly cleanup of old backups.

## Troubleshooting

### Common Issues

#### Service Won't Start
1. Check if the port is already in use:
   ```bash
   lsof -i :8317
   ```
2. Check the configuration file for syntax errors:
   ```bash
   cliproxyapi-manager config-validate
   ```
3. Check system logs:
   ```bash
   cliproxyapi-manager logs
   ```

#### API Keys Not Working
1. Verify API keys are correctly configured:
   ```bash
   grep -A 5 "api-keys:" ~/.config/cliproxyapi/config.yaml
   ```
2. Check if SOPS decryption is working properly
3. Test with a simple curl command:
   ```bash
   curl -H "Authorization: Bearer YOUR_API_KEY" http://127.0.0.1:8317/v1/models
   ```

#### High Memory Usage
1. Check current memory usage:
   ```bash
   cliproxyapi-manager performance
   ```
2. Enable commercial mode in the configuration to reduce memory overhead
3. Review the number of active models and providers

### Diagnostic Commands

- `cliproxyapi-manager discover` - Discover configuration and capabilities
- `cliproxyapi-manager health-full` - Perform comprehensive health check
- `cliproxyapi-manager config-full-validate` - Perform comprehensive configuration validation
- `cliproxyapi-manager performance detailed` - Detailed performance analysis

### Log Analysis

View system logs for the service:

```bash
cliproxyapi-manager logs
```

## Advanced Topics

### Custom Configuration Templates

Manage configuration templates:

```bash
cliproxyapi-manager templates
```

This allows you to maintain different configurations for different environments.

### Integration with Other Services

The system includes integration with Opencode. The `opencode` command will automatically ensure CLIProxyAPI is running before execution.

### Deployment Management

For advanced users, the system includes deployment and rollback capabilities:

```bash
cliproxyapi-manager deploy create-backup
cliproxyapi-manager deploy list-backups
```

### Performance Tuning

Advanced performance tuning options:

```bash
cliproxyapi-manager tune all
```

This performs a full analysis including stress testing.

### Security Auditing

Perform comprehensive security auditing:

```bash
cliproxyapi-manager harden all
```

This scans, audits, and reports on security posture.

## Support

For support with the CLIProxyAPI configuration:
1. Check the logs using `cliproxyapi-manager logs`
2. Run diagnostics with `cliproxyapi-manager health-full`
3. Consult this documentation
4. If issues persist, create an issue in the nix-config repository

---

**Note**: This documentation reflects the enhanced CLIProxyAPI configuration system. Regular updates to this documentation are recommended to reflect any changes to the system.