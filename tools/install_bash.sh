#!/bin/bash

PN="${BASH_SOURCE[0]##*/}"
PD="${BASH_SOURCE[0]%/*}"

function compare_config() {
	local path_src="${1}"
	local path_tar="${2}"
	local autobackup="${3}"
	if [ -f "${path_tar}" ] ; then
		local diff_file="$(diff -ruNp "${path_tar}" "${path_src}")"
		if [ "${diff_file}" ] ; then
			if [ "${autobackup}" ] ; then
				local backup_file="${path_tar}_$(date +%s)"
				printf '\033[0;32m%s %s %s\033[0m\n' "${path_tar}" 'exists, backup to' "${backup_file}"
				mv "${path_tar}" "${backup_file}"
				cp -a "${path_src}" "${path_tar}"
			else
				printf '\033[0;33m%s %s\033[0m\n' "${path_tar}" 'exists, difference:'
				echo "${diff_file}"
				echo
			fi
		fi
	else
		cp -a "${path_src}" "${path_tar}"
	fi
}

pushd "${PD}" &>/dev/null
cd ..
export MYSHELL="${MYSHELL:-${PWD}}"

compare_config "bash/bashrc.template" "${HOME}/.bashrc" true
compare_config "bash/bashlogout.template" "${HOME}/.bash_logout" true
compare_config "screen/screenrc.template" "${HOME}/.screenrc" true
compare_config "vim/vimrc.template" "${HOME}/.vimrc" true
compare_config "top/toprc.template" "${HOME}/.toprc" true
compare_config "git/gitconfig.template" "${HOME}/.gitconfig"

popd &>/dev/null

