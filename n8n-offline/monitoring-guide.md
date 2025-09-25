# N8N Monitoring Guide - Kiểm Tra RAM, CPU, Storage

## 📊 **Real-time Resource Monitoring**

### **Docker Stats - Giám Sát Tức Thì**
```bash
# Xem resource usage real-time
docker stats n8n

# Format output đẹp hơn
docker stats n8n --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"

# Continuous monitoring (refresh mỗi 2 giây)
watch -n 2 'docker stats --no-stream n8n'

# Export stats to file
docker stats --no-stream n8n >> n8n-stats-$(date +%Y%m%d).log
```

### **System Resource Overview**
```bash
# Tổng quan hệ thống
htop

# Memory usage
free -h

# Disk usage
df -h

# CPU info
lscpu
cat /proc/cpuinfo | grep "model name" | head -1
```

## 🧠 **Memory (RAM) Monitoring**

### **Container Memory Usage**
```bash
# Memory usage chi tiết
docker exec n8n cat /proc/meminfo

# Memory usage của processes trong container
docker exec n8n ps aux --sort=-%mem | head -10

# Memory limit của container
docker inspect n8n | grep -i memory

# Memory usage theo thời gian
while true; do
    echo "$(date): $(docker stats --no-stream n8n --format '{{.MemUsage}}')"
    sleep 60
done
```

### **System Memory Analysis**
```bash
# Detailed memory info
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached"

# Memory usage by process
ps aux --sort=-%mem | head -20

# Memory usage của Docker
sudo du -sh /var/lib/docker

# Check for memory leaks
sudo slabtop
```

### **Memory Alerts Script**
```bash
#!/bin/bash
# memory-alert.sh

CONTAINER_NAME="n8n"
THRESHOLD=80  # 80% memory usage

MEMORY_USAGE=$(docker stats --no-stream $CONTAINER_NAME --format "{{.MemPerc}}" | sed 's/%//')

if (( $(echo "$MEMORY_USAGE > $THRESHOLD" | bc -l) )); then
    echo "⚠️ ALERT: $CONTAINER_NAME memory usage is ${MEMORY_USAGE}%"
    # Send notification (email, Slack, etc.)
    # curl -X POST -H 'Content-type: application/json' \
    #   --data '{"text":"N8N Memory Alert: '${MEMORY_USAGE}'%"}' \
    #   YOUR_SLACK_WEBHOOK_URL
else
    echo "✅ Memory usage normal: ${MEMORY_USAGE}%"
fi
```

## ⚡ **CPU Monitoring**

### **Container CPU Usage**
```bash
# CPU usage real-time
docker exec n8n top -bn1 | head -20

# CPU usage của container
docker stats --no-stream n8n --format "{{.CPUPerc}}"

# Process CPU usage trong container
docker exec n8n ps aux --sort=-%cpu | head -10

# CPU usage theo thời gian
while true; do
    echo "$(date): $(docker stats --no-stream n8n --format '{{.CPUPerc}}')"
    sleep 60
done
```

### **System CPU Analysis**
```bash
# CPU load average
uptime

# Detailed CPU usage
iostat -c 1 5

# CPU usage by process
top -o %CPU

# CPU temperature (if available)
sensors | grep -i temp

# CPU frequency
cat /proc/cpuinfo | grep "cpu MHz"
```

### **CPU Performance Script**
```bash
#!/bin/bash
# cpu-monitor.sh

CONTAINER_NAME="n8n"
DURATION=300  # 5 minutes

echo "🔍 Monitoring CPU usage for $DURATION seconds..."

for i in $(seq 1 $DURATION); do
    CPU_USAGE=$(docker stats --no-stream $CONTAINER_NAME --format "{{.CPUPerc}}" | sed 's/%//')
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "$TIMESTAMP,$CPU_USAGE" >> cpu-usage-log.csv
    
    if (( $(echo "$CPU_USAGE > 90" | bc -l) )); then
        echo "⚠️ HIGH CPU: ${CPU_USAGE}% at $TIMESTAMP"
    fi
    
    sleep 1
done

echo "✅ CPU monitoring completed. Check cpu-usage-log.csv"
```

## 💾 **Storage Monitoring**

### **Container Storage Usage**
```bash
# Container filesystem usage
docker exec n8n df -h

# N8N data directory size
docker exec n8n du -sh /home/node/.n8n

# Detailed directory sizes
docker exec n8n du -h /home/node/.n8n/* | sort -hr

# Large files trong container
docker exec n8n find /home/node/.n8n -type f -size +10M -exec ls -lh {} \;

# Docker volume size
docker run --rm -v n8n_n8n_data:/data alpine du -sh /data
```

