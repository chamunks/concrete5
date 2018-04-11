#!/bin/bash
## Documentation for Concrete5 CLI installation
## https://documentation.concrete5.org/developers/appendix/cli-commands
## This start script makes some assumptions:
## * That you're using the default mysql port
## * That you just want C5 running instantly at first.
## * That you can set environment variables in your setup
echo "[Info] Running start script"

function console_break() {
  for i in {1..5}; do
    echo
  done
}

function setup_conf() {
	if [ ! -z "$1" ]; then
		sed -i "s/$2/$$1/g" $3
	else
		echo "[Info] $$1 was not set leaving as default instead."
	fi
}

console_break
# if empty, copy database.php configuration to volume
if [ ! -e /var/www/html/config/database.php ]; then
		echo "[Info] /var/www/html/config/database.php is missing installing alternative."
		echo "[RUN] cp /usr/local/src/database.php /etc/apache2"
		cp /usr/local/src/database.php /var/www/html/config/database.php
		echo "[Info] copied database.php configuration into /var/www/html/config/database.php"
fi

## Configure database.php
setup_conf '$DB_SERVER' DBCONF_SERVER /var/www/html/config/database.php
setup_conf '$DB_NAME' DBCONF_NAME /var/www/html/config/database.php
setup_conf '$DB_USERNAME' DBCONF_USERNAME /var/www/html/config/database.php
setup_conf '$DB_PASSWORD' DBCONF_PASSWORD /var/www/html/config/database.php

console_break
echo "[Info] Testing connection to MariaDB database"
echo "[RUN] Executing the command: mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME"
DBCHECK=`mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME`
eval $DBCHECK

console_break
if [[ "$C5_PRESEED" == yes ]]; then
  echo $DBCHECK
  if [[ "$DBCHECK" == "$DB_NAME" ]]; then
    die() {
    echo "[FAIL] You already have a database on the specified server."
    echo "       please run this container with the environment variable C5_PRESEED set to no if you wish to start it without the database C5_PRESEED."
    1>&2 ; exit 1; }
  else
    echo "[Info] No DB Found at $DB_USERNAME@$DB_SERVER using password $DB_PASSWORD"
    echo "[Info] Running C5 installation with the following settings"
    echo "[RUN]     /var/www/html/concrete/bin/concrete5 c5:install \
          --db-server=$DB_SERVER \
          --db-username=$DB_USERNAME \
          --db-password=$DB_PASSWORD \
          --db-database=$DB_NAME \
          --site=$C5_SITE_NAME \
          --starting-point=$C5_STARTING_POINT \
          --admin-email=$C5_EMAIL \
          --admin-password=$C5_PASSWORD \
          --site-locale=$C5_LOCALE && \
          apache2-foreground"
    /var/www/html/concrete/bin/concrete5 c5:install \
      --db-server=$DB_SERVER \
      --db-username=$DB_USERNAME \
      --db-password=$DB_PASSWORD \
      --db-database=$DB_NAME \
      --site=$C5_SITE_NAME \
      --starting-point=$C5_STARTING_POINT \
      --admin-email=$C5_EMAIL \
      --admin-password=$C5_PASSWORD \
      --site-locale=$C5_LOCALE && \
      apache2-foreground
  fi
  else
    echo "[DONE] Starting your Concrete5 installation"
    apache2-foreground
fi
