# php Alpine
FROM alpine:3.8
LABEL maintainer=brisaning@gmail.com

# Update packages list
RUN apk --no-cache update

# Install rc services
# RUN apk add --no-cache openrc

# Install bash
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
COPY ./docker/files/php/php-fpm.conf /etc/php7/php-fpm.conf

# OCI8

RUN apk add --no-cache musl-dev libnsl libaio unzip curl

RUN apk --no-cache upgrade

ENV LD_LIBRARY_PATH /usr/local/instantclient
ENV ORACLE_HOME /usr/local/instantclient

RUN curl -o /temp_docker/basic.zip https://raw.githubusercontent.com/bumpx/oracle-instantclient/master/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
curl -o /temp_docker/sdk.zip https://raw.githubusercontent.com/bumpx/oracle-instantclient/master/instantclient-sdk-linux.x64-11.2.0.4.0.zip && \
curl -o /temp_docker/sqlplus.zip https://raw.githubusercontent.com/bumpx/oracle-instantclient/master/instantclient-sqlplus-linux.x64-11.2.0.4.0.zip && \
unzip -d /usr/local/ /temp_docker/basic.zip && \
unzip -d /usr/local/ /temp_docker/sdk.zip && \
unzip -d /usr/local/ /temp_docker/sqlplus.zip

## Links are required for older SDKs
RUN ln -s /usr/local/instantclient_11_2 ${ORACLE_HOME} && \
ln -s ${ORACLE_HOME}/libclntsh.so.* ${ORACLE_HOME}/libclntsh.so && \
ln -s ${ORACLE_HOME}/libocci.so.* ${ORACLE_HOME}/libocci.so && \
ln -s ${ORACLE_HOME}/lib* /usr/lib && \
ln -s ${ORACLE_HOME}/sqlplus /usr/bin/sqlplus &&\
ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1

## Build OCI8 with PECL
RUN echo "instantclient,${ORACLE_HOME}" | pecl install oci8 &&\
echo 'extension=oci8.so' > /etc/php7/conf.d/30-oci8.ini

RUN rm -rf /temp_docker/*.zip /var/cache/apk/* /tmp/pear/

ENTRYPOINT ["php-fpm7"]
