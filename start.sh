#!/bin/bash
## Documentation for Concrete5 CLI installation
## https://documentation.concrete5.org/developers/appendix/cli-commands
## This start script makes some assumptions:
## * That you're using the default mysql port
## * That you just want C5 running instantly at first.
## * That you can set environment variables in your setup
echo "[Info] Running start script"
echo "[Info] Waiting for a grace period to let MariaDB start up."
sleep 5s
function console_break() {
  for i in {1..2}; do
    echo
  done
}

function setup_conf() {
	if [ ! -z "$1" ]; then
    echo "[RUN] sed -i "s/$2/$1/g" $3"
		sed -i "s/$2/$1/g" $3
    OUT=$(cat ${3}|grep ${1})
    ## If I want to keep this make it better using a test but for now it's just for debugging
    echo "[Info] Configuration of ${1} is set at ${OUT}"
	else
		echo "[Info] $1 was not set leaving as default instead."
	fi
}
## Disabling config installation for now.  It may conflict with the invocation.
# console_break
# echo "[Info] If empty, copy database.php configuration to volume"
# if [ ! -e /var/www/html/config/database.php ]; then
# 		echo "[Info] /var/www/html/config/database.php is missing installing alternative."
# 		echo "[RUN] cp /usr/local/src/database.php /var/www/html/config/database.php"
# 		cp /usr/local/src/database.php /var/www/html/config/database.php
# 		echo "[Info] copied database.php configuration into /var/www/html/config/database.php"
# fi
#
# ## Configure database.php
# echo "[Info] Installing configuration changes."
# setup_conf "${DB_SERVER}" DBCONF_SERVER /var/www/html/config/database.php
# setup_conf "${DB_NAME}" DBCONF_NAME /var/www/html/config/database.php
# setup_conf "${DB_USERNAME}" DBCONF_USERNAME /var/www/html/config/database.php
# setup_conf "${DB_PASSWORD}" DBCONF_PASSWORD /var/www/html/config/database.php

console_break
echo "[Info] Testing connection to MariaDB database"
echo "[RUN] Executing the command: mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME"
DBCHECK=$(mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME)
mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME
echo "[Info] Waiting for a grace period to let MariaDB get over the fact we've connected to it already once."
sleep 10s
DBCHECK_RESULT=${DBCHECK}
echo "[Info], mysqlshow indicates the presence of the database: $DBCHECK_RESULT"

console_break
## To run database preseed or not to.  Then run the appliance.
echo "[Info] Preseed Database during first run?"
if [[ "$C5_PRESEED" == yes ]]; then
  echo [Info] Checking that MariaDB is connectable and has the correct default database available.
  if [[ ! "$DBCHECK_RESULT" == "$DB_NAME" ]]; then
    echo The database $DB_NAME does not exist on $DB_USERNAME@$DB_SERVER.
    ## This needs to be more advanced
    # die() {
    # echo "[FAIL] You already have a database on the specified server."
    # echo "       please run this container with the environment variable C5_PRESEED set to no if you wish to start it without the database C5_PRESEED."
    # 1>&2 ; exit 1; }
  else
    echo "[Info] No tables Found at $DB_USERNAME@$DB_SERVER in $DB_NAME using password $DB_PASSWORD"
    echo "[Info] Running C5 installation with the following settings"
    echo "[RUN]  /var/www/html/concrete/bin/concrete5 c5:install --db-server=$DB_SERVER --db-username=$DB_USERNAME --db-password=$DB_PASSWORD --db-database=$DB_NAME --site=$C5_SITE_NAME --starting-point=$C5_STARTING_POINT --admin-email=$C5_EMAIL --admin-password=$C5_PASSWORD --site-locale=$C5_LOCALE"
    /var/www/html/concrete/bin/concrete5 c5:install -vvv \
      --db-server=$DB_SERVER \
      --db-username=$DB_USERNAME \
      --db-password=$DB_PASSWORD \
      --db-database=$DB_NAME \
      --site=$C5_SITE_NAME \
      --starting-point=$C5_STARTING_POINT \
      --admin-email=$C5_EMAIL \
      --admin-password=$C5_PASSWORD \
       --site-locale=$C5_LOCALE
  fi
  else
    echo "[DONE] Starting your Concrete5 installation"
fi

apache2-foreground
