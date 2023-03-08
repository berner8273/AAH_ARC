#!/bin/bash

function parchiveSLR1()
{

     runStep parchiveSLR1
}

ERR_EXIT () {
	printf "Error: *******************************************\n$@\n"
	exit 1
}

function runStep()
{
    stepName=${1}
    /aah/scripts/StartStep.sh ${1}
    [[ $? = 0 ]] || ERR_EXIT ${1}
}


# Run all steps and print standard out and err to screen and log file
parchiveSLR1 "$@" 2>&1 | tee parchiveSLR1$(date +"%b-%d-%y").log