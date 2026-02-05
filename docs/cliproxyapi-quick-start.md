# CLIProxyAPI Quick Start Guide

## Overview

This guide provides a quick introduction to getting started with CLIProxyAPI, a proxy server that wraps various AI services (OpenAI, Claude, Qwen, etc.) and presents them as an OpenAI-compatible API service.

## Prerequisites

- macOS system with Nix installed
- Home Manager configured
- Access to the nix-config repository

## Installation

1. Clone the nix-config repository:
   ```bash
   git clone https://github.com/your-username/nix-config.git
   cd nix-config
   ```

2. Build and activate the configuration:
   ```bash
   just
   ```

3. The CLIProxyAPI service will be automatically installed and started.

## Basic Usage

### Check Service Status
```bash
cliproxyapi-manager status
```

### Test the API
```bash
cliproxyapi-manager test
```

### View Available Models
```bash
curl -H "Authorization: Bearer sk-cliproxyapi-1234567890abcdef" http://127.0.0.1:8317/v1/models
```

### Monitor Performance
```bash
cliproxyapi-manager performance
```

## Management Commands

| Command | Description |
|---------|-------------|
| `cliproxyapi-manager start` | Start the service |
| `cliproxyapi-manager stop` | Stop the service |
| `cliproxyapi-manager restart` | Restart the service |
| `cliproxyapi-manager status` | Check service status |
| `cliproxyapi-manager test` | Test API connectivity |
| `cliproxyapi-manager performance` | Monitor performance |
| `cliproxyapi-manager backup` | Manage backups |
| `cliproxyapi-manager logs` | View service logs |

## Configuration

The main configuration file is located at `~/.config/cliproxyapi/config.yaml`. You can edit it with:

```bash
cliproxyapi-manager edit-config
```

## Security

### Set Up Secure API Keys

For enhanced security, use SOPS to encrypt your API keys:

1. Add your API keys to the encrypted secrets file
2. Update the configuration to reference the encrypted values

### Security Hardening

Apply security best practices:

```bash
cliproxyapi-manager harden
```

## Monitoring

### Web Dashboard

Start the web-based monitoring dashboard:

```bash
cliproxyapi-manager dashboard
```

The dashboard will be available at `http://localhost:8080`.

### Performance Monitoring

Monitor performance metrics:

```bash
cliproxyapi-manager performance
```

## Backup and Recovery

### Create a Backup
```bash
cliproxyapi-manager backup create my-backup
```

### List Available Backups
```bash
cliproxyapi-manager backup list
```

### Restore from Backup
```bash
cliproxyapi-manager backup restore my-backup
```

## Troubleshooting

### Service Not Starting
```bash
cliproxyapi-manager logs
cliproxyapi-manager config-validate
```

### API Tests Failing
```bash
cliproxyapi-manager health
cliproxyapi-manager test
```

### Need More Help
```bash
cliproxyapi-manager  # Shows all available commands
```

## Next Steps

1. Customize your configuration in `~/.config/cliproxyapi/config.yaml`
2. Set up secure API keys with SOPS encryption
3. Configure automated backups
4. Explore integration with other services
5. Set up the web dashboard for continuous monitoring

For more detailed information, refer to the [Complete Setup Guide](./cliproxyapi-setup-guide.md).