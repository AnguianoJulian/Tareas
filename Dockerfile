# Usamos PHP 8.2 con FPM
FROM php:8.2-fpm

# Instalar dependencias del sistema y extensiones de PHP necesarias
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    curl \
    npm \
    nodejs \
    build-essential \
    && docker-php-ext-install pdo pdo_pgsql

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar todo el proyecto
COPY . .

# Instalar dependencias de PHP y Node
RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build

# Copiar .env de producción si no está en el repo
# COPY .env.production .env

# Generar la key de Laravel si no existe
RUN php artisan key:generate

# Exponer el puerto que usará Laravel
EXPOSE 10000

# Comando para iniciar la app
CMD php artisan serve --host 0.0.0.0 --port 10000
