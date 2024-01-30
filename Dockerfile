# Use an official PHP runtime as a parent image
FROM php:8.2-fpm

# Install Composer 2.0
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=2.0.14

# Install nginx
RUN apt-get update && apt-get install -y  libsqlite3-dev nano git zip unzip nginx openssl libssl-dev pkg-config
# RUN apt-get install php-mysql -y
# Install sqlite driver for PHP

RUN docker-php-ext-install pdo_mysql

# Install Node.js and npm
# RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
# RUN apt-get install -y nodejs



# Copy nginx configuration file to the container
COPY ./default.conf /etc/nginx/sites-available/default

COPY . /usr/src/app/
COPY ./.env  /usr/src/app/.env

WORKDIR /usr/src/app/

RUN composer clearcache
RUN composer selfupdate
RUN composer install --verbose
RUN php artisan cache:clear
RUN php artisan config:clear
RUN php artisan route:clear
# RUN php artisan passport:keys
# RUN php artisan l5-swagger:generate


# Set permissions for storage and bootstrap directories
RUN chmod -R 777 storage bootstrap/cache
RUN chmod -R 777 public/uploads

# WORKDIR /usr/src/app/

# Expose port 80 for Nginx
EXPOSE 80

CMD service nginx start && php-fpm
