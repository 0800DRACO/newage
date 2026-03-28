# RealVest - Complete Deployment Guide

## System Requirements

| Component | Requirement |
|-----------|-------------|
| PHP | 8.3+ |
| MySQL | 8.0+ |
| Docker | Latest |
| RAM | 2GB minimum |
| Storage | 50GB |

## Architecture

```
Client Browser
     ↓
Nginx (80/443)
     ↓
PHP-FPM 8.3
     ↓
  Laravel 11
     ↓
MySQL 8.0
```

## Deployment Options

### Option 1: DigitalOcean App Platform (Recommended)

1. Login to DigitalOcean Dashboard
2. Create → App Platform
3. Connect GitHub repository
4. Auto-detect Dockerfile
5. Add MySQL database
6. Configure environment variables
7. Deploy

**Deployment Time:** 3-5 minutes  
**Cost:** $12/month (App Platform includes hosting + managed DB)

### Option 2: Self-Hosted on Droplet

1. Create Ubuntu 24.04 Droplet
2. SSH into droplet
3. Install Docker
4. Clone repository
5. Run deploy script

**Deployment Time:** 10-15 minutes  
**Cost:** $6/month (Droplet) + database storage

### Option 3: Manual Docker Deployment

```bash
mkdir -p data/mysql
docker-compose build
docker-compose up -d
docker-compose exec app php artisan migrate
```

## Environment Configuration

Edit `.env` before deployment:

```env
# Required
APP_URL=https://yourdomain.com
APP_ENV=production
APP_DEBUG=false
DB_PASSWORD=YOUR_STRONG_PASSWORD

# Optional
STRIPE_PUBLIC_KEY=YOUR_KEY
STRIPE_SECRET_KEY=YOUR_KEY
MAIL_HOST=smtp.mailtrap.io
```

## Database

Database is automatically initialized with schema from `install/database.sql`.

Default admin:
- Email: admin@site.com
- Password: Set during deployment

## Security

✅ CSRF Protection  
✅ SQL Injection Prevention  
✅ XSS Protection  
✅ Bcrypt Hashing  
✅ Security Headers  
✅ SSL/TLS Ready  

**Post-Deployment:**
- [ ] Change admin password
- [ ] Enable HTTPS
- [ ] Configure firewall
- [ ] Setup automated backups

## Troubleshooting

### Services won't start
```bash
docker-compose logs app
docker-compose restart
```

### Database connection error
```bash
docker-compose exec db mysql -u root -p -e "SELECT 1"
```

### Permission denied
```bash
docker-compose exec app chmod -R 777 storage
```

## Scaling

- **Small:** Single 2GB Droplet
- **Medium:** 4GB Droplet + Managed Database
- **Large:** Load balanced + Separate database

## Support

- Laravel: https://laravel.com/docs
- Docker: https://docs.docker.com
- DigitalOcean: https://docs.digitalocean.com
