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

# 4. Establecer directorio de trabajo
WORKDIR /var/www/html

# 5. Copiar archivos de la aplicación
COPY . .

# 6. Instalar dependencias de PHP y optimizar autoload
RUN composer install --no-dev --optimize-autoloader

# 7. Instalar dependencias de Node y compilar assets
RUN npm install && npm run build

# 8. Configurar permisos para storage y bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Generar key de Laravel solo si no está definida
# (En producción normalmente ya tienes APP_KEY definida)
# RUN php artisan key:generate

# 10. Cachear configuración, rutas y vistas
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# 11. Exponer puerto que coincide con render.yaml
EXPOSE 10000

# 12. Comando para correr Laravel con PHP built-in server
CMD ["php", "-S", "0.0.0.0:10000", "-t", "public"]
