#!/bin/bash

function parchiveSTN2()
{

     runStep parchiveSTN2
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
parchiveSTN2 "$@" 2>&1 | tee parchiveSTN2$(date +"%b-%d-%y").log