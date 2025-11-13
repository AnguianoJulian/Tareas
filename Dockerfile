# Etapa base: PHP con FPM
FROM php:8.2-fpm

# Instalar dependencias del sistema y extensiones necesarias
RUN apt-get update && apt-get install -y \
    git unzip curl nginx libpq-dev libzip-dev zip nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip bcmath mbstring exif pcntl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar Composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . .

# Copiar archivo .env.example como .env (Render no lo incluye automáticamente)
RUN cp .env.example .env

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias de Node y compilar assets
RUN npm install && npm run build

# Asignar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Generar clave y cachear configuración
RUN php artisan key:generate --force \
    && php artisan config:cache \
    && php artisan route:cache

# Copiar configuración de Nginx personalizada
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80
EXPOSE 80

# Iniciar PHP-FPM y Nginx juntos
CMD service nginx start && php-fpm
