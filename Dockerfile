FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    zip \
    bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for dependency installation
COPY core/composer.json core/composer.lock* ./

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Copy application files
COPY core/ .

# Copy environment configuration
COPY .env.production ./

# Create necessary directories with proper permissions
RUN mkdir -p storage/logs storage/framework/sessions storage/framework/views storage/framework/cache bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Create startup script for runtime configuration
RUN cat > /start.sh << 'EOFSCRIPT' && chmod +x /start.sh
#!/bin/bash
set -e

# Copy environment file if not exists
if [ ! -f ".env" ]; then
    cp .env.production .env
fi

# Generate APP_KEY if missing
if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
    echo "[INFO] Generating APP_KEY..."
    php artisan key:generate --force --no-interaction
fi

# Wait for database to be ready
echo "[INFO] Waiting for database connection..."
max_attempts=30
attempt=0
until php artisan tinker --execute="DB::connection()->getPDO()" 2>/dev/null || [ $attempt -eq $max_attempts ]; do
    attempt=$((attempt + 1))
    echo "[INFO] Database attempt $attempt/$max_attempts..."
    sleep 1
done

if [ $attempt -eq $max_attempts ]; then
    echo "[WARN] Database not available, continuing anyway..."
fi

# Run migrations if needed
echo "[INFO] Running database migrations..."
php artisan migrate --force --no-interaction

# Run seeders if database is empty
php artisan db:seed --force --no-interaction

echo "[INFO] Application ready, starting PHP-FPM..."
exec php-fpm
EOFSCRIPT

# Expose port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD php artisan tinker --execute="echo 'OK'" || exit 1

CMD ["/start.sh"]
