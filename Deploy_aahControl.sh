#!/usr/bin/sh
###############################################################################
# File    : Deploy_aahControl.sh
# Info    : Octopus Deploy.sh script for aahControl package
# Date    : 2018-01-19
# Author  : Elli Wang
# Version : 2018040401
# Note    :
#   2018-03-09	Elli	GA 5.10.7
#   2018-02-02	Elli	GA 1.2.2
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
IS_DEBUG=0
RC=0

# Aptitude variables
SRC_DIR="scripts"
DST_DIR="/aah/scripts"

# Command variables
INSTALL="/usr/bin/install"
FIND="/usr/bin/find"

# Functions ===================================================================
# Exit with an error
ERR_EXIT () {
	printf "Error: $@\n"
	exit 1
}

# Run a command
RUN () {
	if [[ $IS_DEBUG != 1 ]]; then
		"$@"
	else
		echo "Debug: $@"
	fi
}

# Main ========================================================================
printf "*** $PROGRAM starts ... $(date +'%F %T')\n"

# Check if debug mode
if [[ $(get_octopusvariable "AAH.Octopus.RunScripts"|tr '[A-Z]' '[a-z]') \
		= "false" ]]; then
	printf "** Run scripts in debug mode!!!\n"
	IS_DEBUG=1
fi

# Check destination directory
[[ ! -w "$DST_DIR" ]] && ERR_EXIT "$DST_DIR is not writable!"

# Delete files
printf "* Delete files from $DST_DIR ...\n"
RUN $FIND $DST_DIR/ -xdev -mindepth 1 -print -delete \
	|| ERR_EXIT "$Cannot remove files from $DST_DIR!"

# Copy files
printf "* Copy files ...\n"
ls $SRC_DIR/* | while read file; do
	RUN $INSTALL -m 750 -pv $file $DST_DIR/ \
		|| ERR_EXIT "Cannot copy $file to $DST_DIR/!"
done

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC