#!/usr/bin/env bash
###############################################################################
# File    : aahGUI.sh
# Info    : Octopus Deploy.sh script for aahGUI package
# Date    : 2018-10-03
# Author  : Elli Wang
# Version : 2020120901
# Note    :
#   2020-12-09	Elli	GA 20.3.1.164
#   2018-10-02	Elli	GA 1.8.0
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
IS_DEBUG=0
RC=0

# AAH variables
AAH_SRC="/aah/src"
AAH_ZIP="$AAH_SRC/AAH.zip"
BUILD_DIR="build"
WORK_BASE="$PWD"

# Command variables
INSTALL="/usr/bin/install"
JAR="/usr/bin/jar"
RM="/usr/bin/rm"
SUDO="/usr/bin/sudo"
UNZIP="/usr/bin/unzip"

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

# Prepare aah.war file ----------------------------------------------
printf "* Prepare aah.war file ...\n"

# Create $BUILD_DIR
printf "* Create $BUILD_DIR ...\n"
[[ mkdir $BUILD_DIR ]] || ERR_EXIT "Cannot create $BUILD_DIR!"

# Extract scheduler-web.war file
WAR="gui_application/Oracle/aah-web.war"
printf "* Extract $WAR to $BUILD_DIR ...\n"
RUN $UNZIP -p $AAH_ZIP $WAR | (cd $BUILD_DIR && RUN $JAR x)
[[ $(echo $PIPESTATUS[@]|grep -cE '^[0 ]+$') = 1 ]] || \
	|| ERR_EXIT "Cannot extract $GUI_WAR from $AAH_ZIP to $BUILD_DIR!"

# Copy lib files
for f in ojdbc8.jar orai18n.jar; do
	printf "* Copy $f to $BUILD_DIR/WEB-INF/lib/ ...\n"
	RUN $INSTALL -pv ./lib/$f $BUILD_DIR/WEB-INF/lib/ \
		|| ERR_EXIT "Cannot copy $f to $BUILD_DIR/WEB-INF/lib/!"
done

# Copy application.properties
# Need Octopus variable substitution
RUN $INSTALL -pv ./config/aah/application.properties \
	$BUILD_DIR/WEB-INF/classes/ \
	|| ERR_EXIT "Cannot copy application.properties to $BUILD_DIR/WEB-INF/classes/!"

# Copy core.properties
# Need Octopus variable substitution
# Need to encrypt passwords
RUN $INSTALL -pv ./config/aah/core.properties \
	$BUILD_DIR/WEB-INF/classes/ \
	|| ERR_EXIT "Cannot copy core.properties to $BUILD_DIR/WEB-INF/classes/!"

# Copy logback.xml
RUN $INSTALL -pv ./config/aah/logback.xml \
	$BUILD_DIR/WEB-INF/classes/ \
	|| ERR_EXIT "Cannot copy logback.xml to $BUILD_DIR/WEB-INF/classes/!"

# Create aah`.war
WAR="aah.war"
printf "* Create $WAR file ...\n"
RUN $JAR cf $WAR -C $BUILD_DIR . \
	|| ERR_EXIT "Cannot create $_WAR from $BUILD_DIR!"

# Deploy aah.war
printf "* Deploy $WAR ...\n"
# RUN $SUDO $INSTALL -m 640 -o tomcat -g tomcat \
	# -pv $WAR /opt/tomcat/webapps/ \
	# || ERR_EXIT "cannot deploy $WAR!"

# Clean up $BUILD_DIR
printf "* Clean up $BUILD_DIR ...\n"
RUN $RM -rf $BUILD_DIR || ERR_EXIT "Cannot remove $BUILD_DIR!"

# Clean up aah-web.war
printf "* Clean up $WAR ...\n"
# RUN $RM -f $WAR || ERR_EXIT "Cannot remove $WAR!"

# Prepare aah_OLD.war file ----------------------------------------------
printf "* Prepare aah_OLD.war file ...\n"

# Create $BUILD_DIR
printf "* Create $BUILD_DIR ...\n"
[[ mkdir $BUILD_DIR ]] || ERR_EXIT "Cannot create $BUILD_DIR!"

# Extract scheduler-web.war file
WAR="gui_application/Oracle/GUI.war"
printf "* Extract $WAR to $BUILD_DIR ...\n"
RUN $UNZIP -p $AAH_ZIP $WAR | (cd $BUILD_DIR && RUN $JAR x)
[[ $(echo $PIPESTATUS[@]|grep -cE '^[0 ]+$') = 1 ]] || \
	|| ERR_EXIT "Cannot extract $GUI_WAR from $AAH_ZIP to $BUILD_DIR!"

