# RealVest Payment Processing Platform

A production-ready Laravel 11 payment processing application with support for multiple payment gateways.

## Features

✅ Multi-gateway payment processing (Stripe, Razorpay, Bitcoin, Mollie, etc.)  
✅ Admin Dashboard  
✅ User Management  
✅ Transaction History  
✅ Email Notifications  
✅ API Support  
✅ Docker Ready  

## Quick Deploy

### 1. DigitalOcean App Platform (Easiest)
- Connection GitHub repo
- Click Deploy
- Done!

### 2. Self-Hosted Droplet
```bash
git clone YOUR_REPO
cd newage
chmod +x deploy.sh
./deploy.sh
```

## What's Included

📦 **Docker Setup**
- Dockerfile (PHP 8.3-FPM)
- docker-compose.yml (Complete stack)
- nginx.conf (Production web server)

🚀 **Deployment Files**
- deploy.sh (Automated deployment)
- healthcheck.sh (System monitoring)
- backup.sh (Database backups)

📚 **Documentation**
- QUICK_START.md (5-minute guide)
- DEPLOYMENT_GUIDE.md (Complete instructions)
- .env.production (Configuration template)

💾 **Database**
- MySQL 8.0 schema included
- Automated initialization
- Sample data ready

## System Requirements

- PHP 8.3+
- MySQL 8.0+
- Docker & Docker Compose
- 2GB RAM minimum

## First Steps

1. Copy `.env.production` to `.env`
2. Update configuration values
3. Run `./deploy.sh`
4. Access at your domain
5. Login with admin credentials

## Documentation

- **QUICK_START.md** - Get started in 5 minutes
- **DEPLOYMENT_GUIDE.md** - Full deployment instructions
- **Dockerfile** - Application container
- **docker-compose.yml** - Complete stack definition

## Support

For issues, check:
- Application logs: `docker-compose logs app`
- Database logs: `docker-compose logs db`
- Nginx logs: `docker-compose logs nginx`

## License

Your License Here
