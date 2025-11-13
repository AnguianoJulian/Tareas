# Dockerfile para Laravel en Render con PHP-FPM y Nginx

# Etapa 1: Imagen base de PHP con FPM
FROM php:8.2-fpm

# Instalar dependencias del sistema y extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    nginx \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    libpng-dev \
    libonig-dev \
    zlib1g-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring zip exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto
COPY . .

# Si no existe .env, crear una copia desde .env.example
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Instalar dependencias PHP y optimizar autoload
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias Node y compilar los assets (Vite)
RUN npm install && npm run build

# Asignar permisos correctos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Generar clave y cachés de Laravel
RUN php artisan key:generate --force \
    && php artisan config:cache \
    && php artisan route:cache

# Copiar configuración de Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80
EXPOSE 80

# Comando de inicio
CMD service nginx start && php-fpm
