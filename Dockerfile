FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Instalar Node 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Habilitar mod_rewrite
RUN a2enmod rewrite

WORKDIR /var/www/html

# Copiar TODOS los archivos del proyecto
COPY . .

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php

# Instalar dependencias PHP
RUN php composer.phar install --no-dev --optimize-autoloader

# Instalar dependencias NPM y compilar Vite
RUN npm install && npm run build

# Ajustar permisos
RUN chown -R www-data:www-data storage bootstrap/cache

# Configurar Apache para servir /public
RUN sed -i 's#/var/www/html#/var/www/html/public#g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2-foreground"]
