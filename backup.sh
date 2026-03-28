#!/bin/bash

# Backup script for RealVest database
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/realvest_db_$TIMESTAMP.sql.gz"

mkdir -p $BACKUP_DIR

echo "Starting database backup..."

docker-compose exec -T db mysqldump \
    -u realvest_user \
    -p${DB_PASSWORD} \
    realvest_db | gzip > $BACKUP_FILE

if [ $? -eq 0 ]; then
    SIZE=$(du -h $BACKUP_FILE | cut -f1)
    echo "✓ Backup created: $BACKUP_FILE ($SIZE)"
else
    echo "❌ Backup failed"
    exit 1
fi
