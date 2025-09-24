# N8N Best Practices Guide - Docker Deployment

## 🎯 Tổng Quan
Hướng dẫn best practices để deploy và vận hành n8n trên Docker một cách hiệu quả và an toàn.

## 🏗️ **Architecture Best Practices**

### **1. Container Strategy**
```yaml
# ✅ Recommended: Single container cho development
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n

# ✅ Recommended: Multi-container cho production
services:
  n8n:
    image: n8nio/n8n:latest
  postgres:
    image: postgres:15-alpine
  redis:
    image: redis:7-alpine
```

### **2. Data Persistence**
```yaml
# ✅ Named volumes (Recommended)
volumes:
  n8n_data:
    driver: local

# ❌ Bind mounts (Avoid for production)
volumes:
  - ./data:/home/node/.n8n
```

### **3. Network Isolation**
```yaml
# ✅ Custom network
networks:
  n8n_network:
    driver: bridge

# ✅ Internal communication
services:
  n8n:
    networks:
      - n8n_network
```

## 🔒 **Security Best Practices**

### **1. Authentication & Authorization**
```bash
# ✅ Strong passwords
N8N_BASIC_AUTH_PASSWORD=ComplexPassword123!@#

# ✅ Disable unnecessary features
N8N_DIAGNOSTICS_ENABLED=false
N8N_VERSION_NOTIFICATIONS_ENABLED=false
N8N_HIRING_BANNER_ENABLED=false
```

### **2. Environment Variables Security**
```bash
# ✅ Use .env file
echo "N8N_BASIC_AUTH_PASSWORD=your_secure_password" > .env

# ✅ Set proper permissions
chmod 600 .env
```

### **3. Container Security**
```yaml
# ✅ Health checks
healthcheck:
  test: ["CMD", "wget", "--spider", "http://localhost:5678/healthz"]
  interval: 30s
  timeout: 10s
  retries: 3

# ✅ Restart policy
restart: unless-stopped

# ✅ Read-only Docker socket (if needed)
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
```

## 📊 **Performance Best Practices**

### **1. Resource Optimization**
```yaml
# ✅ Efficient image
image: n8nio/n8n:latest  # Use specific version in production

# ✅ Timezone configuration
environment:
  - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh

# ✅ Log level optimization
environment:
  - N8N_LOG_LEVEL=info  # Use 'warn' or 'error' in production
```

### **2. Database Configuration**
```yaml
# ✅ PostgreSQL for production
postgres:
  image: postgres:15-alpine
  environment:
    - POSTGRES_DB=n8n
    - POSTGRES_USER=n8n
    - POSTGRES_PASSWORD=secure_password

# ✅ Connection pooling
environment:
  - DB_POSTGRESDB_HOST=postgres
  - DB_POSTGRESDB_PORT=5432
  - DB_POSTGRESDB_DATABASE=n8n
  - DB_POSTGRESDB_USER=n8n
  - DB_POSTGRESDB_PASSWORD=secure_password
```

### **3. Caching Strategy**
```yaml
# ✅ Redis for queue management
redis:
  image: redis:7-alpine
  command: redis-server --requirepass redis_password

# ✅ Queue configuration
environment:
  - QUEUE_BULL_REDIS_HOST=redis
  - QUEUE_BULL_REDIS_PORT=6379
  - QUEUE_BULL_REDIS_PASSWORD=redis_password
```

## 🔄 **Backup & Recovery Best Practices**

### **1. Data Backup Strategy**
```bash
# ✅ Volume backup
docker run --rm -v n8n_n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz -C /data .

# ✅ Database backup
docker exec n8n_postgres pg_dump -U n8n n8n > n8n-db-backup-$(date +%Y%m%d).sql
```

### **2. Automated Backup**
```bash
# ✅ Cron job for daily backup
0 2 * * * /path/to/backup-script.sh
```

## 🚀 **Deployment Best Practices**

