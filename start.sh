#!/bin/bash
## Documentation for Concrete5 CLI installation
## https://documentation.concrete5.org/developers/appendix/cli-commands
## This start script makes some assumptions:
## * That you're using the default mysql port
## * That you just want C5 running instantly at first.
## * That you can set environment variables in your setup

if [[ "$PRESEED" = yes ]]; then
  DBCHECK=`mysqlshow --host=$DB_SERVER --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME`
  if [[ "$dbcheck" == "$DB_NAME" ]]; then
    die() {
    echo "[FAIL] You already have a database on the specified server."
    echo "please run this container with the environment variable PRESEED set to false if you wish to start it without the database preseed."
    1>&2 ; exit 1; }
  else
    /var/www/html/concrete/bin/concrete5 c5:install \
      --db-server=$DB_SERVER \
      --db-username=$DB_USERNAME \
      --db-password=$DB_PASSWORD \
      --db-database=$DB_NAME \
      --site=$C5_SITE_NAME \
      --starting-point=$C5_STARTING_POINT \
      --admin-email=$C5_EMAIL \
      --admin-password=$C5_PASSWORD \
      --default-locale=$C5_LOCALE && \
      apache2-foreground
  fi
  else
    echo "Starting your Concrete5 installation"
    apache2-foreground
fi
