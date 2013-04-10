#!/bin/bash

PN="${BASH_SOURCE[0]##*/}"
PD="${BASH_SOURCE[0]%/*}"

pushd "${PD}" &>/dev/null

tarhost="${1}"
if [ "${tarhost}" ] ; then
	echo "deploy to '${tarhost}'"
	rsync -aP -e "ssh -o Ciphers=arcfour" "${PD}" "${tarhost}:/tmp/bash/" && \
		ssh "${tarhost}" "cd /tmp/bash ; ./setrcs.sh ; cd / ; rm -rf /tmp/bash"
fi

popd &>/dev/null

