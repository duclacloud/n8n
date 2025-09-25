# N8N Operations Manual - Sổ Tay Vận Hành

## 🎛️ **Quản Lý Container**

### **Start/Stop/Restart Commands**
```bash
# Start n8n
docker compose up -d

# Stop n8n
docker compose down

# Restart n8n
docker compose restart n8n

# Force recreate (sau khi update)
docker compose up -d --force-recreate

# Start specific service
docker compose up -d n8n
docker compose up -d postgres redis

# Stop specific service
docker compose stop n8n
docker compose stop postgres
```

### **Container Status Check**
```bash
# Xem status tất cả containers
docker compose ps

# Xem detailed info
docker compose ps -a

# Check container health
docker inspect n8n --format='{{.State.Health.Status}}'

# Xem container processes
docker compose top n8n
```

### **Logs Management**
```bash
# Xem logs real-time
docker compose logs -f n8n

# Xem logs với timestamp
docker compose logs -t n8n

# Xem logs từ thời điểm cụ thể
docker compose logs --since="2024-01-01T00:00:00" n8n

# Xem logs cuối cùng (100 lines)
docker compose logs --tail=100 n8n

# Xem logs tất cả services
docker compose logs -f

# Export logs to file
docker compose logs n8n > n8n-logs-$(date +%Y%m%d).log
```

## 📊 **Monitoring & Resource Management**

### **Resource Usage Monitoring**
```bash
# Real-time resource usage
docker stats n8n

# Detailed container info
docker inspect n8n

# System resource usage
htop
free -h
df -h

# Docker system info
docker system df
docker system info
```

### **Memory Monitoring**
```bash
# Container memory usage
docker stats --no-stream n8n --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# System memory
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"

# Memory usage by process
ps aux --sort=-%mem | head -10

# Check for memory leaks
docker exec n8n ps aux --sort=-%mem
```

### **CPU Monitoring**
```bash
# Container CPU usage
docker stats --no-stream n8n --format "table {{.Container}}\t{{.CPUPerc}}"

# System CPU usage
top -p $(docker inspect -f '{{.State.Pid}}' n8n)

# CPU load average
uptime

# Detailed CPU info
lscpu
```

### **Storage Monitoring**
```bash
# Docker volumes usage
docker system df -v

# Specific volume size
docker run --rm -v n8n_n8n_data:/data alpine du -sh /data

# Container filesystem usage
docker exec n8n df -h

# System disk usage
df -h /var/lib/docker

# Large files in container
docker exec n8n find /home/node/.n8n -type f -size +100M -exec ls -lh {} \;
```

### **Network Monitoring**
```bash
# Container network stats
docker exec n8n netstat -i

# Network connections
docker exec n8n netstat -tuln

# Check port accessibility
telnet localhost 5678
curl -I http://localhost:5678/healthz

# Docker network info
docker network ls
docker network inspect n8n_n8n_network
```

## 🔧 **Maintenance Operations**

### **Database Maintenance**
```bash
# Connect to PostgreSQL
docker compose exec postgres psql -U n8n -d n8n

# Database size
docker compose exec postgres psql -U n8n -d n8n -c "SELECT pg_size_pretty(pg_database_size('n8n'));"

# Table sizes
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"

# Vacuum database
docker compose exec postgres psql -U n8n -d n8n -c "VACUUM ANALYZE;"

# Database backup
docker compose exec postgres pg_dump -U n8n n8n > backup-$(date +%Y%m%d).sql
```

### **Log Rotation**
```bash
# Manual log rotation
docker compose logs n8n > n8n-$(date +%Y%m%d).log
docker compose restart n8n

# Setup logrotate
sudo tee /etc/logrotate.d/n8n << EOF
/var/lib/docker/containers/*/*-json.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
    postrotate
        docker kill --signal=USR1 \$(docker ps -q) 2>/dev/null || true
    endscript
}
EOF
```

### **Cleanup Operations**
```bash
# Remove unused Docker resources
docker system prune -f

# Remove unused volumes
docker volume prune -f

# Remove unused images
docker image prune -f

# Clean n8n execution data (older than 30 days)
docker compose exec postgres psql -U n8n -d n8n -c "
DELETE FROM execution_entity 
WHERE \"startedAt\" < NOW() - INTERVAL '30 days';"

# Clean old logs
find /var/log -name "*.log" -mtime +7 -delete
```

## 🔄 **Backup & Recovery Operations**

### **Full Backup**
```bash
#!/bin/bash
# backup-n8n.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$DATE"
mkdir -p $BACKUP_DIR

echo "🔄 Starting N8N backup..."

# Backup n8n data volume
echo "📁 Backing up n8n data..."
docker run --rm -v n8n_n8n_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine \
    tar czf /backup/n8n-data.tar.gz -C /data .

# Backup database
echo "🗄️ Backing up database..."
docker compose exec -T postgres pg_dump -U n8n n8n > $BACKUP_DIR/database.sql

# Backup docker-compose files
echo "📋 Backing up configuration..."
cp docker-compose.yml $BACKUP_DIR/
cp .env $BACKUP_DIR/env-backup

# Create backup info
echo "📝 Creating backup info..."
cat > $BACKUP_DIR/backup-info.txt << EOF
Backup Date: $(date)
N8N Version: $(docker inspect n8n --format='{{.Config.Image}}')
Database Size: $(docker compose exec postgres psql -U n8n -d n8n -t -c "SELECT pg_size_pretty(pg_database_size('n8n'));" | xargs)
Data Size: $(docker run --rm -v n8n_n8n_data:/data alpine du -sh /data | cut -f1)
EOF

echo "✅ Backup completed: $BACKUP_DIR"
```

