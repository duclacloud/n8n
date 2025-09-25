# N8N Docker Deployment Guide

## 🚀 **Quick Start Deployment**

### **Bước 1: Chuẩn Bị Môi Trường**
```bash
# Cài Docker và Docker Compose
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker

# Kiểm tra cài đặt
docker --version
docker compose version
```

### **Bước 2: Clone Repository**
```bash
# Tạo thư mục project
mkdir -p ~/n8n-docker
cd ~/n8n-docker

# Copy docker-compose.yml từ repository này
cp /ducla-cloud/n8n/docker-compose.yml .
```

### **Bước 3: Cấu Hình Environment**
```bash
# Tạo file .env
cat > .env << EOF
# N8N Configuration
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password_here
N8N_HOST=localhost
N8N_PORT=5678
WEBHOOK_URL=http://localhost:5678/

# Database Configuration (for production)
POSTGRES_DB=n8n
POSTGRES_USER=n8n
POSTGRES_PASSWORD=your_db_password_here

# Redis Configuration (for production)
REDIS_PASSWORD=your_redis_password_here

# Timezone
GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
EOF

# Bảo mật file .env
chmod 600 .env
```

## 🎯 **Deployment Options**

### **Option 1: Development (Single Container)**
```bash
# Chỉ chạy n8n container
docker compose up -d n8n

# Kiểm tra status
docker compose ps
docker compose logs -f n8n
```

### **Option 2: Production (Full Stack)**
```bash
# Chạy full stack với database và redis
docker compose --profile production up -d

# Kiểm tra tất cả services
docker compose ps
```

### **Option 3: Custom Configuration**
```bash
# Tạo custom docker-compose override
cat > docker-compose.override.yml << EOF
version: '3.8'
services:
  n8n:
    ports:
      - "8080:5678"  # Custom port
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
EOF

# Deploy với override
docker compose up -d
```

## 🔧 **Configuration Options**

### **Basic Configuration**
```yaml
# Minimal setup
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=secure_password
    volumes:
      - n8n_data:/home/node/.n8n
```

### **Advanced Configuration**
```yaml
# Production setup with database
services:
  n8n:
    image: n8nio/n8n:latest
    depends_on:
      - postgres
      - redis
    environment:
      # Database
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=db_password
      
      # Queue
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_PASSWORD=redis_password
      
      # Security
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=secure_password
```

## 🌐 **Network Configuration**

### **Internal Network**
```yaml
# Isolated network for security
networks:
  n8n_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### **External Access**
```bash
# Firewall configuration
sudo ufw allow 5678/tcp
sudo ufw enable

# Nginx reverse proxy (optional)
sudo apt install nginx
```

### **SSL/TLS Setup**
```nginx
# /etc/nginx/sites-available/n8n
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 📊 **Storage Configuration**

### **Volume Management**
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect n8n_n8n_data

# Backup volume
docker run --rm -v n8n_n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .

# Restore volume
docker run --rm -v n8n_n8n_data:/data -v $(pwd):/backup alpine tar xzf /backup/n8n-backup.tar.gz -C /data
```

### **Custom Storage Paths**
```yaml
# Custom bind mounts
services:
  n8n:
    volumes:
      - ./n8n-data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows
      - ./credentials:/home/node/.n8n/credentials
```

## 🔍 **Health Checks & Monitoring**

### **Built-in Health Check**
```yaml
# Health check configuration
healthcheck:
  test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:5678/healthz"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### **Custom Health Check Script**
```bash
#!/bin/bash
# health-check.sh

# Check if n8n is responding
if curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "✅ N8N is healthy"
    exit 0
else
    echo "❌ N8N is not responding"
    exit 1
fi
```

## 🚨 **Troubleshooting Deployment**

### **Common Issues**

#### **1. Port Already in Use**
```bash
# Check what's using port 5678
sudo netstat -tulpn | grep 5678
sudo lsof -i :5678

# Kill process or change port
docker compose down
# Edit docker-compose.yml to use different port
docker compose up -d
```

#### **2. Permission Issues**
```bash
# Fix volume permissions
sudo chown -R 1000:1000 ./n8n-data

# Fix Docker socket permissions
sudo chmod 666 /var/run/docker.sock
```

#### **3. Database Connection Issues**
```bash
# Check database logs
docker compose logs postgres

# Test database connection
docker compose exec postgres psql -U n8n -d n8n -c "SELECT version();"
```

#### **4. Memory Issues**
```bash
# Check container memory usage
docker stats n8n

# Check system memory
free -h
df -h
```

### **Debug Mode**
```yaml
# Enable debug logging
services:
  n8n:
    environment:
      - N8N_LOG_LEVEL=debug
      - DEBUG=n8n*
```

## 📋 **Deployment Checklist**

### **Pre-deployment**
- [ ] Docker và Docker Compose đã cài đặt
- [ ] Ports 5678 available (hoặc custom port)
- [ ] Sufficient disk space (>2GB recommended)
- [ ] RAM available (>1GB recommended)
- [ ] Network connectivity
- [ ] Backup strategy planned

### **During Deployment**
- [ ] Environment variables configured
- [ ] Passwords changed from defaults
- [ ] Volumes properly mounted
- [ ] Network configuration correct
- [ ] Health checks passing

### **Post-deployment**
- [ ] Application accessible via browser
- [ ] Authentication working
- [ ] Workflows can be created
- [ ] Database connectivity (if using external DB)
- [ ] Backup tested
- [ ] Monitoring configured

## 🔄 **Update & Maintenance**

### **Update N8N**
```bash
# Pull latest image
docker compose pull n8n

# Recreate container with new image
docker compose up -d --force-recreate n8n

# Verify update
docker compose logs n8n
```

### **Backup Before Update**
```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$DATE"

mkdir -p $BACKUP_DIR

# Backup volumes
docker run --rm -v n8n_n8n_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/n8n-data.tar.gz -C /data .

# Backup database (if using postgres)
docker compose exec -T postgres pg_dump -U n8n n8n > $BACKUP_DIR/database.sql

echo "Backup completed: $BACKUP_DIR"
EOF

chmod +x backup.sh
./backup.sh
```

## 🎯 **Production Deployment**

### **Production docker-compose.yml**
```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:1.15.0  # Pin specific version
    container_name: n8n_prod
    restart: unless-stopped
    depends_on:
      - postgres
      - redis
    ports:
      - "127.0.0.1:5678:5678"  # Bind to localhost only
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_PASSWORD=${REDIS_PASSWORD}
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://${N8N_HOST}/
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_LOG_LEVEL=warn
      - N8N_METRICS=true
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  postgres:
    image: postgres:15-alpine
    container_name: n8n_postgres_prod
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - n8n_network

  redis:
    image: redis:7-alpine
    container_name: n8n_redis_prod
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - n8n_network

volumes:
  n8n_data:
  postgres_data:
  redis_data:

networks:
  n8n_network:
    driver: bridge
```

### **Production Environment File**
```bash
# .env.production
N8N_USER=admin
N8N_PASSWORD=very_secure_password_2024!
N8N_HOST=your-domain.com
POSTGRES_PASSWORD=secure_db_password_2024!
REDIS_PASSWORD=secure_redis_password_2024!
```

### **Deploy to Production**
```bash
# Copy production files
cp .env.production .env
cp docker-compose.prod.yml docker-compose.yml

# Deploy
docker compose up -d

# Verify deployment
docker compose ps
docker compose logs -f
```

Deployment guide này cung cấp tất cả thông tin cần thiết để deploy n8n thành công!