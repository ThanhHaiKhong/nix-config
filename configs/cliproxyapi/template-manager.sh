#!/usr/bin/env bash

# CLIProxyAPI Template Manager
# Manages different configuration templates for CLIProxyAPI

CONFIG_DIR="$HOME/.config/cliproxyapi"
TEMPLATES_DIR="$(dirname "$0")/../templates"  # Go up from bin to config directory

ACTION="${1:-list}"
TEMPLATE_NAME="$2"

case "$ACTION" in
  list)
    echo "Available CLIProxyAPI configuration templates:"
    for template in "$TEMPLATES_DIR"/*.yaml; do
      if [ -f "$template" ]; then
        template_name=$(basename "$template" .yaml)
        echo "  - $template_name"
      fi
    done
    ;;
    
  apply)
    if [ -z "$TEMPLATE_NAME" ]; then
      echo "Usage: $0 apply <template-name>"
      exit 1
    fi
    
    TEMPLATE_FILE="$TEMPLATES_DIR/$TEMPLATE_NAME.yaml"
    if [ ! -f "$TEMPLATE_FILE" ]; then
      echo "ERROR: Template '$TEMPLATE_NAME' not found"
      echo "Available templates:"
      for template in "$TEMPLATES_DIR"/*.yaml; do
        if [ -f "$template" ]; then
          echo "  - $(basename "$template" .yaml)"
        fi
      done
      exit 1
    fi
    
    # Backup current config
    if [ -f "$CONFIG_DIR/config.yaml" ]; then
      cp "$CONFIG_DIR/config.yaml" "$CONFIG_DIR/config.yaml.backup.$(date +%Y%m%d_%H%M%S)"
      echo "Backed up current config to $CONFIG_DIR/config.yaml.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Apply template
    cp "$TEMPLATE_FILE" "$CONFIG_DIR/config.yaml"
    echo "Applied template '$TEMPLATE_NAME' to $CONFIG_DIR/config.yaml"
    echo "Please restart CLIProxyAPI for changes to take effect"
    ;;
    
  create-backup)
    if [ -f "$CONFIG_DIR/config.yaml" ]; then
      BACKUP_NAME="${TEMPLATE_NAME:-$(date +%Y%m%d_%H%M%S)}"
      cp "$CONFIG_DIR/config.yaml" "$CONFIG_DIR/backups/config-$BACKUP_NAME.yaml"
      mkdir -p "$CONFIG_DIR/backups"
      cp "$CONFIG_DIR/config.yaml" "$CONFIG_DIR/backups/config-$BACKUP_NAME.yaml"
      echo "Created backup: $CONFIG_DIR/backups/config-$BACKUP_NAME.yaml"
    else
      echo "ERROR: No configuration file found at $CONFIG_DIR/config.yaml"
      exit 1
    fi
    ;;
    
  *)
    echo "Usage: $0 {list|apply|create-backup} [template-name]"
    echo "  list           - List available templates"
    echo "  apply          - Apply a template by name"
    echo "  create-backup  - Create a backup of current config"
    exit 1
    ;;
esac