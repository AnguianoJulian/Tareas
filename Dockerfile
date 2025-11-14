FROM php:8.2-fpm

# Instalar dependencias del sistema necesarias para PostgreSQL y extensiones
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev \
    postgresql-client

# Instalar extensiones PHP requeridas
RUN docker-php-ext-install pdo pdo_pgsql pdo_mysql

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar archivos del proyecto
COPY . /var/www/html

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Instalar dependencias de Laravel
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Asignar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Copiar configuración de Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Habilitar rewrite de Apache
RUN a2enmod rewrite

# Exponer el puerto por el cual Render accede
EXPOSE 80

# Iniciar Apache
CMD ["apache2-foreground"]
