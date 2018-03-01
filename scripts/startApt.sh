#!/bin/bash
APT_BASE=/opt/aptitude
LOG_BASE=/aah/logs/aptitude
SCRIPT_BASE=/aah/scripts

echo "Starting aptsrv"
nohup ${APT_BASE}/bin/aptsrv > ${LOG_BASE}/aptsrv.out 2> ${LOG_BASE}/aptsrv_err.out &

sleep 10
echo "Starting apteng"
nohup ${APT_BASE}/bin/apteng > ${LOG_BASE}/apteng.out 2> ${LOG_BASE}/apteng_err.out &

sleep 10
echo "Starting aptbus"
nohup ${APT_BASE}/bin/aptbus > ${LOG_BASE}/aptbus.out 2> ${LOG_BASE}/aptbus_err.out &

sleep 80