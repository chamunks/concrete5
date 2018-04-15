#!/bin/bash

## Function echo_fancy echof
## Useage: echof [run|warn|info] {Message}
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
		esac
}
