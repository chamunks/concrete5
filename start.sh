#!/bin/bash
## Documentation for Concrete5 CLI installation
## https://documentation.concrete5.org/developers/appendix/cli-commands
## This start script makes some assumptions:
## * That you're using the default mysql port
## * That you just want C5 running instantly at first.
## * That you can set environment variables in your setup
echof info "Running start script"

## Function echo_fancy echof
## Colorize and fancify console output.
## Useage: echof [run|warn|info] {Message}
function echof() {
	LGREEN_STDOUT='\033[1;32m'
	YELLOW_STDOUT='\033[1;33m'
	BLUE_STDOUT='\033[0;34'
  DGRAY_STDOUT='\033[1:30m'
  WHITE_STDOUT='\033[1;37m'
	case $1 in
		run )
			echo "[${LGREEN_STDOUT}RUN${WHITE_STDOUT}]  $2"
			;;
		warn )
			echo "[${YELLOW_STDOUT}Warn${WHITE_STDOUT}] $2"
			;;
		info )
			echo "[${BLUE_STDOUT}Info${WHITE_STDOUT}] ${DGRAY_STDOUT}$2"
			;;
		esac
}

# echof info "Waiting for a grace period to let MariaDB start up."
# sleep 30s
function console_break() {
  for i in {1..2}; do
    echo
  done
}

function setup_conf() {
	if [ ! -z "$1" ]; then
    echof run "sed -i "s/$2/$1/g" $3"
		sed -i "s/$2/$1/g" $3
    OUT=$(cat ${3}|grep ${1})
    ## If I want to keep this make it better using a test but for now it's just for debugging
    echof info "Configuration of ${1} is set at ${OUT}"
	else
		echof info "$1 was not set leaving as default instead."
	fi
}
## Disabling config installation for now.  It may conflict with the invocation.
# console_break
# echof info "If empty, copy database.php configuration to volume"
# if [ ! -e /var/www/html/config/database.php ]; then
# 		echof info "/var/www/html/config/database.php is missing installing alternative."
# 		echof run "cp /usr/local/src/database.php /var/www/html/config/database.php"
# 		cp /usr/local/src/database.php /var/www/html/config/database.php
# 		echof info "copied database.php configuration into /var/www/html/config/database.php"
# fi
#
# ## Configure database.php
# echof info "Installing configuration changes."
# setup_conf "${DB_SERVER}" DBCONF_SERVER /var/www/html/config/database.php
# setup_conf "${DB_NAME}" DBCONF_NAME /var/www/html/config/database.php
# setup_conf "${DB_USERNAME}" DBCONF_USERNAME /var/www/html/config/database.php
# setup_conf "${DB_PASSWORD}" DBCONF_PASSWORD /var/www/html/config/database.php

console_break
echof info "Testing connection to MariaDB database"
echof run "Executing the command: mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME"
DBCHECK=$(mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME)
mysqlshow --host=$DB_SERVER --port=3306 --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME
# echof info "Waiting for a grace period to let MariaDB get over the fact we've connected to it already once."
# sleep 10s
DBCHECK_RESULT=${DBCHECK}
echo "[Info], mysqlshow indicates the presence of the database: $DBCHECK_RESULT"

console_break
## To run database preseed or not to.  Then run the appliance.
echof info "Preseed Database during first run?"
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
    echof info "No tables Found at $DB_USERNAME@$DB_SERVER in $DB_NAME using password $DB_PASSWORD"
    echof info "Running C5 installation with the following settings"
    echof run "/var/www/html/concrete/bin/concrete5 c5:install --db-server=$DB_SERVER --db-username=$DB_USERNAME --db-password=$DB_PASSWORD --db-database=$DB_NAME --site=$C5_SITE_NAME --starting-point=$C5_STARTING_POINT --admin-email=$C5_EMAIL --admin-password=$C5_PASSWORD --site-locale=$C5_LOCALE"
    /var/www/html/concrete/bin/concrete5 c5:install \
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
