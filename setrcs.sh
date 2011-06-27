#!/bin/bash

PN="${BASH_SOURCE[0]##*/}"
PD="${BASH_SOURCE[0]%/*}"

pushd "${PD}" &>/dev/null
echo "Setup rc files ..."
for i in .bash_logout .bashrc .screenrc .toprc .vimrc ; do
	cp -af "${i}" "${HOME}"
done

if [ ! -f "${HOME}/.profile" ] && [ ! -f "${HOME}/.bash_profile" ] ; then
	ln -s "${HOME}/.bashrc" "${HOME}/.bash_profile"
fi

f="/usr/share/vim/vim72/syntax/doxygen.vim"
d="${HOME}/.vim/after/syntax"
if [ -f "${f}" ] ; then
	echo "Setup vim syntax for doxygen ..."
	[ ! -d "${d}" ] && mkdir -p "${d}"
	[ ! -d "${d}" ] && exit 1
	pushd "${d}" &>/dev/null
	for i in c.vim cpp.vim java.vim ; do
		[ ! -f "${i}" ] && ln -s "${f}" "${i}"
	done
	popd &>/dev/null
fi

if [ -e "${HOME}/.gitconfig" ] ; then
	diff -ruNp .gitconfig "${HOME}"
else
	cp -a .gitconfig "${HOME}"
fi
popd &>/dev/null

