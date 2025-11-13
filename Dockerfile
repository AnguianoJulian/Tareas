FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git unzip curl nginx libpq-dev libzip-dev libpng-dev libonig-dev zlib1g-dev zip nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip bcmath mbstring exif pcntl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN if [ ! -f .env ]; then cp .env.example .env; fi

RUN composer install --no-dev --optimize-autoloader

RUN npm install && npm run build

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

RUN php artisan key:generate --force
RUN php artisan config:cache
RUN php artisan route:cache

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD service nginx start && php-fpm
