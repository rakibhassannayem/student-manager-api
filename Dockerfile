FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install intl pdo_pgsql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data tmp logs

RUN sed -i 's!/var/www/html!/var/www/html/webroot!g' \
    /etc/apache2/sites-available/000-default.conf

RUN sed -i 's!/var/www/!/var/www/html/webroot!g' \
    /etc/apache2/apache2.conf

EXPOSE 80