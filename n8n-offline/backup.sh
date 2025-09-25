#!/bin/bash
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "💾 Creating backup..."
mkdir -p $BACKUP_DIR

# Backup data volume
docker run --rm -v n8n_n8n_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine \
    tar czf /backup/n8n-data-$DATE.tar.gz -C /data .

echo "✅ Backup created: $BACKUP_DIR/n8n-data-$DATE.tar.gz"