FROM php:7.4-apache

WORKDIR /var/www/html
COPY . /var/www/html
# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    git \
    curl \
    libonig-dev libzip-dev \
    dirmngr gnupg apt-transport-https software-properties-common ca-certificates \
    mariadb-server 

RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - 
RUN mkdir -p /data/db && \
    add-apt-repository 'deb https://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main' && \
    apt update && apt install mongodb-org nodejs npm -y

# Starting services
RUN service mysql start && mysql < /var/www/html/docker/initscript.sql


# Clear cache
#RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN npm install nodemon sequelize-cli sequelize pm2 mysql2 npm@latest -g 
# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd


# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Install Node deps
RUN cd /var/www/html/socioboard-api/feeds && npm i
RUN cd /var/www/html/socioboard-api/library && npm i
RUN cd /var/www/html/socioboard-api/notification && npm i
RUN cd /var/www/html/socioboard-api/publish && npm i
RUN cd /var/www/html/socioboard-api/user && npm i


RUN cd /var/www/html/socioboard-api/library/sequelize-cli && set node_env=development && service mysql start && \
    sequelize db:migrate && sequelize db:seed --seed "seeders/20190213051930-initialize_application_info.js" &


#Frontend 
WORKDIR /var/www/html/socioboard-web-php
RUN a2enmod rewrite && chmod -R 777 storage bootstrap/cache && composer install && composer update

EXPOSE 3000 3001 3002 3003 3004 3005 80 3306
COPY docker/entrypoint.sh /usr/local/bin/
COPY docker/000-default.conf /etc/apache2/sites-enabled/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]