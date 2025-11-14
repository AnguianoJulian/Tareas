FROM php:8.2-apache

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    postgresql-client

# Extensiones PHP
RUN docker-php-ext-install pdo pdo_pgsql pdo_mysql mbstring zip exif pcntl bcmath gd

# Configuración de Apache
RUN a2enmod rewrite

# Copiar configuración de Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Copiar proyecto
COPY . /var/www/html

WORKDIR /var/www/html

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instalar dependencias Laravel
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Permisos Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Limpiar cache (¡Render lo necesita!)
RUN php artisan config:clear || true
RUN php artisan cache:clear || true

# Crear link de storage
RUN php artisan storage:link || true

# Exponer puerto
EXPOSE 80

CMD ["apache2-foreground"]
