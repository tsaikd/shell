#!/bin/sh

_check_for_upgrade() {
	local epoch_file="${MYSHELL}/.last-update"
	local epoch_cur=$(($(date +%s) / 60 / 60 / 24))
	local epoch_last=0
	[ -f "${epoch_file}" ] && . "${epoch_file}"
	local epoch_diff=$((${epoch_cur} - ${epoch_last}))
	if [ "${epoch_diff}" -gt "${UPDATE_SHELL_DAYS:-13}" ] ; then
		${SHELL} "${MYSHELL}/tools/upgrade.sh"
		echo "epoch_last=${epoch_cur}" > "${epoch_file}"
	fi
}

_check_for_upgrade

