# CLIProxyAPI Troubleshooting Guide

## Common Issues and Solutions

### Service Won't Start

**Symptoms:**
- `cliproxyapi-manager status` shows "not running"
- Manual start attempts fail silently

**Solutions:**
1. Check if the port is already in use:
   ```bash
   lsof -i :8317
   ```
   If another process is using the port, either stop that process or change the port in the configuration.

2. Check the configuration file for syntax errors:
   ```bash
   cliproxyapi-manager config-validate
   ```

3. Check system logs for detailed error messages:
   ```bash
   cliproxyapi-manager logs
   ```

4. Try starting manually to see error messages:
   ```bash
   cliproxyapi --config ~/.config/cliproxyapi/config.yaml
   ```

### API Keys Not Working

**Symptoms:**
- API requests return "Invalid API key" or "Missing API key" errors
- Authentication failures

**Solutions:**
1. Verify API keys are correctly configured:
   ```bash
   grep -A 5 "api-keys:" ~/.config/cliproxyapi/config.yaml
   ```

2. Check if you're using the correct API key format in your requests:
   ```bash
   curl -H "Authorization: Bearer sk-cliproxyapi-1234567890abcdef" http://127.0.0.1:8317/v1/models
   ```

3. If using SOPS encryption, verify that secrets are properly decrypted:
   ```bash
   # Check if the runtime directory has decrypted secrets
   ls -la ~/.local/share/cliproxyapi-api-keys/
   ```

4. Test with a simple curl command to isolate the issue.

### High Memory Usage

**Symptoms:**
- Process memory usage exceeds expected levels
- System slowdowns
- Performance degradation

**Solutions:**
1. Check current memory usage:
   ```bash
   cliproxyapi-manager performance
   ```

2. Enable commercial mode in the configuration to reduce memory overhead:
   ```bash
   # Edit the config file
   cliproxyapi-manager edit-config
   # Set commercial-mode: true
   ```

3. Review the number of active models and providers in your configuration.

4. Restart the service to clear any potential memory leaks:
   ```bash
   cliproxyapi-manager restart
   ```

### Slow Response Times

**Symptoms:**
- API requests taking longer than expected
- Timeout errors
- Poor performance

**Solutions:**
1. Check response times with the performance monitor:
   ```bash
   cliproxyapi-manager performance
   ```

2. Verify upstream API provider response times - CLIProxyAPI performance depends on the speed of the underlying services.

3. Check if commercial mode is enabled to reduce overhead:
   ```bash
   grep "commercial-mode:" ~/.config/cliproxyapi/config.yaml
   ```

4. Review payload manipulation settings in the configuration.

5. Check network connectivity and bandwidth.

### Service Keeps Crashing

**Symptoms:**
- Service starts but stops shortly after
- Repeated restart cycles
- Process exits with errors

**Solutions:**
1. Check system logs for crash details:
   ```bash
   cliproxyapi-manager logs
   ```

2. Verify configuration file integrity:
   ```bash
   cliproxyapi-manager config-validate
   ```

3. Check system resources (memory, disk space):
   ```bash
   cliproxyapi-manager performance
   ```

4. Temporarily disable complex features in the configuration to isolate the issue.

5. Check for conflicting processes or services.

### Authentication Issues

**Symptoms:**
- Authentication failures
- Login commands not working
- Missing auth files

**Solutions:**
1. Check if auth directory exists and has proper permissions:
   ```bash
   ls -la ~/.local/share/cli-proxy-api/
   ```

2. Run authentication setup:
   ```bash
   # For Qwen
   cliproxyapi --config ~/.config/cliproxyapi/config.yaml -qwen-login
   ```

3. Verify auth directory permissions:
   ```bash
   chmod 700 ~/.local/share/cli-proxy-api/auths
   ```

4. Check if auth files are properly formatted.

### Backup/Restore Failures

**Symptoms:**
- Backup creation fails
- Restore operations don't complete
- Corrupted backup files

**Solutions:**
1. Check backup integrity:
   ```bash
   cliproxyapi-manager backup verify [backup-name]
   ```

2. Verify sufficient disk space:
   ```bash
   df -h ~/.local/share/cli-proxy-api/backups/
   ```

3. Check file permissions in backup directories.

4. Try creating a fresh backup:
   ```bash
   cliproxyapi-manager backup create new-backup-$(date +%Y%m%d_%H%M%S)
   ```

## Diagnostic Commands

Use these commands to gather information about the system:

### Health Checks
```bash
cliproxyapi-manager health
cliproxyapi-manager health-full
```

### Configuration Validation
```bash
cliproxyapi-manager config-validate
cliproxyapi-manager config-full-validate
```

### Performance Analysis
```bash
cliproxyapi-manager performance
cliproxyapi-manager performance detailed
```

### Log Inspection
```bash
cliproxyapi-manager logs
```

### System Status
```bash
cliproxyapi-manager discover
```

## Advanced Troubleshooting

### Debug Mode

Enable debug mode in the configuration file to get more detailed logs:

1. Edit the configuration:
   ```bash
   cliproxyapi-manager edit-config
   ```

2. Set `debug: true` in the config file

3. Restart the service:
   ```bash
   cliproxyapi-manager restart
   ```

4. Reproduce the issue and check logs

### Process Analysis

Analyze the running process:

```bash
# Get the process ID
pgrep -f cliproxyapi

# Check process details
ps -fp $(pgrep -f cliproxyapi)

# Check open files and network connections
lsof -p $(pgrep -f cliproxyapi)
```

### Configuration Reset

If the configuration is severely corrupted:

1. Stop the service:
   ```bash
   cliproxyapi-manager stop
   ```

2. Rename the current config:
   ```bash
   mv ~/.config/cliproxyapi/config.yaml ~/.config/cliproxyapi/config.yaml.corrupted
   ```

3. Restore from a backup or recreate the basic configuration

4. Restart the service

## Getting Help

If you're unable to resolve an issue:

1. Gather diagnostic information using the commands above
2. Check the system logs
3. Review the configuration file
4. Consult the [Setup Guide](./cliproxyapi-setup-guide.md)
5. Create an issue in the nix-config repository with:
   - Detailed description of the problem
   - Steps to reproduce
   - Diagnostic output
   - System information (OS, Nix version, etc.)