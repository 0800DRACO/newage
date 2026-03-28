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

# Create simple Nginx configuration for Docker
RUN mkdir -p /etc/nginx/conf.d && \
    printf 'server {\n    listen 8080;\n    server_name _;\n    root /var/www/html/public;\n    index index.php index.html;\n    client_max_body_size 100M;\n\n    location / {\n        try_files $uri $uri/ /index.php?$query_string;\n    }\n\n    location ~ \.php$ {\n        fastcgi_pass 127.0.0.1:9000;\n        fastcgi_index index.php;\n        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;\n        include fastcgi_params;\n        fastcgi_hide_header X-Powered-By;\n    }\n\n    location ~ /\.(?!well-known).* {\n        deny all;\n    }\n}\n' > /etc/nginx/conf.d/default.conf

# Create Supervisor configuration
RUN mkdir -p /etc/supervisor/conf.d /var/log/supervisor && \
    printf '[supervisord]\nlogfile=/var/log/supervisor/supervisord.log\npidfile=/var/run/supervisord.pid\nnodaemon=true\n\n[program:php-fpm]\ncommand=php-fpm --nodaemonize\nautostart=true\nautorestart=unexpected\nstarterrors_max=0\nexitreboots=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\n\n[program:nginx]\ncommand=/usr/sbin/nginx -g "daemon off;"\nautostart=true\nautorestart=unexpected\nstarterrors_max=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstopasgroup=true\nstopprogram=/bin/kill -TERM $group_pid\n' > /etc/supervisor/conf.d/app.conf

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/up || exit 1

CMD ["/start.sh"]
