#!/bin/bash
# ========================================================================
# Goal:
#     Backup config files by diff or duplicate
# ========================================================================
# License:
#     GNU GPL V2: http://www.gnu.org/copyleft/gpl.html
# ========================================================================
# Environment:
#     Linux 2.6.17-gentoo-r4 i686 Intel(R) Pentium(R) M processor 1400MHz GNU/Linux
# ========================================================================
# Author:
#     tsaikd <tsaikd@gmail.com>
# ========================================================================
# ChangeLog:
#     2006-11-23 tsaikd: first release
# ========================================================================
# Include files:
source /usr/lib/portage/bin/isolated-functions.sh && set_colors

# ========================================================================
# Variable definition:

# When the number of parameter is 0, show help message
# ( 0: continue the following script )
# ( 1: show help message and exit script )
declare -ir DENY_NULL_PARAM="1"

# Set options list (separated by <space>)
# IMPORTANT: SHORT_OPTION cannot be null
declare -r  LONG_OPTION="help quiet"
declare -r  SHORT_OPTION="hqd:"

# Define all flags
# Tips: Flag variable with readonly attribute is a good idea
declare -i  FF=0			# Default Flag
declare -ir F_QUIET=0x01	# Quiet Flag

# Define error code
declare -ir E_INVALID_PARAMETER=0x01	# Invalid parameter

# Define readonly variables
declare -r  PFP="${0}"					# Program full path
declare -r  PN="$(basename ${PFP})"		# Program name
declare -r  PD="$(dirname ${PFP})"		# Program directory

# ========================================================================
# Function definition:

# define a String Variable with Default Value
# $1: Varable Name
# $2: Default Value
function DEF() {
	[ "$#" -lt 2 ] && eerror "line ${BASH_LINENO}: ${FUNCNAME} invalid parameters" && return
	[ -z "$(eval echo \$${1})" ] && eval ${1}="${2}"
}

# show help message to stdout
function show_help() {
	echo "Usage of ${PN} :"
	echo "  -h | --help    : show this help message"
	echo "  -q | --quiet   : only show necessary message"
	echo "  -d <DIR PATH>  : set base directory (default: ${HOME})"
}

# ========================================================================
# Analyze parameters:
((DENY_NULL_PARAM)) && [ $# -eq 0 ] && show_help && exit ${E_INVALID_PARAMETER}
unset GETOPT_OPTION
for i in ${LONG_OPTION} ; do
	GETOPT_OPTION="${GETOPT_OPTION}-l ${i} "
done
eval set -- $(getopt ${GETOPT_OPTION} ${SHORT_OPTION} "$@")
for i ; do
	case $i in # ${2} := parameter value (if use it, then shift 2)
	--) shift && break ;;
	-h|--help) show_help && shift && exit ;;
	-q|--quiet) ((FF|=F_QUIET)) && shift ;;
	-d) BAK_BASE_DIR="${2}" && shift 2 ;;
	esac
done

if ((FF & F_QUIET)) ; then
	function ebegin() { return 0 ; }
	function eend() { return $1 ; }
	function ewarn() { return 0 ; }
	function einfo() { return 0 ; }
	function einfon() { return 0 ; }
fi

# ========================================================================
# Script start from here:

[ "${PD}" != "." ] && eerror "Please use './${PN} ...'" && exit ${E_INVALID_PARAMETER}

BAK_BASE_DIR="${BAK_BASE_DIR:=${HOME}}"

for i ; do
	PROG_NAME="$(basename "${i}")"

	case ${PROG_NAME} in
	icewm)
#		SRC_DIR="/usr/share/icewm"
		DES_DIR="${BAK_BASE_DIR}/.icewm"
		LIST="keys menu preferences toolbar"
		if [ -d "${PROG_NAME}" ] ; then
			einfo "Generating config patch of ${PROG_NAME}"
			for i in ${LIST} ; do
				ebegin "Process ${i} in ${PROG_NAME}"
				cp -fp "${DES_DIR}/${i}" "${PROG_NAME}/${i}"
#				diff -ruNp "${SRC_DIR}/${i}" "${DES_DIR}/${i}" > "${PROG_NAME}/${i}.patch"
				eend $?
			done
		fi
		;;
	mlterm)
		DES_DIR="${BAK_BASE_DIR}/.mlterm"
		LIST="aafont font key main termcap"
		if [ -d "${PROG_NAME}" ] ; then
			einfo "Duplicating config of ${PROG_NAME}"
			for i in ${LIST} ; do
				ebegin "Process ${i} in ${PROG_NAME}"
				cp -fp "${DES_DIR}/${i}" "${PROG_NAME}/${i}"
				eend $?
			done
		fi
		;;
	*) eerror "Unknown program: ${PROG_NAME}" && continue
	esac
done

[ "$#" -gt 0 ] && ewarn "Remember to svn commit"

