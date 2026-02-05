#!/usr/bin/env bash

# Enhanced CLIProxyAPI Performance Monitor
# Monitors and reports performance metrics for CLIProxyAPI

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
SERVICE_NAME="local.cliproxyapi"
REPORT_TYPE="${1:-full}"  # Options: full, quick, detailed

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${1:-INFO}] ${2:-}"
}

# Load configuration values
if command -v yq >/dev/null 2>&1; then
    HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null | tr -d '"' || echo "127.0.0.1")
    PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null | tr -d '"' || echo "8317")
else
    # Fallback to grep if yq is not available
    HOST=$(grep "^host:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs | sed 's/"//g')
    PORT=$(grep "^port:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs | sed 's/"//g')

    # If values are still empty, use defaults
    HOST=${HOST:-"127.0.0.1"}
    PORT=${PORT:-"8317"}
fi

ENDPOINT="http://$HOST:$PORT"

# Check if service is running
if ! pgrep -f "cliproxyapi" >/dev/null 2>&1; then
    log "ERROR" "CLIProxyAPI is not running"
    exit 1
fi

echo "=== CLIProxyAPI Performance Report ==="
echo "Timestamp: $(date)"
echo "Endpoint: $ENDPOINT"
echo "Report Type: $REPORT_TYPE"
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

        # Get RSS in KB for comparison
        RSS=$(echo "$MEM_INFO" | tail -n+2 | awk '{print $2}')
        if [ "$RSS" -gt 1048576 ]; then  # More than 1GB
            echo "⚠️  WARNING: High memory usage detected (>1GB RSS)"
        elif [ "$RSS" -gt 524288 ]; then  # More than 512MB
            echo "⚠️  NOTICE: Moderate memory usage detected (>512MB RSS)"
        fi
    fi

    # CPU usage
    CPU_USAGE=$(ps -o %cpu -p $PID | tail -n+2 | tr -d ' ')
    if [ -n "$CPU_USAGE" ]; then
        echo "CPU Usage: $CPU_USAGE%"
        if (( $(echo "$CPU_USAGE > 80" | bc -l 2>/dev/null || echo 0) )); then
            echo "⚠️  WARNING: High CPU usage detected (>80%)"
        fi
    fi
    echo ""
fi

# Test response time with multiple samples
echo "--- Response Time Analysis ---"
if [ "$REPORT_TYPE" != "quick" ]; then
    # Get API key for authentication
    if command -v yq >/dev/null 2>&1; then
        API_KEY=$(yq '.["api-keys"][0]' "$CONFIG_FILE" 2>/dev/null | tr -d '"')
    else
        API_KEY=$(grep -A 10 "api-keys:" "$CONFIG_FILE" | grep "- " | head -n1 | sed 's/.*"\(.*\)".*/\1/')
    fi

    # Perform multiple response time tests
    SAMPLES=5
    TOTAL_RESPONSE_TIME=0
    MIN_RESPONSE_TIME=9999
    MAX_RESPONSE_TIME=0
    SUCCESSFUL_TESTS=0

    for i in $(seq 1 $SAMPLES); do
        START_TIME=$(date +%s.%N)
        if curl -sf --max-time 10 -H "Authorization: Bearer $API_KEY" "$ENDPOINT/v1/models" >/dev/null 2>&1; then
            END_TIME=$(date +%s.%N)
            RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
            TOTAL_RESPONSE_TIME=$(echo "$TOTAL_RESPONSE_TIME + $RESPONSE_TIME" | bc -l)

            if (( $(echo "$RESPONSE_TIME < $MIN_RESPONSE_TIME" | bc -l 2>/dev/null || echo 1) )); then
                MIN_RESPONSE_TIME=$RESPONSE_TIME
            fi

            if (( $(echo "$RESPONSE_TIME > $MAX_RESPONSE_TIME" | bc -l 2>/dev/null || echo 0) )); then
                MAX_RESPONSE_TIME=$RESPONSE_TIME
            fi

            SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
        else
            echo "Request $i failed"
        fi
    done

    if [ $SUCCESSFUL_TESTS -gt 0 ]; then
        AVG_RESPONSE_TIME=$(echo "$TOTAL_RESPONSE_TIME / $SUCCESSFUL_TESTS" | bc -l)
        printf "Average Response Time: %.3f seconds\n" $AVG_RESPONSE_TIME
        printf "Min Response Time: %.3f seconds\n" $MIN_RESPONSE_TIME
        printf "Max Response Time: %.3f seconds\n" $MAX_RESPONSE_TIME
        printf "Successful Requests: %d/%d\n" $SUCCESSFUL_TESTS $SAMPLES

        if (( $(echo "$AVG_RESPONSE_TIME > 2" | bc -l 2>/dev/null || echo 0) )); then
            echo "⚠️  WARNING: Slow average response time detected (>2s)"
        elif (( $(echo "$AVG_RESPONSE_TIME > 1" | bc -l 2>/dev/null || echo 0) )); then
            echo "⚠️  NOTICE: Moderate response time detected (>1s)"
        fi
    else
        echo "❌ All requests failed"
    fi
else
    # Quick test
    if command -v yq >/dev/null 2>&1; then
        API_KEY=$(yq '.["api-keys"][0]' "$CONFIG_FILE" 2>/dev/null | tr -d '"')
    else
        API_KEY=$(grep -A 10 "api-keys:" "$CONFIG_FILE" | grep "- " | head -n1 | sed 's/.*"\(.*\)".*/\1/')
    fi

    START_TIME=$(date +%s.%N)
    if curl -sf --max-time 10 -H "Authorization: Bearer $API_KEY" "$ENDPOINT/v1/models" >/dev/null 2>&1; then
        END_TIME=$(date +%s.%N)
        RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
        printf "Response time: %.3f seconds\n" $RESPONSE_TIME
    else
        echo "Could not reach API endpoint for response time test"
    fi
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
        USAGE_PERCENT=$((USED_MEM_MB * 100 / TOTAL_MEM_MB))
        echo "System Memory: $USED_MEM_MB MB used / $TOTAL_MEM_MB MB total ($USAGE_PERCENT%)"

        if [ $USAGE_PERCENT -gt 90 ]; then
            echo "⚠️  WARNING: High system memory usage detected (>$USAGE_PERCENT%)"
        elif [ $USAGE_PERCENT -gt 80 ]; then
            echo "⚠️  NOTICE: Moderate system memory usage detected (>$USAGE_PERCENT%)"
        fi
    fi
fi

# Disk usage for runtime directory
RUNTIME_DIR="$HOME/.local/share/cli-proxy-api"
if [ -d "$RUNTIME_DIR" ]; then
    DISK_USAGE=$(du -sh "$RUNTIME_DIR" 2>/dev/null | cut -f1)
    if [ -n "$DISK_USAGE" ]; then
        echo "Runtime Directory Size: $DISK_USAGE"

        # Extract numeric value for comparison
        SIZE_VALUE=$(echo "$DISK_USAGE" | sed 's/[^0-9.]//g')
        SIZE_UNIT=$(echo "$DISK_USAGE" | sed 's/[0-9.]//g')

        # Check if directory size is large
        if [[ "$SIZE_UNIT" == "G" ]] && (( $(echo "$SIZE_VALUE > 2" | bc -l 2>/dev/null || echo 0) )); then
            echo "⚠️  WARNING: Large runtime directory detected: ${DISK_USAGE}"
        elif [[ "$SIZE_UNIT" == "M" ]] && (( $(echo "$SIZE_VALUE > 1000" | bc -l 2>/dev/null || echo 0) )); then
            echo "⚠️  WARNING: Large runtime directory detected: ${DISK_USAGE}"
        fi
    fi
fi

# Network connections
if [ "$REPORT_TYPE" = "detailed" ]; then
    echo ""
    echo "--- Network Connections ---"
    CONNECTIONS=$(lsof -i -P -n | grep "$PID" | wc -l)
    echo "Active Connections: $CONNECTIONS"

    if [ "$CONNECTIONS" -gt 100 ]; then
        echo "⚠️  WARNING: High number of active connections detected (>$CONNECTIONS)"
    fi
fi

# Performance tuning recommendations
echo ""
echo "--- Performance Tuning Recommendations ---"
if [ -n "$RSS" ] && [ "$RSS" -gt 524288 ]; then
    echo "• Consider increasing resource limits in the launchd plist"
    echo "• Review configuration for potential optimizations"
    echo "• Check for memory leaks in active models"
fi

if [ $USAGE_PERCENT -gt 80 ]; then
    echo "• Consider optimizing system resources or upgrading hardware"
    echo "• Review other processes that might be consuming memory"
fi

if [ -n "${AVG_RESPONSE_TIME:-}" ] && (( $(echo "${AVG_RESPONSE_TIME:-0} > 1" | bc -l 2>/dev/null || echo 0) )); then
    echo "• Investigate slow response times - check network and upstream services"
    echo "• Consider caching strategies for frequently accessed data"
fi

echo ""
echo "Performance monitoring completed."