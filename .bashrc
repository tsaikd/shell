# .bashrc

if [ "${PS1}" ] ; then # this line is used for sftp login

bind '"\x1b\x5b\x41":history-search-backward'
bind '"\x1b\x5b\x42":history-search-forward'

[ "$(type -p distcc)" ] && export PATH="/usr/lib/distcc/bin:${PATH}"
if [ "$(type -p ccache)" ] ; then
	if [ -d "/usr/lib/ccache/bin" ] ; then
		export PATH="/usr/lib/ccache/bin:${PATH}"
	elif [ -x "/usr/lib/ccache/gcc" ] ; then
		export PATH="/usr/lib/ccache:${PATH}"
	else
		echo "ccache detected, but unknown path!!"
	fi
fi

export PATH="${PATH}:${HOME}/script:${HOME}/bin"
export LANG="C"
unset LANGUAGE
export LESSHISTFILE="-"
export KD_PUBLIC_PC=1
[ "$(type -p vim)" ] && true ${EDITOR:=vim}
export EDITOR
umask 022

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

if [ "$(type -p locale)" ] ; then
	localelist="$(locale -a)"
	if [ "$(grep -i "zh_TW.utf" <<<"${localelist}")" ] ; then
		export LANG="$(grep -i "zh_TW.utf" <<<"${localelist}")"
	elif [ "$(grep -i "en_US.utf" <<<"${localelist}")" ] ; then
		export LANG="$(grep -i "en_US.utf" <<<"${localelist}")"
	fi
	unset localelist
fi

[ "$(type -p setterm)" ] && TERM=linux setterm -regtabs 4

[ "$(type -p screen)" ] && [ "$TERM" != "screen" ] && function sr() {
	screen -wipe
	{ screen -x `whoami` || screen -S `whoami` ; } && clear
}

[ "$(type -p wget)" ] && function myip () {
	wget "http://whatismyip.org/" -qO /dev/stdout
	echo
}

