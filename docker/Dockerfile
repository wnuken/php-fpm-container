# php Alpine
FROM alpine:3.8
LABEL maintainer=brisaning@gmail.com

# Update packages list
RUN apk --no-cache update

#  Install rc services
# RUN apk add  --no-cache openrc

#  Install bash
RUN apk add --no-cache bash

# Recreate user with correct params
RUN set -e && \
addgroup -g 1000 -S www-data && \
adduser -u 1000 -D -S -s /bin/bash -G www-data www-data && \
sed -i '/^www-data/s/!/*/' /etc/shadow

# Install base
RUN apk add --no-cache gcc g++ autoconf make \
apk-cron ca-certificates curl-dev libcurl \
sed re2c wget

# Install php-fpm
RUN apk add --no-cache php7-fpm

# Install base php libs
RUN apk add --no-cache php7-dev php7-openssl \
php7-common php7-ftp php7-gd \
php7-dom php7-sockets \
php7-zlib php7-bz2 php7-pear php7-cli \
php7-exif php7-phar php7-zip php7-calendar \
php7-iconv php7-imap php7-soap \
php7-mbstring php7-bcmath \
php7-mcrypt php7-curl php7-json \
php7-opcache php7-ctype php7-xml \
php7-xsl php7-ldap php7-xmlwriter php7-xmlreader \
php7-intl php7-tokenizer php7-session \
php7-pcntl php7-posix php7-apcu php7-simplexml \
php7-pdo php7-imagick php7-redis \
php7-mysqlnd php7-pdo_mysql php7-mysqli \
php7-pgsql php7-pdo_pgsql php7-memcached php7-mongodb php7-xdebug

# Install git
RUN apk add --no-cache git

# Install composer
RUN apk add --no-cache composer

# Create /temp_dir for using
RUN mkdir /temp_docker && chmod -R +x /temp_docker && cd /temp_docker

# Install uploadprogress
RUN cd /temp_docker && git clone https://github.com/php/pecl-php-uploadprogress.git && cd pecl-php-uploadprogress && \
phpize && \
./configure && \
make && \
make install && \
echo 'extension=uploadprogress.so' > /etc/php7/conf.d/uploadprogress.ini

# Configure php-fpm by copy our config files
RUN touch /var/log/fpm-php.www.log
RUN chown -R www-data:www-data /var/log/fpm-php.www.log

RUN mkdir -p /var/www/localhost/htdocs && \
chown -R www-data:www-data /var/www/ && \
chown -R www-data:www-data /var/log/
WORKDIR /var/www/localhost/htdocs

# Secundary apps
# RUN apk add pdftk
COPY ./files/php/php-fpm.conf /etc/php7/php-fpm.conf

ENTRYPOINT ["php-fpm7"]




