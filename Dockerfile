# 1. Imagen base oficial de PHP con extensiones necesarias
FROM php:8.2-fpm

# 2. Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    curl \
    npm \
    nodejs \
    zip \
    && docker-php-ext-install pdo pdo_pgsql zip \
    && apt-get clean

# 3. Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Establecer directorio de trabajo
WORKDIR /var/www/html

# 5. Copiar proyecto al contenedor
COPY . .

# 6. Dar permisos a storage y cache
RUN chown -R www-data:www-data storage bootstrap/cache

# 7. Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# 8. Instalar dependencias de Node y compilar assets
RUN npm install
RUN npm run build

# 9. Exponer puerto de la app
EXPOSE 8000

# 10. Comando para iniciar Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
