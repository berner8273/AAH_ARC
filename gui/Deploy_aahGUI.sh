#!/usr/bin/env bash
###############################################################################
# File    : aahGUI.sh
# Info    : Octopus Deploy.sh script for aahGUI package
# Date    : 2018-10-03
# Author  : Elli Wang
# Version : 2020121101
# Note    :
#   2020-12-11	Elli	GA 20.3.1.164
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
JAVA="/usr/bin/java"
MKDIR="/usr/bin/mkdir"
PERL="/usr/bin/perl"
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

# Copy file
COPY_FILE () {
	printf "* Copy $1 to $2 ...\n"
	RUN $INSTALL -pv $1 $2 || ERR_EXIT "Cannot copy $1 to $2!"
}

# Extract WAR file
EXTRACT_WAR_FILE () {

	# Create $BUILD_DIR directory
	printf "* Create $BUILD_DIR directory ...\n"
	RUN $MKDIR $BUILD_DIR \
		|| ERR_EXIT "Cannot create $BUILD_DIR directory!"

	# Extract $WAR file from $AAH_ZIP
	WAR=$1
	printf "* Extract $WAR ...\n"
	RUN $UNZIP -j $AAH_ZIP $WAR \
		|| ERR_EXIT "Cannot extract $WAR from $AAH_ZIP!"

	# Unpack $WAR file to $BUILD_DIR
	WAR=${WAR##*/}
	RUN $UNZIP -q $WAR -d $BUILD_DIR \
		|| ERR_EXIT "Cannot extract $WAR to $BUILD_DIR!"
	
	# Remove $WAR file
	RUN $RM -f $WAR || ERR_EXIT "Cannot remove $WAR!"
}

# Create webapp
CREATE_WEBAPP () {
	WAR=$1
	printf "* Create $WAR file ...\n"
	RUN $JAR cf $WAR -C $BUILD_DIR . \
		|| ERR_EXIT "Cannot create $WAR from $BUILD_DIR!"
}

# Deploy webapp
DEPLOY_WEBAPP () {
	WAR=$1
	printf "* Deploy $WAR ...\n"
	RUN $SUDO $INSTALL -m 640 -o tomcat -g tomcat \
		-pv $WAR /opt/tomcat/webapps/$WAR \
		|| ERR_EXIT "cannot deploy $WAR!"
}

# Clean up $BUILD_DIR directory and $WAR file
CLEANUP () {

	# Clean up $BUILD_DIR directory
	printf "* Clean up $BUILD_DIR directory ...\n"
	RUN $RM -rf $BUILD_DIR \
		|| ERR_EXIT "Cannot remove $BUILD_DIR directory!"

	# Clean up $WAR
	printf "* Clean up $WAR ...\n"
	# RUN $RM -f *.war || ERR_EXIT "Cannot remove war files!"
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

# Extract aah.war file
EXTRACT_WAR_FILE "gui_application/Oracle/aah-web.war"

# Copy lib files
for f in ojdbc8.jar orai18n.jar; do
	COPY_FILE "lib/$f" "$BUILD_DIR/WEB-INF/lib/"
done

# Copy application.properties
# Need Octopus variable substitution
COPY_FILE "config/aah/application.properties" \
	"$BUILD_DIR/WEB-INF/classes/"

# Copy core.properties
# Need Octopus variable substitution
# Encrypt passwords
file="config/aah/core.properties"
for p in aah_ui security_ui; do
	printf "* Encrypt $p password ...\n"
	p="${p}Password"
	enc_string=$(RUN $JAVA -jar lib/aptitude-crypto-encryptor-cli-1.0-all.jar \
				-q encrypt -t $(get_octopusvariable $p))
	[[ $? = 0 ]] || ERR_EXIT "Cannot encrypt password!"
	RUN $PERL -pi -e "s!###\($p\)###!$enc_string!" $file \
		|| ERR_EXIT "Cannot modify $file!"
done

# Copy file
COPY_FILE $file "$BUILD_DIR/WEB-INF/classes/"

# Copy logback.xml
COPY_FILE "config/aah/logback.xml" "$BUILD_DIR/WEB-INF/classes/"

# Create aah.war
WAR="aah.war"
CREATE_WEBAPP $WAR

# Deploy aah.war
DEPLOY_WEBAPP $WAR

# Clean up
CLEANUP

# Prepare aah_OLD.war file ----------------------------------------------
printf "* Prepare aah_OLD.war file ...\n"

# Extract aah_OLD.war file
EXTRACT_WAR_FILE "gui_application/Oracle/GUI.war"

# Copy lib files
COPY_FILE "lib/ojdbc8.jar" "$BUILD_DIR/WEB-INF/lib/"

# Copy context.xml
# Need Octopus variable substitution
# Encrypt fdr password
file="config/aah_OLD/context.xml"
printf "* Encrypt fdr password ...\n"
p="fdrPassword"
class_path="commons-codec-1.10.jar:tomcat-jdbc-7.0.52.jar:tomcat-juli-7.0.52.jar:GUI.jar"
enc_string=$(cd $BUILD_DIR/WEB-INF/lib && RUN $JAVA -cp $class_path \
				uk.co.microgen.tomcat.EncryptedDataSourceFactory \
				-s $(get_octopusvariable $p))
[[ $? = 0 ]] || ERR_EXIT "Cannot encrypt password!"
RUN $PERL -pi -e "s!###\($p\)###!$enc_string!" $file \
	|| ERR_EXIT "Cannot modify $file!"

# Copy file
COPY_FILE $file "$BUILD_DIR/META-INF/"

# Modify log4j2.xml
file="$BUILD_DIR/WEB-INF/classes/log4j2.xml"
printf "* Modify $file ...\n"
RUN $PERL -pi -e 's/GUI_/aah_OLD/' $file \
	|| ERR_EXIT "Cannot modify $file!"

# Copy ApplicationResources.properties
COPY_FILE "config/aah_OLD/ApplicationResources.properties" \
	"$BUILD_DIR/WEB-INF/classes/resources/"

# Copy UploadTemplate.csv
COPY_FILE "config/aah_OLD/UploadTemplate.csv" "$BUILD_DIR/client_specific/"

# Create aah_OLD.war
WAR="aah_OLD.war"
CREATE_WEBAPP $WAR

# Deploy aah_OLD.war
DEPLOY_WEBAPP $WAR

# Clean up
CLEANUP

# Prepare scheduler-web.war file ----------------------------------------------
printf "* Prepare scheduler-web.war file ...\n"

# Extract scheduler-web.war file
EXTRACT_WAR_FILE "gui_application/scheduler/scheduler-web.war"

# Copy lib files
for f in ojdbc8.jar orai18n.jar; do
	COPY_FILE "lib/$f" "$BUILD_DIR/WEB-INF/lib/"
done

# Copy application.properties
# Need Octopus variable substitution
# Encrypt passwords
file="config/scheduler-web/application.properties"
for p in scheduler_ui security_ui; do
	printf "* Encrypt $p password ...\n"
	p="${p}Password"
	enc_string=$(RUN $JAVA -jar lib/aptitude-crypto-encryptor-cli-1.0-all.jar \
		-q encrypt -t $(get_octopusvariable $p))
	[[ $? = 0 ]] || ERR_EXIT "Cannot encrypt password!"
	RUN $PERL -pi -e "s!###\($p\)###!$enc_string!" $file \
		|| ERR_EXIT "Cannot modify $file!"
done

# Copy file
COPY_FILE $file "$BUILD_DIR/WEB-INF/classes/"

# Create scheduler-web.war
WAR="scheduler-web.war"
CREATE_WEBAPP $WAR

# Deploy scheduler-web.war
DEPLOY_WEBAPP $WAR

# Clean up
CLEANUP

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC