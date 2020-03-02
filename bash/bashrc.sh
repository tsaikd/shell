# .bashrc

if [ "${PS1}" ] ; then # this line is used for sftp login

if [ "$DISABLE_AUTO_UPDATE" != "true" ]; then
	${SHELL} "${MYSHELL}/tools/check_for_upgrade.sh"
fi

# path control functions
function pathadd() {
	local i
	for i in "$@" ; do
		if [ -z "$(grep ":${i}:" <<< ":${PATH}:")" ] ; then
			export PATH="${PATH}:${i}"
		fi
	done
}

function pathins() {
	local i
	for i in "$@" ; do
		if [ -z "$(grep ":${i}:" <<< ":${PATH}:")" ] ; then
			export PATH="${i}:${PATH}"
		fi
	done
}

# load bach complation
function lbcomp() {
	local d i
	[ -f "/etc/bash_completion" ] && source "/etc/bash_completion"
	d="${HOME}/script/bash_completion.d"
	if [ -d "${d}" ] ; then
		for i in "${d}"/* ; do
			[[ ${i##*/} != @\(*~\|*.bak\|*.swp\|\#*\#\|*.dpkg*\|.rpm*\) ]] && \
				source "${i}"
		done
	fi

	[ -f "/snap/google-cloud-sdk/current/completion.bash.inc" ] && source "/snap/google-cloud-sdk/current/completion.bash.inc"

	# set PS1
	[ "$(type -t __git_ps1)" ] && PS1_GIT='$(__git_ps1 " \[\e[01;35m\](%s)")'
	eval PS1="${PS1_EVAL}"
}

if [ -d "${MYSHELL}/plugins" ]; then
	for i in "${MYSHELL}/plugins/"* ; do
		source "${i}"
	done
fi

bind '"\x1b\x5b\x41":history-search-backward'
bind '"\x1b\x5b\x42":history-search-forward'

# setup path info
pathadd "/sbin" "/usr/sbin" "/usr/local/sbin" \
	"/bin" "/usr/bin" "/usr/local/bin"
[ "$(type -p distcc)" ] && pathins "/usr/lib/distcc/bin"
if [ "$(type -p ccache)" ] ; then
	if [ -d "/usr/lib64/ccache/bin" ] ; then
		pathins "/usr/lib64/ccache/bin"
	elif [ -d "/usr/lib/ccache/bin" ] ; then
		pathins "/usr/lib/ccache/bin"
	elif [ -x "/usr/lib64/ccache/gcc" ] ; then
		pathins "/usr/lib64/ccache"
	elif [ -x "/usr/lib/ccache/gcc" ] ; then
		pathins "/usr/lib/ccache"
	else
		echo "ccache detected, but unknown path!!"
	fi
fi
pathins "${HOME}/bin" "${HOME}/script"

