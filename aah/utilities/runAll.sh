#!/bin/bash

ConnString=aptitude/srz4i2GvnLCzREvV@oraaptdev/aptdev


function runAllSteps()
{
    setSystemDates              
    updateStatsStn
    runGroupOne
    updateStatsStn
    runGroupTwo
    setOpenPeriods 2018 12
    updateStatsOne
    runGroupThree
    updateStatsTwo
    setOpenPeriods 2019 07
    runGroupFour
    updateStatsGlintMapping
    #runGlint    
    #updateStatsSlrRdr
    runYEClearDown
    runAutoResubmit
}

function runGroupOne()
{
    echo "----------------------------Group One (StandardiseEventHierarchy)-----------------------------------------------------------------"
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
}

function runGroupTwo()
{
    echo "----------------------------Group Two (StandardiseInsurancePolicies)-----------------------------------------------------------------"
    runStep StandardiseInsurancePolicies
    runStep DSRInsurancePolicies
    runStep DSRPolicyTaxJurisdictions
    runStep StandardiseLedgers
    runStep DSRLedgers
    runStep StandardiseGLComboEdit
    runStep DSRGLComboEdit
}

function runGroupThree()
{
    echo "----------------------------Group Three (StandardiseJournalLine)-----------------------------------------------------------------"
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
}

function runGroupFour()
{
    echo "----------------------------Group Four (StandardiseCessionEvents)-----------------------------------------------------------------"
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
}

function runGlint()
{
    echo "----------------------------Run Glint-----------------------------------------------------------------"

    runStep GLINTExtract

}

function runYEClearDown()
{
    echo "----------------------------YEClearDown-----------------------------------------------------------------"

    runStep GLINTExtract
    runStep pYECleardown
    runStep SLRpProcess
    runStep AutoResubmitTransactions
    runStep CheckResubmittedErrors
}

function runAutoResubmit()
{
    echo "----------------------------AutoResubmit-----------------------------------------------------------------"

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

function runSqlPLus()
{
    #echo "${1}"
    sqlplus ${ConnString} <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	set serveroutput on format wrapped
    set feedback off
    ${1}
	exit
EOF!

[[ $? = 0 ]] || ERR_EXIT "${1}"

}

# Set system dates
function setSystemDates()
{
    echo "----------------------------Setting System Dates-----------------------------------------------------------------"
    runSqlPLus "
        begin
        for i in ( select lpg_id from fdr.fr_global_parameter ) loop 
            update fdr.fr_global_parameter set gp_todays_bus_date = sysdate -1 where lpg_id = i.lpg_id; 
            update slr.slr_entities e      set ent_business_date  = sysdate -1 where exists ( select null from fdr.fr_lpg_config l where l.lc_lpg_id = i.lpg_id and l.lc_grp_code = e.ent_entity );
            fdr.pr_roll_date ( i.lpg_id ); 
            for j in ( select ent_entity from slr.slr_entities ) loop 
                slr.slr_pkg.pROLL_ENTITY_DATE ( j.ent_entity , null , 'N' );
            end loop;
        end loop; 
        end;
        /
        commit;
    "    
}

function setOpenPeriods()
{
    echo "----------------------------Setting Open Periods ${1}-${2} -----------------------------------------------------------------"
    runSqlPLus "
        declare v_open_year varchar2(4 char) := '${1}';
                v_open_period varchar2(2 char) := '${2}';
        begin
        update
            fdr.fr_general_lookup fgl
        set
            fgl.lk_lookup_value1 = ( case
                                            when lk_match_key2||lk_match_key3 >= v_open_year||lpad(v_open_period,2,'0')
                                            then 'O'
                                            else 'C'
                                        end )
            , fgl.lk_lookup_value4 = ( case
                                            when lk_match_key2||lk_match_key3 >= v_open_year||lpad(v_open_period,2,'0')
                                            then null
                                            else nvl( fgl.lk_lookup_value4 , to_char( sysdate , 'DD-MON-YYYY' ) )
                                        end )
        where fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
        ;
        end;
        /

        /* SET STATUS OF CORRESPONDING SLR.SLR_ENTITY_PERIODS */

        declare v_ent_entity varchar2(30 char);
        begin
            for i in (select ent_entity from slr.slr_entities)
            loop
                v_ent_entity := i.ent_entity;
                slr.slr_pkg.pROLL_ENTITY_DATE(v_ent_entity);
            end loop;
        end;
        /
        commit;
    "
}

function updateStatsStn()
{
    echo "----------------------------Running Update Stats STN -----------------------------------------------------------------"
    runSqlPLus "
        exec dbms_stats.gather_schema_stats ( ownname => 'STN' , cascade => true );
        /
        commit;
    "
}

function updateStatsSlrRdr()
{
    echo "----------------------------Running Update Stats SLR and RDR -----------------------------------------------------------------"
    runSqlPLus "
        exec dbms_stats.gather_schema_stats ( ownname => 'RDR' , cascade => true, no_invalidate => false );
        commit;
        exec dbms_stats.gather_schema_stats ( ownname => 'SLR' , cascade => true, no_invalidate => false );
        commit;
    "
}

function updateStatsGlintMapping()
{
    echo "----------------------------Running Update Stats GLINT mapping tables -----------------------------------------------------------------"
    runSqlPLus "
        exec dbms_stats.gather_table_stats ( ownname => 'RDR' , tabname => 'RR_GLINT_JOURNAL_LINE' , cascade => true, no_invalidate => false );
        exec dbms_stats.gather_table_stats ( ownname => 'SLR' , tabname => 'SLR_JRNL_LINES' , cascade => true, no_invalidate => false );
        exec dbms_stats.gather_table_stats ( ownname => 'SLR' , tabname => 'SLR_JRNL_HEADERS' , cascade => true, no_invalidate => false );
        /
        commit;
    "
}

function updateStatsOne()
{
    echo "----------------------------Running Update Stats One -----------------------------------------------------------------"
    runSqlPLus "
        exec dbms_stats.gather_table_stats ( ownname => 'FDR' , tabname => 'fr_trade' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'FDR' , tabname => 'fr_instrument' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'FDR' , tabname => 'fr_instr_insure_extend' , cascade => true );
        /
        commit;
    "
}

function updateStatsTwo()
{
    echo "----------------------------Running Update Stats Two-----------------------------------------------------------------"
    runSqlPLus "
        exec dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'cession_event' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'SLR' , tabname => 'slr_eba_combinations' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'SLR' , tabname => 'slr_fak_combinations' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'SLR' , tabname => 'slr_eba_daily_balances' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'SLR' , tabname => 'slr_fak_daily_balances' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'SLR' , tabname => 'slr_jrnl_lines' , cascade => true );
        exec dbms_stats.gather_table_stats ( ownname => 'FDR' , tabname => 'fr_accounting_event_imp' , cascade => true );
        /
        commit;
    "
}

# Run all steps and print standard out and err to screen and log file
runAllSteps "$@" 2>&1 | tee runAllSteps_$(date +"%b-%d-%y").log