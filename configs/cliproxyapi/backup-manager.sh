#!/usr/bin/env bash

# CLIProxyAPI Backup & Recovery Script
# Manages backups and recovery for CLIProxyAPI

BACKUP_BASE_DIR="$HOME/.local/share/cli-proxy-api/backups"
CONFIG_DIR="$HOME/.config/cliproxyapi"
RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"

# Create backup directory
mkdir -p "$BACKUP_BASE_DIR"

ACTION="${1:-list}"
BACKUP_NAME="${2:-$(date +%Y%m%d_%H%M%S)}"

case "$ACTION" in
  create)
    TIMESTAMP="$BACKUP_NAME"
    BACKUP_DIR="$BACKUP_BASE_DIR/backup_$TIMESTAMP"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup configuration
    if [ -d "$CONFIG_DIR" ]; then
      cp -r "$CONFIG_DIR" "$BACKUP_DIR/config"
      echo "Configuration backed up to $BACKUP_DIR/config"
    fi
    
    # Backup runtime data (excluding logs)
    if [ -d "$RUNTIME_DIR" ]; then
      # Create a temporary copy excluding logs and other unnecessary files
      TEMP_RUNTIME=$(mktemp -d)
      cp -r "$RUNTIME_DIR"/* "$TEMP_RUNTIME/" 2>/dev/null || true
      # Exclude logs if they exist
      rm -rf "$TEMP_RUNTIME/logs" 2>/dev/null || true
      rm -rf "$TEMP_RUNTIME/backups" 2>/dev/null || true
      
      if [ "$(ls -A $TEMP_RUNTIME)" ]; then
        cp -r "$TEMP_RUNTIME" "$BACKUP_DIR/runtime"
        echo "Runtime data backed up to $BACKUP_DIR/runtime"
      fi
      rm -rf "$TEMP_RUNTIME"
    fi
    
    # Create manifest
    echo "timestamp: $TIMESTAMP" > "$BACKUP_DIR/MANIFEST"
    echo "created_at: $(date -u)" >> "$BACKUP_DIR/MANIFEST"
    echo "version: $(cliproxyapi --version 2>/dev/null || echo 'unknown')" >> "$BACKUP_DIR/MANIFEST"
    
    echo "Backup created: $BACKUP_DIR"
    ;;
    
  list)
    echo "Available backups:"
    if [ -d "$BACKUP_BASE_DIR" ] && [ -n "$(ls -A "$BACKUP_BASE_DIR")" ]; then
      for backup in "$BACKUP_BASE_DIR"/backup_*; do
        if [ -d "$backup" ]; then
          backup_name=$(basename "$backup")
          if [ -f "$backup/MANIFEST" ]; then
            created_at=$(grep "created_at:" "$backup/MANIFEST" | cut -d':' -f2-)
            echo "  - $backup_name (created: $created_at)"
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
      echo "Usage: $0 restore <backup-name>"
      echo "Available backups:"
      for backup in "$BACKUP_BASE_DIR"/backup_*; do
        if [ -d "$backup" ]; then
          echo "  - $(basename "$backup")"
        fi
      done
      exit 1
    fi
    
    BACKUP_DIR="$BACKUP_BASE_DIR/backup_$BACKUP_NAME"
    if [ ! -d "$BACKUP_DIR" ]; then
      echo "ERROR: Backup '$BACKUP_NAME' not found"
      exit 1
    fi
    
    # Stop the service before restoring
    echo "Stopping CLIProxyAPI service..."
    launchctl bootout "gui/$(id -u)/local.cliproxyapi" 2>/dev/null || true
    
    # Restore configuration
    if [ -d "$BACKUP_DIR/config" ]; then
      echo "Restoring configuration..."
      # Backup current config before overwriting
      if [ -d "$CONFIG_DIR" ]; then
        cp -r "$CONFIG_DIR" "$CONFIG_DIR.backup.pre-restore.$(date +%Y%m%d_%H%M%S)"
      fi
      rm -rf "$CONFIG_DIR"
      cp -r "$BACKUP_DIR/config" "$CONFIG_DIR"
      chmod 700 "$CONFIG_DIR"
      # Secure config files
      find "$CONFIG_DIR" -name "*.yaml" -exec chmod 600 {} \;
    fi
    
    # Restore runtime data
    if [ -d "$BACKUP_DIR/runtime" ]; then
      echo "Restoring runtime data..."
      # Backup current runtime before overwriting
      if [ -d "$RUNTIME_DIR" ]; then
        cp -r "$RUNTIME_DIR" "$RUNTIME_DIR.backup.pre-restore.$(date +%Y%m%d_%H%M%S)"
      fi
      rm -rf "$RUNTIME_DIR"/*
      cp -r "$BACKUP_DIR/runtime"/* "$RUNTIME_DIR/" 2>/dev/null || true
      chmod 700 "$RUNTIME_DIR"
    fi
    
    echo "Restore completed from $BACKUP_DIR"
    echo "Please restart the CLIProxyAPI service to apply changes"
    ;;
    
  info)
    if [ -z "$BACKUP_NAME" ]; then
      echo "Usage: $0 info <backup-name>"
      exit 1
    fi
    
    BACKUP_DIR="$BACKUP_BASE_DIR/backup_$BACKUP_NAME"
    if [ ! -d "$BACKUP_DIR" ]; then
      echo "ERROR: Backup '$BACKUP_NAME' not found"
      exit 1
    fi
    
    echo "Backup Information for: $BACKUP_NAME"
    if [ -f "$BACKUP_DIR/MANIFEST" ]; then
      cat "$BACKUP_DIR/MANIFEST"
    fi
    
    echo ""
    echo "Contents:"
    if [ -d "$BACKUP_DIR/config" ]; then
      echo "  Config files: $(find "$BACKUP_DIR/config" -name '*.yaml' | wc -l) YAML files"
    fi
    if [ -d "$BACKUP_DIR/runtime" ]; then
      echo "  Runtime data: $(find "$BACKUP_DIR/runtime" -type f | wc -l) files"
    fi
    ;;
    
  *)
    echo "Usage: $0 {create|list|restore|info} [backup-name]"
    echo "  create  - Create a new backup (uses timestamp if no name provided)"
    echo "  list    - List all available backups"
    echo "  restore - Restore from a backup"
    echo "  info    - Show information about a specific backup"
    exit 1
    ;;
esac