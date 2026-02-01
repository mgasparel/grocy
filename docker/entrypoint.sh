#!/bin/sh
set -e

: "${GROCY_DATAPATH:=/config/data}"

# Ensure GROCY_DATAPATH is passed into php-fpm so the app uses the mounted data volume.
if grep -q "^env\[GROCY_DATAPATH\]" /etc/php83/php-fpm.d/www.conf; then
	sed -E -i "s|^env\[GROCY_DATAPATH\].*$|env[GROCY_DATAPATH] = ${GROCY_DATAPATH}|" /etc/php83/php-fpm.d/www.conf
else
	echo "env[GROCY_DATAPATH] = ${GROCY_DATAPATH}" >> /etc/php83/php-fpm.d/www.conf
fi

mkdir -p \
	"$GROCY_DATAPATH" \
	"$GROCY_DATAPATH/viewcache" \
	"$GROCY_DATAPATH/storage" \
	"$GROCY_DATAPATH/settingoverrides" \
	"$GROCY_DATAPATH/plugins"

# Make sure php-fpm can write caches and the database.
chown -R nginx:nginx "$GROCY_DATAPATH"
chmod -R 775 "$GROCY_DATAPATH"

DB_PATH="$GROCY_DATAPATH/grocy.db"

if command -v sqlite3 >/dev/null 2>&1; then
	# Bootstrap SQL migrations when the database is empty (first run or reset).
	sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS migrations (migration INTEGER NOT NULL PRIMARY KEY UNIQUE, execution_time_timestamp DATETIME DEFAULT (datetime('now', 'localtime')));"
	MIGRATION_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM migrations;")
	if [ "$MIGRATION_COUNT" -eq 0 ]; then
		for file in /app/www/migrations/*.sql; do
			migration_id=$(basename "$file" .sql)
			migration_id="${migration_id##0}"
			if [ -z "$migration_id" ]; then migration_id=0; fi
			exists=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM migrations WHERE migration = $migration_id;")
			if [ "$exists" -eq 0 ]; then
				sqlite3 "$DB_PATH" ".read $file"
				sqlite3 "$DB_PATH" "INSERT INTO migrations (migration) VALUES ($migration_id);"
			fi
		done
	fi
fi

if [ ! -f "$GROCY_DATAPATH/config.php" ] && [ -f /app/www/config-dist.php ]; then
	cp /app/www/config-dist.php "$GROCY_DATAPATH/config.php"
fi

exec "$@"