### **Restore Operations**
```bash
#!/bin/bash
# restore-n8n.sh

BACKUP_DIR=$1
if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 <backup-directory>"
    exit 1
fi

echo "🔄 Starting N8N restore from $BACKUP_DIR..."

# Stop services
echo "⏹️ Stopping services..."
docker compose down

# Restore n8n data
echo "📁 Restoring n8n data..."
docker run --rm -v n8n_n8n_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine \
    tar xzf /backup/n8n-data.tar.gz -C /data

# Restore database
echo "🗄️ Restoring database..."
docker compose up -d postgres
sleep 10
docker compose exec -T postgres psql -U n8n -d n8n < $BACKUP_DIR/database.sql

# Start all services
echo "▶️ Starting services..."
docker compose up -d

echo "✅ Restore completed!"
```

### **Automated Backup Schedule**
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /path/to/backup-n8n.sh

# Weekly cleanup (keep only 4 weeks)
0 3 * * 0 find /path/to/backups -type d -mtime +28 -exec rm -rf {} \;
```

## 🚨 **Troubleshooting Operations**

### **Health Check Commands**
```bash
# Application health
curl -f http://localhost:5678/healthz || echo "❌ N8N not healthy"

# Container health
docker inspect n8n --format='{{.State.Health.Status}}'

# Service connectivity
docker compose exec n8n ping postgres
docker compose exec n8n ping redis

# Port accessibility
nmap -p 5678 localhost
telnet localhost 5678
```

### **Performance Diagnostics**
```bash
# Check slow queries (PostgreSQL)
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;"

# Check connection count
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT count(*) as connections 
FROM pg_stat_activity 
WHERE state = 'active';"

# Memory usage inside container
docker exec n8n cat /proc/meminfo

# Process list inside container
docker exec n8n ps aux --sort=-%mem
```

### **Error Investigation**
```bash
# Check container exit codes
docker compose ps -a

# Inspect container for errors
docker inspect n8n | jq '.State'

# Check system events
docker events --filter container=n8n

# Application-specific logs
docker compose logs n8n | grep -i error
docker compose logs n8n | grep -i warning
```

## 📈 **Performance Optimization**

### **Database Optimization**
```bash
# Analyze database performance
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation 
FROM pg_stats 
WHERE schemaname = 'public';"

# Update database statistics
docker compose exec postgres psql -U n8n -d n8n -c "ANALYZE;"

# Check index usage
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;"
```

### **Container Optimization**
```bash
# Optimize Docker daemon
sudo tee /etc/docker/daemon.json << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker
```

## 🔐 **Security Operations**

### **Security Audit**
```bash
# Check container security
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image n8nio/n8n:latest

# Check for exposed ports
nmap -sS localhost

# Audit file permissions
docker exec n8n find /home/node/.n8n -type f -perm /o+w

# Check environment variables
docker inspect n8n | jq '.Config.Env'
```

### **Password Management**
```bash
# Generate secure passwords
openssl rand -base64 32

# Update passwords
docker compose down
# Edit .env file with new passwords
docker compose up -d
```

## 📋 **Daily Operations Checklist**

### **Morning Check (5 minutes)**
- [ ] Check container status: `docker compose ps`
- [ ] Check application health: `curl http://localhost:5678/healthz`
- [ ] Review overnight logs: `docker compose logs --since="24h" n8n | grep -i error`
- [ ] Check disk space: `df -h`
- [ ] Check memory usage: `free -h`

### **Weekly Maintenance (30 minutes)**
- [ ] Review resource usage trends
- [ ] Clean up old logs and unused Docker resources
- [ ] Update containers if needed
- [ ] Test backup and restore procedures
- [ ] Review security logs
- [ ] Check for N8N updates

### **Monthly Operations (1 hour)**
- [ ] Full system backup
- [ ] Database maintenance (vacuum, analyze)
- [ ] Security audit
- [ ] Performance review
- [ ] Update documentation
- [ ] Review and rotate passwords

## 🎯 **Quick Reference Commands**

```bash
# Essential commands
docker compose ps                    # Status
docker compose logs -f n8n          # Logs
docker stats n8n                    # Resources
docker compose restart n8n          # Restart
docker compose down && docker compose up -d  # Full restart

# Backup
./backup-n8n.sh                     # Full backup
docker compose exec postgres pg_dump -U n8n n8n > db-backup.sql  # DB only

# Monitoring
curl http://localhost:5678/healthz  # Health check
docker inspect n8n --format='{{.State.Health.Status}}'  # Container health
htop                                 # System resources

# Troubleshooting
docker compose logs n8n | grep -i error  # Errors
docker exec n8n ps aux              # Container processes
docker network inspect n8n_n8n_network  # Network info
```

Sổ tay này cung cấp tất cả commands và procedures cần thiết để vận hành n8n hiệu quả!