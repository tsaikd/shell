#!/bin/bash

PN="${BASH_SOURCE[0]##*/}"
PD="${BASH_SOURCE[0]%/*}"

pushd "${PD}" &>/dev/null
echo "Setup rc files ..."
for i in .bash_logout .bashrc .screenrc .toprc .vimrc ; do
	cp -f "${i}" "${HOME}"
done

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

diff -ruNp .gitconfig "${HOME}"
popd &>/dev/null

