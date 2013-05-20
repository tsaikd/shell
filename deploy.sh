#!/bin/bash

PN="${BASH_SOURCE[0]##*/}"
PD="${BASH_SOURCE[0]%/*}"

pushd "${PD}" &>/dev/null

for i in $@ ; do
	tarhost="$(cut -d: -f1 <<<"${i}:")"
	tarport="$(cut -d: -f2 <<<"${i}:")"
	true ${tarport:=22}
	if [ "${tarhost}" ] ; then
		echo "deploy to '${tarhost}:${tarport}'"
		rsync -aPq -e "ssh -p ${tarport} -o Ciphers=arcfour -o StrictHostKeyChecking=no" "${PD}/" "${tarhost}:/tmp/bash/" && \
			ssh "${tarhost}" -p "${tarport}" "cd /tmp/bash ; bash /tmp/bash/setrcs.sh ; cd / ; rm -rf /tmp/bash"
	fi
done

popd &>/dev/null

