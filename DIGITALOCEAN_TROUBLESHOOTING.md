# DigitalOcean Deployment Troubleshooting Guide

## Issue: Application Returns Error on Load

If your RealVest application returns an error when accessing `https://your-app-name.ondigitalocean.app/`, follow this guide to diagnose and fix the issue.

---

## 🔍 Step 1: Check Application Logs

### Access Logs via DigitalOcean Dashboard

1. Go to **DigitalOcean App Platform** → **Your Application**
2. Click **"Deployments"** tab
3. Select the most recent deployment
4. Click **"View Logs"** button
5. Look for error messages like:
   - `PHP Fatal error`
   - `Class not found`
   - `Cannot open database connection`
   - `Permission denied`

### Common Log Patterns and Solutions

**Pattern: "No such file or directory"**
```
Fatal error: Open failed: /var/www/html/vendor/autoload.php
```
**Solution:** Composer dependencies not installed. Redeploy or check `composer.json`.

**Pattern: "Permission denied" on storage**
```
Warning: is_writable(/var/www/html/storage): Permission denied
```
**Solution:** Fixed in startup script. Force redeploy.

**Pattern: "Cannot declare class"**
```
PHP Fatal error: Cannot declare class Illuminate\...
```
**Solution:** Vendor directory corrupted. Clear cache and redeploy.

---

## 🧪 Step 2: Test Application Endpoints

### Test Health Endpoint

Try these URLs to verify the application is responding:

1. **Simple Health Check** (No Laravel required)
   ```
   https://your-app-name.ondigitalocean.app/health.php
   ```
   Response should show PHP info and detected issues.

2. **Main API Endpoint** (Laravel required)
   ```
   https://your-app-name.ondigitalocean.app/
   ```
   Response should be JSON with application status.

3. **Health Status Endpoint**
   ```
   https://your-app-name.ondigitalocean.app/health
   ```
   Response should say: `{"status":"healthy"}`

### Endpoint Response Examples

**Successful Health Response:**
```json
{
  "timestamp": "2026-03-28T01:35:00+00:00",
  "status": "healthy",
  "application": "RealVest",
  "environment": "production",
  "php_version": "8.3.0",
  ".env": "found",
  "dependencies": "installed"
}
```

**Successful Main App Response:**
```json
{
  "message": "RealVest Payment Gateway API",
  "version": "1.0.0",
  "status": "operational"
}
```

---

## 🔧 Step 3: Manual Diagnostics with SSH

### Connect via SSH

1. **Get your app's credentials:**
   - DigitalOcean Dashboard → Your App → Settings → Component Information
   - You'll see SSH command like:
   ```bash
   ssh -i path/to/key app@your-app-id-component-id.ondigitalocean.app
   ```

2. **Connect to your app:**
   ```bash
   ssh -i your/ssh/key app@your-app-container.ondigitalocean.app
   ```

### Run Diagnostic Commands

**Check Environmental Setup:**
```bash
cat /var/www/html/.env | grep APP_KEY
cat /var/www/html/.env | grep DB_HOST
```

**Check File Permissions:**
```bash
ls -la /var/www/html/storage
ls -la /var/www/html/bootstrap/cache
ls -la /var/www/html/public/index.php
```

**Check Vendor Installation:**
```bash
ls -la /var/www/html/vendor | head -20
test -f /var/www/html/vendor/autoload.php && echo "✓ autoload.php found"
```

**Test PHP-FPM Connection:**
```bash
curl -X GET http://localhost:9000/health.php 2>&1 | head -20
```

**Check Nginx Access:**
```bash
curl -v http://localhost/health.php
```

**View PHP Error Logs:**
```bash
tail -f /var/www/html/storage/logs/laravel.log
```

---

## 🚀 Step 4: Common Fixes

### Fix 1: Force Redeploy After Code Changes

1. Go to **DigitalOcean App Platform** → **Your App**
2. Click **Deployments** tab
3. Click **"Deploy"** button (the most recent failed deployment)
4. Select **"Redeploy"**
5. Wait 5-10 minutes for fresh build

### Fix 2: Clear Build Cache

If redeploy doesn't help:

1. Go to **Settings** → **Builder** 
2. Click **"Clear Caches"**
3. Go back to **Deployments**
4. Click **"Redeploy"**

