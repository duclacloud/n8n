# N8N Docker Deployment - Complete Guide

## 📁 **Cấu Trúc Thư Mục**

```
n8n/
├── docker-compose.yml          # Docker Compose configuration
├── n8n-best-practices.md      # Best practices guide
├── deployment-guide.md         # Deployment instructions
├── operations-manual.md        # Operations manual
├── monitoring-guide.md         # Monitoring & resource management
└── README.md                   # This file
```

## 🚀 **Quick Start**

### **1. Cài Đặt Nhanh**
```bash
# Clone repository
cd /ducla-cloud/n8n

# Tạo environment file
cp .env.example .env
# Edit .env với passwords của bạn

# Start n8n (sử dụng script)
./n8n.sh start
# hoac su dung cli
docker compose up -d

# Check status
./n8n.sh status
# hoac su dung cli
docker compose ps
```

### **2. Sử Dụng Script Đơn Giản**
```bash
# Quản lý N8N với 1 script duy nhất
./n8n.sh start     # Khởi động
./n8n.sh stop      # Dừng
./n8n.sh restart   # Khởi động lại
./n8n.sh status    # Kiểm tra trạng thái
./n8n.sh logs      # Xem logs
./n8n.sh backup    # Sao lưu
./n8n.sh help      # Trợ giúp
```

### **2. Truy Cập N8N**
- **URL**: http://localhost:5678
- **Username**: admin
- **Password**: (xem trong file .env)

## 📚 **Tài Liệu Hướng Dẫn**

### **🎯 [Best Practices Guide](./n8n-best-practices.md)**
- Architecture best practices
- Security recommendations
- Performance optimization
- Backup & recovery strategies
- Production deployment guidelines

### **🚀 [Deployment Guide](./deployment-guide.md)**
- Step-by-step deployment instructions
- Environment configuration
- Network setup
- SSL/TLS configuration
- Production deployment
- Troubleshooting common issues

### **🎛️ [Operations Manual](./operations-manual.md)**
- Start/Stop/Restart commands
- Container management
- Logs management
- Backup & restore procedures
- Maintenance operations
- Daily/Weekly/Monthly checklists

### **📊 [Monitoring Guide](./monitoring-guide.md)**
- RAM monitoring
- CPU monitoring
- Storage monitoring
- Performance metrics
- Alerting system
- Health checks

## ⚡ **Quick Commands**

### **Script Commands (Đơn Giản)**
```bash
# Tất cả trong 1 script
./n8n.sh start     # Khởi động
./n8n.sh stop      # Dừng
./n8n.sh restart   # Khởi động lại
./n8n.sh status    # Kiểm tra trạng thái
./n8n.sh logs      # Xem logs
./n8n.sh backup    # Sao lưu
```

### **Docker Commands (Nâng Cao)**
```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart n8n
docker compose restart n8n

# View logs
docker compose logs -f n8n

# Check status
docker compose ps
```

### **Resource Monitoring**
```bash
# Real-time resource usage
docker stats n8n

# System resources
htop
free -h
df -h

# Application health
curl http://localhost:5678/healthz
```

### **Backup & Restore**
```bash
# Quick backup
docker run --rm -v n8n_n8n_data:/data -v $(pwd):/backup alpine \
    tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz -C /data .

# Database backup
docker compose exec postgres pg_dump -U n8n n8n > n8n-db-$(date +%Y%m%d).sql
```

## 🔧 **Configuration Files**

### **docker-compose.yml**
- Main Docker Compose configuration
- Includes n8n, PostgreSQL, and Redis services
- Development and production profiles
- Health checks and networking

### **Environment Variables**
```bash
# Core N8N settings
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password
N8N_HOST=localhost
N8N_PORT=5678

# Database settings (production)
POSTGRES_DB=n8n
POSTGRES_USER=n8n
POSTGRES_PASSWORD=your_db_password

# Redis settings (production)
REDIS_PASSWORD=your_redis_password
```

## 🏗️ **Architecture Options**

### **Development Setup**
- Single n8n container
- SQLite database (built-in)
- Local file storage
- Basic authentication

### **Production Setup**
- N8N application container
- PostgreSQL database
- Redis for queues
- Nginx reverse proxy (optional)
- SSL/TLS certificates

## 🔒 **Security Features**

- Basic authentication enabled
- Custom Docker network isolation
- Environment variables for secrets
- Health checks for monitoring
- Read-only Docker socket access
- Container restart policies

## 📈 **Monitoring & Alerting**

### **Built-in Monitoring**
- Container health checks
- Resource usage tracking
- Application health endpoint
- Log aggregation

### **Custom Monitoring Scripts**
- CPU/Memory/Disk monitoring
- Automated alerting
- Performance metrics collection
- Health dashboard

## 🔄 **Backup Strategy**

### **Automated Backups**
- Daily data backups
- Database dumps
- Configuration backups
- Retention policies

### **Recovery Procedures**
- Point-in-time recovery
- Full system restore
- Disaster recovery planning

## 🚨 **Troubleshooting**

### **Common Issues**
1. **Port conflicts**: Change port in docker-compose.yml
2. **Permission issues**: Check volume permissions
3. **Memory issues**: Monitor with `docker stats`
4. **Database connection**: Check PostgreSQL logs

### **Debug Commands**
```bash
# Check container logs
docker compose logs n8n

# Check container status
docker inspect n8n

# Test connectivity
docker compose exec n8n ping postgres

# Check resources
docker stats n8n
```

## 📋 **Maintenance Schedule**

### **Daily (5 minutes)**
- [ ] Check container status
- [ ] Monitor resource usage
- [ ] Review error logs
- [ ] Verify application health

### **Weekly (30 minutes)**
- [ ] Update containers
- [ ] Clean up old logs
- [ ] Review performance metrics
- [ ] Test backup procedures

### **Monthly (1 hour)**
- [ ] Security audit
- [ ] Capacity planning
- [ ] Update documentation
- [ ] Review and optimize

## 🎯 **Production Checklist**

### **Before Deployment**
- [ ] Strong passwords configured
- [ ] SSL certificates ready
- [ ] Database setup completed
- [ ] Backup strategy implemented
- [ ] Monitoring configured
- [ ] Security review completed

### **After Deployment**
- [ ] Application accessible
- [ ] Authentication working
- [ ] Database connectivity verified
- [ ] Backups tested
- [ ] Monitoring alerts configured
- [ ] Performance baseline established

## 🔗 **Useful Links**

- [N8N Official Documentation](https://docs.n8n.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)

## 💡 **Tips & Tricks**

1. **Use specific image versions** in production
2. **Enable metrics** for monitoring
3. **Regular database maintenance** (vacuum, analyze)
4. **Monitor disk space** regularly
5. **Test backup/restore** procedures
6. **Use environment variables** for configuration
7. **Implement proper logging** rotation
8. **Regular security updates**

## 🆘 **Support**

Nếu gặp vấn đề:
1. Kiểm tra logs: `docker compose logs n8n`
2. Xem monitoring guide để debug
3. Tham khảo troubleshooting section
4. Kiểm tra N8N community forum

---

**Happy Automating with N8N! 🚀**