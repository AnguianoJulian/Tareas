FROM php:8.2-apache

# Habilitar módulos
RUN docker-php-ext-install pdo pdo_pgsql

# Habilitar Apache mod_rewrite
RUN a2enmod rewrite

# Instalar Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs git unzip

# Copiar archivos del proyecto
COPY . /var/www/html/

# Ir al directorio
WORKDIR /var/www/html

# Instalar dependencias PHP
RUN php composer.phar install --no-dev --optimize-autoloader || true
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias NPM y build
RUN npm install && npm run build

# Permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar DocumentRoot
RUN sed -i 's#/var/www/html#/var/www/html/public#g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2-foreground"]
