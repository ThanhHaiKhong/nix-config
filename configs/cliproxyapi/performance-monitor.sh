#!/usr/bin/env bash

# CLIProxyAPI Performance Monitor
# Monitors and reports performance metrics for CLIProxyAPI

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
SERVICE_NAME="local.cliproxyapi"

# Load configuration values
if command -v yq >/dev/null 2>&1; then
    HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null || echo "127.0.0.1")
    PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null || echo "8317")
else
    # Fallback to grep if yq is not available
    HOST=$(grep "^host:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs)
    PORT=$(grep "^port:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs)
    
    # If values are still empty, use defaults
    HOST=${HOST:-"127.0.0.1"}
    PORT=${PORT:-"8317"}
fi

ENDPOINT="http://$HOST:$PORT"

# Check if service is running
if ! pgrep -f "cliproxyapi" >/dev/null 2>&1; then
    echo "CLIProxyAPI is not running"
    exit 1
fi

echo "=== CLIProxyAPI Performance Report ==="
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
    fi
    
    # CPU usage
    CPU_USAGE=$(ps -o %cpu -p $PID | tail -n+2 | tr -d ' ')
    if [ -n "$CPU_USAGE" ]; then
        echo "CPU Usage: $CPU_USAGE%"
    fi
    echo ""
fi

# Test response time
echo "--- Response Time ---"
START_TIME=$(date +%s.%N)
if curl -sf --max-time 10 "$ENDPOINT/v1/models" >/dev/null 2>&1; then
    END_TIME=$(date +%s.%N)
    RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    echo "Response time: $(printf "%.3f" $RESPONSE_TIME) seconds"
else
    echo "Could not reach API endpoint for response time test"
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
        echo "Health Status: Unavailable"
    fi
else
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
        echo "System Memory: $USED_MEM_MB MB used / $TOTAL_MEM_MB MB total"
    fi
fi

# Disk usage for runtime directory
RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"
if [ -d "$RUNTIME_DIR" ]; then
    DISK_USAGE=$(du -sh "$RUNTIME_DIR" 2>/dev/null | cut -f1)
    if [ -n "$DISK_USAGE" ]; then
        echo "Runtime Directory Size: $DISK_USAGE"
    fi
fi

echo ""
echo "Performance monitoring completed."