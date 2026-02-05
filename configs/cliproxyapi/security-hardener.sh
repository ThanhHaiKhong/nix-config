#!/usr/bin/env bash

# CLIProxyAPI Security Hardening Script
# Implements advanced security measures for CLIProxyAPI

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

CONFIG_DIR="$HOME/.config/cliproxyapi"
RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"
LOGS_DIR="$RUNTIME_DIR/logs"
AUTH_DIR="$RUNTIME_DIR/auths"
BACKUP_DIR="$RUNTIME_DIR/backups"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${1:-INFO}] ${2:-}"
}

# Function to check if service is running
is_service_running() {
    if pgrep -f "cliproxyapi" >/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to restart the service
restart_service() {
    log "INFO" "Restarting CLIProxyAPI service to apply security changes..."
    ~/.local/bin/cliproxyapi-manager restart
}

# Function to backup the current config
backup_config() {
    local backup_file="${CONFIG_DIR}/config.yaml.backup.$(date +%Y%m%d_%H%M%S)"
    cp "${CONFIG_DIR}/config.yaml" "$backup_file"
    log "INFO" "Configuration backed up to $backup_file"
}

# Function to check file permissions
check_permissions() {
    local file="$1"
    local expected_perms="$2"
    local desc="$3"
    
    if [ -f "$file" ] || [ -d "$file" ]; then
        local actual_perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%OLp" "$file" 2>/dev/null || echo "unknown")
        if [ "$actual_perms" != "$expected_perms" ]; then
            log "WARN" "$desc has incorrect permissions: $actual_perms (expected: $expected_perms)"
            return 1
        else
            log "INFO" "$desc has correct permissions: $actual_perms"
            return 0
        fi
    else
        log "WARN" "$desc does not exist: $file"
        return 1
    fi
}

# Function to fix file permissions
fix_permissions() {
    local file="$1"
    local perms="$2"
    local desc="$3"
    
    if [ -f "$file" ] || [ -d "$file" ]; then
        chmod "$perms" "$file"
        log "INFO" "Fixed permissions for $desc: $file (set to $perms)"
    else
        log "WARN" "$desc does not exist: $file"
    fi
}

# Function to scan for security vulnerabilities
scan_security_issues() {
    log "INFO" "Scanning for security issues..."
    
    echo "=== Security Scan Results ==="
    
    # Check config file permissions
    check_permissions "${CONFIG_DIR}/config.yaml" "600" "Config file"
    
    # Check config directory permissions
    check_permissions "$CONFIG_DIR" "700" "Config directory"
    
    # Check runtime directory permissions
    check_permissions "$RUNTIME_DIR" "700" "Runtime directory"
    
    # Check auth directory permissions
    if [ -d "$AUTH_DIR" ]; then
        check_permissions "$AUTH_DIR" "700" "Auth directory"
        # Check individual auth files
        for auth_file in "$AUTH_DIR"/*; do
            if [ -f "$auth_file" ]; then
                check_permissions "$auth_file" "600" "Auth file: $auth_file"
            fi
        done
    fi
    
    # Check for sensitive data in logs
    if [ -d "$LOGS_DIR" ]; then
        log "INFO" "Checking logs for sensitive data..."
        local sensitive_found=0
        for log_file in "$LOGS_DIR"/*; do
            if [ -f "$log_file" ]; then
                if grep -E "(api[-_]?key|token|password|secret|bearer)" "$log_file" >/dev/null 2>&1; then
                    log "WARN" "Potential sensitive data found in log: $log_file"
                    sensitive_found=1
                fi
            fi
        done
        if [ $sensitive_found -eq 0 ]; then
            log "INFO" "No sensitive data found in logs"
        fi
    fi
    
    # Check for default API keys
    if grep -E "(sk-cliproxyapi-[a-z0-9]{16})" "${CONFIG_DIR}/config.yaml" >/dev/null 2>&1; then
        log "WARN" "Default API keys detected in config file"
    else
        log "INFO" "No default API keys detected in config file"
    fi
    
    # Check if TLS is enabled
    if grep -E "enable: true" "${CONFIG_DIR}/config.yaml" | grep -q "tls"; then
        log "INFO" "TLS is enabled in configuration"
    else
        log "WARN" "TLS is not enabled in configuration"
    fi
    
    echo ""
}

# Function to apply security hardening
apply_hardening() {
    log "INFO" "Applying security hardening measures..."
    
    # Backup current config
    backup_config
    
    # Fix file permissions
    fix_permissions "${CONFIG_DIR}/config.yaml" "600" "Config file"
    fix_permissions "$CONFIG_DIR" "700" "Config directory"
    fix_permissions "$RUNTIME_DIR" "700" "Runtime directory"
    
    # Fix auth directory permissions if it exists
    if [ -d "$AUTH_DIR" ]; then
        fix_permissions "$AUTH_DIR" "700" "Auth directory"
        # Fix individual auth files
        for auth_file in "$AUTH_DIR"/*; do
            if [ -f "$auth_file" ]; then
                fix_permissions "$auth_file" "600" "Auth file: $auth_file"
            fi
        done
    fi
    
    # Create a temporary config file to apply security settings
    TEMP_CONFIG=$(mktemp)
    cp "${CONFIG_DIR}/config.yaml" "$TEMP_CONFIG"
    
    # Enable request logging to file if not already enabled
    if ! grep -q "logging-to-file: true" "$TEMP_CONFIG"; then
        sed -i.bak 's/logging-to-file: false/logging-to-file: true/' "$TEMP_CONFIG" 2>/dev/null || {
            log "WARN" "Could not enable logging-to-file setting"
        }
    fi
    
    # Update the config file
    cp "$TEMP_CONFIG" "${CONFIG_DIR}/config.yaml"
    rm "$TEMP_CONFIG" "$TEMP_CONFIG.bak" 2>/dev/null || true
    
    log "INFO" "Security hardening measures applied"
}

# Function to generate security report
generate_report() {
    local report_file="/tmp/cliproxyapi-security-report-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "CLIProxyAPI Security Report"
        echo "Generated on: $(date)"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo ""
        
        echo "=== File Permissions ==="
        if [ -d "$CONFIG_DIR" ]; then
            echo "Config directory: $(stat -c "%a %U:%G" "$CONFIG_DIR" 2>/dev/null || stat -f "%OLp %Su:%Sg" "$CONFIG_DIR" 2>/dev/null)"
            echo "Config file: $(stat -c "%a %U:%G" "${CONFIG_DIR}/config.yaml" 2>/dev/null || stat -f "%OLp %Su:%Sg" "${CONFIG_DIR}/config.yaml" 2>/dev/null)"
        fi
        
        if [ -d "$RUNTIME_DIR" ]; then
            echo "Runtime directory: $(stat -c "%a %U:%G" "$RUNTIME_DIR" 2>/dev/null || stat -f "%OLp %Su:%Sg" "$RUNTIME_DIR" 2>/dev/null)"
        fi
        
        if [ -d "$AUTH_DIR" ]; then
            echo "Auth directory: $(stat -c "%a %U:%G" "$AUTH_DIR" 2>/dev/null || stat -f "%OLp %Su:%Sg" "$AUTH_DIR" 2>/dev/null)"
        fi
        
        echo ""
        echo "=== Security Settings ==="
        echo "Remote management allowed: $(grep -E 'allow-remote:' "${CONFIG_DIR}/config.yaml" | awk '{print $2}')"
        echo "TLS enabled: $(grep -E 'enable:' "${CONFIG_DIR}/config.yaml" | grep -A5 -B5 tls | grep enable | awk '{print $2}')"
        echo "Debug mode: $(grep -E 'debug:' "${CONFIG_DIR}/config.yaml" | awk '{print $2}')"
        echo "Request logging to file: $(grep -E 'logging-to-file:' "${CONFIG_DIR}/config.yaml" | awk '{print $2}')"
        
        echo ""
        echo "=== Process Security ==="
        if is_service_running; then
            local pid=$(pgrep -f "cliproxyapi")
            echo "Process ID: $pid"
            echo "Process owner: $(ps -o user= -p $pid 2>/dev/null || echo 'unknown')"
            echo "Process started: $(ps -o lstart= -p $pid 2>/dev/null || echo 'unknown')"
        else
            echo "Process: Not running"
        fi
        
    } > "$report_file"
    
    echo "Security report generated: $report_file"
    cat "$report_file"
}

# Function to audit security events
audit_security_events() {
    log "INFO" "Auditing security events..."
    
    echo "=== Security Audit ==="
    
    # Check for failed authentication attempts in logs (if available)
    if [ -d "$LOGS_DIR" ]; then
        local failed_auth=0
        for log_file in "$LOGS_DIR"/*; do
            if [ -f "$log_file" ]; then
                # Look for common authentication failure indicators
                local count=$(grep -i -E "(auth|authentication|unauthorized|401|403|invalid.*key|missing.*key)" "$log_file" | wc -l)
                if [ "$count" -gt 0 ]; then
                    echo "Found $count potential authentication issues in $log_file"
                    failed_auth=$((failed_auth + count))
                fi
            fi
        done
        echo "Total potential authentication issues found: $failed_auth"
    else
        echo "Logs directory not found, cannot audit authentication events"
    fi
    
    echo ""
}

# Main execution
case "${1:-scan}" in
    scan)
        scan_security_issues
        ;;
    harden)
        scan_security_issues
        echo ""
        read -p "Apply security hardening measures? (yes/no): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apply_hardening
            echo ""
            read -p "Restart service to apply changes? (yes/no): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                restart_service
            else
                echo "Remember to restart the service to apply security changes."
            fi
        else
            echo "Skipping security hardening."
        fi
        ;;
    report)
        generate_report
        ;;
    audit)
        audit_security_events
        ;;
    all)
        scan_security_issues
        generate_report
        audit_security_events
        echo ""
        read -p "Apply security hardening measures? (yes/no): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apply_hardening
            echo ""
            read -p "Restart service to apply changes? (yes/no): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                restart_service
            else
                echo "Remember to restart the service to apply security changes."
            fi
        fi
        ;;
    *)
        echo "CLIProxyAPI Security Hardening Tool"
        echo ""
        echo "Usage:"
        echo "  $0 scan     - Scan for security issues"
        echo "  $0 harden   - Scan and apply security hardening"
        echo "  $0 report   - Generate security report"
        echo "  $0 audit    - Audit security events"
        echo "  $0 all      - Perform all security tasks"
        echo ""
        echo "Examples:"
        echo "  $0          # Run basic security scan"
        echo "  $0 harden   # Scan and harden security"
        exit 0
        ;;
esac