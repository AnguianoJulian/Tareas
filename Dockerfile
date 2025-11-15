FROM php:8.2-apache

# Extensiones necesarias
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    postgresql-client

RUN docker-php-ext-install pdo pdo_pgsql mbstring zip gd

# Habilitar rewrite
RUN a2enmod rewrite

# Copiar configuración de Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Copiar proyecto
COPY . /var/www/html
WORKDIR /var/www/html

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instalar vendors limpio
RUN composer clear-cache
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Permisos
RUN chown -R www-data:www-data storage bootstrap/cache vendor

# Limpiar cache Laravel
RUN php artisan config:clear || true
RUN php artisan cache:clear || true

# Migraciones automáticas
RUN php artisan migrate --force || true

EXPOSE 80

CMD ["apache2-foreground"]
