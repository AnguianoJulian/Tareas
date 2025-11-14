FROM php:8.2-apache

# Instalar dependencias del sistema
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

# Extensiones PHP necesarias
RUN docker-php-ext-install pdo pdo_pgsql pdo_mysql mbstring zip exif pcntl bcmath gd

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Copiar configuración de Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Copiar proyecto
WORKDIR /var/www/html
COPY . .

# Instalar dependencias Laravel (solo producción)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Permisos para Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Exponer el puerto
EXPOSE 80

# Iniciar Apache
CMD ["apache2-foreground"]
