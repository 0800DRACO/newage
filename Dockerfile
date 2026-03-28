FROM php:8.3-fpm

# Cache invalidation: 2026-03-28-fixed-composer
ARG BUILD_DATE

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    nginx \
    supervisor \
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
# Note: COMPOSER_ALLOW_SUPERUSER=1 allows composer to run as root during Docker build
# This is acceptable in Docker build context for installing dependencies
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --no-progress --no-interaction

# Copy application files
COPY core/ .

# Copy environment configuration
COPY .env.production ./

# Create necessary directories
RUN mkdir -p storage/logs storage/framework/sessions storage/framework/views storage/framework/cache bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Copy Nginx and Supervisor configurations
COPY nginx.conf.docker /etc/nginx/conf.d/default.conf
COPY supervisord.conf.docker /etc/supervisor/supervisord.conf

# Create necessary directories for logs
RUN mkdir -p /var/log/nginx /var/log/supervisor /var/run/supervisor \
    && chown -R www-data:www-data /var/log/nginx

# Expose port
EXPOSE 8080

# Health check - with longer startup period for services to boot
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:8080/up || exit 1

CMD ["/start.sh"]
