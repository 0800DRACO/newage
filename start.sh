#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Starting RealVest application..."

# Copy environment file if not exists
if [ ! -f ".env" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Copying .env from .env.production"
    cp .env.production .env
    if [ $? -ne 0 ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: Failed to copy .env file"
        exit 1
    fi
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] .env file already exists"
fi

# Generate APP_KEY if needed
if grep -q "THIS_WILL_BE_GENERATED_AT_STARTUP" .env; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Generating APP_KEY..."
    KEY=$(openssl rand -base64 32)
    if [ -z "$KEY" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: Failed to generate APP_KEY"
        exit 1
    fi
    sed -i "s|THIS_WILL_BE_GENERATED_AT_STARTUP|$KEY|" .env
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] APP_KEY generated successfully"
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] APP_KEY already set"
fi

# Verify .env has APP_KEY set
if grep -q "^APP_KEY=" .env; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] APP_KEY verified in .env"
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: APP_KEY not found in .env"
    exit 1
fi

# Fix storage permissions
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Setting storage permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true
chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Verify vendor/autoload.php exists
if [ ! -f /var/www/html/vendor/autoload.php ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: vendor/autoload.php not found"
    exit 1
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] All checks passed. Starting services via supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
