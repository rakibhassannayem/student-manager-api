FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install intl pdo_pgsql \
    && a2dismod mpm_event mpm_worker mpm_prefork || true \
    && a2enmod mpm_prefork rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . .

RUN printf '%s\n' \
'<VirtualHost *:80>' \
'    DocumentRoot /var/www/html/webroot' \
'    <Directory /var/www/html/webroot>' \
'        AllowOverride All' \
'        Require all granted' \
'    </Directory>' \
'</VirtualHost>' \
> /etc/apache2/sites-available/cakephp.conf \
&& a2dissite 000-default.conf \
&& a2ensite cakephp.conf

RUN mkdir -p tmp logs \
    && chown -R www-data:www-data tmp logs

RUN echo "=== APACHE MPM CONFIG ===" \
    && grep -R "LoadModule mpm_" /etc/apache2/ \
    && echo "=== ENABLED MPM MODULES ===" \
    && ls -la /etc/apache2/mods-enabled/ | grep mpm

EXPOSE 80