### **System Storage Analysis**
```bash
# Docker system usage
docker system df

# Detailed volume info
docker system df -v

# Docker images size
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# System disk usage
df -h /var/lib/docker

# Inode usage
df -i

# Large files on system
find /var/lib/docker -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

### **Database Storage Monitoring**
```bash
# PostgreSQL database size
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT 
    pg_size_pretty(pg_database_size('n8n')) as database_size;"

# Table sizes
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    pg_total_relation_size(schemaname||'.'||tablename) as bytes
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY bytes DESC;"

# Index sizes
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes 
ORDER BY pg_relation_size(indexrelid) DESC;"
```

### **Storage Cleanup Script**
```bash
#!/bin/bash
# storage-cleanup.sh

echo "🧹 Starting storage cleanup..."

# Clean Docker system
echo "Cleaning Docker system..."
docker system prune -f

# Clean old logs
echo "Cleaning old logs..."
find /var/log -name "*.log" -mtime +7 -delete 2>/dev/null

# Clean old executions (older than 30 days)
echo "Cleaning old N8N executions..."
docker compose exec postgres psql -U n8n -d n8n -c "
DELETE FROM execution_entity 
WHERE \"startedAt\" < NOW() - INTERVAL '30 days';"

# Vacuum database
echo "Vacuuming database..."
docker compose exec postgres psql -U n8n -d n8n -c "VACUUM ANALYZE;"

echo "✅ Storage cleanup completed"

# Show current usage
echo "📊 Current storage usage:"
docker system df
df -h /var/lib/docker
```

## 📈 **Performance Metrics Collection**

### **Comprehensive Monitoring Script**
```bash
#!/bin/bash
# comprehensive-monitor.sh

CONTAINER_NAME="n8n"
LOG_FILE="n8n-metrics-$(date +%Y%m%d).log"
INTERVAL=60  # seconds

echo "🔍 Starting comprehensive monitoring..."
echo "Timestamp,CPU%,Memory_Usage,Memory%,Network_RX,Network_TX,Block_Read,Block_Write" > $LOG_FILE

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get container stats
    STATS=$(docker stats --no-stream $CONTAINER_NAME --format "{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}}")
    
    # Parse network and block IO
    NET_IO=$(echo $STATS | cut -d',' -f4)
    BLOCK_IO=$(echo $STATS | cut -d',' -f5)
    
    NET_RX=$(echo $NET_IO | cut -d'/' -f1 | tr -d ' ')
    NET_TX=$(echo $NET_IO | cut -d'/' -f2 | tr -d ' ')
    
    BLOCK_READ=$(echo $BLOCK_IO | cut -d'/' -f1 | tr -d ' ')
    BLOCK_WRITE=$(echo $BLOCK_IO | cut -d'/' -f2 | tr -d ' ')
    
    CPU=$(echo $STATS | cut -d',' -f1)
    MEM_USAGE=$(echo $STATS | cut -d',' -f2)
    MEM_PERCENT=$(echo $STATS | cut -d',' -f3)
    
    # Log metrics
    echo "$TIMESTAMP,$CPU,$MEM_USAGE,$MEM_PERCENT,$NET_RX,$NET_TX,$BLOCK_READ,$BLOCK_WRITE" >> $LOG_FILE
    
    # Display current stats
    echo "[$TIMESTAMP] CPU: $CPU | Memory: $MEM_USAGE ($MEM_PERCENT)"
    
    sleep $INTERVAL
done
```

### **Health Check Dashboard**
```bash
#!/bin/bash
# health-dashboard.sh

clear
echo "🎛️ N8N Health Dashboard"
echo "========================"

while true; do
    # Move cursor to top
    tput cup 3 0
    
    # Container status
    echo "📦 Container Status:"
    docker compose ps n8n
    echo ""
    
    # Resource usage
    echo "📊 Resource Usage:"
    docker stats --no-stream n8n --format "CPU: {{.CPUPerc}} | Memory: {{.MemUsage}} ({{.MemPerc}}) | Network: {{.NetIO}} | Block I/O: {{.BlockIO}}"
    echo ""
    
    # Application health
    echo "🏥 Application Health:"
    if curl -f -s http://localhost:5678/healthz > /dev/null; then
        echo "✅ N8N is responding"
    else
        echo "❌ N8N is not responding"
    fi
    echo ""
    
    # System resources
    echo "💻 System Resources:"
    echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5" used)"}')"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    
    # Database info
    echo "🗄️ Database Info:"
    DB_SIZE=$(docker compose exec -T postgres psql -U n8n -d n8n -t -c "SELECT pg_size_pretty(pg_database_size('n8n'));" 2>/dev/null | xargs)
    echo "Database size: ${DB_SIZE:-"N/A"}"
    echo ""
    
    echo "Last updated: $(date)"
    echo "Press Ctrl+C to exit"
    
    sleep 5
