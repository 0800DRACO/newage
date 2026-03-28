# Quick deployment guide for DigitalOcean

## 1. Via DigitalOcean App Platform (Easiest - Recommended)

### Step 1: Connect GitHub Repository
- Login to DigitalOcean Console
- Go to "App Platform" → "Create App"
- Select "GitHub" and connect your repository
- Choose the "newage" repository
- Click "Next"

###  Step 2: Configure Application
- Source Directory: leave empty (root)
- Build Command: `composer install --no-dev --optimize-autoloader`
- Run Command: `php-fpm`

### Step 3: Add MySQL Database
- Click "Add Resource" → "MySQL"
- Create new database
- Database name: `realvest_db`
- Database user: `realvest_user`

### Step 4: Set Environment Variables
Copy from `.env.production` and update in App Platform:

```
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-app-name.ondigitalocean.app
DB_CONNECTION=mysql
DB_HOST={{ env.DB_HOST }}
DB_PORT=3306
DB_DATABASE=realvest_db
DB_USERNAME={{ env.DB_USERNAME }}
DB_PASSWORD={{ env.DB_PASSWORD }}
DB_ROOT_PASSWORD=STRONG_PASSWORD
```

### Step 5: Deploy
Click "Deploy App" button. Your app will be live in 3-5 minutes!

---

## 2. Via Self-Hosted Droplet

### Step 1: Create Droplet
- Ubuntu 24.04 LTS
- 2GB RAM minimum
- Add SSH key

### Step 2: Deploy
```bash
# SSH into your droplet
ssh root@YOUR_DROPLET_IP

# Clone repository
git clone YOUR_REPO_URL newage
cd newage

# Create environment file
cp .env.production .env

# Edit with your values
nano .env

# Deploy
chmod +x deploy.sh
./deploy.sh
```

### Step 3: Access Application
```
http://YOUR_DROPLET_IP
```

---

## Post-Deployment Checklist

- [ ] Application is running
- [ ] Database is connected
- [ ] Admin can login
- [ ] Change admin password
- [ ] Configure payment gateways
- [ ] Setup SSL certificate
- [ ] Configure firewall
- [ ] Enable backups
