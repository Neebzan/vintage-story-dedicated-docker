#!/bin/sh

if [ -z "$VERSION" ]; then
    echo "ERROR: VERSION environment variable is not set."
    exit 1
fi

if [ -z "$CHANNEL" ]; then
    echo "ERROR: CHANNEL environment variable is not set."
    exit 1
fi

# Download location
GAME_URL="https://cdn.vintagestory.at/gamefiles/$CHANNEL"
GAME_ARCHIVE="vs_server_linux-x64_${VERSION}.tar.gz"
# Downloaded files dir
GAME_FILES_DIR="/app/game_files"
GAME_VERSION_DIR="$GAME_FILES_DIR/$VERSION"
ASSETS_DIR="$GAME_VERSION_DIR/assets"
# Server config files dir
SERVER_FILES_DIR="/app/server_files"
LOG_DIR="$SERVER_FILES_DIR/Logs"
LOG_FILE="$SERVER_FILES_DIR/Logs/server-main.log"

mkdir -p "$GAME_VERSION_DIR" "$SERVER_FILES_DIR" "$LOG_DIR"

if [ ! -f "$GAME_VERSION_DIR/$GAME_ARCHIVE" ]; then
    echo "Downloading new game version: $VERSION from channel $CHANNEL..."
    curl -# -o "$GAME_VERSION_DIR/$GAME_ARCHIVE" "$GAME_URL/$GAME_ARCHIVE"

    echo "Extracting game files..."
    tar xzf "$GAME_VERSION_DIR/$GAME_ARCHIVE" -C "$GAME_VERSION_DIR"
    chmod +x "$GAME_VERSION_DIR/server.sh"
else
    echo "Game version $VERSION already downloaded."
fi

sed -i "s|^USERNAME='.*'|USERNAME='$(whoami)'|" "$GAME_VERSION_DIR/server.sh"
sed -i "s|^VSPATH='.*'|VSPATH='$GAME_VERSION_DIR'|" "$GAME_VERSION_DIR/server.sh"
sed -i "s|^DATAPATH='.*'|DATAPATH='$SERVER_FILES_DIR'|" "$GAME_VERSION_DIR/server.sh"

tail_log() {
    echo "Tailing the log file: $LOG_FILE"
    tail -F "$LOG_FILE"
}

echo "Starting server..."
"$GAME_VERSION_DIR/server.sh" start &

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