### **1. Environment Separation**
```bash
# ✅ Development
docker-compose up -d

# ✅ Production with profiles
docker-compose --profile production up -d
```

### **2. Configuration Management**
```bash
# ✅ Environment-specific configs
cp .env.example .env.development
cp .env.example .env.production

# ✅ Use different compose files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### **3. Health Monitoring**
```bash
# ✅ Container health check
docker-compose ps
docker-compose logs -f n8n

# ✅ Application health
curl http://localhost:5678/healthz
```

## 📈 **Monitoring Best Practices**

### **1. Metrics Collection**
```yaml
# ✅ Enable metrics
environment:
  - N8N_METRICS=true
  - N8N_METRICS_PREFIX=n8n_
```

### **2. Log Management**
```yaml
# ✅ Log configuration
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### **3. Resource Monitoring**
```bash
# ✅ Container stats
docker stats n8n

# ✅ System resources
htop
df -h
```

## 🔧 **Maintenance Best Practices**

### **1. Regular Updates**
```bash
# ✅ Update strategy
docker-compose pull
docker-compose up -d --force-recreate

# ✅ Version pinning for production
image: n8nio/n8n:1.15.0  # Specific version
```

### **2. Cleanup Strategy**
```bash
# ✅ Remove unused resources
docker system prune -f
docker volume prune -f

# ✅ Log rotation
docker-compose logs --tail=1000 n8n > n8n.log
```

## 🚨 **Troubleshooting Best Practices**

### **1. Common Issues**
```bash
# ✅ Check container status
docker-compose ps
docker-compose logs n8n

# ✅ Check resource usage
docker stats n8n
df -h /var/lib/docker

# ✅ Network connectivity
docker-compose exec n8n ping postgres
```

### **2. Debug Mode**
```yaml
# ✅ Enable debug logging
environment:
  - N8N_LOG_LEVEL=debug
  - DEBUG=n8n*
```

## 📋 **Production Checklist**

### **Pre-deployment**
- [ ] Strong passwords configured
- [ ] Database setup (PostgreSQL)
- [ ] Redis configured for queues
- [ ] SSL/TLS certificates ready
- [ ] Backup strategy implemented
- [ ] Monitoring setup
- [ ] Resource limits defined
- [ ] Health checks configured

### **Post-deployment**
- [ ] Application accessible
- [ ] Authentication working
- [ ] Database connectivity verified
- [ ] Backup tested
- [ ] Monitoring alerts configured
- [ ] Performance baseline established
- [ ] Documentation updated

## 🎯 **Key Recommendations**

### **Development Environment**
- Use basic setup with SQLite
- Enable debug logging
- Use bind mounts for development
- Disable authentication for local testing

### **Production Environment**
- Use PostgreSQL database
- Enable Redis for queues
- Implement proper backup strategy
- Use specific image versions
- Enable monitoring and alerting
- Implement SSL/TLS
- Use secrets management
- Regular security updates

### **Scaling Considerations**
- Horizontal scaling with multiple n8n instances
- Load balancer configuration
- Database connection pooling
- Queue management with Redis
- Shared storage for workflows

## 💡 **Performance Tips**

1. **Use PostgreSQL** instead of SQLite for production
2. **Enable Redis** for better queue management
3. **Optimize workflows** to reduce execution time
4. **Monitor resource usage** regularly
5. **Use caching** where appropriate
6. **Implement proper indexing** in database
7. **Regular cleanup** of old executions
8. **Use webhooks** instead of polling when possible

## 🔐 **Security Recommendations**

1. **Change default passwords** immediately
2. **Use environment variables** for secrets
3. **Enable HTTPS** in production
4. **Regular security updates**
5. **Network isolation** with Docker networks
6. **Principle of least privilege**
7. **Regular security audits**
8. **Backup encryption**

Tuân thủ các best practices này sẽ đảm bảo n8n chạy ổn định, an toàn và hiệu quả!