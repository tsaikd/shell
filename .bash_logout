#!/bin/bash
cd

if [ "${KD_PUBLIC_PC}" -ne 0 ] ; then
	rm -rf .bash_history .lesshst .lftp .rnd .viminfo
	rm -rf .sqlite_history .subversion
	rm -rf .links .w3m
fi

clear

[ -r "${HOME}/.bash_logout.local" ] && source "${HOME}/.bash_logout.local"

