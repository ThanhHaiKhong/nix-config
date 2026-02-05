#!/usr/bin/env bash

# CLIProxyAPI Backup & Recovery Script
# Manages backups and recovery for CLIProxyAPI

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

BACK_UP_BASE_DIR="$HOME/.local/share/cli-proxy-api/backups"
CONFIG_DIR="$HOME/.config/cliproxyapi"
RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"
LOGS_DIR="$RUNTIME_DIR/logs"

# Create backup directory
mkdir -p "$BACK_UP_BASE_DIR"

ACTION="${1:-list}"
BACKUP_NAME="${2:-$(date +%Y%m%d_%H%M%S)}"
RETENTION_DAYS="${3:-30}"  # Default retention period

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${1:-INFO}] ${2:-}"
}

# Function to check if service is running
is_service_running() {
    if pgrep -f "cliproxyapi.*config" >/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to stop the service
stop_service() {
    log "INFO" "Stopping CLIProxyAPI service..."
    if is_service_running; then
        ~/.local/bin/cliproxyapi-manager graceful-stop 2>/dev/null || true
        # Wait a bit for graceful shutdown
        sleep 5
    fi
    
    # Double check and force stop if needed
    if is_service_running; then
        log "WARN" "Service still running, forcing stop..."
        pkill -f "cliproxyapi.*config" 2>/dev/null || true
        sleep 2
    fi
}

# Function to start the service
start_service() {
    log "INFO" "Starting CLIProxyAPI service..."
    ~/.local/bin/cliproxyapi-manager start
}

case "$ACTION" in
  create)
    TIMESTAMP="$BACKUP_NAME"
    BACKUP_DIR="$BACK_UP_BASE_DIR/backup_$TIMESTAMP"

    # Check if backup already exists
    if [ -d "$BACKUP_DIR" ]; then
        log "ERROR" "Backup '$BACKUP_NAME' already exists"
        exit 1
    fi

    mkdir -p "$BACKUP_DIR"

    # Backup configuration
    if [ -d "$CONFIG_DIR" ]; then
        log "INFO" "Backing up configuration..."
        # Create a temporary copy to avoid file locking issues
        TEMP_CONFIG=$(mktemp -d)
        cp -r "$CONFIG_DIR"/* "$TEMP_CONFIG/" 2>/dev/null || true
        # Exclude any temporary files that might be in use
        find "$TEMP_CONFIG" -name "*tmp*" -delete 2>/dev/null || true
        
        if [ "$(ls -A $TEMP_CONFIG)" ]; then
            cp -r "$TEMP_CONFIG" "$BACKUP_DIR/config"
            log "INFO" "Configuration backed up to $BACKUP_DIR/config"
        fi
        rm -rf "$TEMP_CONFIG"
    fi

    # Backup runtime data (excluding logs and backups)
    if [ -d "$RUNTIME_DIR" ]; then
        log "INFO" "Backing up runtime data..."
        # Create a temporary copy excluding logs and other unnecessary files
        TEMP_RUNTIME=$(mktemp -d)
        cp -r "$RUNTIME_DIR"/* "$TEMP_RUNTIME/" 2>/dev/null || true
        # Exclude logs and backups if they exist
        rm -rf "$TEMP_RUNTIME/logs" 2>/dev/null || true
        rm -rf "$TEMP_RUNTIME/backups" 2>/dev/null || true
        rm -rf "$TEMP_RUNTIME/cache" 2>/dev/null || true  # Exclude cache if present

        if [ "$(ls -A $TEMP_RUNTIME)" ]; then
            cp -r "$TEMP_RUNTIME" "$BACKUP_DIR/runtime"
            log "INFO" "Runtime data backed up to $BACKUP_DIR/runtime"
        fi
        rm -rf "$TEMP_RUNTIME"
    fi

    # Create manifest
    MANIFEST_FILE="$BACKUP_DIR/MANIFEST"
    echo "timestamp: $TIMESTAMP" > "$MANIFEST_FILE"
    echo "created_at: $(date -u)" >> "$MANIFEST_FILE"
    echo "version: $(cliproxyapi --version 2>/dev/null || echo 'unknown')" >> "$MANIFEST_FILE"
    echo "hostname: $(hostname)" >> "$MANIFEST_FILE"
    echo "user: $(whoami)" >> "$MANIFEST_FILE"
    
    # Calculate backup size
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    echo "size: $BACKUP_SIZE" >> "$MANIFEST_FILE"

    log "INFO" "Backup created: $BACKUP_DIR (Size: $BACKUP_SIZE)"
    ;;

  list)
    log "INFO" "Available backups:"
    if [ -d "$BACK_UP_BASE_DIR" ] && [ -n "$(ls -A "$BACK_UP_BASE_DIR" 2>/dev/null || true)" ]; then
      for backup in "$BACK_UP_BASE_DIR"/backup_*; do
        if [ -d "$backup" ]; then
          backup_name=$(basename "$backup")
          if [ -f "$backup/MANIFEST" ]; then
            created_at=$(grep "created_at:" "$backup/MANIFEST" | cut -d':' -f2- | xargs)
            size=$(grep "size:" "$backup/MANIFEST" | cut -d':' -f2- | xargs)
            echo "  - $backup_name (created: $created_at, size: $size)"
          else
            echo "  - $backup_name"
          fi
        fi
      done
    else
      echo "  No backups found"
    fi
    ;;

  restore)
    if [ -z "$BACKUP_NAME" ]; then
      log "ERROR" "Usage: $0 restore <backup-name>"
      echo "Available backups:"
      for backup in "$BACK_UP_BASE_DIR"/backup_*; do
        if [ -d "$backup" ]; then
          echo "  - $(basename "$backup")"
        fi
      done
      exit 1
    fi

    BACKUP_DIR="$BACK_UP_BASE_DIR/backup_$BACKUP_NAME"
    if [ ! -d "$BACKUP_DIR" ]; then
      log "ERROR" "Backup '$BACKUP_NAME' not found"
      exit 1
    fi

    # Confirm before proceeding with restore
    echo "WARNING: This will restore from backup '$BACKUP_NAME'"
    echo "This will stop the CLIProxyAPI service and overwrite current configuration/data."
    read -p "Are you sure you want to continue? (yes/no): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "INFO" "Restore cancelled by user"
        exit 0
    fi

    # Stop the service before restoring
    stop_service

    # Restore configuration
    if [ -d "$BACKUP_DIR/config" ]; then
      log "INFO" "Restoring configuration..."
      # Backup current config before overwriting
      if [ -d "$CONFIG_DIR" ]; then
        CURRENT_BACKUP="$CONFIG_DIR.backup.pre-restore.$(date +%Y%m%d_%H%M%S)"
        log "INFO" "Backing up current config to $CURRENT_BACKUP"
        cp -r "$CONFIG_DIR" "$CURRENT_BACKUP"
      fi
      # Remove old config and restore from backup
      rm -rf "$CONFIG_DIR"
      mkdir -p "$(dirname "$CONFIG_DIR")"
      cp -r "$BACKUP_DIR/config" "$CONFIG_DIR"
      chmod 700 "$CONFIG_DIR"
      # Secure config files
      find "$CONFIG_DIR" -name "*.yaml" -exec chmod 600 {} \;
    fi

    # Restore runtime data
    if [ -d "$BACKUP_DIR/runtime" ]; then
      log "INFO" "Restoring runtime data..."
      # Backup current runtime before overwriting
      if [ -d "$RUNTIME_DIR" ]; then
        CURRENT_BACKUP="$RUNTIME_DIR.backup.pre-restore.$(date +%Y%m%d_%H%M%S)"
        log "INFO" "Backing up current runtime to $CURRENT_BACKUP"
        cp -r "$RUNTIME_DIR" "$CURRENT_BACKUP"
      fi
      # Remove old runtime data and restore from backup
      rm -rf "$RUNTIME_DIR"/*
      cp -r "$BACKUP_DIR/runtime"/* "$RUNTIME_DIR/" 2>/dev/null || true
      chmod 700 "$RUNTIME_DIR"
    fi

    log "INFO" "Restore completed from $BACKUP_DIR"
    log "INFO" "Starting CLIProxyAPI service..."
    start_service
    
    # Verify the service is running
    sleep 5
    if is_service_running; then
        log "INFO" "CLIProxyAPI service is running after restore"
    else
        log "ERROR" "CLIProxyAPI service failed to start after restore"
        exit 1
    fi
    ;;

  info)
    if [ -z "$BACKUP_NAME" ]; then
      log "ERROR" "Usage: $0 info <backup-name>"
      exit 1
    fi

    BACKUP_DIR="$BACK_UP_BASE_DIR/backup_$BACKUP_NAME"
    if [ ! -d "$BACKUP_DIR" ]; then
      log "ERROR" "Backup '$BACKUP_NAME' not found"
      exit 1
    fi

    log "INFO" "Backup Information for: $BACKUP_NAME"
    if [ -f "$BACKUP_DIR/MANIFEST" ]; then
      cat "$BACKUP_DIR/MANIFEST"
    fi

    echo ""
    echo "Contents:"
    if [ -d "$BACKUP_DIR/config" ]; then
      echo "  Config files: $(find "$BACKUP_DIR/config" -name '*.yaml' -o -name '*.json' | wc -l) files"
    fi
    if [ -d "$BACKUP_DIR/runtime" ]; then
      echo "  Runtime data: $(find "$BACKUP_DIR/runtime" -type f | wc -l) files"
      echo "  Runtime dirs: $(find "$BACKUP_DIR/runtime" -type d | wc -l) directories"
    fi
    ;;

  cleanup)
    log "INFO" "Cleaning up backups older than $RETENTION_DAYS days..."
    
    # Find and delete backups older than RETENTION_DAYS
    find "$BACK_UP_BASE_DIR" -maxdepth 1 -type d -name "backup_*" -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null || true
    
    log "INFO" "Cleanup completed. Removed backups older than $RETENTION_DAYS days."
    ;;
    
  verify)
    if [ -z "$BACKUP_NAME" ]; then
      log "ERROR" "Usage: $0 verify <backup-name>"
      exit 1
    fi

    BACKUP_DIR="$BACK_UP_BASE_DIR/backup_$BACKUP_NAME"
    if [ ! -d "$BACKUP_DIR" ]; then
      log "ERROR" "Backup '$BACKUP_NAME' not found"
      exit 1
    fi

    log "INFO" "Verifying backup integrity: $BACKUP_NAME"
    
    # Check if MANIFEST exists
    if [ ! -f "$BACKUP_DIR/MANIFEST" ]; then
        log "ERROR" "MANIFEST file missing in backup"
        exit 1
    fi
    
    # Check if config directory exists and has content
    if [ -d "$BACKUP_DIR/config" ]; then
        config_count=$(find "$BACKUP_DIR/config" -name '*.yaml' -o -name '*.json' | wc -l)
        if [ "$config_count" -eq 0 ]; then
            log "WARN" "No config files found in backup"
        else
            log "INFO" "Found $config_count config files in backup"
        fi
    fi
    
    # Check if runtime directory exists and has content
    if [ -d "$BACKUP_DIR/runtime" ]; then
        runtime_count=$(find "$BACKUP_DIR/runtime" -type f | wc -l)
        if [ "$runtime_count" -eq 0 ]; then
            log "WARN" "No runtime files found in backup"
        else
            log "INFO" "Found $runtime_count runtime files in backup"
        fi
    fi
    
    log "INFO" "Backup verification completed for: $BACKUP_NAME"
    ;;
    
  schedule)
    log "INFO" "Setting up scheduled backups..."
    
    # Create a cron job for daily backups
    # This is a simplified example - in a real system you'd want to be more careful about this
    BACKUP_SCRIPT_PATH="$(realpath "$0")"
    CRON_JOB="0 2 * * * $BACKUP_SCRIPT_PATH create daily-\$(date +\%Y\%m\%d)"
    
    # Check if the cron job already exists
    if crontab -l 2>/dev/null | grep -q "$BACKUP_SCRIPT_PATH"; then
        log "INFO" "Scheduled backup already exists in crontab"
    else
        # Add the cron job
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        log "INFO" "Added daily backup to crontab (runs at 2 AM daily)"
    fi
    
    # Also set up cleanup for old backups (weekly)
    CLEANUP_JOB="0 3 * * 0 $BACKUP_SCRIPT_PATH cleanup 30"
    if ! crontab -l 2>/dev/null | grep -q "cleanup"; then
        (crontab -l 2>/dev/null; echo "$CLEANUP_JOB") | crontab -
        log "INFO" "Added weekly cleanup to crontab (runs Sundays at 3 AM)"
    fi
    ;;
    
  *)
    echo "Usage: $0 {create|list|restore|info|cleanup|verify|schedule} [backup-name] [retention-days]"
    echo "  create    - Create a new backup (uses timestamp if no name provided)"
    echo "  list      - List all available backups"
    echo "  restore   - Restore from a backup"
    echo "  info      - Show information about a specific backup"
    echo "  cleanup   - Remove backups older than specified days (default: 30)"
    echo "  verify    - Verify the integrity of a backup"
    echo "  schedule  - Schedule automatic daily backups via cron"
    exit 1
    ;;
esac