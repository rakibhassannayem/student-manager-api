FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install intl pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

# Disable every MPM except prefork
RUN a2dismod mpm_event mpm_worker mpm_auto 2>/dev/null || true \
    && a2enmod mpm_prefork rewrite

# Point Apache to CakePHP webroot
RUN sed -i \
    's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/webroot|' \
    /etc/apache2/sites-available/000-default.conf

RUN sed -i \
    's|<Directory /var/www/>|<Directory /var/www/html/webroot>|' \
    /etc/apache2/apache2.conf

RUN chown -R www-data:www-data tmp logs

EXPOSE 80