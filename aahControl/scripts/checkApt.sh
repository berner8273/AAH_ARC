#!/bin/bash
BASE=/opt/aptitude

echo "checking aptbus"
for APTPID in `fuser ${BASE}/lock/aptbus.lock 2> /dev/null`;do
    ps -fp ${APTPID}
done

echo "checking apteng"
for APTPID in `fuser ${BASE}/lock/apteng.lock 2> /dev/null`;do
    ps -fp ${APTPID}
done

echo "checking aptsrv"
for APTPID in `fuser ${BASE}/lock/aptsrv.lock 2> /dev/null`;do
    ps -fp ${APTPID}
done
