FROM php:apache
MAINTAINER Chamunks chamunks AT gmail.com

# This image provides Concrete5.7 at root of site

# Install pre-requisites for Concrete5
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install gnupg apt-utils wget -y
RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list
RUN echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list
RUN wget -qO - http://www.dotdeb.org/dotdeb.gpg | apt-key add - >/dev/null
RUN DEBIAN_FRONTEND=noninteractive apt install ca-certificates apt-transport-https -y
RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
RUN echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
RUN apt-get update
RUN apt-cache search php |grep php7.2-
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
      unzip \
      patch \
      && rm -rf /var/lib/apt/lists/*

# Find latest download details at https://www.concrete5.org/get-started
# - for newer version: change Concrete5 version# & download url & md5
ENV CONCRETE5_VERSION 8.3.2
ENV C5_URL https://github.com/concrete5/concrete5-core/archive/$CONCRETE5_VERSION.zip
# nano and other commands will not work without this

# Copy apache2 conf dir & Download Concrete5
## sed -i 's/AllowOverride None/AllowOverride FileInfo/g' /etc/apache2/apache2.conf && \
## One day figure out tags for this https://www.concrete5.org/developers/developer-downloads/
RUN mkdir -p /usr/local/src
RUN mkdir -p /var/www/html
RUN chown www-data:www-data /var/www/html
RUN cd /usr/local/src
RUN wget --header 'Host: www.concrete5.org' --user-agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:52.0) Gecko/20100101 Firefox/52.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Upgrade-Insecure-Requests: 1' 'https://www.concrete5.org/download_file/-/view/100595/8497/' --output-document 'concrete5-8.3.2.zip'
RUN unzip -qq concrete5-${CONCRETE5_VERSION}.zip
RUN chown www-data:www-data /usr/local/src/concrete5-${CONCRETE5_VERSION}
RUN ls -lAh /usr/local/src/concrete5-${CONCRETE5_VERSION}
RUN rm -v concrete5-${CONCRETE5_VERSION}.zip

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
