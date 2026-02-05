#!/usr/bin/env bash

# Enhanced CLIProxyAPI Monitoring and Alerting Script
# Provides comprehensive monitoring with alerting capabilities for CLIProxyAPI

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
SERVICE_NAME="local.cliproxyapi"
LOG_FILE="$HOME/.local/share/cli-proxy-api/monitoring.log"
ALERT_EMAIL=""  # Set this to your email if you want email alerts
SLACK_WEBHOOK=""  # Set this to your Slack webhook URL if you want Slack alerts

# Load configuration values
if command -v yq >/dev/null 2>&1; then
    # Use yq to extract values without quotes
    HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null | sed 's/"//g' || echo "127.0.0.1")
    PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null | sed 's/"//g' || echo "8317")
else
    # Fallback to grep if yq is not available
    HOST=$(grep "^host:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs | sed 's/"//g')
    PORT=$(grep "^port:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs | sed 's/"//g')

    # If values are still empty, use defaults
    HOST=${HOST:-"127.0.0.1"}
    PORT=${PORT:-"8317"}
fi

ENDPOINT="http://$HOST:$PORT"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to send alerts
send_alert() {
    local message="$1"
    log_message "ALERT: $message"
    
    # Print to console
    echo "🚨 ALERT: $message"
    
    # Send to Slack if configured
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"CLIProxyAPI Alert: $message\"}" \
            "$SLACK_WEBHOOK" 2>/dev/null
    fi
    
    # Send email if configured
    if [ -n "$ALERT_EMAIL" ]; then
        echo "$message" | mail -s "CLIProxyAPI Alert" "$ALERT_EMAIL" 2>/dev/null
    fi
}

# Check if service is running
if ! pgrep -f "cliproxyapi" >/dev/null 2>&1; then
    send_alert "CLIProxyAPI is not running"
    exit 1
fi

# Log successful check
log_message "Service check: Running"

echo "=== CLIProxyAPI Enhanced Monitoring Report ==="
echo "Timestamp: $(date)"
echo "Endpoint: $ENDPOINT"
echo ""

# Get process information
PID=$(pgrep -f "cliproxyapi" | head -n1)
if [ -n "$PID" ]; then
    echo "--- Process Information ---"
    echo "PID: $PID"

    # Memory usage
    MEM_INFO=$(ps -o pid,rss,vsz,comm -p $PID 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$MEM_INFO" | head -n1
        echo "$MEM_INFO" | tail -n+2 | awk '{printf "Memory: %.2f MB RSS, %.2f MB VSZ\n", $2/1024, $3/1024}'
        
        # Check for high memory usage (alert if over 500MB RSS)
        RSS=$(echo "$MEM_INFO" | tail -n+2 | awk '{print $2}')
        if [ "$RSS" -gt 512000 ]; then  # 500MB in KB
            send_alert "High memory usage detected: $(echo "$RSS/1024" | bc -l 2>/dev/null || echo $RSS) MB RSS"
        fi
    fi

    # CPU usage
    CPU_USAGE=$(ps -o %cpu -p $PID | tail -n+2 | tr -d ' ')
    if [ -n "$CPU_USAGE" ]; then
        echo "CPU Usage: $CPU_USAGE%"
        # Alert if CPU usage is over 80%
        if (( $(echo "$CPU_USAGE > 80" | bc -l 2>/dev/null || echo 0) )); then
            send_alert "High CPU usage detected: ${CPU_USAGE}%"
        fi
    fi
    echo ""
fi

# Test response time
echo "--- Response Time ---"
# Get the first API key from the config file for testing
if command -v yq >/dev/null 2>&1; then
    API_KEY=$(yq '.["api-keys"][0]' "$CONFIG_FILE" 2>/dev/null | tr -d '"')
else
    # Fallback to grep and sed to extract the first API key
    API_KEY=$(grep -A 10 "api-keys:" "$CONFIG_FILE" | grep "- " | head -n1 | sed 's/.*"\(.*\)".*/\1/')
fi

START_TIME=$(date +%s.%N)
if curl -sf --max-time 10 -H "Authorization: Bearer $API_KEY" "$ENDPOINT/v1/models" >/dev/null 2>&1; then
    END_TIME=$(date +%s.%N)
    RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    printf "Response time: %.3f seconds\n" $RESPONSE_TIME

    # Alert if response time is over 5 seconds
    if (( $(echo "$RESPONSE_TIME > 5" | bc -l 2>/dev/null || echo 0) )); then
        send_alert "Slow response time detected: ${RESPONSE_TIME}s"
    fi
else
    send_alert "API endpoint is not responding"
    echo "❌ Could not reach API endpoint for response time test"
    exit 1
fi
echo ""

# Check if health endpoint is available
echo "--- Health Status ---"
if curl -sf --max-time 5 "$ENDPOINT/health" >/dev/null 2>&1; then
    HEALTH_STATUS=$(curl -s --max-time 5 "$ENDPOINT/health" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Health Status: Available"
        # Try to parse basic health info if available
        if command -v jq >/dev/null 2>&1; then
            STATUS=$(echo "$HEALTH_STATUS" | jq -r '.status // "unknown" 2>/dev/null')
            if [ "$STATUS" != "unknown" ]; then
                echo "Status: $STATUS"
            fi
        fi
    else
        send_alert "Health check failed to parse response"
        echo "Health Status: Unavailable"
    fi
else
    send_alert "Health endpoint is not available"
    echo "Health Status: Endpoint not available"
fi
echo ""

# System resource usage
echo "--- System Resources ---"
TOTAL_MEM=$(sysctl -n hw.memsize 2>/dev/null)
if [ -n "$TOTAL_MEM" ]; then
    FREE_MEM=$(vm_stat | awk '/free/ { print $3 }' | sed 's/\.//')
    PAGE_SIZE=$(vm_stat | awk '/page size/ { print $8 }' | sed 's/\.//')
    if [ -n "$FREE_MEM" ] && [ -n "$PAGE_SIZE" ]; then
        FREE_MEM_BYTES=$((FREE_MEM * PAGE_SIZE))
        TOTAL_MEM_MB=$((TOTAL_MEM / 1024 / 1024))
        FREE_MEM_MB=$((FREE_MEM_BYTES / 1024 / 1024))
        USED_MEM_MB=$((TOTAL_MEM_MB - FREE_MEM_MB))
        USAGE_PERCENT=$((USED_MEM_MB * 100 / TOTAL_MEM_MB))
        echo "System Memory: $USED_MEM_MB MB used / $TOTAL_MEM_MB MB total ($USAGE_PERCENT%)"
        
        # Alert if system memory usage is over 85%
        if [ $USAGE_PERCENT -gt 85 ]; then
            send_alert "High system memory usage: ${USAGE_PERCENT}%"
        fi
    fi
fi

# Disk usage for runtime directory
RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"
if [ -d "$RUNTIME_DIR" ]; then
    DISK_USAGE=$(du -sh "$RUNTIME_DIR" 2>/dev/null | cut -f1)
    if [ -n "$DISK_USAGE" ]; then
        echo "Runtime Directory Size: $DISK_USAGE"
        
        # Extract numeric value for comparison (this is a simplified approach)
        SIZE_VALUE=$(echo "$DISK_USAGE" | sed 's/[^0-9.]//g')
        SIZE_UNIT=$(echo "$DISK_USAGE" | sed 's/[0-9.]//g')
        
        # Alert if directory size is over 1GB
        if [[ "$SIZE_UNIT" == "G" ]] && (( $(echo "$SIZE_VALUE > 1" | bc -l 2>/dev/null || echo 0) )); then
            send_alert "Large runtime directory detected: ${DISK_USAGE}"
        elif [[ "$SIZE_UNIT" == "M" ]] && (( $(echo "$SIZE_VALUE > 1000" | bc -l 2>/dev/null || echo 0) )); then
            send_alert "Large runtime directory detected: ${DISK_USAGE}"
        fi
    fi
fi

# Count active connections if possible
echo ""
echo "--- API Activity ---"
ACTIVE_MODELS=$(curl -s --max-time 5 "$ENDPOINT/v1/models" 2>/dev/null | grep -c 'id')
if [ "$ACTIVE_MODELS" -gt 0 ]; then
    echo "Active models available: $ACTIVE_MODELS"
else
    send_alert "No active models detected"
    echo "Active models available: 0"
fi

echo ""
echo "Enhanced monitoring completed."

# Optional: Clean up old log entries (keep only last 7 days)
if [ -f "$LOG_FILE" ]; then
    # This is a simplified cleanup - in practice you might want more sophisticated log rotation
    touch -d '7 days ago' /tmp/seven_days_ago 2>/dev/null
    if [ $? -eq 0 ]; then
        # Find lines newer than 7 days and keep only those
        TEMP_LOG=$(mktemp)
        awk -v cutoff="$(stat -c %Y /tmp/seven_days_ago 2>/dev/null || date -d '7 days ago' +%s)" \
            '{gsub(/[-:]/, " ", $1); gsub(/T/, " ", $1); cmd="date -d \"" $1 "\" +%s 2>/dev/null"; cmd | getline timestamp; close(cmd); if(timestamp > cutoff || NF < 3) print}' \
            "$LOG_FILE" > "$TEMP_LOG" 2>/dev/null
        mv "$TEMP_LOG" "$LOG_FILE" 2>/dev/null
        rm /tmp/seven_days_ago 2>/dev/null
    fi
fi