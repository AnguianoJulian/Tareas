# 1. Imagen base PHP con FPM y extensiones necesarias
FROM php:8.2-fpm

# 2. Instalar dependencias del sistema y extensiones PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    npm \
    libpng-dev \
    libonig-dev \
    zlib1g-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring zip exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Directorio de trabajo
WORKDIR /var/www/html

# 5. Copiar archivos de la aplicación
COPY . .

# 6. Instalar dependencias de PHP y Node
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

# 7. Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 8. Exponer puerto
EXPOSE 10000

# 9. Iniciar servidor Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