# Copy lib files
printf "* Copy ojdbc8.jar to $BUILD_DIR/WEB-INF/lib/ ...\n"
RUN $INSTALL -pv ./lib/ojdbc8.jar $BUILD_DIR/WEB-INF/lib/ \
	|| ERR_EXIT "Cannot copy ojdbc8.jar to $BUILD_DIR/WEB-INF/lib/!"

# Copy context.xml
# Need Octopus variable substitution
# Need to encrypt passwords
RUN $INSTALL -pv ./config/aah_OLD/context.xml \
	$BUILD_DIR/META-INF/ \
	|| ERR_EXIT "Cannot copy context.xml to $BUILD_DIR/META-INF/!"

# Create aah_OLD.war
WAR="aah_OLD.war"
printf "* Create $WAR file ...\n"
RUN $JAR cf $WAR -C $BUILD_DIR . \
	|| ERR_EXIT "Cannot create $_WAR from $BUILD_DIR!"

# Deploy aah_OLD.war
printf "* Deploy $WAR ...\n"
# RUN $SUDO $INSTALL -m 640 -o tomcat -g tomcat \
	# -pv $WAR /opt/tomcat/webapps/ \
	# || ERR_EXIT "cannot deploy $WAR!"

# Clean up $BUILD_DIR
printf "* Clean up $BUILD_DIR ...\n"
RUN $RM -rf $BUILD_DIR || ERR_EXIT "Cannot remove $BUILD_DIR!"

# Clean up scheduler-web.war
printf "* Clean up $WAR ...\n"
# RUN $RM -f $WAR || ERR_EXIT "Cannot remove $WAR!"

# Prepare scheduler-web.war file ----------------------------------------------
printf "* Prepare scheduler-web.war file ...\n"

# Create $BUILD_DIR
printf "* Create $BUILD_DIR ...\n"
[[ mkdir $BUILD_DIR ]] || ERR_EXIT "Cannot create $BUILD_DIR!"

# Extract scheduler-web.war file
WAR="gui_application/scheduler/scheduler-web.war"
printf "* Extract $WAR to $BUILD_DIR ...\n"
RUN $UNZIP -p $AAH_ZIP $WAR | (cd $BUILD_DIR && RUN $JAR x)
[[ $(echo $PIPESTATUS[@]|grep -cE '^[0 ]+$') = 1 ]] || \
	|| ERR_EXIT "Cannot extract $GUI_WAR from $AAH_ZIP to $BUILD_DIR!"

# Copy lib files
for f in ojdbc8.jar orai18n.jar; do
	printf "* Copy $f to $BUILD_DIR/WEB-INF/lib/ ...\n"
	RUN $INSTALL -pv ./lib/$f $BUILD_DIR/WEB-INF/lib/ \
		|| ERR_EXIT "Cannot copy $f to $BUILD_DIR/WEB-INF/lib/!"
done

# Copy application.properties
# Need Octopus variable substitution
# Need to encrypt passwords
RUN $INSTALL -pv ./config/scheduler-web/application.properties \
	$BUILD_DIR/WEB-INF/classes/ \
	|| ERR_EXIT "Cannot copy application.properties to $BUILD_DIR/WEB-INF/classes/!"

# Create scheduler-web.war
WAR="scheduler-web.war"
printf "* Create $WAR file ...\n"
RUN $JAR cf $WAR -C $BUILD_DIR . \
	|| ERR_EXIT "Cannot create $_WAR from $BUILD_DIR!"

# Deploy scheduler-web.war
printf "* Deploy $WAR ...\n"
# RUN $SUDO $INSTALL -m 640 -o tomcat -g tomcat \
	# -pv $WAR /opt/tomcat/webapps/ \
	# || ERR_EXIT "cannot deploy $WAR!"

# Clean up $BUILD_DIR
printf "* Clean up $BUILD_DIR ...\n"
RUN $RM -rf $BUILD_DIR || ERR_EXIT "Cannot remove $BUILD_DIR!"

# Clean up scheduler-web.war
printf "* Clean up $WAR ...\n"
# RUN $RM -f $WAR || ERR_EXIT "Cannot remove $WAR!"

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC