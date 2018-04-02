FROM php:apache
MAINTAINER Chamunks chamunks AT gmail.com

# This image provides Concrete5.7 at root of site

# Install pre-requisites for Concrete5
RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get -y install \
      unzip \
      wget \
      patch \
      && rm -rf /var/lib/apt/lists/*

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
    wget --no-verbose $C5_URL -O concrete${CONCRETE5_VERSION}.zip && \
    unzip -qq concrete${CONCRETE5_VERSION}.zip -d concrete${CONCRETE5_VERSION} && \
    chown www-data:www-data /usr/local/src/concrete* && \
    ls -lAh /usr/local/src/ && \
    rm -v concrete${CONCRETE5_VERSION}.zip

ADD config/database.php /var/www/html/config/database.php
ADD docker-entrypoint /bin/docker-entrypoint
ADD apache2-foreground /bin/apache2-foreground

RUN chmod +x /bin/docker-entrypoint && chmod +x /bin/apache2-foreground

# Persist website user data, logs & apache config
VOLUME [ "/var/www/html", "/usr/local/etc/php", "/var/www/html/config" ]

EXPOSE 80
WORKDIR /var/www/html

COPY docker-entrypoint /docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["apache2-foreground"]
