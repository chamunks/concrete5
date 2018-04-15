#!/bin/bash

## Function echo_fancy echof all this does is makes consecutive console echo's
## much easier to read in CI/CD environments.
## Useage: echof [run|warn|info|fail|done|blank] {Message}
function echof() {
	case $1 in
		run )
			echo "[RUN]  $2"
			;;
		warn )
			echo "[Warn] $2"
			;;
		info )
			echo "[Info] $2"
			;;
		fail )
			echo "[Fail]" $2
			;;
		done )
			echo "[DONE] $2"
			;;
		blank )
			echo "       $2"
			;;
		* )
			echof info "You've not included instructions echo_fancy understands printing usage."
			echof info "echof [run|warn|info|fail|done|blank] {Message}"
			echof info "Example:"
			echof info "echof blank This is a second line echoed to console."
			echof blank "This is a second line echoed to console."
		esac
}
