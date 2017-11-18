#!/bin/zsh

export PATH="${HOME}/bin:${HOME}/script:${PATH}"
export HISTSIZE=1000000

if [[ -z "${HOSTNAME}" ]] ; then
	export HOSTNAME="${HOST:-$(hostname)}"
fi

lsopt="-F"
if [[ "$(uname)" == "FreeBSD" ]] || [[ "$(uname)" == "Darwin" ]] ; then
	lsopt="${lsopt} -GF"
	alias df='df -h'
else
	lshelp="$(ls --help)"
	lsopt="${lsopt} --color=auto"
	[ "$(grep -- "--show-control-chars" <<<"${lshelp}")" ] && \
		lsopt="${lsopt} --show-control-chars"
	[ "$(grep -- "--group-directories-first" <<<"${lshelp}")" ] && \
		lsopt="${lsopt} --group-directories-first"
	alias df='df -T -h -x supermount'
fi
alias l="ls ${lsopt}"
alias la='l -a'
alias l1='l -1'
alias ll='l -l'
alias lla='l -la'
alias lsd='l -d */'
unset lshelp lsopt

alias ssu='sudo -H bash --rcfile "${HOME}/.bashrc"'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com || wget -qO /dev/stdout "http://icanhazip.com" || curl -s "http://icanhazip.com"'

if (( $+commands[ssh] )) ; then
	alias ssh='ssh -oStrictHostKeyChecking=no'
	alias ssht='ssh tsaikd@home.tsaikd.org'
fi

if (( $+commands[vim] )) ; then
	export EDITOR="${EDITOR:-vim}"
fi

if (( $+commands[docker] )) ; then
	alias docker="sudo docker"
	alias dklog="docker logs -f"
	alias dkre="docker restart -t 0"
	alias dkcrm='docker rm -v $(docker ps -qf "status=exited")'
	function dkt() {
		local run="run -it --rm"
		local mntpwd="-v '$PWD:$PWD' -w '$PWD'"
		if (($#)) ; then
			eval docker ${run} ${mntpwd} "$@"
		else
			eval docker ${run} ${mntpwd} ubuntu:14.04
		fi
	}
	function dku() {
		local chuser="-u $UID -e 'HOME=$HOME' -v '$HOME:$HOME' -v '/etc/passwd:/etc/passwd:ro' -v '/etc/shadow:/etc/shadow:ro' -v '/etc/group:/etc/group:ro' -v '/etc/sudoers.d:/etc/sudoers.d:ro'"
		if (($#)) ; then
			eval dkt ${chuser} "$@"
		else
			eval dkt ${chuser} ubuntu:14.04
		fi
	}
	function dksh() {
		eval docker exec -it "$@" bash -l
	}
fi

if (( $+commands[fig] )) ; then
	alias fig='sudo fig'
	alias figup="fig up -d"
	function figre() {
		eval fig kill "$@" && \
		eval fig rm --force "$@" && \
		eval fig up -d "$@"
	}
fi

if (( $+commands[git] )) && (( $+commands[gitk] )) ; then
	alias gitk='gitk --all &'
	alias gitkui='gitk --all & ; git gui &'
fi

if [[ "${TERM}" == "xterm" ]] ; then
	if (( $+commands[tmux] )) ; then
		if [[ -z "${TMUX}" ]] ; then
			tmux attach || tmux
		fi
	elif (( $+commands[screen] )) ; then
		screen -wipe
		screen -x "$(whoami)" || screen -S "$(whoami)"
	elif [ "$(uname -s)" != "Darwin" ] ; then
		[ "$(id -u)" -ne 0 ] && [ -n "$(type -p last)" ] && last -5
	fi
elif [ "$(uname -s)" != "Darwin" ] ; then
	[ "$(id -u)" -ne 0 ] && [ -n "$(type -p last)" ] && last -5
fi

# archlinux
[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ] && \
	source "/usr/share/doc/pkgfile/command-not-found.zsh"

# load custom script post login
if [ -d "${MYSHELL}/custom/zsh/login-post" ] ; then
	for i in $(find "${MYSHELL}/custom/zsh/login-post" -iname \*.zsh) ; do
		source "${i}"
	done
fi

# load custom script by host
[ -f "${HOME}/.zshrc-${HOSTNAME}" ] && \
	source "${HOME}/.zshrc-${HOSTNAME}"

unset i

