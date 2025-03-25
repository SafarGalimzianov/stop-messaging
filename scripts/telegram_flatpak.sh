#!/bin/bash

# =====================================================================
# Telegram Monitor & Blocker
# =====================================================================
# This script monitors and optionally blocks the Telegram desktop app
# when it's running. It's designed to help users limit their messaging
# app usage by automatically closing Telegram.
# =====================================================================

# Configuration variables
SLEEP_INTERVAL=5  # Time in seconds between checks
ALLOW_MODE=false  # Default mode: disallow Telegram
PAUSE_DURATION=120  # Duration in seconds to pause blocking (2 minutes)
PAUSE_COMMAND="pause"  # Command to pause telegram blocking
PAUSE_UNTIL=0  # Timestamp until blocking is paused

# Parse command line arguments
# --allow: Run in monitoring-only mode without closing Telegram
if [[ "$1" == "--allow" ]]; then
    ALLOW_MODE=true
fi

# Function to check if Telegram is installed via Flatpak
# Returns: Exits with error code 1 if not installed
check_telegram_installed() {
    if ! flatpak list --app | grep -q 'org.telegram.desktop'; then
        echo "Telegram (Flatpak) is not installed."
        exit 1
    fi
}

# Function to check if Telegram is currently running
# Returns: 0 (true) if running, 1 (false) if not running
check_telegram_running() {
    if flatpak ps | grep -q 'org.telegram.desktop'; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

# Function to forcefully close Telegram
close_telegram() {
    echo "Stopping Telegram..."
    flatpak kill org.telegram.desktop
}

# Function to check if blocking is currently paused
# Returns: 0 (true) if paused, 1 (false) if not paused
is_paused() {
    local current_time=$(date +%s)
    if [ $current_time -lt $PAUSE_UNTIL ]; then
        return 0  # Paused
    else
        return 1  # Not paused
    fi
}

# Function to handle script termination and cleanup
# This ensures background processes are properly terminated
cleanup() {
    echo -e "\nMonitoring stopped. Exiting..."
    kill $READER_PID 2>/dev/null  # Kill the background reader process
    exit 0
}

# Set up trap to catch Ctrl+C and other termination signals
trap cleanup SIGINT SIGTERM

# Check installation once at startup
check_telegram_installed

# Start a background process to read stdin for commands
# This allows us to accept commands while the script is running
(
    while read -r line; do
        if [ "$line" = "$PAUSE_COMMAND" ]; then
            PAUSE_UNTIL=$(($(date +%s) + PAUSE_DURATION))
            echo "[$(date +"%H:%M:%S")] Paused blocking for $PAUSE_DURATION seconds (until $(date -d "@$PAUSE_UNTIL" +"%H:%M:%S"))"
        fi
    done
) &
READER_PID=$!

# Display startup information
echo "Starting Telegram monitoring. Press Ctrl+C to stop."
echo "Checking every $SLEEP_INTERVAL seconds."
if $ALLOW_MODE; then
    echo "Mode: ALLOW - Telegram will be allowed to run"
else
    echo "Mode: BLOCK - Telegram will be closed when detected"
    echo "Type '$PAUSE_COMMAND' to pause blocking for $((PAUSE_DURATION / 60)) minutes"
fi
echo "----------------------------------------"

# Main monitoring loop
# Redirect stdin to ensure we can read user input from terminal
exec < /dev/tty
while true; do
    # Non-blocking read with timeout to check for pause command
    read -t 0.1 -r line || true
    if [ "$line" = "$PAUSE_COMMAND" ]; then
        PAUSE_UNTIL=$(($(date +%s) + PAUSE_DURATION))
        echo "[$(date +"%H:%M:%S")] Paused blocking for $PAUSE_DURATION seconds (until $(date -d "@$PAUSE_UNTIL" +"%H:%M:%S"))"
    fi
    
    # Check Telegram status and take appropriate action
    if check_telegram_running; then
        if $ALLOW_MODE || is_paused; then
            # Allow Telegram to run if in allow mode or during pause period
            pause_status=""
            if is_paused; then
                remaining=$((PAUSE_UNTIL - $(date +%s)))
                pause_status=" (blocking paused for ${remaining}s)"
            fi
            echo "[$(date +"%H:%M:%S")] Telegram is running${pause_status}"
        else
            # Close Telegram if in block mode and not paused
            echo "[$(date +"%H:%M:%S")] Telegram is running, closing it"
            close_telegram
        fi
    else
        echo "[$(date +"%H:%M:%S")] Telegram is not running"
    fi
    
    # Wait before checking again
    sleep $SLEEP_INTERVAL
done