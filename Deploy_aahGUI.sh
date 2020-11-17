#!/usr/bin/env bash
###############################################################################
# File    : aahGUI.sh
# Info    : Octopus Deploy.sh script for aahGUI package
# Date    : 2018-10-03
# Author  : Elli Wang
# Version : 2018100301
# Note    :
#   2018-10-02	Elli	GA 1.8.0
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
IS_DEBUG=0
RC=0

# Aptitude variables
AAH_CORE_BASE="$PWD/aah/aahCore"

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

# Prepare aah.war file --------------------------------------------------------
printf "* Prepare aah.war (GUI.war) file ...\n"

# Extract GUI.war file
AAH_ZIP="$AAH_CORE_BASE/src/main/aah/AAH.zip"
GUI_WAR="gui_application/Oracle/GUI.war"
BUILD_DIR="build"
printf "* Extract $GUI_WAR from $AAH_ZIP to $BUILD_DIR ...\n"
RUN $UNZIP -oj $AAH_ZIP $GUI_WAR -d $BUILD_DIR \
	|| ERR_EXIT "Cannot extract $GUI_WAR from $AAH_ZIP to $BUILD_DIR!"

# Reset GUI.war file location
GUI_WAR="$BUILD_DIR/GUI.war"

# Unzip GUI.war
TMP_DIR="tmp"
printf "* Unzip $GUI_WAR to $TMP_DIR ...\n"
RUN $UNZIP -q $GUI_WAR -d $TMP_DIR \
	|| ERR_EXIT "Cannot unzip $GUI_WAR to $TMP_DIR!"

# Copy web.xml
file="$AAH_CORE_BASE/src/main/resources/gui/web.xml"
printf "* Copy web.xml file ...\n"
RUN $INSTALL -pv $file $TMP_DIR/WEB-INF/ || ERR_EXIT "Cannot copy $file!"

# Copy 3 property files
printf "* Copy 3 property files ...\n"
for f in ApplicationResources.properties \
		ApplicationResourcesSorted.properties \
		log4j.properties; do
	RUN $INSTALL -pv $AAH_CORE_BASE/src/main/resources/gui/$f \
		$TMP_DIR/WEB-INF/classes/resources/ \
		|| ERR_EXIT "Cannot copy property file!"
done

# Copy UploadTemplate.csv
file="$AAH_CORE_BASE/src/main/resources/gui/UploadTemplate.csv"
printf "* Copy UploadTemplate.csv file ...\n"
RUN $INSTALL -pv $file $TMP_DIR/client_specific/ || ERR_EXIT "Cannot copy $file!"

# Copy ojdbc7-12.1.0.2.jar
file="$AAH_CORE_BASE/src/main/resources/gui/ojdbc7-12.1.0.2.jar"
printf "* Copy ojdbc7-12.1.0.2.jar file ...\n"
RUN $INSTALL -pv $file $TMP_DIR/WEB-INF/lib/ || ERR_EXIT "Cannot copy $file!"

# Remove context.xml
printf "* Remove ./META-INF/context.xml file ...\n"
RUN $RM -f $TMP_DIR/META-INF/context.xml

# Create aah.war
AAH_WAR="aah.war"
printf "* Create $AAH_WAR file ...\n"
RUN $JAR cf $AAH_WAR -C $TMP_DIR . \
	|| ERR_EXIT "Cannot create $AAH_WAR from $TMP_DIR!"

# Deploy aah.war
printf "* Deploy aah.war ...\n"
RUN $SUDO /usr/bin/install -m 640 -o tomcat -g tomcat \
	-pv aah.war /opt/tomcat/webapps/aah.war \
	|| ERR_EXIT "cannot deploy aah.war!"

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC