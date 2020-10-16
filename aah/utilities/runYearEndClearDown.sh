#!/bin/bash

ConnString=aptitude/srz4i2GvnLCzREvV@oraaptdev/aptdev


function runYearEndClearDown()
{
    runStep GLINTExtract
    runStep pYECleardown
    runStep SLRpProcess
    runStep AutoResubmitTransactions
    runStep CheckResubmittedErrors
}



ERR_EXIT () {
	printf "Error: ********************************************\n$@\n"
	exit 1
}

function runStep()
{
    stepName=${1}
    /aah/scripts/StartStep.sh ${1}
    [[ $? = 0 ]] || ERR_EXIT ${1}
}


# Run all steps and print standard out and err to screen and log file
runYearEndClearDown "$@" 2>&1 | tee runYearEndClearDown_$(date +"%b-%d-%y").log