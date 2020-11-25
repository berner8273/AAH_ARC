#!/bin/bash


function runIntraDay()
{
    runStep StandardiseEventHierarchy
    runStep DSREventHierarchy
    runStep StandardiseTaxJurisdiction
    runStep DSRTaxJurisdiction
    runStep StandardiseGLChartfields
    runStep DSRGLChartfields
    runStep StandardiseDepartments
    runStep DSRDepartments
    runStep StandardiseFXRates
    runStep DSRFXRates
    runStep StandardiseGLAccounts
    runStep DSRGLAccounts
    runStep StandardiseLegalEntities
    runStep DSRLegalEntities
    runStep DSRPartyBusiness
    runStep DSRInternalProcessEntities
    runStep DSRDepartments
    runStep DSRLegalEntityHierNodes
    runStep StandardiseLegalEntityLinks
    runStep DSRLegalEntityHierLinks
    runStep DSRLegalEntityHierarchyData
    runStep DSRLegalEntitySupplementalData
    runStep SLRUpdateDaysPeriods

    runStep StandardiseInsurancePolicies
    runStep DSRInsurancePolicies
    runStep DSRPolicyTaxJurisdictions
    runStep StandardiseLedgers
    runStep DSRLedgers
    runStep StandardiseGLComboEdit
    runStep DSRGLComboEdit

    runStep StandardiseJournalLine
    runStep DSRJournalLine

    runStep StandardiseCessionEvents
    runStep DSRCessionEvents

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

    runStep GLINTExtract

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
runIntraDay "$@" 2>&1 | tee /aah/logs/runIntraDay_$(date +"%Y%m%d%H%M%S").log
