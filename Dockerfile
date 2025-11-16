FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    zip unzip git libpq-dev libonig-dev libxml2-dev curl gnupg

# Instalar extensiones PHP
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Instalar Node 18 (necesario para Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Copiar archivos del proyecto
COPY . /var/www/html
WORKDIR /var/www/html

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install --no-dev --optimize-autoloader

# Construir front (Vite)
RUN npm install && npm run build

# Permisos correctos
RUN chown -R www-data:www-data storage bootstrap/cache

# Cachear configuración Laravel
RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

# Iniciar Apache
CMD ["apache2-foreground"]
