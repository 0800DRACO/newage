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
set -e\n\
# Copy environment file if not exists\n\
if [ ! -f ".env" ]; then\n\
    echo "[INFO] Setting up .env from .env.production"\n\
    cp .env.production .env\n\
fi\n\
\n\
# Generate APP_KEY if needed\n\
if grep -q "THIS_WILL_BE_GENERATED_AT_STARTUP" .env; then\n\
    echo "[INFO] Generating APP_KEY..."\n\
    KEY=$(openssl rand -base64 32)\n\
    sed -i "s/THIS_WILL_BE_GENERATED_AT_STARTUP/$KEY/" .env\n\
fi\n\
\n\
# Fix storage permissions\n\
echo "[INFO] Setting storage permissions..."\n\
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true\n\
chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache\n\
\n\
echo "[INFO] Application ready, starting PHP-FPM..."\n\
exec php-fpm\n' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD php artisan tinker --execute="echo 'OK'" || exit 1

CMD ["/start.sh"]