### Fix 3: Verify Environment Variables

1. Go to **Settings** → **Environment Variables**
2. Check these are set:
   - `APP_ENV` = `production`
   - `APP_KEY` = (should auto-generate)
   - `DB_HOST` = (DigitalOcean database hostname)
   - `DB_DATABASE` = `realvest_db`
   - `DB_USERNAME` = `realvest_user`
   - `DB_PASSWORD` = (your secure password)

3. If using DigitalOcean Managed Database:
   - Go to **Databases** tab
   - Copy the database credentials
   - Update environment variables

### Fix 4: Rebuild from Fresh

If nothing works, force a complete rebuild:

1. Commit a change to trigger build:
   ```bash
   git commit --allow-empty -m "Force rebuild"
   git push origin main
   ```

2. Watch the deployment in DigitalOcean dashboard
3. Check logs for errors

---

## 📊 Step 5: Specific Error Debugging

### Error: "SQLSTATE[HY000]: General error"

**Cause:** Database connection failure

**Fix:**
1. Verify DB credentials in environment variables
2. Check database is ready (created on DigitalOcean)
3. Try manual DB connection from container:
   ```bash
   mysql -h YOUR_DB_HOST -u realvest_user -p realvest_db
   ```

### Error: "Class 'Illuminate\...' not found"

**Cause:** Laravel framework not installed or corrupted

**Fix:**
1. In your repository, delete `composer.lock`
2. Recreate it:
   ```bash
   cd core && composer update --no-dev
   ```
3. Commit and push:
   ```bash
   git add composer.lock && git commit -m "Update composer lock"
   git push origin main
   ```

### Error: "Permission denied" for files

**Cause:** File ownership/permissions incorrect

**Fix:**
- Startup script handles this automatically
- Force redeploy:
  ```bash
  git commit --allow-empty -m "Reset permissions"
  git push origin main
  ```

### Error: "APP_KEY not set" or "base64 decode error"

**Cause:** APP_KEY not generated at startup

**Fix:**
1. Check startup script ran:
   - View deployment logs
   - Look for "[INFO] Generating APP_KEY..."

2. If not, restart the component:
   - DigitalOcean Dashboard → Components → Click component name
   - Click restart button

3. Or redeploy:
   ```bash
   git commit --allow-empty -m "Regenerate APP_KEY"  
   git push origin main
   ```

---

## 📋 Step 6: Validation Checklist

After making changes, verify:

- [ ] Latest code pushed to GitHub
- [ ] DigitalOcean deployment shows green checkmark
- [ ] Logs show no PHP errors
- [ ] Health endpoint returns `healthy` status
- [ ] Main API endpoint returns application status
- [ ] Database connection works (test with phpmyadmin if available)
- [ ] Storage directory is writable
- [ ] APP_KEY is set (not showing placeholder text)

---

## 🆘 Still Not Working? 

### Get Detailed Error Message

1. Enable debug mode temporarily:
   ```
   APP_DEBUG=true
   ```
2. Redeploy
3. Check errors returned by application
4. **IMPORTANT:** Turn debug off (`APP_DEBUG=false`) in production after fixing

### Check System Resources

1. DigitalOcean Dashboard → Your App → Resources
2. Check if app is:
   - Out of memory (red indicators)
   - CPU-constrained
   - Disk space issues

3. If needed, upgrade the app plan

### Review Recent Changes

1. Check git log for recent commits
2. Look at what changed in:
   - `Dockerfile`
   - `core/composer.json`
   - `core/.env.example`
   - Environment variable settings

3. Try reverting recent changes:
   ```bash
   git revert HEAD  # Revert last commit
   git push origin main
   ```

---

## 📞 Additional Resources

- **DigitalOcean Docs:** https://docs.digitalocean.com/app-platform/
- **Laravel Docs:** https://laravel.com/docs/
- **Logs Location:** `/var/www/html/storage/logs/laravel.log`
- **Health Check File:** `/var/www/html/public/health.php`

---

## 💾 Local Testing

Test your changes locally before pushing:

```bash
# Use docker-compose to test locally
docker-compose up

# Access at http://localhost

# Check health endpoint
curl http://localhost/health.php
```

---

**Updated:** March 28, 2026
**Status:** For RealVest v1.0.0 on DigitalOcean App Platform
