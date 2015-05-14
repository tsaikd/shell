#!/bin/bash

PN="${BASH_SOURCE[0]##*/}"
PD="${BASH_SOURCE[0]%/*}"

function usage() {
	cat <<EOF
Usage: ${PN} [Options] [Shell]
Options:
  -h       : show this help message

Shell: (default: auto select from current shell)
  bash     : install bash environment
  zsh      : install zsh environment
EOF
	[ $# -gt 0 ] && { echo ; echo "$@" ; exit 1 ; } || exit 0
}

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
				mv "${path_tar}" "${backup_file}" || exit $?
				cp -a "${path_src}" "${path_tar}" || exit $?
			else
				printf '\033[0;33m%s %s\033[0m\n' "${path_tar}" 'exists, difference:'
				echo "${diff_file}"
				echo
			fi
		fi
	else
		cp -a "${path_src}" "${path_tar}" || exit $?
	fi
}

while getopts "h" opt; do
	case "${opt}" in
	h) usage ;;
	esac
done

action="${1}"

if [ -z "${action}" ] ; then
	case "${SHELL}" in
	/bin/bash) action="bash" ;;
	/bin/zsh) action="zsh" ;;
	*) usage "Unknown SHELL: '${SHELL}'" ;;
	esac
fi

pushd "${PD}" &>/dev/null
cd ..
export MYSHELL="${MYSHELL:-${PWD}}"

case "${action}" in
bash)
	pushd "${MYSHELL}/bash" &>/dev/null
	compare_config "bashrc.template" "${HOME}/.bashrc" true
	compare_config "bashlogout.template" "${HOME}/.bash_logout" true
	popd &>/dev/null
	;;
zsh)
	pushd "${MYSHELL}/zsh" &>/dev/null
	if [ ! -d oh-my-zsh ] ; then
		git clone https://github.com/robbyrussell/oh-my-zsh || exit 1
	fi
	cp -af "oh-my-zsh/templates/zshrc.zsh-template" ./
	patch -p2 < zshrc.patch >/dev/null
	compare_config "zshrc.zsh-template" "${HOME}/.zshrc" true
	rm -f "zshrc.zsh-template"
	ln -sf "${PWD}/robbyrussell.zsh-theme" "oh-my-zsh/custom/"
	ln -sf "${PWD}/tsaikd.zsh" "oh-my-zsh/custom/"
	popd &>/dev/null
	;;
*)
	usage "Unknown action: '${action}'"
	;;
esac

compare_config "screen/screenrc.template" "${HOME}/.screenrc" true
compare_config "vim/vimrc.template" "${HOME}/.vimrc" true
compare_config "top/toprc.template" "${HOME}/.toprc" true
compare_config "tmux/tmux.conf.template" "${HOME}/.tmux.conf" true
compare_config "git/gitconfig.template" "${HOME}/.gitconfig"

popd &>/dev/null

