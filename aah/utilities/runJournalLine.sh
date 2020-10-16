#!/bin/bash

ConnString=aptitude/srz4i2GvnLCzREvV@oraaptdev/aptdev


function runJournalLine()
{
    runStep StandardiseJournalLine
    runStep DSRJournalLine

    runStep SLRUpdateDaysPeriods
    runStep SLRAccounts
    runStep SLRFXRates
    runStep SLRUpdateCurrencies
    runStep SLRUpdateFakSeg3
    runStep SLRUpdateFakSeg4
    runStep SLRUpdateFakSeg5
    runStep SLRUpdateFakSeg6
    runStep SLRUpdateFakSeg7
    runStep SLRUpdateFakSeg8
    runStep SLRpUpdateJLU
    runStep SLRpProcess

    # runStep GLINTExtract

    # runStep AutoResubmitTransactions
    # runStep CheckResubmittedErrors
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
runJournalLine "$@" 2>&1 | tee runJournalLine$(date +"%b-%d-%y").log