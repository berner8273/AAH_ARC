#!/bin/bash
# Variables
APT_BASE=/opt/aptitude
LOG_BASE=/aah/logs/aptitude
SCRIPT_BASE=/aah/scripts
SRV_PORT=2500
ENG_PORT=2504
BUS_PORT=2503

# Start aptsrv
echo "$(date +'%F %T') Starting aptsrv ..."
nohup ${APT_BASE}/bin/aptsrv > ${LOG_BASE}/aptsrv.out 2> ${LOG_BASE}/aptsrv_err.out &

# Wait until port $SRV_PORT to be available
timeout 360 bash -c "until > /dev/tcp/localhost/$SRV_PORT; do sleep 5; done" 2>/dev/null
[[ $? = 0 ]] || { echo "Timeout to start aptsrv!"; exit 1; }

# Start apteng
echo "$(date +'%F %T') Starting apteng ..."
nohup ${APT_BASE}/bin/apteng > ${LOG_BASE}/apteng.out 2> ${LOG_BASE}/apteng_err.out &

# Wait until port $ENG_PORT to be available
timeout 60 bash -c "until > /dev/tcp/localhost/$ENG_PORT; do sleep 1; done" 2>/dev/null
[[ $? = 0 ]] || { echo "Timeout to start apteng!"; exit 1; }

# Start aptbus
echo "$(date +'%F %T') Starting aptbus ..."
nohup ${APT_BASE}/bin/aptbus > ${LOG_BASE}/aptbus.out 2> ${LOG_BASE}/aptbus_err.out &

# Wait until port $BUS_PORT to be available
timeout 60 bash -c "until > /dev/tcp/localhost/$BUS_PORT; do sleep 1; done" 2>/dev/null
[[ $? = 0 ]] || { echo "Timeout to start aptbus!"; exit 1; }

# Wait 30 seconds, otherwise startProjects.sh will fail
echo "Sleep 30 seconds ..."
sleep 30

# End
echo "$(date +'%F %T') All processes are started."
exit 0
