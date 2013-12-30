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

	# app-shells/gentoo-bashcomp feature
	if [[ -f /etc/profile.d/bash-completion ]] ; then
		source /etc/profile.d/bash-completion
		if [ "$(type -p emerge)" ] ; then
			for i in eei ee eea eef ee1 ; do
				complete -o filenames -F _emerge "${i}"
			done
		fi
	fi

	# set PS1
	[ "$(type -t __git_ps1)" ] && PS1_GIT='$(__git_ps1 " \[\e[01;35m\](%s)")'
	eval PS1="${PS1_EVAL}"
}

bind '"\x1b\x5b\x41":history-search-backward'
bind '"\x1b\x5b\x42":history-search-forward'

# setup path info
pathadd "/sbin" "/usr/sbin" "/usr/local/sbin" \
	"/bin" "/usr/bin" "/usr/local/bin" \
	"${HOME}/bin" "${HOME}/script"
[ "$(type -p distcc)" ] && pathins "/usr/lib/distcc/bin"
if [ "$(type -p ccache)" ] ; then
	if [ -d "/usr/lib/ccache/bin" ] ; then
		pathins "/usr/lib/ccache/bin"
	elif [ -x "/usr/lib/ccache/gcc" ] ; then
		pathins "/usr/lib/ccache"
	else
		echo "ccache detected, but unknown path!!"
	fi
fi

export LANG="C"
unset LANGUAGE $(set | grep ^LC_ | cut -f1 -d=)
export LESSHISTFILE="-"
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

[ "$(type -p screen)" ] && [ "${TERM}" != "screen" ] && function sr() {
	screen -wipe
	{ screen -x `whoami` || screen -S `whoami` ; } && clear
}

[ "$(type -p wget)" ] && function myip () {
	wget -qO /dev/stdout "http://www.whatismyip.com.tw" | perl -ane 's/h2[^0-9]+([0-9.]+)/print $1/e'
	echo
}

[ "$(type -p wget)" ] && [ "$(type -p tar)" ] && function kd_get_bash () {
	wget --no-cache 'http://www.tsaikd.org/git/?p=bash.git;a=snapshot;h=refs/heads/master;sf=tbz2' -O - | tar xjf -
}

lsopt="-F"
if [ "$(uname)" == "FreeBSD" ] ; then
	lsopt="${lsopt} -G"
	alias df='df -T -h'
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

[ "$(type -p readlink)" ] && \
	alias cd.='cd "$(readlink -f .)"'
[ "$(type -p sudo)" ] && \
	alias ssu='sudo su -c "bash --rcfile \"${HOME}/.bashrc\""'
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
	alias rscp='rsync -aP -e "ssh -oCiphers=arcfour -oStrictHostKeyChecking=no"'
[ "$(type -p telnet)" ] && \
	alias telnet='telnet -8'
[ "$(type -p fuser)" ] && \
	alias fuser='fuser -muv'
[ "$(type -p mail)" ] && \
	alias mail='mail -u `\whoami`'
[ "$(type -p htop)" ] && \
	alias top='htop'
[ "$(type -p mkisofs)" ] && \
	alias mkisofs='mkisofs -l -r -J'
[ "$(type -p irssi)" ] && [ "$TERM" == "screen" ] && \
	alias irssi='screen -t IRC 10 irssi'
[ "$(type -p cscope)" ] && \
	alias csc='cscope -bR'
[ "$(type -p gitk)" ] && \
	alias gitk='gitk --all --date-order &'
[ "$(type -p mc)" ] && [ "$TERM" == "screen" ] && \
	alias mc='mc -a'
[ -z "$(type -p host)" ] && [ "$(type -p links)" ] && \
	alias host='links -lookup'
if [ "$(type -p ssh)" ] ; then
	alias ssh='ssh -oStrictHostKeyChecking=no'
	alias ssht='ssh tsaikd@home.tsaikd.org'
fi

i="/var/log/messages"
[ -r "${i}" ] && alias cmesg="tail -n 20 \"${i}\""
i="/var/log/syslog"
[ -r "${i}" ] && alias csyslog="tail -n 20 \"${i}\""

if [ "$(type -p qemu-img)" ] ; then
	function _qemu_img() {
		local cur=${COMP_WORDS[COMP_CWORD]}
		if [ "${COMP_CWORD}" -eq 1 ] ; then
			COMPREPLY=( $( compgen -W "create convert info" -- ${cur} ) )
			return
		fi
	}
	complete -F _qemu_img -o default qemu-img
fi

# gentoo
if [ "$(type -p emerge)" ] ; then
	alias eei='emerge --info'
	if [ "$(id -u)" -eq 0 ] ; then
		alias ee='emerge -v'
		alias eea='ee -a'
		alias eec='eea -C'
		alias eeC='eea --depclean'
		alias eef='eea -fO'
		alias ee1='eea -1'
		alias eew='eea -uDN world'
		alias eewp='eew -p'
	fi

	if [ "$(id -u)" -eq 0 ] ; then
		if [ "$(type -p eix)" ] ; then
			alias eixx='type -p layman >/dev/null && layman -S ; eix-sync -v'
		fi
	fi
fi

if [ "$(id -u)" -ne 0 ] ; then
	[ "$(type -p reboot)" ] && \
		alias reboot='exec sudo reboot'
	[ "$(type -p poweroff)" ] && \
		alias halt='exec sudo poweroff'
else
	pathadd "${HOME}/script/sbin"
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
	if [ "$(type -t btrfs)" ] ; then
		alias btv='btrfs subvolume'
		alias btf='btrfs filesystem'
		alias btd='btrfs device'
		alias bts='btf show'
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

	if [ "$(type -p docker)" ] ; then
		function dkcrm() {
			if [ $# -eq 0 ] ; then
				local list="$(docker ps -a | grep Exit | awk '{print $1}')"
				if [ "${list}" ] ; then
					docker rm ${list}
				fi
			else
				docker rm $@
			fi
		}
		alias dkcls="docker ps -a"
		alias dkils="docker images -a -tree | less"
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
[ "${TERM}" == "xterm" ] && [ "$(id -u)" -ne 0 ] && [ "$(type -t sr)" ] && sr

fi # [ "${PS1}" ]

