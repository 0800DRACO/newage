FROM php:8.3-fpm

# Install system dependencies including nginx and supervisor
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

# Setup Nginx configuration
RUN printf 'server {\n\
    listen 8080;\n\
    server_name _;\n\
    root /var/www/html/public;\n\
    index index.php index.html;\n\
    client_max_body_size 100M;\n\
\n\
    location / {\n\
        try_files $uri $uri/ /index.php?$query_string;\n\
    }\n\
\n\
    location ~ \.php$ {\n\
        fastcgi_pass 127.0.0.1:9000;\n\
        fastcgi_index index.php;\n\
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;\n\
        include fastcgi_params;\n\
        fastcgi_hide_header X-Powered-By;\n\
    }\n\
\n\
    location ~ /\.(?!well-known).* {\n\
        deny all;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

# Setup Supervisor configuration
RUN printf '[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
\n\
[program:php-fpm]\n\
command=/usr/local/sbin/php-fpm\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
\n\
[program:nginx]\n\
command=/usr/sbin/nginx -g "daemon off;"\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stopasgroup=true\n\
stopwaitsecs=5\n' > /etc/supervisor/conf.d/app.conf

# Create startup script for runtime configuration
RUN printf '#!/bin/bash\n\
set -e\n\
echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] Starting RealVest application..."\n\
\n\
# Copy environment file if not exists\n\
if [ ! -f ".env" ]; then\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] Copying .env from .env.production"\n\
    cp .env.production .env\n\
    if [ $? -ne 0 ]; then\n\
        echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] ERROR: Failed to copy .env file"\n\
        exit 1\n\
    fi\n\
else\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] .env file already exists"\n\
fi\n\
\n\
# Generate APP_KEY if needed\n\
if grep -q "THIS_WILL_BE_GENERATED_AT_STARTUP" .env; then\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] Generating APP_KEY..."\n\
    KEY=$(openssl rand -base64 32)\n\
    if [ -z "$KEY" ]; then\n\
        echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] ERROR: Failed to generate APP_KEY"\n\
        exit 1\n\
    fi\n\
    sed -i "s|THIS_WILL_BE_GENERATED_AT_STARTUP|$KEY|" .env\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] APP_KEY generated successfully"\n\
else\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] APP_KEY already set"\n\
fi\n\
\n\
# Verify .env has APP_KEY set\n\
if grep -q "^APP_KEY=" .env; then\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] APP_KEY verified in .env"\n\
else\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] ERROR: APP_KEY not found in .env"\n\
    exit 1\n\
fi\n\
\n\
# Fix storage permissions\n\
echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] Setting storage permissions..."\n\
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true\n\
chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache\n\
\n\
# Verify vendor/autoload.php exists\n\
if [ ! -f /var/www/html/vendor/autoload.php ]; then\n\
    echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] ERROR: vendor/autoload.php not found"\n\
    exit 1\n\
fi\n\
\n\
echo "[$(date +'%%Y-%%m-%%d %%H:%%M:%%S')] All checks passed. Starting services via supervisor..."\n\
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf\n' > /start.sh && chmod +x /start.sh

# Expose port (8080 for HTTP, 9000 for PHP-FPM internal)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/up || exit 1

CMD ["/start.sh"]
