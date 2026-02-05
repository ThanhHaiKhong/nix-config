#!/usr/bin/env bash

# CLIProxyAPI Performance Tuning Script
# Analyzes performance metrics and provides optimization recommendations

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

CONFIG_FILE="$HOME/.config/cliproxyapi/config.yaml"
LAUNCHD_PLIST_FILE="$HOME/Library/LaunchAgents/local.cliproxyapi.plist"
REPORT_FILE="/tmp/cliproxyapi-performance-analysis-$(date +%Y%m%d_%H%M%S).txt"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${1:-INFO}] ${2:-}"
}

# Function to check if service is running
is_service_running() {
    if pgrep -f "cliproxyapi" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to restart the service
restart_service() {
    log "INFO" "Restarting CLIProxyAPI service to apply changes..."
    ~/.local/bin/cliproxyapi-manager restart
}

# Function to backup the current config
backup_config() {
    local backup_file="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$backup_file"
    log "INFO" "Configuration backed up to $backup_file"
}

# Function to analyze performance and suggest optimizations
analyze_performance() {
    log "INFO" "Analyzing CLIProxyAPI performance..."
    
    # Run the enhanced performance monitor
    $(dirname "$0")/enhanced-monitoring.sh > "$REPORT_FILE"
    
    echo "Performance analysis report saved to: $REPORT_FILE"
    echo ""
    echo "=== Performance Analysis Results ==="
    
    # Check for specific issues in the report
    if grep -q "WARNING" "$REPORT_FILE"; then
        echo "⚠️  WARNINGS DETECTED:"
        grep "WARNING" "$REPORT_FILE" | sed 's/^/  /'
        echo ""
    fi
    
    if grep -q "High memory usage" "$REPORT_FILE"; then
        echo "🔧 MEMORY OPTIMIZATION SUGGESTIONS:"
        echo "  • Consider adjusting the commercial-mode setting in config"
        echo "  • Review the number of active models and providers"
        echo "  • Consider increasing the launchd memory limits"
        echo ""
    fi
    
    if grep -q "Slow response time" "$REPORT_FILE"; then
        echo "🔧 RESPONSE TIME OPTIMIZATIONS:"
        echo "  • Check upstream API provider response times"
        echo "  • Consider enabling commercial-mode for reduced overhead"
        echo "  • Review payload manipulation settings"
        echo ""
    fi
    
    if grep -q "High CPU usage" "$REPORT_FILE"; then
        echo "🔧 CPU USAGE OPTIMIZATIONS:"
        echo "  • Consider reducing concurrent request limits"
        echo "  • Review streaming behavior settings"
        echo "  • Check for inefficient model routing strategies"
        echo ""
    fi
}

# Function to optimize the configuration based on recommendations
optimize_configuration() {
    log "INFO" "Optimizing CLIProxyAPI configuration..."
    
    # Backup the current config
    backup_config
    
    # Create a temporary config file
    TEMP_CONFIG=$(mktemp)
    cp "$CONFIG_FILE" "$TEMP_CONFIG"
    
    # Apply optimizations based on common performance issues
    echo "Applying performance optimizations..."
    
    # Enable commercial mode if not already enabled (reduces memory usage)
    if ! grep -q "commercial-mode: true" "$TEMP_CONFIG"; then
        sed -i.bak 's/commercial-mode: false/commercial-mode: true/' "$TEMP_CONFIG" 2>/dev/null || {
            # If commercial-mode doesn't exist, add it
            sed -i.bak '/# Performance and Operation/a\
commercial-mode: true
' "$TEMP_CONFIG" 2>/dev/null || {
                # Alternative approach if the above doesn't work on macOS
                perl -i.bak -pe 's/(# Performance and Operation)/$1\ncommercial-mode: true\n/' "$TEMP_CONFIG" 2>/dev/null || {
                    log "WARN" "Could not modify commercial-mode setting"
                }
            }
        }
    fi
    
    # Increase request retry settings if they seem low
    if grep -q "request-retry: 3" "$TEMP_CONFIG"; then
        # Already optimal
        log "INFO" "Request retry setting is already optimized"
    elif grep -q "request-retry:" "$TEMP_CONFIG"; then
        # Update to recommended value
        sed -i.bak 's/request-retry: [0-9]*/request-retry: 3/' "$TEMP_CONFIG" 2>/dev/null || {
            log "WARN" "Could not update request-retry setting"
        }
    else
        # Add the setting
        sed -i.bak '/# The number of times the program automatically retries/a\
request-retry: 3
' "$TEMP_CONFIG" 2>/dev/null || {
            log "WARN" "Could not add request-retry setting"
        }
    fi
    
    # Update the config file
    cp "$TEMP_CONFIG" "$CONFIG_FILE"
    rm "$TEMP_CONFIG" "$TEMP_CONFIG.bak" 2>/dev/null || true
    
    log "INFO" "Configuration optimizations applied"
}

