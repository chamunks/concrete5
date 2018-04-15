#!/bin/bash

## If directory doesn't exist create it and set group perms.
## Var $1 should be a directory.
## Var $2 should be your octal permissions for said directory.
## Var $3 should be your "user:group" names

## Set variables from idices
CHK_PATH=$1
CHK_OWNERSHIP=$2
CHK_OCTAL=$3
## Test for directory existence if it exists then test_perm else make it so.
if [ -d '$1' ]; then
  test_perm $CHK_PATH $CHK_OWNERSHIP $CHK_OCTAL
else
  ## make the directory exist with the correct perms.
  echof info "Directory $1 was missing, creating directory and setting permissions."
  echof run "mkdir -pv $1"
  mkdir -pv $1
  echof info "test_for_dir is running test_perm $CHK_PATH $CHK_OWNERSHIP $CHK_OCTAL"
  test_perm $CHK_PATH $CHK_OWNERSHIP $CHK_OCTAL
fi
