#!/bin/zsh

export PATH="${HOME}/bin:${HOME}/script:${PATH}"
export HISTSIZE=1000000

if [[ -z "${HOSTNAME}" ]] ; then
	export HOSTNAME="${HOST:-$(hostname)}"
fi

if [[ -d "${MYSHELL}/plugins" ]]; then
	for i in "${MYSHELL}/plugins/"* ; do
		source "${i}"
	done
fi

function prompt_char() {
	if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

local ret_status="%(?:%{$fg_bold[green]%}$(prompt_char) :%{$fg_bold[red]%}$(prompt_char) %s)"

PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[red]%}%m%{$fg_bold[green]%} )%n %{$fg_bold[blue]%}%(!.%1~.%~) $(git_prompt_info)%_${ret_status}%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}%{$fg[yellow]%}*%{$fg[blue]%}) "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) "

lsopt="-F"
dfopt="-h"
if [ -x /usr/bin/dircolors ]; then
	lsopt="${lsopt} --color=auto"
	alias grep='grep --color=auto'
fi
if [[ "$(uname)" == "FreeBSD" ]] || [[ "$(uname)" == "Darwin" ]] ; then
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

alias ssu='sudo -H bash --rcfile "${HOME}/.bashrc"'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com || wget -qO /dev/stdout "http://icanhazip.com" || curl -s "http://icanhazip.com"'

if (( $+commands[ssh] )) ; then
	alias ssh='ssh -oStrictHostKeyChecking=no'
	alias ssht='ssh tsaikd@home.tsaikd.org'
fi

if (( $+commands[vim] )) ; then
	export EDITOR="${EDITOR:-vim}"
fi

if (( $+commands[direnv] )) ; then
	eval "$(direnv hook zsh)"
fi

if (( $+commands[docker] )) ; then
	alias dklog="docker logs -f"
	alias dkre="docker restart -t 0"
fi

if (( $+commands[gitk] )) ; then
	alias gitk='gitk --all &'
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

if (( $+functions[kube_ps1] )); then
	KUBE_PS1_SUFFIX=") "
	PROMPT='$(kube_ps1)'${PROMPT}
fi

# load custom script post login
if [ -d "${MYSHELL}/custom/zsh/login-post" ] ; then
	for i in $(find "${MYSHELL}/custom/zsh/login-post" -iname \*.zsh) ; do
		source "${i}"
	done
fi

[ -f "${HOME}/.zshrc.local" ] && \
	source "${HOME}/.zshrc.local"

unset i


