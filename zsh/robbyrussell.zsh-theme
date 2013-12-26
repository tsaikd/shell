function prompt_char {
	if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

local ret_status="%(?:%{$fg_bold[green]%}$(prompt_char) :%{$fg_bold[red]%}$(prompt_char) %s)"

PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[red]%}%m%{$fg_bold[green]%} )%n %{$fg_bold[blue]%}%(!.%1~.%~) $(git_prompt_info)%_${ret_status}%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}%{$fg[yellow]%}*%{$fg[blue]%}) "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) "
