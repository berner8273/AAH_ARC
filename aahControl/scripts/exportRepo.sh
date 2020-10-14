#!/bin/bash
NOW=`date +"%C%y%m%d%H%M%S"`
BASE=/opt/aptitude
BKPS=$HOME/aptitude/bkp/${NOW}

mkdir -p ${BKPS}

cd ${BASE}/scripts

./stopApt.sh

cd ${BASE}/bin

./aptsrv --import_export_mode bin --export ${BKPS}/srv_exp.xml

zip -r ${BKPS}/server_sqlite.zip ${BASE}/db/server_sqlite

cd ${BASE}/scripts

./startApt.sh
