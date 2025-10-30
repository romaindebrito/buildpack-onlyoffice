#!/usr/bin/env bash

# -----------------------------
# Configuration
# -----------------------------
SRC_DIR="/app/${OO_S3_STORAGE_FOLDER_NAME}"
REMOTE="onlyoffice-s3:${${OO_S3_BUCKET_NAME}}"
SYNC_INTERVAL=5         # seconds between periodic pulls
RETRY_DELAY=10          # seconds before retry on failure
LOG_FILE="/app/logs/sync.log"

mkdir -p "$SRC_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

echo "[INIT] Starting optimized bidirectional S3 sync..." | tee -a "$LOG_FILE"

# Create a remote for OVH S3
rclone config create onlyoffice-s3 s3 \
    provider Other \
    access_key_id "${OO_S3_ACCESS_KEY_ID}" \
    secret_access_key "${OO_S3_SECRET_ACCESS_KEY}" \
    endpoint "${OO_S3_ENDPOINT}" \
	region "${OO_S3_REGION}" \
    acl "private"

# -----------------------------
# Initial sync from remote -> local
# -----------------------------
echo "[INIT] Initial pull: Remote -> Local" | tee -a "$LOG_FILE"
until rclone sync "$REMOTE" "$SRC_DIR" --progress >> "$LOG_FILE" 2>&1; do
    echo "[ERROR] Initial pull failed, retrying in $RETRY_DELAY seconds..." | tee -a "$LOG_FILE"
    sleep "$RETRY_DELAY"
done

# -----------------------------
# Cleanup function for container exit
# -----------------------------
cleanup() {
    echo "[CLEANUP] Stopping sync loop..." | tee -a "$LOG_FILE"
    kill 0  # kill all child processes
}
trap cleanup SIGINT SIGTERM

# -----------------------------
# Main loop: handles both push and pull
# -----------------------------
(
    echo "[START] Sync loop started..." | tee -a "$LOG_FILE"

    # Start inotifywait in background to detect local changes
    inotifywait -m -r -e create -e modify -e delete --format '%w%f' "$SRC_DIR" |
    while read FILE; do
        echo "[LOCAL CHANGE] $FILE detected, syncing..." | tee -a "$LOG_FILE"

        # Push local changes to remote with retry
        until rclone sync "$SRC_DIR" "$REMOTE" --progress >> "$LOG_FILE" 2>&1; do
            echo "[ERROR] Push failed, retrying in $RETRY_DELAY seconds..." | tee -a "$LOG_FILE"
            sleep "$RETRY_DELAY"
        done
    done &
    
    # Periodic pull loop (remote -> local)
    while true; do
        echo "[SYNC] Periodic pull: Remote -> Local" | tee -a "$LOG_FILE"

        until rclone sync "$REMOTE" "$SRC_DIR" --progress >> "$LOG_FILE" 2>&1; do
            echo "[ERROR] Pull failed, retrying in $RETRY_DELAY seconds..." | tee -a "$LOG_FILE"
            sleep "$RETRY_DELAY"
        done

        sleep "$SYNC_INTERVAL"
    done
) &

# Wait indefinitely
wait