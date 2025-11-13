# 1. Imagen base con PHP 8.2 y extensiones necesarias
FROM php:8.2-fpm

# 2. Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev zlib1g-dev libzip-dev \
    libpng-dev libonig-dev curl npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring zip exif pcntl bcmath gd \
    && apt-get clean

# 3. Configurar directorio de trabajo
WORKDIR /var/www/html

# 4. Copiar archivos
COPY . .

# 5. Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 6. Instalar dependencias PHP y optimizar autoload
RUN composer install --no-dev --optimize-autoloader

# 7. Instalar dependencias Node y construir assets
RUN npm install && npm run build

# 8. Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Generar key de Laravel
RUN php artisan key:generate

# 10. Cache de configuración y rutas
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# 11. Exponer puerto
EXPOSE 8000

# 12. Comando para correr Laravel
CMD php artisan serve --host=0.0.0.0 --port=8000
