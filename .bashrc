# .bashrc

if [ "${PS1}" ] ; then # this line is used for sftp login

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
unset LANGUAGE
export LESSHISTFILE="-"
export HISTFILESIZE=50000
export HISTSIZE=10000
export KD_PUBLIC_PC=1
[ "$(type -p vim)" ] && true ${EDITOR:=vim}
export EDITOR
umask 022

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

[ "$(type -p screen)" ] && [ "$TERM" != "screen" ] && function sr() {
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
	alias rscp='rsync -v -v -z -P -e ssh'
[ "$(type -p telnet)" ] && \
	alias telnet='telnet -8'
[ "$(type -p fuser)" ] && \
	alias fuser='fuser -muv'
[ "$(type -p mail)" ] && \
	alias mail='mail -u `\whoami`'
[ "$(type -p svn)" ] && \
	alias sla='svn log -r 1:HEAD'
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
	alias ssht='ssh tsaikd@home.tsaikd.org'
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

i="/var/log/messages"
[ -r "${i}" ] && alias cmesg="tail -n 20 \"${i}\""
i="/var/log/syslog"
[ -r "${i}" ] && alias csyslog="tail -n 20 \"${i}\""

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
	[ "$(type -p halt)" ] && \
		alias halt='exec sudo halt'
else
	[ "$(type -p reboot)" ] && \
		alias reboot='exec reboot'
	[ "$(type -p halt)" ] && \
		alias halt='exec halt'

	i="/root/script/config/general.sh"
	[ -w "${i}" ] && alias viconf="vi \"${i}\""
	if [ "$(type -p ccache)" ] ; then
		export CCACHE_DIR="/var/tmp/ccache"
		export CCACHE_NOLINK=1
		export CCACHE_UMASK="002"
	fi
	if [ "$(type -p ntpdate)" ] ; then
		function ntpdate() {
			$(type -P ntpdate) "$@" time.stdtime.gov.tw
			hwclock -w
		}
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