# $1 : title
# $2 : bbs site url
# $3 : screen number
# $4 : login name (default `whoami`)
[ "$(type -p bbsbot)" ] && [ "${TERM}" == "screen" ] && function fun_bbs_bot () {
	[ $# -lt 3 ] && return 1
	local USERNAME
	[ "$4" ] && USERNAME="$4" || USERNAME="$(whoami)"
	screen -X eval "screen -t \"$1\" $3 /usr/bin/kd_bbsbot.py \"$2\"" "encoding big5 utf8"
#	screen -X eval "screen -t \"$1\" $3 bbsbot $USERNAME \"$2\"" "encoding big5 utf8"
}

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
fi

lshelp="$(ls --help)"
lsopt="-F"
if [ "$(uname)" == "FreeBSD" ] ; then
	lsopt="${lsopt} -G"
else
	lsopt="${lsopt} --color=auto"
fi
[ "$(grep -- "--show-control-chars" <<<"${lshelp}")" ] && \
	lsopt="${lsopt} --show-control-chars"
[ "$(grep -- "--group-directories-first" <<<"${lshelp}")" ] && \
	lsopt="${lsopt} --group-directories-first"
alias l="ls ${lsopt}"
alias la='l -a'
alias l1='l -1'
alias ll='l -l'
alias lla='l -la'
alias lsd='l -d */'
unset lshelp lsopt

alias cd..='cd ..'
alias cp='cp -i'
alias df='df -h -x supermount'
alias du='du -h'
alias fuser='fuser -muv'
alias md='mkdir'
alias mv='mv -i'
alias ping='ping -n'
alias rd='rmdir'
alias rm='rm -i'
alias tar='nice -n 19 tar'
alias telnet='telnet -8'
alias sdiff='sdiff -s -w 80'
alias qq='[ -r "${HOME}/.bash_logout" ] && source "${HOME}/.bash_logout" ; exec clear'

alias sshg='ssh tsaikd@goodguy.csie.ncku.edu.tw'
alias ssht='ssh tsaikd@home.tsaikd.org'
[ "$(type -p rdesktop)" ] && \
	alias rdt='rdesktop home.tsaikd.org $(cat "${HOME}/.rdesktop/password" 2>/dev/null)' && \
	alias rdtsl='rdt -r sound:local -x lan' && \
	alias rdtsr='rdt -r sound:remote'

[ "$(type -p readlink)" ] && \
	alias cd.='cd "$(readlink -f .)"'
[ "$(type -p sudo)" ] && \
	alias ssu='sudo su'
[ "$(type -p vim)" ] && \
	alias vi='vim'
[ "$(type -p perl)" ] && \
	alias col='perl -e "while (<>) { s/\033\[[\d;]*[mH]//g; print; }" | col'
[ "$(type -p reboot)" ] && \
	alias reboot='sync;sync;sync;sync;sync;sync;sleep 1; exec /sbin/reboot'
[ "$(type -p colordiff)" ] && \
	alias diff='colordiff'
[ "$(type -p diff)" ] && \
	alias diff='diff -ruNp'
[ "$(type -p rsync)" ] && [ "$(type -p ssh)" ] && \
	alias rscp='rsync -v -v -P -e ssh'
[ "$(type -p mail)" ] && \
	alias mail='mail -u `\whoami`'
[ "$(type -p svn)" ] && \
	alias sla='svn log -r 1:HEAD'
[ "$(type -p htop)" ] && \
	alias top='htop'
[ "$(type -p mutt)" ] && \
	alias mutt='LANG="zh_TW.utf8" mutt'
[ "$(type -p mkisofs)" ] && \
	alias mkisofs='mkisofs -l -r -J'
[ "$(type -p irssi)" ] && [ "$TERM" == "screen" ] && \
	alias irssi='screen -t IRC 10 irssi'
[ "$(type -p azureus)" ] && [ "$TERM" == "screen" ] && \
	alias bt='screen -X eval "screen -t BT 20 azureus"'
[ "$(type -p cscope)" ] && \
	alias csc='cscope -bR'
[ "$(type -p rdesktop)" ] && \
	alias rdesktop='rdesktop -a 16 -P -f -z'
[ "$(type -p gitk)" ] && \
	alias gitk='gitk --all &'
[ "$(type -p mc)" ] && [ "$TERM" == "screen" ] && \
	alias mc='mc -a'
[ -z "$(type -p host)" ] && [ "$(type -p links)" ] && \
	alias host='links -lookup'
if [ "$(type -p rtorrent)" ] && [ "$TERM" == "screen" ] ; then
	alias btr='screen -X eval "screen -t BT 6 rt"'
	alias btrr='screen -X eval "screen -t BT2 7 rt -r"'
fi
if [ "$(type -t fun_bbs_bot)" ] ; then
	alias bbot_tsaikd='fun_bbs_bot "KD BBS" tsaikd 8'
#	alias bbot_tsaikd='fun_bbs_bot "KD BBS" bbs.tsaikd.twbbs.org 8'
	alias bbot_goodguy='fun_bbs_bot "GoodGuy" goodguy 9'
#	alias bbot_goodguy='fun_bbs_bot "GoodGuy" goodguy.csie.ncku.edu.tw 9'
	alias bbot_dorm='fun_bbs_bot "Dorm" dorm 0'
#	alias bbot_dorm='fun_bbs_bot "Dorm" bbs.ccns.ncku.edu.tw 0'
	alias bbot_bahamut='fun_bbs_bot "BaHa" baha 0'
#	alias bbot_bahamut='fun_bbs_bot "BaHa" bahamut.twbbs.org 0'
	alias bbot_rical='fun_bbs_bot "Rical" rical 0'
#	alias bbot_rical='fun_bbs_bot "Rical" rical.twbbs.org 0'
	alias bbot_qazq='fun_bbs_bot "qazq" qazq 0'
#	alias bbot_qazq='fun_bbs_bot "qazq" qazq.twbbs.org 0'
	alias bbot_ptt='fun_bbs_bot "ptt" ptt 0'
#	alias bbot_ptt='fun_bbs_bot "ptt" ptt.twbbs.org 0'
	alias bbot_fancy='fun_bbs_bot "fancy" fancy 0'
#	alias bbot_fancy='fun_bbs_bot "fancy" fancy.twbbs.org 0'
	alias bbot_moon='fun_bbs_bot "MoonStar" moon 0 Tsaikd'
#	alias bbot_moon='fun_bbs_bot "MoonStar" moonstar.twbbs.org 0 Tsaikd'
fi

# only in gentoo
if [ "$(uname -r | grep "^2\.[46]\.[0-9]\+-gentoo\(-r[0-9]\+\)\?$")" ] ; then
	[ -z "$(type -p dig)" ] && alias dig='echo "Please emerge \"net-dns/bind-tools\" for dig"'
fi

i="/var/log/messages"
[ -r "${i}" ] && alias cmesg="tail -n 20 \"${i}\""
i="/var/log/syslog"
[ -r "${i}" ] && alias csyslog="tail -n 20 \"${i}\""
i="/var/log/syslog"
[ -r "${i}" ] && alias csyslog="tail -n 20 \"${i}\""
i="/var/log/apache2/access.log"
[ -r "${i}" ] && alias capacheaccess="tail -n 20 \"${i}\""
i="/var/log/apache2/error.log"
[ -r "${i}" ] && alias capacheerror="tail -n 20 \"${i}\""

if [ "$(id -u)" -eq 0 ] ; then
	i="/root/script/config/general.sh"
	[ -w "${i}" ] && alias viconf="vi \"${i}\""
	if [ "$(type -p ccache)" ] ; then
		export CCACHE_DIR="/var/tmp/ccache"
		export CCACHE_NOLINK=1
		export CCACHE_UMASK="002"
	fi
	if [ "$(type -p eix)" ] ; then
		alias eixx='type -p layman >/dev/null && layman -S ; eix-sync -v'
	fi
	if [ "$(type -p ntpdate)" ] ; then
		function ntpdate() {
			$(type -P ntpdate) "$@" time.stdtime.gov.tw
			hwclock -w
		}
	fi
	function swapre() {
		swapoff "$@"
		swapon "$@"
	}
	function kd_port_kdbashlib() {
		cd /usr/portage/app-shells
		wget -m -nH --cut-dirs=3 -p -l 2 \
			http://svn.tsaikd.org/gentoo/kdport/app-shells/kdbashlib/
		find -iname "index.htm*" -delete ; cd - >/dev/null
	}
fi

# $1 := public key file path
# $2 := remote host ([user@]host.ip[:sshport])
function ssh_send_authpubkey() {
	if [ $# -ne 2 ] ; then
		echo "Usage: ${FUNCNAME} <KEYFILE> <HOST>"
	else
		cat "${1}" | ssh "${2}" 'cat >> ~/.ssh/authorized_keys'
	fi
}

if [ "$(type -p tput)" ] ; then
	[ "$(tput cols)" -lt 80 ] && echo "The screen columns are smaller then 80!"
	[ "$(tput lines)" -lt 24 ] && echo "The screen lines are smaller then 24!"
fi
[ "$(id -u)" -ne 0 ] && [ -n "$(type -p last)" ] && last -5

unset i

[ -r "${HOME}/.bashrc.local" ] && source "${HOME}/.bashrc.local"
[ "${TERM}" == "xterm" ] && [ "$(id -u)" -ne 0 ] && [ "$(type -t sr)" ] && sr

fi # [ "${PS1}" ]