shopt -s checkwinsize
export LANG="C"
unset LANGUAGE $(set | grep ^LC_ | cut -f1 -d=)
export LESSHISTFILE="-"
export HISTCONTROL=ignoreboth
export HISTFILESIZE=50000
export HISTSIZE=10000
export KD_PUBLIC_PC=1
[ "$(type -p vim)" ] && true ${EDITOR:=vim}
export EDITOR
export PAGER="less"
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[00;32m'
umask 022

# screen prompt
if [ "${TERM}" == "screen" ] ; then
	PROMPT_COMMAND='echo -ne "\033]0;${PWD:$(( (${#PWD}-45) >= 0 ? (${#PWD}-45) : 0 ))}\007"'
fi

# setup prompt
PS1_HOST='\[\e[01;31m\]\h'
if [ "$(id -u)" -ne 0 ] ; then
	PS1_USER=' \[\e[01;32m\]\u'
else
	PS1_USER=' \[\e[01;33;41m\]\u'
fi
PS1_DIR=' \[\e[01;34;40m\]\w\[\e[m\]'
PS1_TAIL='\[\e[m\] $ '
PS1_EVAL='${PS1_HOST}${PS1_USER}${PS1_DIR}${PS1_GIT}${PS1_TAIL}'
eval PS1="${PS1_EVAL}"

if type kube_ps1 &> /dev/null; then
	KUBE_PS1_SUFFIX=") "
	PS1='$(kube_ps1)'${PS1}
fi

# setup default language
if [ "$(type -p locale)" ] ; then
	localelist="$(locale -a)"
	if [ "${TERM}" == "linux" ] ; then # default language for console
		if [ "$(grep -i "en_US.utf" <<<"${localelist}")" ] ; then
			export LANG="$(grep -i "en_US.utf" <<<"${localelist}")"
		fi
	else # default language for others
		if [ "$(grep -i "zh_TW.utf" <<<"${localelist}")" ] ; then
			export LANG="$(grep -i "zh_TW.utf" <<<"${localelist}")"
		elif [ "$(grep -i "en_US.utf" <<<"${localelist}")" ] ; then
			export LANG="$(grep -i "en_US.utf" <<<"${localelist}")"
		fi
	fi
	unset localelist
fi

[ "$(type -p setterm)" ] && TERM=linux setterm -regtabs 4

if [ "$(type -p tmux)" ] ; then
	if [ -z "${TMUX}" ] ; then
		function sr() {
			tmux attach || tmux
			clear
		}
	fi
elif [ "$(type -p screen)" ] ; then
	function sr() {
		screen -wipe
		{ screen -x `whoami` || screen -S `whoami` ; } && clear
	}
fi

# proxy config
function proxyoff() {
	unset HTTP_PROXY
	unset http_proxy
	unset HTTPS_PROXY
	unset https_proxy
	unset FTP_PROXY
	unset ftp_proxy
	unset RSYNC_PROXY
	unset rsync_proxy
	echo "Proxy environment variable removed."
}

lsopt="-F"
dfopt="-h"
if [ -x /usr/bin/dircolors ]; then
	lsopt="${lsopt} --color=auto"
	alias grep='grep --color=auto'
fi
if [ "$(uname)" == "FreeBSD" ] || [ "$(uname)" == "Darwin" ] ; then
	lsopt="${lsopt} -GF"
else
	lshelp="$(ls --help)"
	[ "$(grep -- "--show-control-chars" <<<"${lshelp}")" ] && \
		lsopt="${lsopt} --show-control-chars"
	[ "$(grep -- "--group-directories-first" <<<"${lshelp}")" ] && \
		lsopt="${lsopt} --group-directories-first"
	dfopt="${dfopt} -T -x supermount"
fi
alias l="ls ${lsopt}"
alias la='l -a'
alias l1='l -1'
alias ll='l -l'
alias lla='l -la'
alias lsd='l -d */'
alias df="df ${dfopt}"
unset lshelp lsopt dfopt

alias cd..='cd ..'
alias cp='cp -i'
alias du='du -h'
alias md='mkdir'
alias mv='mv -i'
alias ping='ping -n'
alias rd='rmdir'
alias rm='rm -i'
alias tar='nice -n 19 tar'
alias qq='[ -r "${HOME}/.bash_logout" ] && source "${HOME}/.bash_logout" ; exec clear'

alias myip='dig +short myip.opendns.com @resolver1.opendns.com || wget -qO /dev/stdout "http://icanhazip.com" || curl -s "http://icanhazip.com"'

[ -x /usr/bin/lesspipe ] && \
	eval "$(SHELL=/bin/sh lesspipe)"
[ "$(type -p readlink)" ] && \
	alias cd.='cd "$(readlink -f .)"'
[ "$(type -p sudo)" ] && \
	alias ssu='sudo -H bash --rcfile "${HOME}/.bashrc"'
[ "$(type -p vim)" ] && \
	alias vi='vim'
[ "$(type -p perl)" ] && \
	alias col='perl -e "while (<>) { s/\033\[[\d;]*[mH]//g; print; }" | col'
[ "$(type -p colordiff)" ] && \
	alias diff='colordiff'
[ "$(type -p diff)" ] && \
	alias diff='diff -ruNp'
[ "$(type -p sdiff)" ] && \
	alias sdiff='sdiff -s -w 80'
[ "$(type -p rsync)" ] && [ "$(type -p ssh)" ] && \
	alias rscp='rsync -aP -e "ssh -oCiphers=arcfour -oStrictHostKeyChecking=no"' && \
	alias rsmv='rscp --remove-source-files'
[ "$(type -p telnet)" ] && \
	alias telnet='telnet -8'
[ "$(type -p fuser)" ] && \
	alias fuser='fuser -muv'
[ "$(type -p mail)" ] && \
	alias mail='mail -u `\whoami`'
[ "$(type -p mkisofs)" ] && \
	alias mkisofs='mkisofs -l -r -J'
[ "$(type -p gitk)" ] && \
	alias gitk='gitk --all --date-order &'
[ "$(type -p direnv)" ] && \
	eval "$(direnv hook bash)"
if [ "$(type -p kubectl)" ]; then
	source <(kubectl completion bash)
	alias k='kubectl'
	complete -o default -F __start_kubectl k
fi
[ "$(type -p helm)" ] && \
	source <(helm completion bash)
[ -z "$(type -p host)" ] && [ "$(type -p links)" ] && \
	alias host='links -lookup'

if [ "$(type -p docker)" ] ; then
	alias dklog="docker logs -f"
	alias dkre="docker restart -t 0"
fi

if [ "$(id -u)" -eq 0 ] ; then
	pathadd "${HOME}/sbin" "${HOME}/script/sbin" "${HOME}/bin/sbin"
	[ "$(type -p reboot)" ] && \
		alias reboot='exec reboot'
	[ "$(type -p poweroff)" ] && \
		alias halt='exec poweroff'

	if [ "$(type -t service)" ] ; then
		function _service() {
			local cur=${COMP_WORDS[COMP_CWORD]}
			local reply=""
			local prev
			if [ "${COMP_CWORD}" -eq 1 ] ; then
				reply="$(ls /etc/init.d/)"
			elif [ "${COMP_CWORD}" -eq 2 ] ; then
				reply="status start stop restart reload"
			fi
			if [ "${reply}" ] ; then
				COMPREPLY=( $( compgen -W "${reply}" -- ${cur} ) )
			fi
		}
		complete -F _service -o default service
	fi
	if [ "$(type -p zfs)" ] ; then
		alias zfl='zfs list -t filesystem'
		alias zfls='zfs list -t filesystem,snapshot,volume'
		function _zfs() {
			local cur=${COMP_WORDS[COMP_CWORD]}
			local reply=""
			local prev
			if [ "${COMP_CWORD}" -eq 1 ] ; then
				reply="create destroy list set get inherit mount unmount send receive"
			elif [ "${COMP_CWORD}" -eq 2 ] ; then
				case "${COMP_WORDS[1]}" in
				create)		reply="$(zfs list -t filesystem,snapshot,volume | sed '1d' | awk '{print $1}')" ;;
				destroy)	reply="$(zfs list -t filesystem,snapshot,volume | sed '1d' | awk '{print $1}')" ;;
				get)		reply="quota mountpoint checksum compression atime dedup all" ;;
				set)		reply="quota mountpoint checksum compression=lz4 atime=off dedup" ;;
				inherit)	reply="quota mountpoint checksum compression atime dedup" ;;
				esac
			elif [ "${COMP_CWORD}" -eq 3 ] ; then
				case "${COMP_WORDS[1]}" in
				get)		reply="$(zfs list -t filesystem,snapshot,volume | sed '1d' | awk '{print $1}')" ;;
				set)		reply="$(zfs list -t filesystem,snapshot,volume | sed '1d' | awk '{print $1}')" ;;
				inherit)	reply="$(zfs list -t filesystem,snapshot,volume | sed '1d' | awk '{print $1}')" ;;
				esac
			elif [ "${COMP_CWORD}" -gt 3 ] ; then
				case "${COMP_WORDS[1]}" in
				set)
					prev="${COMP_WORDS[$((COMP_CWORD-1))]}"
					[ "${prev}" == "=" ] && prev="${COMP_WORDS[$((COMP_CWORD-2))]}"
					case "${prev}" in
					atime)		reply="on off" ;;
					compression)	reply="lz4 off" ;;
					esac
					;;
				esac
			fi
			if [ "${reply}" ] ; then
				COMPREPLY=( $( compgen -W "${reply}" -- ${cur} ) )
			fi
		}
		complete -F _zfs -o default zfs
		function _zpool() {
			local cur=${COMP_WORDS[COMP_CWORD]}
			local reply=""
			local prev
			if [ "${COMP_CWORD}" -eq 1 ] ; then
				reply="create destroy list iostat status scrub set get"
			elif [ "${COMP_CWORD}" -eq 2 ] ; then
				case "${COMP_WORDS[1]}" in
				create)		reply="-o" ;;
				destroy)	reply="$(zpool list | sed '1d' | awk '{print $1}')" ;;
				get)		reply="listsnapshots autoexpand all" ;;
				set)		reply="listsnapshots autoexpand" ;;
				esac
			elif [ "${COMP_CWORD}" -eq 3 ] ; then
				case "${COMP_WORDS[1]}" in
				create)		[ "${COMP_WORDS[2]}" == "-o" ] && reply="autoexpand=on" ;;
				set)		reply="$(zpool list | sed '1d' | awk '{print $1}')" ;;
				esac
			elif [ "${COMP_CWORD}" -gt 3 ] ; then
				case "${COMP_WORDS[1]}" in
				create)
					prev="${COMP_WORDS[$((COMP_CWORD-1))]}"
					[ "${prev}" == "=" ] && prev="${COMP_WORDS[$((COMP_CWORD-2))]}"
					case "${prev}" in
					autoexpand)	reply="on off" ;;
					esac
					;;
				esac
			fi
			if [ "${reply}" ] ; then
				COMPREPLY=( $( compgen -W "${reply}" -- ${cur} ) )
			fi
		}
		complete -F _zpool -o default zpool
	fi
	if [ "$(type -p virsh)" ] ; then
		alias vm='virsh'
		alias vls='virsh list --all'
		function _virsh() {
			local cur=${COMP_WORDS[COMP_CWORD]}
			local reply=""
			if [ "${COMP_CWORD}" -eq 1 ] ; then
				reply="list define undefine edit start destroy setmem dominfo dumpxml autostart"
			elif [ "${COMP_CWORD}" -eq 2 ] ; then
				case "${COMP_WORDS[1]}" in
				list)		reply="--all" ;;
				start)		reply="$(virsh list --all | grep "shut off" | awk '{print $2}')" ;;
				destroy)	reply="$(virsh list --all | grep "running" | awk '{print $2}')" ;;
				undefine)	reply="$(virsh list --all | sed '1,2d;$d' | awk '{print $2}')" ;;
				edit)		reply="$(virsh list --all | sed '1,2d;$d' | awk '{print $2}')" ;;
				setmem)		reply="$(virsh list --all | sed '1,2d;$d' | awk '{print $2}')" ;;
				dominfo)	reply="$(virsh list --all | sed '1,2d;$d' | awk '{print $2}')" ;;
				dumpxml)	reply="$(virsh list --all | sed '1,2d;$d' | awk '{print $2}')" ;;
				autostart)	reply="$(virsh list --all | sed '1,2d;$d' | awk '{print $2}')" ;;
				esac
			elif [ "${COMP_CWORD}" -eq 3 ] ; then
				case "${COMP_WORDS[1]}" in
				autostart)	reply="--disable" ;;
				esac
			fi
			if [ "${reply}" ] ; then
				COMPREPLY=( $( compgen -W "${reply}" -- ${cur} ) )
			fi
		}
		complete -F _virsh -o default virsh
		complete -F _virsh -o default vm
	fi

	i="/root/script/config/general.sh"
	[ -w "${i}" ] && alias viconf="vi \"${i}\""
	if [ "$(type -p ccache)" ] ; then
		export CCACHE_DIR="/var/tmp/ccache"
		export CCACHE_NOLINK=1
		export CCACHE_UMASK="002"
	fi
fi

if [ "$(type -p tput)" ] ; then
	[ "$(tput cols)" -lt 80 ] && echo "The screen columns are smaller then 80!"
	[ "$(tput lines)" -lt 24 ] && echo "The screen lines are smaller then 24!"
fi
[ "$(id -u)" -ne 0 ] && [ -n "$(type -p last)" ] && last -5

if [ -d "${HOME}/.bash.d" ] ; then
	for i in "${HOME}/.bash.d/"* ; do
		source "${i}"
	done
fi

unset i

[ -r "${HOME}/.bashrc.local" ] && source "${HOME}/.bashrc.local"

# auto attach existed session
if [ "${DISABLE_AUTO_SESSION}" != "true" ]; then
	[ "${TERM}" == "xterm" ] && [ "$(id -u)" -ne 0 ] && [ "$(type -t sr)" ] && sr || true
fi

fi # [ "${PS1}" ]
