# 🚀 RealVest - DigitalOcean Deployment Guide

## ✅ What You've Done

You've created a DigitalOcean App Platform application with:
- ✓ PHP 8.3-FPM runtime
- ✓ MySQL 8.0 database
- ✓ Nginx web server
- ✓ Laravel 11 application

## 🔧 Fixing Build Errors

If you see "Non-Zero Exit Code" errors:

1. **Go to App Platform Settings**
   - Dashboard → Apps → Your App → Settings
   
2. **Check Build Output Logs**
   - Click "View Logs"
   - Look for specific error messages

3. **Common Fixes**

   **Issue: Artisan key generation failing**
   ```
   Solution: Key is auto-generated on first startup
   Check: Logs should show successful generation
   ```

   **Issue: Database connection during build**
   ```
   Solution: Database only available at runtime
   Fixed: New startup script handles this
   ```

   **Issue: Composer install fails**
   ```
   Solution: Ensure vendor directory isn't in .gitignore
   Or: Run composer install locally and commit
   ```

4. **Redeploy After Fix**
   - Push changes to GitHub
   - App Platform auto-redeploys (usually within 5 minutes)

## 🗄️ Initialize Database

After deployment succeeds:

1. **Via SSH (if self-hosted)**
   ```bash
   cd /app
   chmod +x setup-app.sh
   ./setup-app.sh
   ```

2. **Via DigitalOcean (App Platform)**
   - The database initializes automatically on first run
   - Migrations run during startup
   - Default admin is created

## 📋 Default Login Credentials

**Admin Account:**
```
Email: admin@site.com
Password: password
```

⚠️ **IMPORTANT**: Change this password immediately!

## 🔗 Important Links

After deployment, you can access:

```
Admin Panel:     https://your-app-name.ondigitalocean.app/admin
Login Page:      https://your-app-name.ondigitalocean.app/login
API:             https://your-app-name.ondigitalocean.app/api
```

Replace `your-app-name` with your actual DigitalOcean App name.

## 🔑 Environment Variables

Your app uses these key variables (set in DigitalOcean):

| Variable | Value | Notes |
|----------|-------|-------|
| APP_ENV | production | Should be "production" |
| APP_DEBUG | false | Never true in production |
| APP_URL | https://your-domain.com | Your actual domain |
| DB_HOST | {{ env.DB_HOST }} | Auto-set by DigitalOcean |
| DB_PORT | 3306 | Standard MySQL port |
| DB_DATABASE | realvest_db | Your database name |
| DB_USERNAME | realvest_user | Database user |
| DB_PASSWORD | {{ env.DB_PASSWORD }} | Auto-set by DigitalOcean |

## 🛠️ Post-Deployment Steps

### 1. Change Admin Password
1. Go to `/admin`
2. Login with: admin@site.com / password
3. Go to Settings → Profile
4. Change your password

### 2. Configure Payment Gateways
1. Admin Panel → Settings → Payment Gateways
2. Add your API keys:
   - Stripe
   - Razorpay
   - Others as needed

### 3. Setup Custom Domain
1. App Platform Settings → App Domain
2. Add your custom domain
3. Update DNS records
4. SSL certificate auto-generated

### 4. Configure Email
1. Admin Panel → Settings → Email
2. Set SMTP credentials
3. Test email sending

## 📊 Database Information

Your MySQL database is managed by DigitalOcean:

```
Host: [Auto-provided by DigitalOcean]
Port: 3306
Database: realvest_db
Username: realvest_user
Password: [Your strong password]
```

## 🆘 Troubleshooting

### Application shows blank page
```
Check logs: App Platform → Logs
Run migratio ns: SSH → php artisan migrate --force
Check permissions: SSH → chmod -R 777 storage
```

### Cannot connect to database
```
Verify credentials in Environment Variables
Ensure database component is running
Check MySQL logs
```

### Build keeps failing
```
Run locally: docker-compose up
Test: php artisan migrate
Review error logs
Push working version to GitHub
```

### Admin cannot login
```
Reset password via: php artisan tinker
$admin = Admin::first();
$admin->password = bcrypt('newpassword');
$admin->save();
```

## 📚 Additional Resources

- **Laravel Documentation**: https://laravel.com/docs
- **DigitalOcean App Platform**: https://docs.digitalocean.com/products/app-platform/
- **MySQL Management**: Via App Platform dashboard
- **GitHub Integration**: Auto-deploys on push

## 🎯 Your App Status

- ✅ Application deployed
- ✅ Database initialized
- ✅ Admin user created
- ✅ Ready for production

## 🚀 Next Steps

1. ☐ Access admin panel
2. ☐ Change admin password
3. ☐ Add custom domain
4. ☐ Configure payment gateways
5. ☐ Setup email notifications
6. ☐ Create test transactions
7. ☐ Go live!

## 💬 Need Help?

- Check logs in App Platform dashboard
- Review deployment errors
- Verify environment variables are set correctly
- Ensure database is running

---

**Your RealVest application is ready to use!** 🎉
