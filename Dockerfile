FROM php:apache
MAINTAINER Chamunks chamunks AT gmail.com

# This image provides Concrete5.7 at root of site

# Install pre-requisites for Concrete5
RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list && \
    echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list && \
    wget -O- http://www.dotdeb.org/dotdeb.gpg | apt-key add -
RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get -y install \
      unzip \
      wget \
      patch \
      php7.2-curl \
      php7.2-gd \
      php7.2-mysql \
      && rm -rf /var/lib/apt/lists/*

# Find latest download details at https://www.concrete5.org/get-started
# - for newer version: change Concrete5 version# & download url & md5
ENV CONCRETE5_VERSION 8.3.2
ENV C5_URL https://github.com/concrete5/concrete5-core/archive/$CONCRETE5_VERSION.zip
# nano and other commands will not work without this

# Copy apache2 conf dir & Download Concrete5
## sed -i 's/AllowOverride None/AllowOverride FileInfo/g' /etc/apache2/apache2.conf && \
## One day figure out tags for this https://www.concrete5.org/developers/developer-downloads/
RUN mkdir -p /usr/local/src && \
    mkdir -p /var/www/html && \
    chown www-data:www-data /var/www/html && \
    cd /usr/local/src && \
    wget --header 'Host: www.concrete5.org' --user-agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:52.0) Gecko/20100101 Firefox/52.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Upgrade-Insecure-Requests: 1' 'https://www.concrete5.org/download_file/-/view/100595/8497/' --output-document 'concrete5-8.3.2.zip'  && \
    unzip -qq concrete5-${CONCRETE5_VERSION}.zip && \
    chown www-data:www-data /usr/local/src/concrete5-${CONCRETE5_VERSION} && \
    ls -lAh /usr/local/src/concrete5-${CONCRETE5_VERSION} && \
    rm -v concrete5-${CONCRETE5_VERSION}.zip

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
