#!/bin/sh

# Ensure VERSION is set
if [ -z "$VERSION" ]; then
    echo "ERROR: VERSION environment variable is not set."
    exit 1
fi

GAME_URL="https://cdn.vintagestory.at/gamefiles/stable"
GAME_ARCHIVE="vs_server_linux-x64_${VERSION}.tar.gz"
GAME_DIR="/app/server"
DATA_DIR="/app/data"
ASSETS_DIR="$GAME_DIR/assets"
LOG_FILE="$DATA_DIR/Logs/server-main.log"
LOG_DIR="$DATA_DIR/Logs"

tail_log() {
    echo "Tailing the log file: $LOG_FILE"
    tail -F "$LOG_FILE"
}

mkdir -p "$GAME_DIR" "$DATA_DIR" "$LOG_DIR"

if [ ! -f "$GAME_DIR/$GAME_ARCHIVE" ]; then
    if [ -d "$ASSETS_DIR" ]; then
        echo "Deleting old assets folder..."
        rm -rf "$ASSETS_DIR"
    fi
    echo "Downloading new game version: $VERSION..."
    wget -q --show-progress -O "$GAME_DIR/$GAME_ARCHIVE" "$GAME_URL/$GAME_ARCHIVE"
    
    echo "Extracting game files..."
    tar xzf "$GAME_DIR/$GAME_ARCHIVE" -C "$GAME_DIR"
    chmod +x "$GAME_DIR/server.sh"
else
    echo "Game version $VERSION already downloaded."

fi

# Ensure correct paths in server.sh
sed -i "s|^USERNAME='.*'|USERNAME='vintagestory'|" "$GAME_DIR/server.sh"
sed -i "s|^VSPATH='.*'|VSPATH='$GAME_DIR'|" "$GAME_DIR/server.sh"
sed -i "s|^DATAPATH='.*'|DATAPATH='$DATA_DIR'|" "$GAME_DIR/server.sh"

# Start server
echo "Starting server..."
"$GAME_DIR/server.sh" start &

# Wait for log file creation
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


