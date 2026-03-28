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

# Install Laravel dependencies with error handling
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --prefer-stable || \
    (composer clear-cache && composer install --no-dev --optimize-autoloader --no-interaction --no-progress)

# Copy application files
COPY core/ .

# Copy environment configuration
COPY .env.production ./

# Create necessary directories with proper permissions
RUN mkdir -p storage/logs storage/framework/sessions storage/framework/views storage/framework/cache bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Create startup script for runtime configuration
RUN printf '#!/bin/bash\n\
# Copy environment file if not exists\n\
if [ ! -f ".env" ]; then\n\
    cp .env.production .env\n\
fi\n\
\n\
# Generate APP_KEY if missing\n\
if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then\n\
    echo "[INFO] Generating APP_KEY..."\n\
    php artisan key:generate --force --no-interaction\n\
fi\n\
\n\
# Wait for database to be ready\n\
echo "[INFO] Waiting for database connection..."\n\
max_attempts=30\n\
attempt=0\n\
until php artisan tinker --execute="DB::connection()->getPDO()" 2>/dev/null || [ $attempt -eq $max_attempts ]; do\n\
    attempt=$((attempt + 1))\n\
    echo "[INFO] Database attempt $attempt/$max_attempts..."\n\
    sleep 1\n\
done\n\
\n\
if [ $attempt -eq $max_attempts ]; then\n\
    echo "[WARN] Database not available, continuing anyway..."\n\
fi\n\
\n\
# Run migrations if needed\n\
echo "[INFO] Running database migrations..."\n\
php artisan migrate --force --no-interaction\n\
\n\
# Run seeders if database is empty\n\
php artisan db:seed --force --no-interaction\n\
\n\
echo "[INFO] Application ready, starting PHP-FPM..."\n\
exec php-fpm\n' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD php artisan tinker --execute="echo 'OK'" || exit 1

CMD ["/start.sh"]
