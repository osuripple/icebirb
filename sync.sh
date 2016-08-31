# Load settings
SYNC_REPLAYS=$(awk -F "=" '/sync_replays/ {print $2}' config.ini)
SYNC_AVATARS=$(awk -F "=" '/sync_avatars/ {print $2}' config.ini)
SYNC_SCREENSHOTS=$(awk -F "=" '/sync_screenshots/ {print $2}' config.ini)
SYNC_DATABASE=$(awk -F "=" '/sync_database/ {print $2}' config.ini)

DB_USERNAME=$(awk -F "=" '/db_username/ {print $2}' config.ini)
DB_PASSWORD=$(awk -F "=" '/db_password/ {print $2}' config.ini)
DB_NAME=$(awk -F "=" '/db_name/ {print $2}' config.ini)

REPLAYS_FOLDER=$(awk -F "=" '/replays_folder/ {print $2}' config.ini)
AVATARS_FOLDER=$(awk -F "=" '/avatars_folder/ {print $2}' config.ini)
SCREENSHOTS_FOLDER=$(awk -F "=" '/screenshots_folder/ {print $2}' config.ini)

RSYNC_REMOTE=$(awk -F "=" '/rsync_remote/ {print $2}' config.ini)

SCHIAVO_URL=$(awk -F "=" '/schiavo_url/ {print $2}' config.ini)

BLUE='\033[0;36m'
NC='\033[0m'

# Sync replays
if [ $SYNC_REPLAYS = true ]; then
	echo "$BLUE==> Syncing replays...$NC"
	rsync -aP "$REPLAYS_FOLDER" "$RSYNC_REMOTE"
fi

# Sync avatars
if [ $SYNC_AVATARS = true ]; then
	echo "\n$BLUE==> Syncing avatars...$NC"
	rsync -aP "$AVATARS_FOLDER" "$RSYNC_REMOTE"
fi

# Sync screenshots
if [ $SYNC_SCREENSHOTS = true ]; then
	echo "\n$BLUE==> Syncing screenshots...$NC"
	rsync -aP "$SCREENSHOTS_FOLDER" "$RSYNC_REMOTE"
fi

# Dump and sync database
if [ $SYNC_DATABASE = true ]; then
	echo "\n$BLUE==> Dumping database...$NC"
	mysqldump -u "$DB_USERNAME" "-p$DB_PASSWORD" "$DB_NAME" > "db.sql"

	echo "$BLUE==> Syncing database...$NC"
	rsync -azP db.sql "$RSYNC_REMOTE"

	#echo "\n$BLUE==> Removing temp database...$NC"
	#rm -rf db.sql
fi

# Update latest sync
echo "Latest sync: $(date '+%F %H:%M:%S')" > latest-sync.txt
rsync -a latest-sync.txt "$RSYNC_REMOTE"

# Schiavo message
if [ -z != $SCHIAVO_URL ]; then
	curl --data-urlencode "message=**icebirb** Ripple data sync completed!" "$SCHIAVO_URL/bunk" 2>&1 > /dev/null
fi

echo "\n$BLUE==> Done!$NC"