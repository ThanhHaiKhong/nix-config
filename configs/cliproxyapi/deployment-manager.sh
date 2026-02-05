#!/usr/bin/env bash

# CLIProxyAPI Automated Deployment & Rollback System
# Provides automated deployment with rollback capabilities for CLIProxyAPI

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.local/share/cliproxyapi-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DEPLOYMENT_ID="deployment_${TIMESTAMP}"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${1:-INFO}] ${2:-}"
}

# Function to create a backup of current configuration
create_backup() {
    local backup_path="$BACKUP_DIR/$DEPLOYMENT_ID"
    mkdir -p "$backup_path"
    
    log "INFO" "Creating backup at $backup_path"
    
    # Backup config file if it exists
    if [ -f "$HOME/.config/cliproxyapi/config.yaml" ]; then
        cp "$HOME/.config/cliproxyapi/config.yaml" "$backup_path/config.yaml.backup"
        log "INFO" "Backed up config.yaml"
    fi
    
    # Backup launchd plist if it exists
    if [ -f "$HOME/Library/LaunchAgents/local.cliproxyapi.plist" ]; then
        cp "$HOME/Library/LaunchAgents/local.cliproxyapi.plist" "$backup_path/launchd.plist.backup"
        log "INFO" "Backed up launchd.plist"
    fi
    
    # Backup any other important files
    if [ -d "$HOME/.local/share/cli-proxy-api" ]; then
        cp -r "$HOME/.local/share/cli-proxy-api" "$backup_path/runtime-data.backup" 2>/dev/null || true
        log "INFO" "Backed up runtime data"
    fi
    
    echo "$DEPLOYMENT_ID" > "$backup_path/backup.info"
    log "INFO" "Backup completed: $DEPLOYMENT_ID"
}

# Function to rollback to a previous deployment
rollback() {
    local rollback_target="${1:-}"
    
    if [ -z "$rollback_target" ]; then
        # Find the most recent backup
        rollback_target=$(ls -t "$BACKUP_DIR" | head -n1)
        if [ -z "$rollback_target" ]; then
            log "ERROR" "No backups found to rollback to"
            exit 1
        fi
    fi
    
    local backup_path="$BACKUP_DIR/$rollback_target"
    
    if [ ! -d "$backup_path" ]; then
        log "ERROR" "Backup path does not exist: $backup_path"
        exit 1
    fi
    
    log "INFO" "Rolling back to $rollback_target"
    
    # Stop the service before rollback
    log "INFO" "Stopping CLIProxyAPI service"
    ~/.local/bin/cliproxyapi-manager stop 2>/dev/null || true
    
    # Restore config file if backup exists
    if [ -f "$backup_path/config.yaml.backup" ]; then
        mkdir -p "$HOME/.config/cliproxyapi"
        cp "$backup_path/config.yaml.backup" "$HOME/.config/cliproxyapi/config.yaml"
        log "INFO" "Restored config.yaml"
    fi
    
    # Restore launchd plist if backup exists
    if [ -f "$backup_path/launchd.plist.backup" ]; then
        mkdir -p "$HOME/Library/LaunchAgents"
        cp "$backup_path/launchd.plist.backup" "$HOME/Library/LaunchAgents/local.cliproxyapi.plist"
        log "INFO" "Restored launchd.plist"
    fi
    
    # Restore runtime data if backup exists
    if [ -d "$backup_path/runtime-data.backup" ]; then
        mkdir -p "$HOME/.local/share"
        rm -rf "$HOME/.local/share/cli-proxy-api"
        cp -r "$backup_path/runtime-data.backup" "$HOME/.local/share/cli-proxy-api"
        log "INFO" "Restored runtime data"
    fi
    
    # Reload the service
    log "INFO" "Starting CLIProxyAPI service after rollback"
    ~/.local/bin/cliproxyapi-manager start
    
    log "INFO" "Rollback to $rollback_target completed"
}

# Function to deploy new configuration
deploy() {
    local config_source="${1:-}"
    
    if [ -z "$config_source" ]; then
        log "ERROR" "No configuration source provided"
        exit 1
    fi
    
    if [ ! -f "$config_source" ]; then
        log "ERROR" "Configuration source does not exist: $config_source"
        exit 1
    fi
    
    # Create backup before deployment
    local backup_id
    backup_id=$(create_backup)
    
    log "INFO" "Starting deployment from $config_source"
    
    # Stop the service before deploying new config
    log "INFO" "Stopping CLIProxyAPI service"
    ~/.local/bin/cliproxyapi-manager stop 2>/dev/null || true
    
    # Deploy new configuration
    mkdir -p "$HOME/.config/cliproxyapi"
    cp "$config_source" "$HOME/.config/cliproxyapi/config.yaml"
    log "INFO" "Deployed new configuration"
    
    # Validate the configuration
    log "INFO" "Validating configuration"
    if ! ~/.local/bin/cliproxyapi-manager config-validate; then
        log "ERROR" "Configuration validation failed, rolling back..."
        rollback "$backup_id"
        exit 1
    fi
    
    # Start the service with new configuration
    log "INFO" "Starting CLIProxyAPI service with new configuration"
    ~/.local/bin/cliproxyapi-manager start
    
    # Test the service
    log "INFO" "Testing service after deployment"
    if ! ~/.local/bin/cliproxyapi-manager test; then
        log "ERROR" "Service test failed after deployment, rolling back..."
        rollback "$backup_id"
        exit 1
    fi
    
    log "INFO" "Deployment completed successfully"
}

# Function to list available backups
list_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log "INFO" "No backups directory found"
        return 0
    fi
    
    echo "Available backups:"
    ls -lt "$BACKUP_DIR" | awk '{print $9}'
}

# Main execution
case "${1:-help}" in
    deploy)
        if [ $# -ne 2 ]; then
            echo "Usage: $0 deploy <config_file_path>"
            exit 1
        fi
        deploy "$2"
        ;;
    rollback)
        rollback "${2:-}"
        ;;
    list-backups)
        list_backups
        ;;
    create-backup)
        create_backup
        ;;
    *)
        echo "CLIProxyAPI Automated Deployment & Rollback System"
        echo ""
        echo "Usage:"
        echo "  $0 deploy <config_file_path>    - Deploy new configuration with rollback protection"
        echo "  $0 rollback [backup_id]         - Rollback to a previous deployment"
        echo "  $0 list-backups                 - List available backups"
        echo "  $0 create-backup                - Create a backup of current configuration"
        echo ""
        echo "Examples:"
        echo "  $0 deploy /path/to/new-config.yaml"
        echo "  $0 rollback                     # Rolls back to most recent backup"
        echo "  $0 rollback deployment_20231201_120000"
        exit 0
        ;;
esac