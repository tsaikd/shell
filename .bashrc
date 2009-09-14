# .bashrc

if [ "${PS1}" ] ; then # this line is used for sftp login

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
export LANG="en_US.utf8"
export LESSHISTFILE="-"
export KD_PUBLIC_PC=1
[ "$(type -p vim)" ] && true ${EDITOR:=vim}
export EDITOR
umask 022
if [ "$(id -u)" -ne 0 ] ; then
	PS1='\[\e[01;31m\]\h \[\e[01;32m\]\u\[\e[01;34;40m\] \w \$ \[\e[m\]'
else
	PS1='\[\e[01;31m\]\h \[\e[01;33;41m\]\u\[\e[01;34;40m\] \w \$ \[\e[m\]'
fi

bind '"\x1b\x5b\x41":history-search-backward' 
bind '"\x1b\x5b\x42":history-search-forward'

[ "$(type -p setterm)" ] && TERM=linux setterm -regtabs 4

[ "$(type -p wget)" ] && function kd_update_bash () {
	local i
	local DIRURL="http://svn.tsaikd.org/gentoo/bash/"
	local FILELIST=".bashrc .bash_logout"

	[ "$(type -p top)" ] && FILELIST="${FILELIST} .toprc"
	[ "$(type -p vi vim)" ] && FILELIST="${FILELIST} .vimrc"
	[ "$(type -p screen)" ] && FILELIST="${FILELIST} .screenrc"

	for i in ${FILELIST} ; do
		wget -q --spider "${DIRURL}${i}" && \
			wget "${DIRURL}${i}" -O "${HOME}/${i}" && \
			chmod 644 "${HOME}/${i}"
	done

	if [ ! -e "${HOME}/.bash_profile" ] ; then
		cd
		ln -s .bashrc .bash_profile
		cd -
	fi
}
[ "$(type -t kd_update_bash)" ] && \
	alias kd_update_bash='kd_update_bash ; source ~/.bashrc'

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

# app-shells/gentoo-bashcomp feature
if [[ -f /etc/profile.d/bash-completion ]] ; then
	source /etc/profile.d/bash-completion
	if [ "$(type -p emerge)" ] ; then
		for i in eei ee eea eef ee1 ; do
			complete -o filenames -F _emerge "${i}"
		done
	fi
fi

if [ "$(type -p emerge)" ] ; then
	alias eei='emerge --info'
	if [ "$(id -u)" -eq 0 ] ; then
		alias ee='emerge -v'
		alias eea='ee -a'
		alias eef='eea -fO'
		alias ee1='eea -1'
		alias eew='eea -uDN world'
		alias eewp='eew -p'
	fi
fi

alias cd..='cd ..'
alias cp='cp -i'
alias df='df -h -x supermount'
alias du='du -h'
alias fuser='fuser -muv'
if [ "$(ls --help | grep -- "--group-directories-first")" ] ; then
	alias l='ls --group-directories-first'
else
	alias l='ls'
fi
alias la='l -a'
alias l1='l -1'
alias ll='l -l'
alias lla='l -la'
alias lsd='l -d */'
alias md='mkdir'
alias mv='mv -i'
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

if [ "$(uname)" == "FreeBSD" ] ; then
	alias ls='ls -FG'
else
	alias ls='ls -F --show-control-chars --color=auto'
fi

[ "$(type -p readlink)" ] && \
	alias cd.='cd "$(readlink -f .)"'
[ "$(type -p sudo)" ] && \
	alias ssu='sudo su' && \
	alias su='echo "Please use ssu instead"'
[ "$(type -p vim)" ] && \
	alias vi='vim'
[ "$(type -p perl)" ] && \
	alias col='perl -e "while (<>) { s/\033\[[\d;]*[mH]//g; print; }" | col'
[ "$(type -p reboot)" ] && \
	alias reboot='sync;sync;sync;sync;sync;sync;sleep 1; exec /sbin/reboot'
[ "$(type -p diff)" ] && \
	alias difff='diff -ruNp'
[ "$(type -p colordiff)" ] && \
	alias diff='colordiff'
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
	alias gitk='gitk --all'
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
if [ "$(type -p emerge)" ] ; then
	alias eei='emerge --info'
fi

# only in gentoo
if [ "$(uname -r | grep "^2\.[46]\.[0-9]\+-gentoo\(-r[0-9]\+\)\?$")" ] ; then
	[ -z "$(type -p dig)" ] && alias dig='echo "Please emerge \"net-dns/bind-tools\" for dig"'
fi

if [ "$(id -u)" -eq 0 ] ; then
	alias cmesg='tail -n 20 /var/log/messages'
	[ -f "/var/log/apache2/access_log" ] && alias capachelog='tail -n 20 /var/log/apache2/access_log'
	alias viconf='vi /root/script/config/general.sh'
	if [ "$(type -p ccache)" ] ; then
		export CCACHE_DIR="/var/tmp/ccache"
		export CCACHE_NOLINK=1
		export CCACHE_UMASK="002"
	fi
	if [ "$(type -p emerge)" ] ; then
		alias ee='emerge -v'
		alias eea='ee -a'
		alias eec='eea -C'
		alias eeC='eea --depclean'
		alias eef='eea -fO'
		alias ee1='eea -1'
		alias eew='eea -uDN world'
		alias eewp='eew -p'
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

[ -r "${HOME}/.bashrc.local" ] && source "${HOME}/.bashrc.local"
[ "${TERM}" == "xterm" ] && [ "$(id -u)" -ne 0 ] && [ "$(type -t sr)" ] && sr

fi

