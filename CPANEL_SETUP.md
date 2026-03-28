# cPanel Installation Guide for RealVest

## .htaccess Files (CRITICAL for Apache/cPanel)

Two `.htaccess` files are now available:

### 1. Root `.htaccess` (`/.htaccess`)
- **Location**: Root directory where you extracted the zip
- **Purpose**: Redirects all traffic to the `/public` folder
- **File**: Already created in repository

### 2. Public `.htaccess` (`/core/public/.htaccess`)
- **Location**: Inside the `core/public` directory
- **Purpose**: Rewrites all requests to `index.php` for Laravel routing
- **File**: Already created in repository

## cPanel Setup Steps

### Step 1: Extract Files
1. Download the latest files from GitHub: https://github.com/0800DRACO/newage
2. Or use: `git clone https://github.com/0800DRACO/newage.git`
3. Extract to cPanel public_html directory
4. Ensure `.htaccess` files are copied (they're hidden files)

### Step 2: Create Database (cPanel → Databases → MySQL Databases)
```
Database Name: yourusername_realvest
Database User: yourusername_realvest_user
Password: [strong password]
Privileges: ALL
```

### Step 3: Update Configuration
Edit `.env` file in the root directory:

```env
APP_NAME="RealVest"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Database (cPanel prepends username)
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=yourusername_realvest
DB_USERNAME=yourusername_realvest_user
DB_PASSWORD=your_strong_password

# Mail (optional)
MAIL_MAILER=log
MAIL_FROM_ADDRESS=noreply@yourdomain.com

# Payment Gateways (optional, add later)
STRIPE_PUBLIC_KEY=
STRIPE_SECRET_KEY=
RAZORPAY_PUBLIC_KEY=
RAZORPAY_SECRET_KEY=
```

### Step 4: Set File Permissions (via cPanel Terminal/SSH)
```bash
cd /home/yourusername/public_html

# Set directory permissions
find . -type d -exec chmod 755 {} \;

# Set file permissions
find . -type f -exec chmod 644 {} \;

# Make scripts executable
chmod +x artisan
chmod +x core/artisan

# Storage directories need write permissions
chmod -R 777 core/storage
chmod -R 777 core/bootstrap/cache
```

### Step 5: Run Database Migrations (cPanel Terminal/SSH)
```bash
cd public_html/core

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Seed database (optional - adds demo data)
php artisan db:seed --force

# Clear caches
php artisan cache:clear
php artisan config:clear
```

### Step 6: Create Admin Account
```bash
cd core

# Create admin user
php artisan tinker
```

Then in the tinker shell:
```php
\App\Models\User::create([
    'name' => 'Admin',
    'email' => 'admin@site.com',
    'password' => bcrypt('password'),
    'role' => 'admin'
]);
exit
```

### Step 7: Test Application
1. Visit: `https://yourdomain.com`
2. You should see the RealVest welcome page
3. Check: `https://yourdomain.com/health.php` for diagnostics

## .htaccess Troubleshooting

### Issue: 404 errors on all pages
**Solution**: Make sure `.htaccess` files are present:
```bash
ls -la /home/yourusername/public_html/.htaccess
ls -la /home/yourusername/public_html/core/public/.htaccess
```

### Issue: Cannot see .htaccess in File Manager
**Solution**: In cPanel File Manager:
1. Click **Settings** (gear icon)
2. Check **"Show Hidden Files"**
3. Now you can see `.htaccess` files

### Issue: 500 Error - mod_rewrite not enabled
**Contact cPanel support** to enable Apache mod_rewrite

## Quick Reference

| Task | Command |
|------|---------|
| Migrate database | `php artisan migrate --force` |
| Seed database | `php artisan db:seed --force` |
| Clear cache | `php artisan cache:clear` |
| View logs | `tail -f core/storage/logs/laravel.log` |
| SSH access | Check cPanel for SSH credentials |

## Support Documentation

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Full deployment guide
- [DIGITALOCEAN_TROUBLESHOOTING.md](DIGITALOCEAN_TROUBLESHOOTING.md) - Troubleshooting
- [APP_CREDENTIALS.txt](APP_CREDENTIALS.txt) - Default credentials

## Important Notes

1. **Never commit `.env` file** to version control
2. **Keep `core/storage` writable** (775 or 777)
3. **Regenerate APP_KEY** for production: `php artisan key:generate`
4. **Change default admin password** immediately
5. **Enable HTTPS** (Let's Encrypt in cPanel is free)
6. **Set up email** for notifications and password resets
