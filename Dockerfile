# Imagen base PHP con FPM y extensiones necesarias
FROM php:8.2-fpm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . .

# Instalar dependencias de PHP y Node, compilar assets
RUN composer install --no-dev --optimize-autoloader \
    && npm install \
    && npm run build

# Configurar permisos para storage y cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Cachear configuración y rutas
RUN php artisan config:cache && php artisan route:cache

# Exponer puerto (Render lo asigna)
EXPOSE 10000

# Iniciar el servidor PHP apuntando a 'public'
CMD ["php", "-S", "0.0.0.0:10000", "-t", "public"]
