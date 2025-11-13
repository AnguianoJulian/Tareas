# Dockerfile para Laravel 12 en Render
FROM php:8.2-fpm

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    git unzip curl nginx libpq-dev libzip-dev libpng-dev libonig-dev zlib1g-dev zip \
    nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip bcmath mbstring exif pcntl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar todo el proyecto
COPY . .

# Crear .env si no existe
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Instalar dependencias PHP
RUN composer install --optimize-autoloader --no-dev

# Instalar dependencias de Node y compilar Vite
RUN npm install && npm run build

# Permisos correctos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
 && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Generar key
RUN php artisan key:generate --force

# Copiar config Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Iniciar PHP-FPM y NGINX
CMD service nginx start && php-fpm
