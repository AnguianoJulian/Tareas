# Dockerfile para Laravel en Render con PHP-FPM y Nginx

# 1. Imagen base PHP con FPM
FROM php:8.2-fpm

# 2. Instalar dependencias del sistema y extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    libpng-dev \
    libonig-dev \
    zlib1g-dev \
    nginx \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring zip exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Establecer directorio de trabajo
WORKDIR /var/www/html

# 5. Copiar archivos de la aplicación
COPY . .

# 6. Instalar dependencias PHP y optimizar autoload
RUN composer install --no-dev --optimize-autoloader

# 7. Instalar dependencias Node y compilar assets
RUN npm install && npm run build

# 8. Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Copiar configuración de Nginx
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# 10. Exponer puerto
EXPOSE 80

# 11. Comando de inicio: PHP-FPM + Nginx
CMD service nginx start && php-fpm
