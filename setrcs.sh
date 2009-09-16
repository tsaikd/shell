#!/bin/bash

PF="$(readlink -f "$0")"
PD="$(dirname "${PF}")"

pushd "${PD}" &>/dev/null
for i in .bash_logout .bashrc .screenrc .toprc .vimrc ; do
	cp -f "${i}" "${HOME}"
done
diff -ruNp .gitconfig "${HOME}"
popd &>/dev/null

