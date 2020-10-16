#!/bin/bash

function runInsurancePolicy()
{
    echo "----------------------------(StandardiseInsurancePolicies)-----------------------------------------------------------------"
    runStep AutoResubmitTransactions
    runStep StandardiseInsurancePolicies
    runStep DSRInsurancePolicies
    runStep DSRPolicyTaxJurisdictions
    runStep StandardiseLedgers
    runStep DSRLedgers
    runStep StandardiseGLComboEdit
    runStep DSRGLComboEdit
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
runInsurancePolicy "$@" 2>&1 | tee runInsurancePolicy$(date +"%b-%d-%y").log