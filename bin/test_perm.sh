#!/bin/bash
## Simple permissions test and assertion.

function test_perm() {
	## This function should only be called by test_for_[dir|file] functions
	echof info "running test_perm function"
			## setting variables
			CURRENT_UID=$(stat -c %U "$1")
			CURRENT_GID=$(stat -c %G "$1")
			CURRENT_OCTAL=$(stat -c %a "$1")
			CURRENT_OWNERSHIP=$(echo $CURRENT_UID:$CURRENT_GID)
			echof info "test_perm for $CHK_PATH $CHK_OWNERSHIP $CHK_OCTAL"
	## test octal permissions and assert any needed corrections.
	if [ ! "$CURRENT_OCTAL" == $CHK_OCTAL ]; then
		echof warn "$CHK_PATH was not set with the correct permissions $CHK_OCTAL"
		echof run "chmod $CHK_OCTAL $CHK_PATH"
		chmod -v $CHK_OCTAL $CHK_PATH
	else
		echof info "$1 has the correct permissions"
	fi
	## Test group and user permissions and assert them if they're wrong.
	if [ ! "$CURRENT_OWNERSHIP" == $CHK_OWNERSHIP ]; then
		echof warn "$CHK_PATH did does not have the correct permissions."
		echof warn "$CHK_PATH has $CURRENT_OCTAL it needs to have $CHK_OWNERSHIP"
		echof run "chown -v $CHK_PATH $CHK_OCTAL"
		chown -v $CHK_OCTAL $CHK_PATH
	else
		echof info "$CHK_PATH is owned by the correct user:group $CHK_OCTAL"
	fi
}
