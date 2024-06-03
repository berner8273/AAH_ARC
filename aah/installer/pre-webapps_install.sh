#!/bin/bash

keepfile="/aah/installer/aah-web-setup/resources/GUI.war"
delfiles="/aah/installer/aah-web-setup/resources/*_*.war"
dir="/aah/installer/aah-web-setup/resources/"
zipfile="/aah/src/installer.zip"
now=$(date)

if [ -f /usr/bin/unzip ]
then
	if ! [ -d /aah/installer ]; then mkdir -p /aah/installer; fi
	if [ -f $zipfile ]
	then
		cp $zipfile /aah/installer/installer.zip
		echo "unzipping files ...."
		cd /aah/installer
		unzip -o installer.zip 1>/dev/null 2>/aah/logs/install_unzip_errors.log
		echo "unzipped_upgrade-"${now} >>/aah/logs/upgrade_files.log 
	fi	
else
	echo "cannot unzip file!"
	exit 1
fi

if [ -f $keepfile ]; then rm -f $keepfile; fi

case $HOSTNAME in
	"aptitudeci.agl.com")
		mv ${dir}C_GUI.war $keepfile
		rm -f $delfiles
		;;
	"aptitudedev.agl.com")
	  echo "rename "${dir}D_GUI.war $keepfile
		mv ${dir}D_GUI.war $keepfile
		rm -f $delfiles
		;;
	"aptitudeqa.agl.com")
		mv ${dir}Q_GUI.war $keepfile
		rm -f $delfiles
		;;
	"aptitudeuat.agl.com")
		mv ${dir}U_GUI.war $keepfile
		rm -f $delfiles
		;;
		*) echo "unknown server $HOSTNAME"
			exit 1 ;;	
esac
echo "War file update script completed"				
	

	



