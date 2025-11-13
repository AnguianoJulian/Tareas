# Dockerfile para Laravel en Render con PHP-FPM y Nginx
FROM php:8.2-fpm

# Instalar dependencias del sistema y extensiones necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    nginx \
    libpq-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    zlib1g-dev \
    zip \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip bcmath mbstring exif pcntl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar Composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . .

# Crear .env si no existe
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias de Node y compilar assets (Vite)
RUN npm install && npm run build

# Permisos correctos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Generar clave y caches
RUN php artisan key:generate --force \
    && php artisan config:cache \
    && php artisan route:cache

# Copiar configuración Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Exponer puerto
EXPOSE 80

# Comando de inicio
CMD service nginx start && php-fpm
