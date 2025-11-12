# 1. Imagen base PHP con Apache
FROM php:8.2-apache

# 2. Variables de entorno para no preguntar al instalar paquetes
ENV DEBIAN_FRONTEND=noninteractive

# 3. Instalar dependencias de sistema y PostgreSQL
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    npm \
    && docker-php-ext-install pdo pdo_pgsql zip \
    && apt-get clean

# 4. Habilitar mod_rewrite para Laravel
RUN a2enmod rewrite

# 5. Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 6. Copiar la app al contenedor
WORKDIR /var/www/html
COPY . .

# 7. Instalar dependencias PHP y optimizar autoload
RUN composer install --no-dev --optimize-autoloader

# 8. Instalar dependencias Node y compilar assets
RUN npm install
RUN npm run build

# 9. Establecer permisos correctos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 10. Exponer puerto 80 para Render
EXPOSE 80

# 11. Comando para correr Laravel en Apache
CMD ["apache2-foreground"]
