FROM php:7.1-apache
MAINTAINER Chamunks chamunks AT gmail.com


###########################
## Environment Variables ##
###########################
#  DB_SERVER is the host name with the database server (if it's available on a custom port, for instance 3333, simply add :3333)
#  DB_USERNAME is the username to be used to access the database server
#  DB_PASSWORD is the password associated to DB_USERNAME
#  DB_NAME is the name of the database to use (it must exist and it must be empty)
#  C5_SITE_NAME is the name to give to the new concrete5 installation (will be shown for instance in the page titles)
#  C5_STARTING_POINT specify which set of initial data should be installed. By default concrete5 comes with elemental_full and elemental_blank
#  C5_EMAIL is the email to associate to the admin account that will be created on the new concrete5 installation
#  C5_PASSWORD is the password to assign to the admin account that will be created on the new concrete5 installation
#  C5_LOCALE (this is optional) is the code of the default site language (by default it's en_US)

ENV C5_VERSION 8.3.2

ENV DB_SERVER         10.5.0.5
ENV DB_USERNAME       default
ENV DB_PASSWORD       default
ENV DB_NAME           default
ENV C5_SITE_NAME      default.com
ENV C5_STARTING_POINT elemental_full
ENV C5_EMAIL          default@default.com
ENV C5_PASSWORD       default
ENV C5_LOCALE         en_US
ENV C5_PRESEED        yes

## Add custom shell scripts as binaries in $PATH
ADD bin/echof.sh /bin/echof
ADD bin/test_for_dir.sh /bin/test_for_dir
ADD bin/test_for_file.sh /bin/test_for_file
ADD bin/test_perm.sh /bin/test_perm
ADD bin/start.sh /bin/start-c5
ADD docker-entrypoint /bin/docker-entrypoint

## Install fancy wrapper from Concrete5 Slack's own mlocati.
## https://github.com/mlocati/docker-php-extension-installer
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions xdebug imagick gd mysqli zip pdo_mysql

## Only including some of the dependencies for now from
## https://documentation.concrete5.org/developers/installation/system-requirements
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libpng-dev \
    mariadb-client \
    wget \
    unzip \
    libjpeg62-turbo-dev \
    libfreetype6-dev && \
    docker-php-source delete && \
    rm -rf /var/lib/apt/lists/* && \
    a2enmod rewrite

## Make sure directories exist where they should.
RUN test_for_file /usr/local/src 775 "root:www-data" && \
    test_for_file /var/www/html 775 "root:www-data"

## get a copy of Concrete5 downloaded and unpacked.
RUN wget -nv --header 'Host: www.concrete5.org' --user-agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:52.0) Gecko/20100101 Firefox/52.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Upgrade-Insecure-Requests: 1' 'https://www.concrete5.org/download_file/-/view/100595/8497/' --output-document '/usr/local/src/concrete5-8.3.2.zip' && \
    unzip -qq /usr/local/src/concrete5-${C5_VERSION}.zip -d /usr/local/src/  && \
    ls -lAh /usr/local/src/ && \
    echof run 'test_for_dir /usr/local/src/concrete5-${C5_VERSION} 775 "root:www-data"' && \
    test_for_dir /usr/local/src/concrete5-${C5_VERSION} 775 "root:www-data" && \
    echof run "ls -lAh /usr/local/src/concrete5-${C5_VERSION}" && \
    ls -lAh /usr/local/src/concrete5-${C5_VERSION} && \
    echof run "rm -v /usr/local/src/concrete5-${C5_VERSION}.zip" && \
    rm -v /usr/local/src/concrete5-${C5_VERSION}.zip

## Assert permissions into extracted files
RUN echof info "Concrete5 Version: $C5_VERSION" && \
    echof run 'test_for_dir /usr/local/src/concrete5-$C5_VERSION 775 "root:www-data"' && \
    test_for_dir /usr/local/src/concrete5-$C5_VERSION 775 "root:www-data" && \

## Add files for use in later stages of deployment.
ADD config/database.php /usr/local/src/database.php
ADD /php/docker-php-uploads.ini /usr/local/etc/php/conf.d/docker-php-uploads.ini

# Persist website user data, logs & apache config if you want
VOLUME [ "/var/www/html", "/usr/local/etc/php", "/var/www/html/config" ]

EXPOSE 80

ENTRYPOINT ["docker-entrypoint"]

CMD ["start-c5"]