done
```

## 🚨 **Alerting System**

### **Resource Alert Script**
```bash
#!/bin/bash
# resource-alerts.sh

CONTAINER_NAME="n8n"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=85

# Function to send alert
send_alert() {
    local message="$1"
    echo "🚨 ALERT: $message"
    
    # Log alert
    echo "$(date): $message" >> alerts.log
    
    # Send to Slack (uncomment and configure)
    # curl -X POST -H 'Content-type: application/json' \
    #   --data "{\"text\":\"$message\"}" \
    #   YOUR_SLACK_WEBHOOK_URL
    
    # Send email (uncomment and configure)
    # echo "$message" | mail -s "N8N Alert" admin@yourcompany.com
}

# Check CPU usage
CPU_USAGE=$(docker stats --no-stream $CONTAINER_NAME --format "{{.CPUPerc}}" | sed 's/%//')
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    send_alert "High CPU usage: ${CPU_USAGE}%"
fi

# Check memory usage
MEMORY_USAGE=$(docker stats --no-stream $CONTAINER_NAME --format "{{.MemPerc}}" | sed 's/%//')
if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    send_alert "High memory usage: ${MEMORY_USAGE}%"
fi

# Check disk usage
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    send_alert "High disk usage: ${DISK_USAGE}%"
fi

# Check application health
if ! curl -f -s http://localhost:5678/healthz > /dev/null; then
    send_alert "N8N application is not responding"
fi

# Check container status
if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME)" != "true" ]; then
    send_alert "N8N container is not running"
fi
```

### **Automated Monitoring Setup**
```bash
# Add to crontab for automated monitoring
crontab -e

# Check every 5 minutes
*/5 * * * * /path/to/resource-alerts.sh

# Daily health report
0 9 * * * /path/to/daily-report.sh

# Weekly performance summary
0 10 * * 1 /path/to/weekly-summary.sh
```

## 📊 **Monitoring Tools Integration**

### **Prometheus Metrics (Optional)**
```yaml
# Add to docker-compose.yml
services:
  n8n:
    environment:
      - N8N_METRICS=true
      - N8N_METRICS_PREFIX=n8n_

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

### **Grafana Dashboard (Optional)**
```yaml
# Add to docker-compose.yml
services:
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
```

## 🎯 **Quick Monitoring Commands**

```bash
# Essential monitoring commands
docker stats n8n                    # Real-time stats
docker compose logs -f n8n          # Live logs
htop                                 # System overview
df -h                               # Disk usage
free -h                             # Memory usage
curl http://localhost:5678/healthz  # Health check

# Resource usage history
docker exec n8n cat /proc/meminfo   # Memory details
docker exec n8n ps aux --sort=-%mem # Memory by process
docker exec n8n ps aux --sort=-%cpu # CPU by process
docker system df                    # Docker storage

# Database monitoring
docker compose exec postgres psql -U n8n -d n8n -c "SELECT pg_size_pretty(pg_database_size('n8n'));"

# Performance analysis
iostat -x 1 5                      # I/O stats
sar -u 1 5                         # CPU utilization
sar -r 1 5                         # Memory utilization
```

## 📋 **Monitoring Checklist**

### **Daily Monitoring (5 minutes)**
- [ ] Check container status: `docker compose ps`
- [ ] Check resource usage: `docker stats n8n`
- [ ] Check application health: `curl http://localhost:5678/healthz`
- [ ] Review error logs: `docker compose logs n8n | grep -i error`
- [ ] Check disk space: `df -h`

### **Weekly Monitoring (15 minutes)**
- [ ] Analyze resource usage trends
- [ ] Check database size growth
- [ ] Review performance metrics
- [ ] Clean up old logs and data
- [ ] Test backup and restore

### **Monthly Monitoring (30 minutes)**
- [ ] Comprehensive performance review
- [ ] Capacity planning analysis
- [ ] Security audit
- [ ] Update monitoring thresholds
- [ ] Review and optimize queries

Monitoring guide này cung cấp tất cả tools và scripts cần thiết để theo dõi n8n hiệu quả!