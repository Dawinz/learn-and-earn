#!/bin/bash

LOG_FILE="/tmp/flutter_console_output.log"
ERROR_LOG="/tmp/flutter_errors_summary.log"

echo "=== Monitoring Flutter App Errors ===" > "$ERROR_LOG"
echo "Started at: $(date)" >> "$ERROR_LOG"
echo "" >> "$ERROR_LOG"

# Function to extract errors
extract_errors() {
    if [ -f "$LOG_FILE" ]; then
        echo "=== ERRORS FOUND ===" >> "$ERROR_LOG"
        grep -iE "(error|Error|ERROR|exception|Exception|EXCEPTION|failed|Failed|FAILED)" "$LOG_FILE" | tail -50 >> "$ERROR_LOG"
        echo "" >> "$ERROR_LOG"
        echo "=== WARNINGS ===" >> "$ERROR_LOG"
        grep -iE "(warning|Warning|WARNING)" "$LOG_FILE" | tail -30 >> "$ERROR_LOG"
    fi
}

# Monitor for 5 minutes
for i in {1..60}; do
    sleep 5
    extract_errors
    echo "Checked at: $(date)" >> "$ERROR_LOG"
done

echo "=== FINAL ERROR SUMMARY ===" >> "$ERROR_LOG"
extract_errors
cat "$ERROR_LOG"