# Function to optimize launchd settings
optimize_launchd() {
    log "INFO" "Optimizing launchd settings..."
    
    if [ -f "$LAUNCHD_PLIST_FILE" ]; then
        # Create a backup
        cp "$LAUNCHD_PLIST_FILE" "${LAUNCHD_PLIST_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # For now, we'll just recommend changes since modifying plists requires more complex XML parsing
        echo "Recommended launchd optimizations:"
        echo "  • Increase SoftResourceLimits.ResidentSetSize for high-memory usage scenarios"
        echo "  • Adjust ThrottleInterval based on restart frequency needs"
        echo "  • Consider adding ProcessType for better resource management"
        echo ""
        echo "To apply these changes, manually edit: $LAUNCHD_PLIST_FILE"
    else
        log "WARN" "Launchd plist not found at $LAUNCHD_PLIST_FILE"
    fi
}

# Function to run stress tests
run_stress_tests() {
    log "INFO" "Running stress tests..."
    
    # Get API key for authentication
    if command -v yq >/dev/null 2>&1; then
        API_KEY=$(yq '.["api-keys"][0]' "$CONFIG_FILE" 2>/dev/null | tr -d '"')
    else
        API_KEY=$(grep -A 10 "api-keys:" "$CONFIG_FILE" | grep "- " | head -n1 | sed 's/.*"\(.*\)".*/\1/')
    fi
    
    # Get endpoint
    if command -v yq >/dev/null 2>&1; then
        HOST=$(yq '.host' "$CONFIG_FILE" 2>/dev/null | tr -d '"' || echo "127.0.0.1")
        PORT=$(yq '.port' "$CONFIG_FILE" 2>/dev/null | tr -d '"' || echo "8317")
    else
        HOST=$(grep "^host:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs | sed 's/"//g')
        PORT=$(grep "^port:" "$CONFIG_FILE" | head -n1 | cut -d':' -f2 | xargs | sed 's/"//g')
        HOST=${HOST:-"127.0.0.1"}
        PORT=${PORT:-"8317"}
    fi
    
    ENDPOINT="http://$HOST:$PORT"
    
    echo "Running basic stress test with 10 concurrent requests..."
    
    # Run multiple requests in parallel
    for i in {1..10}; do
        (
            START_TIME=$(date +%s.%N)
            if curl -sf --max-time 30 -H "Authorization: Bearer $API_KEY" "$ENDPOINT/v1/models" >/dev/null 2>&1; then
                END_TIME=$(date +%s.%N)
                RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
                printf "Request %d: %.3f seconds\n" $i $RESPONSE_TIME
            else
                echo "Request $i: FAILED"
            fi
        ) &
    done
    
    # Wait for all background jobs to complete
    wait
    
    echo ""
    echo "Stress test completed."
}

# Main execution
case "${1:-analyze}" in
    analyze)
        analyze_performance
        ;;
    optimize)
        analyze_performance
        echo ""
        read -p "Apply configuration optimizations? (yes/no): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            optimize_configuration
            echo ""
            read -p "Restart service to apply changes? (yes/no): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                restart_service
            else
                echo "Remember to restart the service to apply configuration changes."
            fi
        else
            echo "Skipping configuration optimizations."
        fi
        optimize_launchd
        ;;
    stress-test)
        run_stress_tests
        ;;
    full-analysis)
        analyze_performance
        echo ""
        run_stress_tests
        echo ""
        optimize_launchd
        ;;
    *)
        echo "CLIProxyAPI Performance Tuning Tool"
        echo ""
        echo "Usage:"
        echo "  $0 analyze           - Analyze performance and generate report"
        echo "  $0 optimize          - Analyze and apply optimizations"
        echo "  $0 stress-test       - Run stress tests on the API"
        echo "  $0 full-analysis     - Full analysis including stress tests"
        echo ""
        echo "Examples:"
        echo "  $0                    # Run basic analysis"
        echo "  $0 optimize           # Analyze and optimize configuration"
        exit 0
        ;;
esac