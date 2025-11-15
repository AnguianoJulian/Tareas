FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Instalar Node.js 18 para Vite
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Copiar proyecto
COPY . /var/www/html/

WORKDIR /var/www/html

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias JS y compilar Vite
RUN npm install
RUN npm run build

# Permisos de Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Configurar DocumentRoot de Apache
RUN sed -i 's#/var/www/html#/var/www/html/public#g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2-foreground"]
