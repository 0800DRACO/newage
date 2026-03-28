#!/bin/bash
# Diagnostic script to check DigitalOcean deployment

echo "═════════════════════════════════════════════════════════"
echo "RealVest Application Diagnostic Report"
echo "═════════════════════════════════════════════════════════"

echo ""
echo "📋 ENVIRONMENT VARIABLES"
echo "───────────────────────────────────────"
echo "APP_ENV: ${APP_ENV}"
echo "APP_DEBUG: ${APP_DEBUG}"
echo "DB_HOST: ${DB_HOST}"
echo "DB_DATABASE: ${DB_DATABASE}"

echo ""
echo "📁 FILE PERMISSIONS"
echo "───────────────────────────────────────"
ls -ld /var/www/html/storage 2>/dev/null || echo "✗ storage directory not found"
ls -ld /var/www/html/bootstrap/cache 2>/dev/null || echo "✗ bootstrap/cache directory not found"

echo ""
echo "✓ ENV FILE STATUS"
echo "───────────────────────────────────────"
if [ -f /var/www/html/.env ]; then
    echo "✓ .env file exists"
    echo "  APP_KEY set: $(grep -c 'APP_KEY=' /var/www/html/.env || echo 'not found')"
    echo "  DB_HOST: $(grep 'DB_HOST=' /var/www/html/.env | cut -d'=' -f2)"
else
    echo "✗ .env file NOT FOUND"
fi

echo ""
echo "🔍 APPLICATION FILES"
echo "───────────────────────────────────────"
test -f /var/www/html/public/index.php && echo "✓ public/index.php" || echo "✗ public/index.php missing"
test -f /var/www/html/bootstrap/app.php && echo "✓ bootstrap/app.php" || echo "✗ bootstrap/app.php missing"
test -f /var/www/html/composer.json && echo "✓ composer.json" || echo "✗ composer.json missing"

echo ""
echo "📦 VENDOR DIRECTORY"
echo "───────────────────────────────────────"
if [ -d /var/www/html/vendor ]; then
    echo "✓ vendor directory exists"
    echo "  Size: $(du -sh /var/www/html/vendor | cut -f1)"
else
    echo "✗ vendor directory NOT FOUND"
fi

echo ""
echo "═════════════════════════════════════════════════════════"
echo "End of Diagnostic Report"
echo "═════════════════════════════════════════════════════════"
