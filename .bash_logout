#!/bin/bash
cd

history -w
history -c
if [ "${KD_PUBLIC_PC}" -eq 0 ] ; then
	# Non-Public PC
	sed -i '/ecryptfs/d' ".bash_history"
else
	# Public PC
	rm -rf .bash_history .lesshst .lftp .rnd .viminfo
	rm -rf .sqlite_history .subversion
	rm -rf .links .w3m
	rm -rf .thumbnails
fi

clear

[ -r ".bash_logout.local" ] && source ".bash_logout.local"

