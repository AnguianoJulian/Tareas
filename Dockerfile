# Etapa 1: dependencias PHP y Composer
FROM php:8.2-fpm

# Instalar dependencias del sistema y extensiones de PHP necesarias
RUN apt-get update && apt-get install -y \
    nginx \
    libpq-dev \
    libzip-dev \
    zip unzip \
    && docker-php-ext-install pdo pdo_pgsql zip

# Copiar archivos del proyecto
WORKDIR /var/www/html
COPY . .

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Limpiar cachés y generar claves/configuración
RUN php artisan key:generate --force \
    && php artisan config:cache \
    && php artisan route:cache

# Copiar configuración personalizada de Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 80
EXPOSE 80

# Iniciar PHP-FPM y Nginx juntos
CMD service nginx start && php-fpm
