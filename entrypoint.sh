#!/bin/sh

LOG_FILE="/app/data/Logs/server-main.log"
LOG_DIR="/app/data/Logs"

./server.sh start &

mkdir -p "$LOG_DIR"

tail_log() {
    echo "Tailing the log file: $LOG_FILE"
    tail -F "$LOG_FILE"
}

while [ ! -f "$LOG_FILE" ]; do
    echo "Waiting for log file to be created..."
    sleep 1
done

tail_log &

while true; do
    cd "$LOG_DIR" || exit 1  # Ensure we're in the correct directory

    if [ ! -f "$LOG_FILE" ]; then
        echo "$LOG_FILE is no longer accessible or has been moved. Looking for a new log file..."

        # Look for the new log file in the correct directory
        NEW_LOG_FILE=$(find "$LOG_DIR" -maxdepth 1 -name 'server-main.log' | head -n 1)

        if [ -n "$NEW_LOG_FILE" ]; then
            echo "Found new log file: $NEW_LOG_FILE"
            LOG_FILE="$NEW_LOG_FILE"
            tail_log &  # Restart tailing
        fi
    fi

    sleep 1
done

