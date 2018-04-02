FROM php:alpine3.7
MAINTAINER Chamunks chamunks AT gmail.com

# This image provides Concrete5.7 at root of site

# Install pre-requisites for Concrete5 & nano for editing conf files
RUN apk add --no-cache --virtual .build-deps \
      unzip \
      wget

# Find latest download details at https://www.concrete5.org/get-started
# - for newer version: change Concrete5 version# & download url & md5
ENV CONCRETE5_VERSION 8.2.1
ENV C5_URL https://github.com/concrete5/concrete5-core/archive/$CONCRETE5_VERSION.zip
# nano and other commands will not work without this

# Copy apache2 conf dir & Download Concrete5
## sed -i 's/AllowOverride None/AllowOverride FileInfo/g' /etc/apache2/apache2.conf && \
RUN mkdir -p /usr/local/src && \
    mkdir -p /var/www/html && \
    chown www-data:www-data /var/www/html && \
    cd /usr/local/src && \
    wget --no-verbose $C5_URL -O concrete5.zip && \
    unzip -qq concrete5.zip && \
    chown www-data:www-data ./ && \
    rm -v concrete5.zip && \
    ls -lAh ./ && \
    ls -lAh /var/www/html

ADD config/database.php /var/www/html/config/database.php
ADD docker-entrypoint /bin/docker-entrypoint

RUN chmod +x /bin/docker-entrypoint

# Persist website user data, logs & apache config
VOLUME [ "/var/www/html", "/usr/local/etc/php", "/var/www/html/config" ]

EXPOSE 80
WORKDIR /var/www/html

COPY docker-entrypoint /docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php", "-a"]
