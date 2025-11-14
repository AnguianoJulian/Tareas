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
    libzip-dev

# Extensiones PHP necesarias
RUN docker-php-ext-install pdo pdo_pgsql pdo_mysql mbstring zip exif pcntl bcmath gd

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Configuración de Apache para Laravel
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Copiar proyecto
WORKDIR /var/www/html
COPY . .

# Instalar dependencias Laravel
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Permisos para Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Exponer puerto
EXPOSE 80

CMD ["apache2-foreground"]
