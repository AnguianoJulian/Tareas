# 1. Usamos PHP 8.2 con FPM
FROM php:8.2-fpm

# 2. Instalar extensiones necesarias para Laravel y PostgreSQL
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql bcmath zip

# 3. Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Crear directorio de la app
WORKDIR /var/www/html

# 5. Copiar archivos de composer y package.json para instalar dependencias
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./

# 6. Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# 7. Instalar dependencias de Node y compilar assets
RUN npm install
RUN npm run build

# 8. Copiar el resto del proyecto
COPY . .

# 9. Exponer el puerto de Laravel
EXPOSE 8000

# 10. Comando para iniciar Laravel (apunta al host 0.0.0.0 para Docker/Render)
CMD php artisan serve --host=0.0.0.0 --port=8000
