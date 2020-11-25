#!/usr/bin/env bash
PATH="/usr/bin"
NOW=`date +"%Y%m%d%H%M%S"`
APT_BASE=/opt/aptitude
AAH_BASE=/aah
SCRIPT_BASE=${AAH_BASE}/scripts
BKPS=${AAH_BASE}/backups/${NOW}

mkdir -p ${BKPS}

${SCRIPT_BASE}/stopApt.sh

${APT_BASE}/bin/aptsrv --import_export_mode bin --export ${BKPS}/srv_exp.xml

tar -zcvf ${BKPS}/server_sqlite.tgz -C ${APT_BASE}/db server_sqlite

${SCRIPT_BASE}/startApt.sh

exit
