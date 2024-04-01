
CREATE OR REPLACE PACKAGE BODY "SLR_VALIDATE_JOURNALS_PKG" AS
-- -------------------------------------------------------------------------------
/* ***************************************************************************
*
*  Id:          $Id: SLR_VALIDATE_JOURNALS_PKG.sql,v 1.1 2007/08/14 16:55:59 adrianj Exp $
*
*  Description: Package body for journal validation.
*
* ************************************************************************** */

    /**************************************************************************
    * Declare private processes
    **************************************************************************/
    PROCEDURE pInitializeProcedure
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER
    );

    FUNCTION fSetFAKDefinition                                                  RETURN BOOLEAN;
    FUNCTION fSanityCheckValidation                                             RETURN BOOLEAN;

    PROCEDURE pSetValidationStatistics
    (
        p_process_id IN NUMBER
    );

    PROCEDURE pWriteLogError( p_proc_name     in VARCHAR2,
                              p_table_name    in VARCHAR2,
                              p_msg           in VARCHAR2);

    PROCEDURE pSetJournalToError( p_process_id   in SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
                                  p_status_text  in SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_STATUS_TEXT%TYPE,
                                  p_epg_id       IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
                                  p_entity       IN slr_entities.ent_entity%TYPE:=NULL,
                                  p_status IN CHAR := 'U');

    PROCEDURE pValidateSegmentDiff
    ( p_process_id IN NUMBER,
        p_seg_no IN NUMBER,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE);

    PROCEDURE pValidateSegment
    ( p_process_id IN NUMBER,
        p_seg_no IN NUMBER,
        p_seg_type IN VARCHAR2,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE);

    PROCEDURE pValidateBalance
    (   p_process_id IN NUMBER,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE,
        lv_sql_group_by IN VARCHAR2
        );

   PROCEDURE pValidateBalanceDiff
    ( p_process_id IN NUMBER,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE);

    PROCEDURE pDeleteLineErrors
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_status IN CHAR
    );

    PROCEDURE pValidateFuturePeriod
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_status IN CHAR:= 'U',
        p_UseHeaders IN BOOLEAN := FALSE
    );

    PROCEDURE pWriteLineErrorEventClass
    (
         p_fdr_event_class IN FDR.FR_GENERAL_LOOKUP.LK_LOOKUP_VALUE3%TYPE,
        p_process_id in NUMBER,
        p_status_text in VARCHAR2,
        p_msg in VARCHAR2,
        p_sql in VARCHAR2,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE
    );

PROCEDURE pUpdateJLUPeriods(pEpgId in slr_jrnl_lines_unposted.jlu_epg_id%type,p_process_id in NUMBER, p_status IN CHAR);

    /**************************************************************************
    * Declare private global variables
    **************************************************************************/
    -- Declare Working Global Variables
    gProcessId                  NUMBER;
    gProcessIdStr               VARCHAR(30) := NULL;
    gEntityConfiguration        SLR_ENTITIES%ROWTYPE;
    gJournalEntity               slr_entities.ent_entity%TYPE;
    gJournalEpgId               SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;
    gJournalType                SLR_JRNL_HEADERS.JH_JRNL_TYPE%TYPE;
    gJournalStatus              CHAR(1);
    gJournalDate                SLR_JRNL_HEADERS.JH_JRNL_DATE%TYPE;
    gFromJrnlId                 NUMBER;
    gToJrnlId                   NUMBER;
    gUseHeaders                 BOOLEAN;

    -- Declare FAK Type Variables
    gFAKDefinition              SLR_FAK_DEFINITIONS%ROWTYPE;

    -- Declare Operational Variables
    gUser   SLR_ENTITIES.ENT_CREATED_BY%TYPE;
    gWhen   SLR_ENTITIES.ENT_CREATED_ON%TYPE;

    -- Declare Statistics Global Variables
    gJournalsValidated          NUMBER;
    gJournalsFailedValidation   NUMBER;
    gJournalLineErrors          NUMBER;
    gValidationStartTime        DATE;
    gValidationEndTime          DATE;

    gSTART_BLOCK_GETS           NUMBER;
    gSTART_CONSISTENT_GETS      NUMBER;
    gSTART_PHYSICAL_READS       NUMBER;
    gSTART_BLOCK_CHANGES        NUMBER;
    gSTART_CONSISTENT_CHANGES   NUMBER;
    gEND_BLOCK_GETS             NUMBER;
    gEND_CONSISTENT_GETS        NUMBER;
    gEND_PHYSICAL_READS         NUMBER;
    gEND_BLOCK_CHANGES          NUMBER;
    gEND_CONSISTENT_CHANGES     NUMBER;
    gRESULT_BLOCK_GETS          NUMBER;
    gRESULT_CONSISTENT_GETS     NUMBER;
    gRESULT_PHYSICAL_READS      NUMBER;
    gRESULT_BLOCK_CHANGES       NUMBER;
    gRESULT_CONSISTENT_CHANGES  NUMBER;

    gInitialFAKNumbers          NUMBER;
    gNewFAKNumbers              NUMBER;
    gOldFAKNumbers              NUMBER;
    gTotalInserts               NUMBER(10);
    gTotalUpdates               NUMBER(10);

    gv_table_name               VARCHAR2(30);
    gErrorsNumber       NUMBER;

    -- Static global data
    gs_stage CHAR(3) := 'SLR';

    -- Global const
    gc_process_name CONSTANT VARCHAR2(10) := 'Validate';

    -- Global exceptions
    ge_bad_count     EXCEPTION;
    ge_bad_lock      EXCEPTION;

    -- For new way of posting
    e_internal_processing_error EXCEPTION;

    /**************************************************************************
    * Processing
    **************************************************************************/

-- ---------------------------------------------------------------------------
-- Procedure:   pValidateJournals
-- Description: Controlling procedure to validate journals in the unposted
--              journals table.
-- Note:        Messages are written to the SLR error log in the subordinate
--              functions.
--
-- -------------------------------------------------------------------------------
-- Process uses mixture of 4GL update\insert and Cursors depedning on the
-- understanding of the data. This aids performance but can lock other
-- processes. Specific logic has been impleneted to manually lock an Entity.
-- this means that only one process can be creating FAK or EBA id's for an
-- entity at a time. Consideration must be given to running the validation
-- process in parallel.
-- -------------------------------------------------------------------------------
--
-- Step 1. Initialize Procedure Variables
-- Step 2. Validate the Journal Date
-- Step 3. Set FAK Deinitions
-- Step 4. Bulk Update journal Header and Line to 'V'
-- Step 5. Bulk Validate Periods
-- Step 6. Bulk Validate Post Dates
-- Step 7. Bulk Validate Currencies
-- Step 8. Bulk Validate Journal Balances
-- Step 9. Bulk Validate Journal Adjustment Balances
-- Step 10. Bulk Pre Assign FAK and Numbers
-- Step 11. Bulk Validate Accounts
-- Step 12. Bulk Validate FAK Segments
-- Step 13. Create FAK numbers for those lines not assigned a FAK ID
-- Step 14. Bulk Pre Assign FAK Numbers
-- Step 15. Bulk Assign EBA Numbers
-- Step 16. Validate that the Validation Process is Successfull
-- Step 17. Mark Journals as Valid
-- Step 18. Set Validation Statistics
-- Step 19. Set end time of the process
-- Step 20. Commit the Process
-- Step 21. Report Process Statisticts
--
-- -------------------------------------------------------------------------------
-- Table Dependancies
--      SLR.SLR_EBA_COMBINATIONS
--      SLR.SLR_ENTITIES
--      SLR.SLR_ENTITY_ACCOUNTS
--      SLR.SLR_ENTITY_CURRENCIES
--      SLR.SLR_ENTITY_DAYS
--      SLR.SLR_ENTITY_PERIODS
--      SLR.SLR_FAK_COMBINATIONS
--      SLR.SLR_FAK_DEFINITIONS
--      SLR.SLR_JOB_STATISTICS
--      SLR.SLR_JRNL_HEADERS
--      SLR.SLR_JRNL_HEADERS_UNPOSTED
--      SLR.SLR_JRNL_LINES_UNPOSTED
--      SLR.SLR_JRNL_LINE_ERRORS
--      SYS.DUAL
-- Procedure/ Function Dependancies
--      SLR.SLR_VALIDATE_JOURNALS_PKG
--      SYS.DBMS_LOCK
--      SYS.dbms_output
--      SYS.DBMS_STANDARD
--      SLR.SLR_UTILITIES_PKG
-- -------------------------------------------------------------------------------
-- ASH 21-OCT-2004 Modified pValidateJournals so that Journals can be
--                 validated prior to effective date. (Version 1)
-- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2 (Version 2)
-- ASH 06-DEC-2004 Changed ENT_CCYS_AND_RATES_SET to ENT_CURRENCY_SET etc
--                 (Version 2.1)
-- ASH 23-DEC-2004 Added Package Registration
-- ASH 13-DEC-2004 Added logic to test if EBE is being used. (Version 2.2)
-- ASH 26-JAN-2005 COMPLETE CODE FOR RELEASE 2
-- SC  28-APR-2005 Modified fBulkValidateSegments and fBulkValidateSegment_n
--                 to validate conditional segments (TTP91/TTP143).
-- JE  13-NOV-2009 removed balance check for segment 3 (book).
--                 Request for core change to make this configurable
--                 approved by LR/AHill and raised as TTP on 6-NOV-09.

-- -------------------------------------------------------------------------------

    PROCEDURE pValidateJournals (
      p_epg_id IN slr_entity_proc_group.epg_id%TYPE,
      p_process_id IN NUMBER,
      p_status IN CHAR := 'U',
      p_useheaders IN BOOLEAN := FALSE,
      p_rate_set IN slr_entities.ent_rate_set%TYPE
    ) IS

      cROWLIMIT CONSTANT NUMBER := 10000;
      lDateFormat CHAR(10) DEFAULT 'yyyy-mm-dd';
      cPROC_NAME VARCHAR2(50) := 'SLR_VALIDATE_JOURNALS_PKG.pValidateJournals';
      lCurrBusDate CONSTANT DATE := SLR_UTILITIES_PKG.fEntityGroupCurrBusDate(p_epg_id);

      lValidateSQL_var VARCHAR2(32767);
      lValidateSQL VARCHAR2(32767) DEFAULT q'[
        with jrnl_lines as (
          select ]'|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || q'[ distinct
            jlu_effective_date,
            jlu_entity,
            jlu_jrnl_rev_date,
            jlu_jrnl_type,
            jlu_epg_id,
            jlu_translation_date,
            jlu_value_date,
            jlu_jrnl_ref_id,
            jlu_tran_ccy,
            jlu_jrnl_ent_rate_set,
            jlu_jrnl_process_id,
            jlu_account,
            JLU_SEGMENT_2,
            jlu_local_ccy,
            jlu_base_ccy,
            jlu_local_rate,
            jlu_base_rate,
            jlu_local_amount,
            jlu_base_amount
          from slr_jrnl_lines_unposted   :p_subpartition_name
          where jlu_epg_id = :pc_epg_id and jlu_jrnl_status = :pc_status
        ), entities as (
          select distinct jlu_epg_id, jlu_entity, jlu_jrnl_type, jlu_account
          from jrnl_lines
        ), dates as (
          select distinct jlu_epg_id, jrnl_date_type, jrnl_date, jlu_entity, jlu_jrnl_type
          from jrnl_lines
          unpivot (jrnl_date for jrnl_date_type in (jlu_effective_date as 'jlu_effective_date', jlu_translation_date as 'jlu_translation_date', jlu_jrnl_rev_date as 'jlu_jrnl_rev_date', jlu_value_date as 'jlu_value_date'))
        ), epg_validate as (
          select distinct jlu_epg_id, jlu_entity, 'EPG validation' as validation, cast(null as varchar2(200)) as value1, cast(null as varchar2(200)) as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from entities
          where not exists (
            select 1 from slr_entity_proc_group  where epg_entity = jlu_entity and epg_id = jlu_epg_id
          )
        ), periods_validate as (
          select distinct jlu_epg_id, jlu_entity, jrnl_date_type, jrnl_date, 'Periods' as validation, jrnl_date_type as value1, to_char(jrnl_date, ']'||lDateFormat||q'[') as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from dates
          where not exists (
            select 1
            from slr_entity_periods
            where ep_entity = jlu_entity and jrnl_date between ep_cal_period_start and ep_cal_period_end and ep_status = 'O'
          ) and jrnl_date_type != 'jlu_value_date'
        ), days_validate as (
          select distinct jlu_epg_id, jlu_entity, jrnl_date_type, jrnl_date, 'Dates' as validation, jrnl_date_type as value1, to_char(jrnl_date, ']'||lDateFormat||q'[') as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from dates
          where not exists (
            select 1
            from slr_entity_days
            where ed_entity_set = (select ent_periods_and_days_set from slr_entities where ent_entity = jlu_entity)
              and ed_date = jrnl_date
              and ed_status = 'O'
          ) and jrnl_date_type != 'jlu_value_date'
        ), value_date_period_validate as (
          select distinct jlu_epg_id, jlu_entity, jrnl_date_type, jrnl_date, 'Period containing Value Date' as validation, jrnl_date_type as value1, to_char(jrnl_date, ']'||lDateFormat||q'[') as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from dates join slr_entities on ent_entity = jlu_entity
          where not exists (
            select 1
            from slr_entity_periods
            where ep_entity = jlu_entity and jrnl_date between ep_cal_period_start and ep_cal_period_end and ep_status = 'O'
          ) and jrnl_date_type = 'jlu_value_date'
          and ent_post_val_date = 'Y'
        ), value_date_day_validate as (
          select distinct jlu_epg_id, jlu_entity, jrnl_date_type, jrnl_date, 'Value date' as validation, jrnl_date_type as value1, to_char(jrnl_date, ']'||lDateFormat||q'[') as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from dates join slr_entities on ent_entity = jlu_entity
          where not exists (
            select 1
            from slr_entity_days
            where ed_entity_set = (select ent_periods_and_days_set from slr_entities where ent_entity = jlu_entity)
              and ed_date = jrnl_date
              and ed_status = 'O'
          ) and jrnl_date_type = 'jlu_value_date'
          and ent_post_val_date = 'Y'
        ), ext_type_none_validate as (
          select distinct jlu_epg_id, jlu_entity, 'External type: None' as validation, jlu_jrnl_type as value1, ext.ejt_rev_ejtr_code as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from jrnl_lines join slr_entities ent on ent.ent_entity = jlu_entity
            join slr_ext_jrnl_types ext on jlu_jrnl_type = ext.ejt_type
            join slr_jrnl_types typ on ext.ejt_jt_type = typ.jt_type
            join slr_ext_jrnl_type_rule rul on rul.ejtr_code = ext.ejt_rev_ejtr_code
          where jlu_jrnl_rev_date is null
        and jlu_jrnl_ref_id is null
            and typ.jt_reverse_flag = 'Y'
            and ext.ejt_rev_ejtr_code = 'NONE'
        ), ext_type_between_validate as (
          select distinct jlu_epg_id, jlu_entity, 'External type: BETWEEN' as validation, jlu_jrnl_type as value1, ejtr_code as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from jrnl_lines join slr_entities ent on ent.ent_entity = jlu_entity
            join slr_ext_jrnl_types ext on jlu_jrnl_type = ext.ejt_type
            join slr_jrnl_types typ on ext.ejt_jt_type = typ.jt_type
            join slr_ext_jrnl_type_rule rul on rul.ejtr_code = ext.ejt_rev_ejtr_code
          where jlu_jrnl_rev_date is null
            and jlu_jrnl_ref_id is null
            and typ.jt_reverse_flag = 'Y'
            and (rul.ejtr_type = 'BETWEEN' or rul.ejtr_period_date = 'B' or  rul.ejtr_prior_next_current = 'B')
        ), ext_type_validate as (
          select distinct jlu_entity, jlu_jrnl_type, 'Invalid Ext type' as validation, jlu_jrnl_type as value1, cast(null as varchar2(200)) as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from entities
          where not exists (
            select 1
            from slr_ext_jrnl_types ejt join slr_jrnl_types jt on ejt.ejt_jt_type = jt.jt_type
            where ejt.ejt_type = jlu_jrnl_type
          )
        ), rev_date_validate as (
          select distinct jlu_epg_id, jlu_entity, jrnl_date_type as value1, jrnl_date, 'Reversing Date' as validation, to_char(jrnl_date, ']'||lDateFormat||q'[') as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from dates join slr_entities ent on ent.ent_entity = jlu_entity
            join slr_ext_jrnl_types ext on jlu_jrnl_type = ext.ejt_type
            join slr_jrnl_types typ on ext.ejt_jt_type = typ.jt_type
            join slr_ext_jrnl_type_rule rul on rul.ejtr_code = ext.ejt_rev_ejtr_code
        where typ.jt_reverse_flag in ('Y','C')
          and jrnl_date_type = 'jlu_jrnl_rev_date'
          and not exists (
            select 1
            from slr_entity_days
            where ed_entity_set = (select ent_periods_and_days_set from slr_entities where ent_entity = jlu_entity)
              and ed_date = jrnl_date
              and ed_status = 'O'
           )
        ), rev_date_rules_validate as (
          select distinct jlu_epg_id, jlu_entity, msg.em_error_message, 'Reversing Date rules' as validation, jlu_jrnl_type as value1, ejtr_period_date as value2,
            to_char(jlu_effective_date, ']'||lDateFormat||q'[') as value3, to_char(jlu_jrnl_rev_date, ']'||lDateFormat||q'[') as value4, em_error_message as value5, ejtr_prior_next_current as value6,
            ejtr_type as value7, to_char(ent_business_date, ']'||lDateFormat||q'[') as value8,
            ent_periods_and_days_set as value9
          from jrnl_lines join slr_entities ent on ent.ent_entity = jlu_entity
            join slr_ext_jrnl_types ext on jlu_jrnl_type = ext.ejt_type
            join slr_jrnl_types typ on ext.ejt_jt_type = typ.jt_type
            join slr_ext_jrnl_type_rule rul on rul.ejtr_code = ext.ejt_rev_ejtr_code
            join slr_error_message msg on msg.em_error_code = rul.ejtr_em_error_code
          where jlu_jrnl_rev_date is not null
            and typ.jt_reverse_flag = 'Y'
            and ext.ejt_rev_validation_flag = 'Y'
        ), rev_date_less as (
          select distinct jlu_epg_id, jlu_entity, jlu_jrnl_rev_date, jlu_effective_date, 'Reversing Date < Effective Date' as validation, to_char(jlu_jrnl_rev_date, ']'||lDateFormat||q'[') as value1,
            to_char(jlu_effective_date, ']'||lDateFormat||q'[') as value2,  cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from jrnl_lines join slr_entities ent on ent.ent_entity = jlu_entity
            join slr_ext_jrnl_types ext on jlu_jrnl_type = ext.ejt_type
            join slr_jrnl_types typ on ext.ejt_jt_type = typ.jt_type
          where jt_reverse_flag = 'Y'
            and jlu_jrnl_rev_date <= jlu_effective_date
        ), cond_rev_date_less as (
          select distinct jlu_epg_id, jlu_entity, jlu_jrnl_rev_date, jlu_effective_date, 'Reversing Date < Effective Date' as validation, to_char(jlu_jrnl_rev_date, ']'||lDateFormat||q'[') as value1,
            to_char(jlu_effective_date, ']'||lDateFormat||q'[') as value2,  cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from jrnl_lines join slr_entities ent on ent.ent_entity = jlu_entity
            join slr_ext_jrnl_types ext on jlu_jrnl_type = ext.ejt_type
            join slr_jrnl_types typ on ext.ejt_jt_type = typ.jt_type
          where jt_reverse_flag = 'C'
            and jlu_jrnl_rev_date is not null
            and jlu_jrnl_rev_date <= jlu_effective_date
        ), accounts as (
          select distinct jlu_epg_id, jlu_entity, jlu_account, 'Accounts' as validation, jlu_account as value1, cast(null as varchar2(200)) as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from entities where not exists (
            select 1 from slr_entity_accounts
            where ea_entity_set = (select ent_accounts_set from slr_entities where ent_entity = jlu_entity)
            and ea_status = 'A'
            and ea_account = jlu_account
          )
        ), adjustment_balance as (
          select distinct jlu_epg_id, jlu_entity, jlu_jrnl_type  as value1, 'Adjustment Balances' as validation, cast(null as varchar2(200)) as value2,
            cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from entities
            join slr_entities ent on jlu_entity = ent.ent_entity
          where exists (
            select 1
            from slr_ext_jrnl_types
            where ejt_type = jlu_jrnl_type
              and ((ejt_balance_type_1 = 20 and ejt_balance_type_2 is null) or (ejt_balance_type_2 = 20 and ejt_balance_type_1 is null)))
            and ent.ent_adjustment_flag = 'N'
        ), currency as (
          select distinct jlu_epg_id, jlu_entity, trim(jlu_tran_ccy) as value1, 'Currency' as validation, to_char(jlu_effective_date, ']'||lDateFormat||q'[') as value2,
            to_char(jlu_translation_date, ']'||lDateFormat||q'[') as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
            cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from jrnl_lines
        ), fx_rate as (
          select distinct jlu_epg_id, jlu_entity, trim(jlu_tran_ccy) as value1, 'FX Rates' as validation, to_char(jlu_effective_date, ']'||lDateFormat||q'[') as value2,
            to_char(jlu_translation_date, ']'||lDateFormat||q'[') as value3, jlu_jrnl_ent_rate_set as value4, trim(coalesce(jlu_local_ccy, ent_local_ccy)) as value5, trim(coalesce(jlu_base_ccy, ent_base_ccy)) as value6,
            JLU_SEGMENT_2 as value7, case when JLU_BASE_AMOUNT is not null then '1' else null end as value8, case when JLU_LOCAL_AMOUNT is not null then '1' else null end as value9
          from jrnl_lines
          join slr_entities on jlu_entity = ent_entity and ent_apply_fx_translation = 'Y'
           where JLU_BASE_AMOUNT is null or JLU_LOCAL_AMOUNT is null
    ),entities_list as (
          select distinct jlu_epg_id, jlu_entity, jlu_tran_ccy as value1, 'Entities' as validation, cast(null as varchar2(200)) as value2,
          cast(null as varchar2(200)) as value3, cast(null as varchar2(200)) as value4, cast(null as varchar2(200)) as value5, cast(null as varchar2(200)) as value6,
          cast(null as varchar2(200)) as value7, cast(null as varchar2(200)) as value8, cast(null as varchar2(200)) as value9
          from jrnl_lines
        ) select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from epg_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from periods_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from days_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from value_date_period_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from value_date_day_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from ext_type_none_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from ext_type_between_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from ext_type_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from rev_date_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from rev_date_rules_validate
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from rev_date_less
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from cond_rev_date_less
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from accounts
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from adjustment_balance
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from currency
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from entities_list
        union all
          select validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 from fx_rate]';

      TYPE lValidateRc IS REF CURSOR;
      lValidateCur lValidateRc;
      lValidationTable ttValidationTable := ttValidationTable();

      lEpgValidation SIMPLE_INTEGER DEFAULT 0;
      lVal VARCHAR2(200);
	/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
		  TYPE cur_type IS REF CURSOR;
		  cValidateRows cur_type;
		  lv_sql VARCHAR2(32000);
	/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
      PROCEDURE validateReversingDateRules (
        pEntity IN slr_entities.ent_entity%TYPE,
        pJrnlType IN slr_jrnl_lines_unposted.jlu_jrnl_type%TYPE,
        pPeriodDate IN slr_ext_jrnl_type_rule.ejtr_period_date%TYPE,
        pEffectiveDate IN slr_jrnl_lines_unposted.jlu_effective_date%TYPE,
        pJrnlRevDate IN slr_jrnl_lines_unposted.jlu_jrnl_rev_date%TYPE,
        pErrorMessage IN slr_error_message.em_error_message%TYPE,
        pPriorNextCurrent IN slr_ext_jrnl_type_rule.ejtr_prior_next_current%TYPE,
        pType IN slr_ext_jrnl_type_rule.ejtr_type%TYPE,
        pBusinessDate IN slr_entities.ent_business_date%TYPE,
        pPeriodsAndDaysSet IN slr_entities.ent_periods_and_days_set%TYPE
      ) IS

        lRevErrMsg VARCHAR2(1500);
        lEntNextBusinessDate TIMESTAMP(6);
        lRevCompareStartDate TIMESTAMP(6);
        lRevCompareEndDate TIMESTAMP(6);
        lPeriodStartDate TIMESTAMP(6);
        lRevCompareDate TIMESTAMP(6);
        lPeriodEndDate TIMESTAMP(6);
        lPrevBusDate TIMESTAMP(6);
        lNextBusDate TIMESTAMP(6);
        lNextPeriodEndDate TIMESTAMP(6);
        lNextPeriodStartDate TIMESTAMP(6);
        lPrevPeriodEndDate TIMESTAMP(6);
        lPrevPeriodStartDate TIMESTAMP(6);

      BEGIN
        GUI_MANUAL_JOURNAL.prui_get_calendar_details(
          pEffectiveDate,
          pPeriodsAndDaysSet,
          pEntity,
          lPrevPeriodStartDate,
          lPrevPeriodEndDate,
          lPeriodStartDate,
          lPrevBusDate,
          lNextBusDate,
          lPeriodEndDate,
          lNextPeriodEndDate,
          lNextPeriodStartDate
        );

        lRevErrMsg := REPLACE(pErrorMessage, '%2', 'current business day');

        IF (pPriorNextCurrent IS NOT NULL AND pPeriodDate IS NOT NULL) THEN

          lRevErrMsg := REPLACE(pErrorMessage, '%1', 'Reversing date');

          CASE pPriorNextCurrent
            WHEN 'P' THEN
              lRevCompareStartDate := lPrevPeriodStartDate;
              lRevCompareEndDate := lPrevPeriodEndDate;
            WHEN 'C' THEN
              lRevCompareStartDate := lPeriodStartDate;
              lRevCompareEndDate := lPeriodEndDate;
            WHEN 'N' THEN
              lRevCompareStartDate := lNextPeriodStartDate;
              lRevCompareEndDate := lNextPeriodEndDate;
            ELSE NULL;
          END CASE;

          CASE pPeriodDate
            WHEN 'S' THEN
              IF (pType = '=' AND pJrnlRevDate != lRevCompareStartDate) THEN lRevErrMsg := REPLACE(lRevErrMsg, '%1', 'Reversing date');
                pWriteLineError(
                  pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
                  ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||''' AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_JRNL_TYPE = '''||pJrnlType||''' ',
                    p_epg_id, p_status, NULL
                );
              ELSIF ((pType = '>' AND pJrnlRevDate <= lRevCompareStartDate) OR (pType = '<' AND pJrnlRevDate >= lRevCompareStartDate)) THEN
                pWriteLineError(
                  pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
                  ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||''' AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_JRNL_TYPE = '''||pJrnlType||''' ',
                  p_epg_id, p_status, NULL
                );
              END IF;
            WHEN 'E' THEN
              IF
                (pType = '=' AND pJrnlRevDate <> lRevCompareEndDate) OR
                (pType = '>' AND pJrnlRevDate <= lRevCompareEndDate) OR
                (pType = '<' AND pJrnlRevDate >= lRevCompareEndDate)
              THEN
                pWriteLineError(
                  pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
                  ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||''' AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_JRNL_TYPE = '''||pJrnlType||''' ',
                  p_epg_id, p_status, NULL
                );
              END IF;
            WHEN 'B' THEN
              IF (pType = 'BETWEEN' AND NOT pJrnlRevDate BETWEEN lRevCompareStartDate AND lRevCompareEndDate) THEN
                pWriteLineError(
                  pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
                  ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||''' AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_JRNL_TYPE = '''||pJrnlType||''' ',
                  p_epg_id, p_status, NULL
                );
              END IF;
          END CASE;

        ELSIF (pPriorNextCurrent IS NOT NULL AND pPeriodDate IS NULL) THEN

          lRevErrMsg := REPLACE(pErrorMessage, '%1', 'Reversing date');

          CASE pPriorNextCurrent
            WHEN 'P' THEN
              lRevCompareDate := lPrevBusDate;
              IF
                (pType = '=' AND pJrnlRevDate <> lRevCompareDate) OR
                (pType = '>' AND pJrnlRevDate <= lRevCompareDate) OR
                (pType = '<' AND pJrnlRevDate >= lRevCompareDate)
              THEN
                pWriteLineError(
                  pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
                  ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||''' AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_JRNL_TYPE = '''||pJrnlType||''' ',
                  p_epg_id, p_status, NULL
                );
              END IF;
            WHEN 'C' THEN
              lRevCompareDate := pBusinessDate;
              IF
                (pType = '=' AND pJrnlRevDate <> lRevCompareDate) OR
                (pType = '>' AND pJrnlRevDate <= lRevCompareDate) OR
                (pType = '<' AND pJrnlRevDate >= lRevCompareDate)
              THEN
                pWriteLineError(
                  pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
                  ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||'''  AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_JRNL_TYPE = '''||pJrnlType||''' ',
                  p_epg_id, p_status, NULL
                );
              END IF;
            WHEN 'N' THEN
              lRevCompareDate := lNextBusDate;
              IF
                (pType = '=' AND pJrnlRevDate <> lRevCompareDate) OR
                (pType = '>' AND pJrnlRevDate <= lRevCompareDate) OR
                (pType = '<' AND pJrnlRevDate >= lRevCompareDate)
              THEN
                pWriteLineError(
                  pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
                  ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||'''  AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_JRNL_TYPE = '''||pJrnlType||''' ',
                  p_epg_id, p_status, NULL
                );
              END IF;
            ELSE NULL;
          END CASE;
        ELSIF (pPriorNextCurrent IS NULL AND pPeriodDate IS NOT NULL) THEN

          lRevErrMsg := REPLACE(pErrorMessage, '%1', 'Reversing date');

        ELSE

          lRevErrMsg := REPLACE(pErrorMessage, '%1', 'Reversing date');
          lRevCompareDate := pBusinessDate;

          IF
            (pType = '=' AND pJrnlRevDate <> lRevCompareDate) OR
            (pType = '>' AND pJrnlRevDate <= lRevCompareDate) OR
            (pType = '<' AND pJrnlRevDate >= lRevCompareDate)
          THEN
            pWriteLineError(
              pEntity, p_process_id, 'Valid Rev Date', lRevErrMsg,
              ' AND JLU_JRNL_REV_DATE = DATE '''||TO_CHAR(pJrnlRevDate, 'yyyy-mm-dd')||'''  AND JLU_EFFECTIVE_DATE = DATE '''||TO_CHAR(pEffectiveDate, 'yyyy-mm-dd')||'''  and jlu_jrnl_type = '''||pJrnlType||''' ',
              p_epg_id, p_status, NULL
            );
          END IF;

        END IF;
      END validateReversingDateRules;

      PROCEDURE pValidateCurrency (
        pEntity IN slr_entities.ent_entity%TYPE,
        pEffectiveDate IN slr_jrnl_lines_unposted.jlu_effective_date%TYPE,
        pTranslationDate IN slr_jrnl_lines_unposted.jlu_translation_date%TYPE,
        pTranCcy IN slr_jrnl_lines_unposted.jlu_tran_ccy%TYPE
      ) IS
        lEntityConfiguration slr_entities%ROWTYPE;
        lIsFound SMALLINT;
      BEGIN
        SELECT * INTO lEntityConfiguration FROM slr_entities
        WHERE ent_entity = pEntity;

        -- when not valid exception NO_DATA_FOUND is raised
        SELECT 1 INTO lIsFound FROM slr_entity_currencies
        WHERE ec_entity_set = lEntityConfiguration.ent_currency_set
          AND TRIM(ec_ccy) = pTranCcy
          AND ec_status = 'A';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          pWriteLineError(pEntity, p_process_id, 'Currency', 'Invalid transaction currency: '||pTranCcy, ' AND JLU_TRAN_CCY = '''||pTranCcy||'''', p_epg_id, p_status, p_UseHeaders);
      END pValidateCurrency;

        PROCEDURE pValidateRates (
            pEntity IN slr_entities.ent_entity%TYPE,
            pEffectiveDate IN slr_jrnl_lines_unposted.jlu_effective_date%TYPE,
            pTranslationDate IN slr_jrnl_lines_unposted.jlu_translation_date%TYPE,
            pTranCcy IN slr_jrnl_lines_unposted.jlu_tran_ccy%TYPE,
            pJrnlEntRateSet IN slr_jrnl_lines_unposted.jlu_jrnl_ent_rate_set%TYPE,
            pLocalCcy IN slr_jrnl_lines_unposted.jlu_local_ccy%TYPE,
            pBaseCcy IN slr_jrnl_lines_unposted.jlu_base_ccy%TYPE,
            pSegment2 IN slr_jrnl_lines_unposted.JLU_SEGMENT_2%TYPE,
            pBaseAmount IN slr_jrnl_lines_unposted.JLU_BASE_AMOUNT%TYPE,
            pLocalAmount IN slr_jrnl_lines_unposted.JLU_LOCAL_AMOUNT%TYPE
        ) IS
            lEntityConfiguration slr_entities%ROWTYPE;
            lIsFound SMALLINT;
            lFxMode SLR_FX_TRANSLATION_CONFIG.FTC_FX_MODE%TYPE;
            LCheckB SMALLINT;
            LCheckL SMALLINT;
        BEGIN
            SELECT * INTO lEntityConfiguration FROM slr_entities
            WHERE ent_entity = pEntity;
            LCheckB:=1;
            LCheckL:=1;


            IF (lEntityConfiguration.ent_apply_fx_translation = 'Y' AND pEffectiveDate <= lEntityConfiguration.ent_business_date
                ) THEN

                -- when not valid exception NO_DATA_FOUND is raised
                BEGIN
                    SELECT 1,FTC_FX_MODE
                    INTO lIsFound,lFxMode
                    FROM slr_entities
                             join SLR_FX_TRANSLATION_CONFIG
                                  on ENT_ENTITY = FTC_ENTITY and FTC_GAAP = pSegment2 and FTC_PROCESS_TYPE = 'FX_TRANSLATION'
                    where ENT_ENTITY = pEntity
                      and FTC_TARGET_AMOUNT_TYPE = 'Base';
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        pWriteLineError(
                                pEntity, p_process_id, 'FX Rate',
                                'Missing configuration for Target Amount Type [Base] , Process Type [FX_TRANSLATION], Entity [' || pEntity || '] and Gaap [' ||
                                pSegment2 || ']',
                                ' AND JLU_ENTITY = ''' || pEntity || ''' AND JLU_SEGMENT_2 = ''' || pSegment2 ||
                                ''' AND JLU_EFFECTIVE_DATE = DATE ''' || to_char(pEffectiveDate, 'yyyy-mm-dd') ||
                                ''' AND JLU_TRANSLATION_DATE '
                                    || CASE
                                           WHEN pTranslationDate IS NULL THEN ' IS NULL '
                                           ELSE ' = DATE ''' || to_char(pTranslationDate, 'yyyy-mm-dd') || '''' END,
                                p_epg_id, p_status, p_useHeaders
                            );
                        LCheckB:=0;
                END;
                --1:1 translate rate not required and also when pBaseAmount is already calculated
                IF LCheckB=1 and ((lFxMode='Step-by-Step' and pLocalCcy<>pBaseCcy) OR (lFxMode='Direct' and pTranCcy<>pBaseCcy)) and pBaseAmount is null THEN
                    BEGIN
                        SELECT 1,FTC_FX_MODE
                        INTO lIsFound,lFxMode
                        FROM slr_entities
                                 join SLR_FX_TRANSLATION_CONFIG
                                      on SLR_ENTITIES.ENT_ENTITY = FTC_ENTITY and FTC_GAAP = pSegment2 and
                                         FTC_PROCESS_TYPE = 'FX_TRANSLATION'
                                 join slr_entity_rates
                                      on er_date = nvl(pTranslationDate, pEffectiveDate)
                                          and er_entity_set = coalesce(FTC_FX_RATE_SET, lEntityConfiguration.ent_rate_set)
                                          and
                                         er_ccy_from = case when FTC_FX_MODE = 'Step-by-Step' then pLocalCcy else pTranCcy end
                                          and er_ccy_to = pBaseCcy
                                          and er_rate_type = FTC_RATE_TYPE
                        where ENT_ENTITY = pEntity
                          and FTC_TARGET_AMOUNT_TYPE = 'Base';
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            pWriteLineError(
                                    pEntity, p_process_id, 'FX Rate',
                                    'No Base FX Rate '||lFxMode||' mode, for source currency ['||case when lFxMode = 'Step-by-Step' then pLocalCcy else pTranCcy end||'] to target ['||pBaseCcy||'] and entity ['||pEntity||'] and date [' || to_char(NVL(pTranslationDate, pEffectiveDate), 'yyyy-mm-dd') || ']',
                                    ' AND '||case when lFxMode = 'Step-by-Step' then 'JLU_LOCAL_CCY' else 'JLU_TRAN_CCY' end||' = '''||case when lFxMode = 'Step-by-Step' then pLocalCcy else pTranCcy end||''' AND JLU_ENTITY = '''||pEntity||''' AND JLU_SEGMENT_2 = ''' || pSegment2 || ''' AND JLU_EFFECTIVE_DATE = DATE '''||to_char(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_TRANSLATION_DATE '
                                        || CASE WHEN pTranslationDate IS NULL THEN ' IS NULL ' ELSE ' = DATE '''||to_char(pTranslationDate, 'yyyy-mm-dd')||'''' END,
                                    p_epg_id, p_status, p_useheaders
                                );
                        WHEN OTHERS THEN
                            pWriteLineError(
                                    pEntity, p_process_id, 'FX Rate',
                                    'FX Base rate error '||lFxMode||' mode, for source currency ['||case when lFxMode = 'Step-by-Step' then pLocalCcy else pTranCcy end||'] to target ['||pBaseCcy||'] and entity ['||pEntity||'] and date [' || to_char(NVL(pTranslationDate, pEffectiveDate), 'yyyy-mm-dd') || ']',
                                    ' AND '||case when lFxMode = 'Step-by-Step' then 'JLU_LOCAL_CCY' else 'JLU_TRAN_CCY' end||' = '''||case when lFxMode = 'Step-by-Step' then pLocalCcy else pTranCcy end||''' AND JLU_ENTITY = '''||pEntity||''' AND JLU_SEGMENT_2 = ''' || pSegment2 || ''' AND JLU_EFFECTIVE_DATE = DATE '''||to_char(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_TRANSLATION_DATE '
                                        || CASE WHEN pTranslationDate IS NULL THEN ' IS NULL ' ELSE ' = DATE '''||to_char(pTranslationDate, 'yyyy-mm-dd')||'''' END,
                                    p_epg_id, p_status, p_useheaders
                                );
                    END;
                end if;

                BEGIN

                    SELECT 1,FTC_FX_MODE
                    INTO lIsFound,lFxMode
                    FROM slr_entities
                             join SLR_FX_TRANSLATION_CONFIG
                                  on ENT_ENTITY = FTC_ENTITY and FTC_GAAP = pSegment2 and FTC_PROCESS_TYPE = 'FX_TRANSLATION'
                    where ENT_ENTITY = pEntity
                      and FTC_TARGET_AMOUNT_TYPE = 'Local';
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        pWriteLineError(
                                pEntity, p_process_id, 'FX Rate',
                                'Missing configuration for Target Amount Type [Local] , Process Type [FX_TRANSLATION], Entity [' || pEntity || '] and Gaap [' ||
                                pSegment2 || ']',
                                ' AND JLU_ENTITY = ''' || pEntity || ''' AND JLU_SEGMENT_2 = ''' || pSegment2 ||
                                ''' AND JLU_EFFECTIVE_DATE = DATE ''' || to_char(pEffectiveDate, 'yyyy-mm-dd') ||
                                ''' AND JLU_TRANSLATION_DATE '
                                    || CASE
                                           WHEN pTranslationDate IS NULL THEN ' IS NULL '
                                           ELSE ' = DATE ''' || to_char(pTranslationDate, 'yyyy-mm-dd') || '''' END,
                                p_epg_id, p_status, p_useHeaders
                            );
                        LCheckL:=0;
                END;
                --1:1 translate rate not required and also when pLocalAmount is already calculated
                IF LCheckL=1 and pTranCcy<>pLocalCcy and pLocalAmount is null THEN
                    BEGIN

                        SELECT 1,FTC_FX_MODE
                        INTO lIsFound,lFxMode
                        FROM slr_entities
                                 join SLR_FX_TRANSLATION_CONFIG
                                      on SLR_ENTITIES.ENT_ENTITY = FTC_ENTITY and FTC_GAAP = pSegment2 and
                                         FTC_PROCESS_TYPE = 'FX_TRANSLATION'
                                 join slr_entity_rates
                                      on er_date = nvl(pTranslationDate, pEffectiveDate)
                                          and er_entity_set = coalesce(FTC_FX_RATE_SET, lEntityConfiguration.ent_rate_set)
                                          and
                                         er_ccy_from = pTranCcy
                                          and er_ccy_to = pLocalCcy
                                          and er_rate_type = FTC_RATE_TYPE
                        where ENT_ENTITY = pEntity
                          and FTC_TARGET_AMOUNT_TYPE = 'Local';
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            pWriteLineError(
                                    pEntity, p_process_id, 'FX Rate',
                                    'No Local FX Rate '||lFxMode||' mode, for source currency ['||pTranCcy||'] to target ['||pLocalCcy||'] and entity ['||pEntity||'] and date ['||to_char(NVL(pTranslationDate, pEffectiveDate), 'yyyy-mm-dd')||']',
                                    ' AND JLU_TRAN_CCY = '''||pTranCcy||''' AND JLU_ENTITY = '''||pEntity||''' AND JLU_SEGMENT_2 = ''' || pSegment2 || ''' AND JLU_EFFECTIVE_DATE = DATE '''||to_char(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_TRANSLATION_DATE '
                                        ||CASE WHEN pTranslationDate IS NULL THEN ' IS NULL ' ELSE ' = DATE '''||to_char(pTranslationDate, 'yyyy-mm-dd')||'''' END,
                                    p_epg_id, p_status, p_useHeaders
                                );
                        WHEN OTHERS THEN
                            pWriteLineError(
                                    pEntity, p_process_id, 'FX Rate',
                                    'FX Local rate error for source currency ['||pTranCcy||'] to target ['||pLocalCcy||'] and entity ['||pEntity||'] and date ['|| to_char(NVL(pTranslationDate, pEffectiveDate), 'yyyy-mm-dd')||']',
                                    ' AND JLU_TRAN_CCY = '''||pTranCcy||''' AND JLU_ENTITY = '''||pEntity||''' AND JLU_SEGMENT_2 = ''' || pSegment2 || ''' AND JLU_EFFECTIVE_DATE = DATE '''||to_char(pEffectiveDate, 'yyyy-mm-dd')||''' AND JLU_TRANSLATION_DATE '
                                        || CASE WHEN pTranslationDate IS NULL THEN ' IS NULL ' ELSE ' = DATE '''||to_char(pTranslationDate, 'yyyy-mm-dd')||'''' END,
                                    p_epg_id, p_status, p_useHeaders
                                );
                    END;
                end if;

            END IF;

        END pValidateRates;

      PROCEDURE pValidateSegments IS
        lNumberOfSegemnts SIMPLE_INTEGER DEFAULT 10;
        lSegmentSql VARCHAR2(32767) DEFAULT '
          select count(distinct fd_segment_[:segment_no]_type), max(fd_segment_[:segment_no]_type)
          from slr_fak_definitions
            inner join slr_entity_proc_group on fd_entity = epg_entity
            where epg_id = ''[:epg_id]''';

        lResultCount NUMBER;
        lDefinition VARCHAR2(1000);

      BEGIN

        FOR lSegmentNo IN 1..lNumberOfSegemnts LOOP

          BEGIN
            EXECUTE IMMEDIATE REPLACE(REPLACE(lSegmentSql, '[:segment_no]', TO_CHAR(lSegmentNo)), '[:epg_id]', p_epg_id)
            INTO lResultCount, lDefinition;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              lResultCount := 0;
              lDefinition := 'I';
          END;

          IF lResultCount = 1 AND lDefinition IN ('M', 'C') THEN
            pValidateSegment(p_process_id, lSegmentNo, lDefinition, p_epg_id, p_status, p_useHeaders);
          ELSIF lResultCount > 1 THEN
            pValidateSegmentDiff(p_process_id, lSegmentNo, p_epg_id, p_status, p_useHeaders);
          END IF;
        END LOOP;

      END pValidateSegments;

      PROCEDURE pValidateBalances IS
        lNumberOfSegments SIMPLE_INTEGER DEFAULT 10;
        lIsDefined BOOLEAN DEFAULT TRUE;
        lSegment VARCHAR2(500);
        lDefinition VARCHAR2(100);
        lAllSegments VARCHAR2(2000);

        lSegmentSql VARCHAR2(32767) DEFAULT '
          select
            case when count(distinct fd_segment_[:segment_no]_balance_check) = 1 and max(fd_segment_[:segment_no]_balance_check) = ''Y'' then '',jlu_segment_[:segment_no]'' else '''' end,
            case when count(distinct fd_segment_[:segment_no]_balance_check) <> 1 then ''FALSE'' else '' '' end
          from slr_fak_definitions inner join slr_entity_proc_group on fd_entity = epg_entity where epg_id = ''[:epg_id]''';
      BEGIN

        FOR lSegmentNo IN 1..lNumberOfSegments LOOP
          EXECUTE IMMEDIATE REPLACE(REPLACE(lSegmentSql, '[:segment_no]', TO_CHAR(lSegmentNo)), '[:epg_id]', p_epg_id)
          INTO lSegment, lDefinition;

          lAllSegments := lAllSegments||lSegment;

          IF (lDefinition = 'FALSE') THEN
            lIsDefined := FALSE;
          END IF;
        END LOOP;

        lAllSegments := 'JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE'||lAllSegments||', JLU_TRAN_CCY ';

        IF NOT lIsDefined THEN
          pValidateBalanceDiff(p_process_id, p_epg_id, p_status, p_UseHeaders);
        ELSE
          pValidateBalance(p_process_id, p_epg_id, p_status, p_UseHeaders, lAllSegments);
        END IF;

      END pValidateBalances;

    BEGIN
      IF slr_post_journals_pkg.gp_business_date is NULL THEN 
        slr_post_journals_pkg.gp_business_date:=lCurrBusDate;
      END IF;
	  gProcessId := p_process_id;
      gProcessIdStr := TO_CHAR(gProcessId);
      SLR_ADMIN_PKG.InitLog(p_epg_id, p_process_id);
      SLR_ADMIN_PKG.Info('Validation start');

      EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

      pInitializeProcedure(p_epg_id, p_process_id);
      pDeleteLineErrors(p_epg_id, p_process_id, p_status);

      UPDATE slr_jrnl_lines_unposted SET jlu_jrnl_status = 'W'
      WHERE jlu_epg_id = p_epg_id AND jlu_jrnl_status = p_status
        AND jlu_effective_date > lCurrBusDate;
      
	  IF p_epg_id IS NOT NULL AND p_status IS NOT NULL THEN 
       lValidateSQL_var := REPLACE(lValidateSQL,':p_subpartition_name',' subpartition (P'||p_epg_id||'_S'||p_status||' )');
      ELSE 
	   lValidateSQL_var := REPLACE(lValidateSQL,':p_subpartition_name','');
	  end if;
     OPEN lValidateCur FOR lValidateSQL_var USING p_epg_id, p_status;
      <<validate_loop>>
      LOOP
        FETCH lValidateCur BULK COLLECT INTO lValidationTable LIMIT cROWLIMIT;
        EXIT WHEN lValidationTable.COUNT = 0;

        -- EPG validation
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'EPG validation'
        ) LOOP
          lEpgValidation := lEpgValidation + 1;
          pr_error(1, 'Missing entity definition in SLR_ENTITY_PROC_GROUP for epg_id ['||p_epg_id||'] and entity ['||rec.jlu_entity||']', 1, 'pValidateJournals', 'SLR_ENTITY_PROC_GROUP', NULL, NULL, NULL,'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        END LOOP;

        IF lEpgValidation > 0 AND lEpgValidation < cROWLIMIT THEN
          raise_application_error(-20001, 'Fatal error during SLR_ENTITY_PROC_GROUP validation');
        ELSIF lEpgValidation > 0 AND lEpgValidation = cROWLIMIT THEN
          CONTINUE;
        END IF;

        SLR_ADMIN_PKG.Debug('Validation. EPG configuration validated.', lValidateSQL);

        -- validation executed only once
        IF lValidateCur%ROWCOUNT <= cROWLIMIT THEN

          -- Validation in External types table
          BEGIN
            SELECT ejt_type INTO lVal FROM slr_ext_jrnl_types WHERE ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              pr_error(1, 'No data found in SLR_EXT_JRNL_TYPES', 1, 'pValidateJournals', 'SLR_EXT_JRNL_TYPES', NULL, NULL, NULL, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
              raise_application_error(-20001, 'Fatal error during SLR_EXT_JRNL_TYPES validation');
          END;

          SLR_ADMIN_PKG.Debug('Validation. Records in SLR_EXT_JRNL_TYPES exist.');

          COMMIT;
          SLR_ADMIN_PKG.Debug('Validation. Future records moved.', NULL);
        END IF;

        -- Period validation
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'Periods' and value1 != 'jlu_translation_date'
        ) LOOP
          pWriteLineError(rec.jlu_entity, p_process_id, 'Period', 'Invalid Period: ['||rec.value2|| '] not valid in Period table for Entity ['||rec.jlu_entity||'] and column ['||rec.value1||']', ' AND '||rec.value1||' = DATE ''' || rec.value2|| '''', p_epg_id, p_status, p_UseHeaders);
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Periods validated.', lValidateSQL);

        -- Reversing Date < Effective Date
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'Reversing Date < Effective Date'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Rev Date', 'The Reversing Date: ['||rec.value1||'] must be greater than the Effective Date: ['||rec.value2||'] .',
            ' AND JLU_JRNL_REV_DATE = DATE '''||rec.value1||''' AND JLU_EFFECTIVE_DATE = DATE '''||rec.value2||''' ', p_epg_id, p_status, p_UseHeaders
          );
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Reversing Date < Effective Date - validated.', lValidateSQL);

        -- Dates
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2,
            CASE value1
              WHEN 'jlu_effective_date' THEN 'Eff Date'
              WHEN 'jlu_translation_date' THEN 'Trans Date'
              WHEN 'jlu_jrnl_rev_date' THEN 'Rev Date'
              WHEN 'jlu_value_date' THEN 'Value Date'
            END AS short_name,
            CASE value1
              WHEN 'jlu_effective_date' THEN 'Effective Date'
              WHEN 'jlu_translation_date' THEN 'Translation Date'
              WHEN 'jlu_jrnl_rev_date' THEN 'Reversing Date'
              WHEN 'jlu_value_date' THEN 'Value Date'
            END AS long_name
            FROM TABLE(lValidationTable) WHERE validation = 'Dates' AND value1 != 'jlu_jrnl_rev_date'
        ) LOOP
          pWriteLineError(rec.jlu_entity, p_process_id, rec.short_name, 'Invalid '||rec.long_name||': ['||rec.value2|| '] not valid in entity days table for Entity ['||rec.jlu_entity||'] ',
          ' AND '||rec.value1||' = DATE ''' || rec.value2|| '''', p_epg_id, p_status, p_UseHeaders);
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Dates validated.', lValidateSQL);

        -- Period containing Value Date
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'Period containing Value Date'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Value Date', 'Period containing Value Date  ['||rec.value2||']  is invalid or is closed.', ' AND JLU_VALUE_DATE = DATE '''||rec.value2||'''', p_epg_id, p_status, NULL
          );
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Period containing Value Date validated.', lValidateSQL);

        -- Value Date
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2,
            CASE value1
              WHEN 'jlu_effective_date' THEN 'Eff Date'
              WHEN 'jlu_translation_date' THEN 'Trans Date'
              WHEN 'jlu_jrnl_rev_date' THEN 'Rev Date'
              WHEN 'jlu_value_date' THEN 'Value Date'
            END AS short_name,
            CASE value1
              WHEN 'jlu_effective_date' THEN 'Effective Date'
              WHEN 'jlu_translation_date' THEN 'Translation Date'
              WHEN 'jlu_jrnl_rev_date' THEN 'Reversing Date'
              WHEN 'jlu_value_date' THEN 'Value Date'
            END AS long_name
            FROM TABLE(lValidationTable) WHERE validation = 'Value date'
        ) LOOP
          pWriteLineError(rec.jlu_entity, p_process_id, rec.short_name, 'Invalid '||rec.long_name||': ['||rec.value2|| '] not valid in entity days table for Entity ['||rec.jlu_entity||'] ',
          ' AND '||rec.value1||' = DATE ''' || rec.value2|| '''', p_epg_id, p_status, p_UseHeaders);
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Value Dates validated.', lValidateSQL);

        -- External type
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'External type: None'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Ext type: NONE', 'Invalid type: '||rec.value1||' and Rule: ' ||rec.value2||' for Reversing Date calculation.', ' AND jlu_jrnl_type = '''||rec.value1||''' ', p_epg_id, p_status, NULL
          );
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. External type: None - validated.', lValidateSQL);

        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'External type: BETWEEN'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Ext type: BETWEEN',
            'Invalid type: '||rec.value1||' and Rule: '||rec.value2||' for Reversing Date calculation.',
            ' AND jlu_jrnl_type = '''||rec.value1||''' ', p_epg_id, p_status, NULL
          );
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. External type: BETWEEN - validated.', lValidateSQL);

        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'Invalid Ext type'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Invalid Ext type',
            'No data found in SLR_EXT_JRNL_TYPES, SLR_JRNL_TYPES for Journal Type: '||rec.value1,
            ' AND jlu_jrnl_type = '''||rec.value1||''' ', p_epg_id, p_status, NULL
          );
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Invalid External type.', lValidateSQL);

        -- Reversing Date
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'Reversing Date'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Reversing Date', 'Invalid Reversing Date: ['||rec.value2||'] not valid in entity days table for Entity ['||rec.jlu_entity||'] ', ' AND JLU_JRNL_REV_DATE = DATE '''||rec.value2||'''', p_epg_id, p_status, NULL
          );
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Reversing Date - validated.', lValidateSQL);

        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 FROM TABLE(lValidationTable) WHERE validation = 'Reversing Date rules'
        ) LOOP

          -- Validate Reverse date with ejt_rev_validation_flag = 'Y'
          validateReversingDateRules (
            pEntity => rec.jlu_entity,
            pJrnlType => rec.value1,
            pPeriodDate => rec.value2,
            pEffectiveDate => TO_DATE(rec.value3, lDateFormat),
            pJrnlRevDate => TO_DATE(rec.value4, lDateFormat),
            pErrorMessage => rec.value5,
            pPriorNextCurrent => rec.value6,
            pType => rec.value7,
            pBusinessDate => TO_DATE(rec.value8, lDateFormat),
            pPeriodsAndDaysSet => rec.value9
          );

        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Reversing Date rules - validated.', lValidateSQL);

        -- Currencies
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7 FROM TABLE(lValidationTable) WHERE validation = 'Currency'
        ) LOOP
          pValidateCurrency (
            pEntity => rec.jlu_entity,
            pEffectiveDate => TO_DATE(rec.value2, lDateFormat),
            pTranslationDate => TO_DATE(rec.value3, lDateFormat),
            pTranCcy => rec.value1
          );
        END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. Currency validated.', lValidateSQL);

        -- Fx Rates
        FOR rec IN (
            SELECT DISTINCT validation, jlu_entity, value1, value2, value3, value4, value5, value6, value7, value8, value9 FROM TABLE(lValidationTable) WHERE validation = 'FX Rates'
            ) LOOP
                pValidateRates (
                        pEntity => rec.jlu_entity,
                        pEffectiveDate => TO_DATE(rec.value2, lDateFormat),
                        pTranslationDate => TO_DATE(rec.value3, lDateFormat),
                        pTranCcy => rec.value1,
                        pJrnlEntRateSet => rec.value4,
                        pLocalCcy => rec.value5,
                        pBaseCcy => rec.value6,
                        pSegment2 => rec.value7,
                        pBaseAmount => rec.value8,
                        pLocalAmount => rec.value9
                    );
            END LOOP;

        SLR_ADMIN_PKG.Debug('Validation. FX Rates validated.', lValidateSQL);

        -- Balances
        -- Adjustment Balances
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'Adjustment Balances'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Adjustment Balances',
            'The entity ['||rec.jlu_entity||'] does not allow adjustments to be processed.',
            ' AND JLU_JRNL_TYPE = '''||rec.value1||''' AND JLU_ENTITY = '''||rec.jlu_entity||'''', p_epg_id, p_status, p_UseHeaders
          );
        END LOOP;

        -- Accounts
        FOR rec IN (
          SELECT DISTINCT validation, jlu_entity, value1, value2 FROM TABLE(lValidationTable) WHERE validation = 'Accounts'
        ) LOOP
          pWriteLineError(
            rec.jlu_entity, p_process_id, 'Account',
            'Invalid Account: '||rec.value1, ' AND JLU_ACCOUNT = '''||rec.value1||'''', p_epg_id, p_status, p_UseHeaders
          );
        END LOOP;

        EXIT WHEN lValidateCur%NOTFOUND;
      END LOOP;
      CLOSE lValidateCur;
	  
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
	  -- Custom AG validation...
	  -- Event Class Periods

      lv_sql := 'SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
			DISTINCT JLU_EFFECTIVE_DATE, fgl_hier.LK_LOOKUP_VALUE3
			FROM SLR_JRNL_LINES_UNPOSTED
			join fdr.fr_general_lookup fgl_hier on JLU_ATTRIBUTE_4 = fgl_hier.LK_MATCH_KEY1
				 and fgl_hier.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_HIERARCHY''
			WHERE JLU_EPG_ID = ''' || p_epg_id || '''
				AND JLU_JRNL_STATUS = ''' || p_status || '''
			AND NOT EXISTS
			(
				SELECT NULL from fdr.fr_general_lookup fgl_period
									left join fdr.fr_general_lookup fgl_cls
										ON fgl_cls.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_CLASS''
										AND fgl_cls.LK_MATCH_KEY1 = fgl_period.LK_MATCH_KEY1
						where fgl_period.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_CLASS_PERIOD''
							AND FGL_HIER.LK_LOOKUP_VALUE3 = FGL_PERIOD.LK_MATCH_KEY1
							AND JLU_EFFECTIVE_DATE BETWEEN
									(CASE WHEN FGL_CLS.LK_LOOKUP_VALUE2 = ''Q''
										  THEN ADD_MONTHS(TO_DATE(FGL_PERIOD.LK_LOOKUP_VALUE2,''DD-MON-YYYY''),-2)
										  ELSE TO_DATE(FGL_PERIOD.LK_LOOKUP_VALUE2,''DD-MON-YYYY'')
										  END)
							AND TO_DATE(FGL_PERIOD.LK_LOOKUP_VALUE3,''DD-MON-YYYY'')
							--AND JLU_EFFECTIVE_DATE BETWEEN TO_DATE(''01-DEC-2017'',''DD-MON-YYYY'') and TO_DATE(''31-DEC-2017'',''DD-MON-YYYY'')
							AND FGL_PERIOD.LK_LOOKUP_VALUE1 = ''O''
			)
		';

      DECLARE
        v_fdr_event_class FDR.FR_GENERAL_LOOKUP.LK_LOOKUP_VALUE3%TYPE;
		v_jlu_effective_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
      BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
          FETCH cValidateRows INTO  v_jlu_effective_date, v_fdr_event_class;
          EXIT WHEN cValidateRows%NOTFOUND;
          pWriteLineErrorEventClass(v_fdr_event_class, p_process_id, 'Period',
            'Invalid Event Class Period: [' || v_jlu_effective_date || '] not valid in Period table for Event Class [' || v_fdr_event_class || '] ',
            ' AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''', p_epg_id, p_status, p_UseHeaders);

        END LOOP;

        CLOSE cValidateRows;
      END;

      SLR_ADMIN_PKG.Debug('Validation. Event Class Periods validated.', lv_sql);
	  --- End of AG custom validations
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/

      -- Segments
      pValidateSegments();
      SLR_ADMIN_PKG.Debug('Validation. Segments validated.');

      -- Balances
      pValidateBalances();
      SLR_ADMIN_PKG.Debug('Validation. Balances validated.');
      COMMIT;

      pValidateFuturePeriod(p_epg_id, p_process_id, p_status, p_UseHeaders);
      SLR_ADMIN_PKG.Debug('Validation. Future period validated.');

      pUpdateJLUPeriods(p_epg_id, p_process_id, p_status);
      SLR_ADMIN_PKG.Debug('Validation. JLU periods updated.');

      pInsertFakEbaCombinations(p_epg_id, p_process_id, p_status);

      SLR_ADMIN_PKG.Info('Validation end');
      pSetValidationStatistics(p_process_id);
      COMMIT;

    EXCEPTION
      WHEN e_internal_processing_error THEN
        -- error was handled in procedure which raised it
        RETURN;

      WHEN OTHERS THEN
        ROLLBACK;
        pWriteLogError(cPROC_NAME, 'SLR_JRNL_LINES_UNPOSTED', 'Error during journal lines validation', p_process_id, null, null);
        SLR_ADMIN_PKG.Error('ERROR in procedure pValidateJournals');
        raise_application_error(-20001, 'Fatal error during journal lines validation: ' || SQLERRM);
    END pValidateJournals;

    -- ---------------------------------------------------------------------------
    -- Function to Set Validation Statistics
    --
    -- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2
    -- ---------------------------------------------------------------------------
    PROCEDURE pSetValidationStatistics
    (
        p_process_id IN NUMBER
    )
    AS
        s_proc_name CONSTANT VARCHAR2(80) := 'SLR_VALIDATE_JOURNALS_PKG.fSetValidationStatistics';
    BEGIN

    -- Log the Number of Journals failing Validation to the error Handler
    -- -------------------------------------------------------------------*
    IF gErrorsNumber > 0 THEN
      			pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', 'There is/are ' || gErrorsNumber || ' journal(s) in error for Process Id [' || p_process_id || ']. More detailed description can be found in SLR_JRNL_LINE_ERRORS');
      gErrorsNumber:=0;
    END IF;

        SELECT  i.BLOCK_GETS,CONSISTENT_GETS,PHYSICAL_READS,BLOCK_CHANGES,CONSISTENT_CHANGES
        INTO    gEND_BLOCK_GETS,gEND_CONSISTENT_GETS,gEND_PHYSICAL_READS,gEND_BLOCK_CHANGES,gEND_CONSISTENT_CHANGES
        FROM    V$SESSION s,  V$SESS_IO i WHERE s.sid = SYS_CONTEXT('userenv','sid') AND i.SID = s.SID;

        gRESULT_BLOCK_GETS          := gEND_BLOCK_GETS        - gSTART_BLOCK_GETS;
        gRESULT_CONSISTENT_GETS     := gEND_CONSISTENT_GETS   - gSTART_CONSISTENT_GETS;
        gRESULT_PHYSICAL_READS      := gEND_PHYSICAL_READS    - gSTART_PHYSICAL_READS;
        gRESULT_BLOCK_CHANGES       := gEND_BLOCK_CHANGES     - gSTART_BLOCK_CHANGES;
        gRESULT_CONSISTENT_CHANGES  := gEND_CONSISTENT_CHANGES- gSTART_CONSISTENT_CHANGES;

        BEGIN
            UPDATE SLR_JOB_STATISTICS
            SET
                JS_END_TIME = SYSDATE,
                RESULT_BLOCK_GETS = gRESULT_BLOCK_GETS,
                RESULT_CONSISTENT_GETS = gRESULT_CONSISTENT_GETS,
                RESULT_PHYSICAL_READS = gRESULT_PHYSICAL_READS,
                RESULT_BLOCK_CHANGES = gRESULT_BLOCK_CHANGES,
                RESULT_CONSISTENT_CHANGES = gRESULT_CONSISTENT_CHANGES
            WHERE JS_PROCESS_ID = p_process_id
                AND JS_PROCESS_NAME = gc_process_name;

            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                pWriteLogError(s_proc_name, 'SLR_JOB_STATISTICS',
                                'Failure to update job statistics for process id ['||p_process_id||'] ');
                SLR_ADMIN_PKG.Error('Failure to update job statistics for process id ['||p_process_id||'] ');
        END;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN;

        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_JOB_STATISTICS',
                            'Failure to set validation statistics for process id ['||gProcessIdStr||'] ');
            SLR_ADMIN_PKG.Error('Failure to set validation statistics for process id ['||gProcessIdStr||'] ');
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during pSetValidationStatistics: ' || SQLERRM);
            --RETURN;

    END pSetValidationStatistics;

    -- ---------------------------------------------------------------------------
    -- Function to Set Validation Statistics
    --
    -- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2
    -- ---------------------------------------------------------------------------
    FUNCTION fSetFAKDefinition   RETURN BOOLEAN IS

        s_proc_name        VARCHAR2(80):= 'SLR_VALIDATE_JOURNALS_PKG.pSetFAKDefinition';

    BEGIN

        --dbms_output.put_line('--> fSetFAKDefinition()');

        SELECT *
        INTO gFAKDefinition
        FROM SLR_FAK_DEFINITIONS
        WHERE FD_ENTITY = gEntityConfiguration.ENT_ENTITY;

        --dbms_output.put_line('<-- fSetFAKDefinition');
        RETURN TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            pWriteLogError(s_proc_name, 'SLR_FAK_DEFINITIONS',
                            'No data found to set FAK definition for entity ['||gEntityConfiguration.ENT_ENTITY||'] ');
            RETURN FALSE;

        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_FAK_DEFINITIONS',
                           'Failure to set FAK definition for entity ['||gEntityConfiguration.ENT_ENTITY||'] ');
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during fSetFAKDefinition: ' || SQLERRM);
            --RETURN FALSE;

    END fSetFAKDefinition;

    -- ---------------------------------------------------------------------------
    -- Function to Set Validation Statistics
    --
    -- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2
    -- ---------------------------------------------------------------------------
    FUNCTION fSanityCheckValidation   RETURN BOOLEAN IS

        lvFAKandEBAErrors NUMBER(10);
        s_proc_name VARCHAR2(80):= 'SLR_VALIDATE_JOURNALS_PKG.fSanityCheckValidation';

    BEGIN

        lvFAKandEBAErrors := 0;

        -- Check All Lines have a FAK ID assigned, EBA ID are checked optionally
        -- ---------------------------------------------------------------------------
        SELECT  COUNT(*)
        INTO    lvFAKandEBAErrors
        FROM    SLR_JRNL_LINES_UNPOSTED
        WHERE   JLU_JRNL_PROCESS_ID     = gProcessIdStr
        AND     JLU_ENTITY = gJournalEntity
        AND     (JLU_FAK_ID = 0 OR JLU_EBA_ID  = 0)
        AND     JLU_JRNL_STATUS         = 'v';

        IF lvFAKandEBAErrors > 0 THEN
            RAISE ge_bad_count;
        END IF;

        RETURN TRUE;

    EXCEPTION
        WHEN ge_bad_count THEN
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED',
                             '(2) FAK or EBA errors for process id ['||gProcessIdStr||'] ');
            RETURN FALSE;

        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED',
                           '(1) Failure of sanity check validation for process id ['||gProcessIdStr||'] ');
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during fSanityCheckValidation: ' || SQLERRM);
            --RETURN FALSE;

    END fSanityCheckValidation;

    -- ---------------------------------------------------------------------------
    -- Function to Initialize Variables and Defaults
    --
    -- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2
    -- ---------------------------------------------------------------------------

    PROCEDURE pInitializeProcedure
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER
    )
    AS
        e_wrong_posting_date_flag EXCEPTION;
        s_proc_name CONSTANT VARCHAR2(80):= 'SLR_VALIDATE_JOURNALS_PKG.fInitializeProcedure';
    s_SID VARCHAR2(256);
    s_business_date date;
        s_bus_date_flag SLR_SYSTEM_CONFIG.PARAM_VALUE%TYPE;
        s_count NUMBER;
        s_entity SLR_ENTITIES.ENT_ENTITY%TYPE;
    BEGIN
    select sys_context('userenv','SID') SID
    into s_SID
    from DUAL;

        SELECT count(PARAM_VALUE)
        INTO s_count
        FROM SLR_SYSTEM_CONFIG
        WHERE PARAM_NAME = 'POSTING_DATE_DERIVATION';

        IF s_count = 1 THEN
            SELECT PARAM_VALUE
            INTO s_bus_date_flag
            FROM SLR_SYSTEM_CONFIG
            WHERE PARAM_NAME = 'POSTING_DATE_DERIVATION';
        ELSE
            s_bus_date_flag := 'E';
        END IF;

        IF s_bus_date_flag = 'E' THEN
            SELECT ENT_BUSINESS_DATE
            INTO s_business_date
            FROM SLR_ENTITIES
            WHERE ENT_ENTITY =
                  (
                      SELECT EPG_ENTITY
                      FROM SLR_ENTITY_PROC_GROUP
                      WHERE EPG_ID = p_epg_id
                      AND ROWNUM = 1
                  );
        ELSIF s_bus_date_flag = 'G' THEN
            SELECT EPG_ENTITY INTO s_entity
            FROM SLR_ENTITY_PROC_GROUP
            WHERE EPG_ID = p_epg_id
              AND ROWNUM = 1;

            SELECT GP_TODAYS_BUS_DATE
            INTO s_business_date
            FROM FR_GLOBAL_PARAMETER
                LEFT OUTER JOIN FR_LPG_CONFIG
                ON NVL(LC_LPG_ID, 1) = LPG_ID
            WHERE NVL(LC_GRP_CODE, s_entity) = s_entity
              AND NVL(LC_LPG_ID,1) = LPG_ID;
        ELSE
            RAISE e_wrong_posting_date_flag;
        END IF;

        INSERT INTO SLR_JOB_STATISTICS
        (
            JS_PROCESS_ID,
            JS_PROCESS_NAME,
            JS_START_TIME,
            JS_EPG_ID,
      JS_SID,
      JS_BUSINESS_DATE
        )
        VALUES
        (
            p_process_id,
            gc_process_name,
            SYSDATE,
            p_epg_id,
      s_SID,
      s_business_date
        );

        COMMIT;

        SELECT  i.BLOCK_GETS,CONSISTENT_GETS,PHYSICAL_READS,BLOCK_CHANGES,CONSISTENT_CHANGES
        INTO    gSTART_BLOCK_GETS,gSTART_CONSISTENT_GETS,gSTART_PHYSICAL_READS,gSTART_BLOCK_CHANGES,gSTART_CONSISTENT_CHANGES
        FROM    V$SESSION s,  V$SESS_IO i
        WHERE s.sid = SYS_CONTEXT('userenv','sid')
        AND i.SID = s.SID;

    EXCEPTION
        WHEN e_wrong_posting_date_flag THEN
            pWriteLogError(s_proc_name, 'SLR_SYSTEM_CONFIG', 'Wrong Posting Date Derivation flag. It should be either E or G.');
            SLR_ADMIN_PKG.Error('Error during posting journals (e_wrong_posting_date_flag).');
            RAISE_APPLICATION_ERROR(-20001, 'Wrong Posting Date Derivation flag. It should be either E or G. Instead value ' || s_bus_date_flag || ' is set in the SLR_SYSTEM_CONFIG table.');

        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_ENTITIES', 'Failure to initialise Validation');
            SLR_ADMIN_PKG.Error('Failure to initialise Validation');
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during pInitializeProcedure: ' || SQLERRM);
    END pInitializeProcedure;

    -- ---------------------------------------------------------------------------
    -- Procedure:    pWriteLineError
    -- Description:  Generic procedure to write journal errors.
    -- Note:         This procedure must not use any global variables.
    --               It is an autonomous transaction to permit error logging
    --               while rolling back other updates.
    -- Author:      Tony Watton
    -- ---------------------------------------------------------------------------
    PROCEDURE pWriteLineError
    (
        p_entity IN slr_entities.ent_entity%TYPE,
        p_process_id in NUMBER,
        p_status_text in VARCHAR2,
        p_msg in VARCHAR2,
        p_sql in VARCHAR2,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE

    )
    IS
    PRAGMA AUTONOMOUS_TRANSACTION;
        s_proc_name     VARCHAR2(80) := 'SLR_VALIDATE_JOURNALS_PKG.pWriteLineError';
        v_sql           VARCHAR2(4000);
        v_msg           SLR_JRNL_LINE_ERRORS.JLE_ERROR_STRING%TYPE;
        vErrorsNumber   NUMBER;
        v_header_ids_sql VARCHAR2(4000);

    BEGIN
        SLR_ADMIN_PKG.Debug('Writing line error with msg: [' || p_msg || ']');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_errors',
                                p_process_id    => p_process_id,
                                p_object_name   => 'SLR_JRNL_LINE_ERRORS',
								p_epg_id        => p_epg_id,
								p_tab_partition => 'P'||p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_uposted',
                                p_process_id    => p_process_id,
                                p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_LINES_UNPOSTED',
                                p_tab_partition => 'P'||p_epg_id,
                                p_sub_partition   => 'P'||p_epg_id||'_SE',
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_header',
                                p_process_id    => p_process_id,
								p_epg_id        => p_epg_id,
								p_tab_partition => 'P'||p_epg_id,
  							    p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_HEADERS_UNPOSTED',
                                p_start_dt      => sysdate,
                                p_status        => 'P');
        v_msg := substr(p_msg, 1, 200);

        v_sql := 'INSERT INTO SLR_JRNL_LINE_ERRORS
            (
                JLE_JRNL_PROCESS_ID,
                JLE_JRNL_HDR_ID,
                JLE_JRNL_LINE_NUMBER,
                JLE_ERROR_CODE,
                JLE_ERROR_STRING
            )
            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || '
                :process_id,
                JLU_JRNL_HDR_ID,
                JLU_JRNL_LINE_NUMBER,
                99999,
                ''' || v_msg|| '''
                FROM SLR_JRNL_LINES_UNPOSTED partition (P'||p_epg_id||')
                WHERE JLU_ENTITY = :p_entity
                AND JLU_EPG_ID = :p_epg_id
				AND JLU_JRNL_STATUS IN (:p_status,''E'') '
                || p_sql;

        --dbms_output.put_line(v_sql);
        EXECUTE IMMEDIATE v_sql USING p_process_id, p_entity, p_epg_id, p_status;
        COMMIT;

        v_header_ids_sql := '(SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                    WHERE JLU_ENTITY = :p_entity
                    AND JLU_EPG_ID = :p_epg_id
					AND JLU_JRNL_STATUS = :p_status '
                        || p_sql || ')';

        EXECUTE IMMEDIATE 'SELECT count(distinct JLU_JRNL_HDR_ID) FROM ' || v_header_ids_sql INTO vErrorsNumber USING p_entity, p_epg_id, p_status;
        gErrorsNumber := NVL(gErrorsNumber, 0) + vErrorsNumber;

        IF p_UseHeaders THEN

             v_sql := 'UPDATE SLR_JRNL_HEADERS_UNPOSTED'
                        ||' SET    JHU_JRNL_STATUS = ''E'','
                        ||'        JHU_AMENDED_BY = :id,'
                        ||'        JHU_AMENDED_ON = SYSDATE,'
						||'        JHU_JRNL_PROCESS_ID = :process_id'
                        ||' WHERE   (JHU_JRNL_ID) IN'
                        ||' :HeaderIds';
            SLR_ADMIN_PKG.Debug('Update headers query', v_sql);
            EXECUTE IMMEDIATE replace(v_sql, ':HeaderIds', v_header_ids_sql) USING USER, p_process_id, p_entity, p_epg_id, p_status ;
        END IF;

        v_sql := 'UPDATE slr_jrnl_lines_unposted partition (P'||p_epg_id||')
            SET JLU_JRNL_STATUS = ''E'',
            JLU_JRNL_STATUS_TEXT = :status_text,
            JLU_AMENDED_BY = :id,
            JLU_AMENDED_ON = SYSDATE,
			JLU_JRNL_PROCESS_ID = :process_id
            WHERE JLU_JRNL_HDR_ID IN
            :HeaderIds
		 AND JLU_EPG_ID = :p_epg_id
		 AND JLU_JRNL_STATUS = :p_status';

        SLR_ADMIN_PKG.Debug('Update lines query', v_sql);
        EXECUTE IMMEDIATE replace(v_sql, ':HeaderIds', v_header_ids_sql) USING p_status_text, USER,p_process_id, p_entity, p_epg_id, p_status, p_epg_id, p_status;
        COMMIT;
																	
																							 
        pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                            p_stage         => LOWER(s_proc_name)||'_errors',
                                            p_process_id    => p_process_id);
        pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                            p_stage         => LOWER(s_proc_name)||'_uposted',
                                            p_process_id    => p_process_id);
        pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                            p_stage         => LOWER(s_proc_name)||'_header',
                                            p_process_id    => p_process_id);

    EXCEPTION
        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINE_ERRORS',
                'Failure to write errors to log and unposted journals for process id ['||p_process_id||'] ',
                p_process_id,p_entity, p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Failure to write errors to log and unposted journals for process id ['||p_process_id||'] ');
            ROLLBACK;
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pWriteLineError: ' || SQLERRM ||' line: '||substr(dbms_utility.format_error_backtrace, 1, instr(dbms_utility.format_error_backtrace, chr(10))));

    END pWriteLineError;

/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
    -- ---------------------------------------------------------------------------
    -- Procedure:    pWriteLineErrorEventClass
    -- Description:  Custom procedure to write journal errors based on Event Class.
    -- Author:       Janet Hine
    -- ---------------------------------------------------------------------------
    PROCEDURE pWriteLineErrorEventClass
    (
        p_fdr_event_class IN FDR.FR_GENERAL_LOOKUP.LK_LOOKUP_VALUE3%TYPE,
        p_process_id in NUMBER,
        p_status_text in VARCHAR2,
        p_msg in VARCHAR2,
        p_sql in VARCHAR2,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN:= FALSE

    )
    IS
    PRAGMA AUTONOMOUS_TRANSACTION;
        s_proc_name     VARCHAR2(80) := 'SLR_VALIDATE_JOURNALS_PKG.pWriteLineErrorEventClass';
        v_sql           VARCHAR2(4000);
        v_msg           SLR_JRNL_LINE_ERRORS.JLE_ERROR_STRING%TYPE;

    BEGIN
        SLR_ADMIN_PKG.Debug('Writing line error with msg: [' || p_msg || ']');

        v_msg := substr(p_msg, 1, 200);

        v_sql := 'INSERT INTO SLR_JRNL_LINE_ERRORS
            (
                JLE_JRNL_PROCESS_ID,
                JLE_JRNL_HDR_ID,
                JLE_JRNL_LINE_NUMBER,
                JLE_ERROR_CODE,
                JLE_ERROR_STRING
            )
            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || '
                :process_id,
                JLU_JRNL_HDR_ID,
                JLU_JRNL_LINE_NUMBER,
                99999,
                ''' || v_msg|| '''
                FROM SLR_JRNL_LINES_UNPOSTED
                join fdr.fr_general_lookup fgl_hier on JLU_ATTRIBUTE_4 = fgl_hier.LK_MATCH_KEY1
                and fgl_hier.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_HIERARCHY''
                WHERE fgl_hier.LK_LOOKUP_VALUE3 = :p_fdr_event_class
                AND JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS IN (:p_status,''E'') '
                || p_sql;

        EXECUTE IMMEDIATE v_sql USING p_process_id, p_fdr_event_class, p_epg_id, p_status;

        IF p_UseHeaders THEN

             v_sql := 'UPDATE SLR_JRNL_HEADERS_UNPOSTED'
                        ||' SET    JHU_JRNL_STATUS = ''E'','
                        ||'        JHU_AMENDED_BY = :id,'
                        ||'        JHU_AMENDED_ON = SYSDATE,'
                        ||'        JHU_JRNL_PROCESS_ID = :process_id'
                        ||' WHERE   (JHU_JRNL_ID) IN
                (
                    SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED

                    join fdr.fr_general_lookup fgl_hier on JLU_ATTRIBUTE_4 = fgl_hier.LK_MATCH_KEY1
                    and fgl_hier.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_HIERARCHY''
                WHERE fgl_hier.LK_LOOKUP_VALUE3 = :p_fdr_event_class
                    AND JLU_EPG_ID = :p_epg_id
                    AND JLU_JRNL_STATUS = :p_status '
                        || p_sql || '
                )';

            EXECUTE IMMEDIATE v_sql USING USER,p_process_id, p_fdr_event_class, p_epg_id, p_status ;
        END IF;

        v_sql := 'UPDATE slr_jrnl_lines_unposted
            SET JLU_JRNL_STATUS = ''E'',
            JLU_JRNL_STATUS_TEXT = :status_text,
            JLU_AMENDED_BY = :id,
            JLU_AMENDED_ON = SYSDATE,
            JLU_JRNL_PROCESS_ID = :process_id
            WHERE JLU_JRNL_HDR_ID IN
            (
                SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                    join fdr.fr_general_lookup fgl_hier on JLU_ATTRIBUTE_4 = fgl_hier.LK_MATCH_KEY1
                    and fgl_hier.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_HIERARCHY''
                WHERE fgl_hier.LK_LOOKUP_VALUE3 = :p_fdr_event_class
               AND JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS = :p_status '
                    || p_sql || '
            )
         AND JLU_EPG_ID = :p_epg_id
         AND JLU_JRNL_STATUS = :p_status';

        EXECUTE IMMEDIATE v_sql USING p_status_text, USER,p_process_id, p_fdr_event_class, p_epg_id, p_status, p_epg_id, p_status;

        gErrorsNumber:=NVL(gErrorsNumber, 0) + SQL%ROWCOUNT;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINE_ERRORS',
                'Failure to write errors to log and unposted journals for process id ['||p_process_id||'] ',
                p_process_id,p_fdr_event_class, p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Failure to write errors to log and unposted journals for process id ['||p_process_id||'] ');
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pWriteLineError: ' || SQLERRM);

    END pWriteLineErrorEventClass;

/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
    --------------------------------------------------------------------------------

    -- ---------------------------------------------------------------------------
    -- Procedure:    pWriteLogError
    -- Description:  Private version of procedure which wraps a call to the error
    --               log in order to write common params to it.
    -- Author:       Tony Watton
    -- ---------------------------------------------------------------------------
    PROCEDURE pWriteLogError
    (
        p_proc_name   in  VARCHAR2,
        p_table_name  in  VARCHAR2,
        p_msg         in  VARCHAR2
    )
    IS
    BEGIN
        pWriteLogError(p_proc_name, p_table_name, p_msg, gProcessId, gJournalEntity, gJournalEpgId, gJournalStatus);
    END pWriteLogError;

    -- ---------------------------------------------------------------------------
    -- Procedure:    pWriteLogError
    -- Description:  Public version of procedure which wraps a call to the error
    --               log in order to write common params to it.
    -- Note:         pr_error is an autonomous transaction to permit error logging
    --               while rolling back other updates.
    -- Author:       Tony Watton
    -- ---------------------------------------------------------------------------
     PROCEDURE pWriteLogError
    (
        p_proc_name     in  VARCHAR2,
        p_table_name    in  VARCHAR2,
        p_msg           in  VARCHAR2,
        p_process_id    in  SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
        p_epg_id        IN  SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status        IN  CHAR := 'U',
        p_entity        IN  slr_entities.ent_entity%TYPE:=NULL
    )
    IS
    BEGIN
        IF SQLCODE != 0 THEN
            pr_error(2, p_msg||'. '||SQLERRM, 0, p_proc_name, p_table_name, p_process_id, 'Process Id', gs_stage, 'PL/SQL', SQLCODE);
        ELSE
            pr_error(2, p_msg, 0, p_proc_name, p_table_name, p_process_id, 'Process Id', gs_stage, 'PL/SQL');
        END IF;

        IF p_process_id != 0 AND p_process_id IS NOT NULL THEN
            pSetJournalToError(p_process_id, 'Error',p_epg_id, p_entity ,p_status);
        END IF;

    END pWriteLogError;

    -- ---------------------------------------------------------------------------
    -- Procedure:    pSetJournalToError
    -- Description:  Generic procedure to set all journals for a given process
    --               id to error.
    -- Author:       Tony Watton
    -- ---------------------------------------------------------------------------
    PROCEDURE pSetJournalToError
    (
        p_process_id   in SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
        p_status_text  in SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_STATUS_TEXT%TYPE,
        p_epg_id       IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_entity       IN slr_entities.ent_entity%TYPE:=NULL,
        p_status       IN CHAR := 'U'
    )
    IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_sql           VARCHAR2(4000);

    v_msg            SLR_JRNL_LINE_ERRORS.JLE_ERROR_STRING%TYPE;
    s_proc_name      VARCHAR2(80) := 'SLR_VALIDATE_JOURNALS_PKG.pSetJournalToError';
    s_UpdatedBy      SLR_ENTITIES.ENT_CREATED_BY%TYPE := USER;
    d_WhenUpdated    SLR_ENTITIES.ENT_CREATED_ON%TYPE := SYSDATE;
	v_tab_partition  prc_object_state_in_process.tab_partition%TYPE;
	v_sub_partion    prc_object_state_in_process.sub_partition%TYPE;
    BEGIN
	 IF P_EPG_ID IS NOT NULL THEN 
	    v_tab_partition :=  'P'||p_epg_id;
	    v_sub_partion   :=  'P'||p_epg_id||'_SE';
     END IF;	  
    --dbms_output.put_line('--> pSetJournalToError');
      gv_table_name := 'SLR_JRNL_LINES_UNPOSTED';
      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_uposted',
                                p_process_id    => p_process_id,
                                p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
                                p_object_name   => 'SLR_JRNL_LINES_UNPOSTED',
                                p_tab_partition => v_tab_partition,
                                p_sub_partition   => v_sub_partion,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_header',
                                p_process_id    => p_process_id,
								p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
                                p_object_name   => 'SLR_JRNL_HEADERS_UNPOSTED',
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_start_dt      => sysdate,
                                p_status        => 'P');
    
      IF gUser IS NOT NULL THEN
          s_UpdatedBy := gUser;
      END IF;
      IF gWhen IS NOT NULL THEN
          d_WhenUpdated := gWhen;
      END IF;

     IF p_entity IS NULL THEN
	      ---quick fix for Issue #10954
                -- old logic for GUI screens compatibility
                gv_table_name := 'SLR_JRNL_HEADERS_UNPOSTED';

                UPDATE 	SLR_JRNL_HEADERS_UNPOSTED
                SET    	JHU_JRNL_STATUS = 'E',
                        JHU_AMENDED_BY = s_UpdatedBy,
                        JHU_AMENDED_ON = d_WhenUpdated
                WHERE  	(JHU_JRNL_ID) IN
                    (
                        SELECT JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                        WHERE JLU_EPG_ID = p_epg_id
                        AND JLU_JRNL_STATUS = p_status );


		  UPDATE 	SLR_JRNL_LINES_UNPOSTED
        	SET    	JLU_JRNL_STATUS = 'E',
               		JLU_JRNL_STATUS_TEXT = p_status_text,
               		JLU_AMENDED_BY = s_UpdatedBy,
            	   	JLU_AMENDED_ON = d_WhenUpdated
        	  WHERE JLU_JRNL_HDR_ID IN
            (
                SELECT JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                WHERE JLU_EPG_ID = p_epg_id
				AND JLU_JRNL_STATUS = p_status
            )
		 AND JLU_EPG_ID = p_epg_id
		 AND JLU_JRNL_STATUS = p_status;
		 COMMIT;

    end if;
    IF p_entity IS NOT NULL THEN
       ---quick fix for Issue #10954
                    -- old logic for GUI screens compatibility
                    gv_table_name := 'SLR_JRNL_HEADERS_UNPOSTED';

                    UPDATE 	SLR_JRNL_HEADERS_UNPOSTED
                    SET    	JHU_JRNL_STATUS = 'E',
                            JHU_AMENDED_BY = s_UpdatedBy,
                            JHU_AMENDED_ON = d_WhenUpdated
                    WHERE  	(JHU_JRNL_ID) IN
                        (
                            SELECT JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                            WHERE JLU_ENTITY = p_entity
                            AND JLU_EPG_ID = p_epg_id
                            AND JLU_JRNL_STATUS = p_status );

	 UPDATE 	SLR_JRNL_LINES_UNPOSTED
        	SET    	JLU_JRNL_STATUS = 'E',
               		JLU_JRNL_STATUS_TEXT = p_status_text,
               		JLU_AMENDED_BY = s_UpdatedBy,
            	   	JLU_AMENDED_ON = d_WhenUpdated
        	  WHERE JLU_JRNL_HDR_ID IN
            (
                SELECT JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                WHERE JLU_ENTITY = p_entity
                AND JLU_EPG_ID = p_epg_id
				AND JLU_JRNL_STATUS = p_status
            )
		 AND JLU_EPG_ID = p_epg_id
		 AND JLU_JRNL_STATUS = p_status;

    END IF;

        COMMIT;


        --dbms_output.put_line('<-- pSetJournalToError');
    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         => LOWER(s_proc_name)||'_uposted',
                                        p_process_id    => p_process_id);
    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         => LOWER(s_proc_name)||'_header',
                                        p_process_id    => p_process_id);
    EXCEPTION
        WHEN OTHERS THEN
            pr_error(2, 'Failure to set journal to error for process id ['||gProcessIdStr||']: '||SQLERRM,
                0, s_proc_name, gv_table_name, gProcessId, 'Process Id', gs_stage, 'PL/SQL', SQLCODE);
            SLR_ADMIN_PKG.Error('Failure to set journal to error for process id ['||gProcessIdStr||']: '||SQLERRM);

    END pSetJournalToError;
    -- -----------------------------------------------------------------------
    -- Procedure:   pCheckJournalStatus
    -- Description: Check unposted journal table for unposted journals that
    --              are not manual adjustments.
    -- Author:      Steve Chan
    -- -----------------------------------------------------------------------
    PROCEDURE pCheckJournalStatus (p_jrnl_type IN SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_TYPE%TYPE := 'MADJ')
    IS

    v_count       NUMBER := 0;
    v_msg         VARCHAR2(1000);
    v_sql         VARCHAR2(4000);
    s_proc_name   VARCHAR2(80) := 'SLR_VALIDATE_JOURNALS.pCheckJournalStatus';
    e_jrnl_errors EXCEPTION;

    BEGIN
        SELECT count(1)
        INTO   v_count
        FROM   SLR_JRNL_LINES_UNPOSTED hdr, SLR_ENTITIES ent
        WHERE  hdr.JLU_ENTITY = ent.ENT_ENTITY
        AND    hdr.JLU_JRNL_STATUS in ('E','V', 'v', 'U', 'u')
        AND    hdr.JLU_JRNL_TYPE not like p_jrnl_type||'%'         -- manual adjustments
        AND    hdr.JLU_EFFECTIVE_DATE >= ent.ENT_BUSINESS_DATE
        AND    rownum = 1;

        IF v_count > 0 THEN
            RAISE e_jrnl_errors;
        END IF;

    EXCEPTION
        WHEN e_jrnl_errors THEN
            v_msg := 'There are ' || to_char(v_count) || ' unposted journal headers.';
            pr_error(2, v_msg, 0, s_proc_name, 'SLR_JRNL_HEADERS_UNPOSTED', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
            -- Fatal so quit
            RAISE_APPLICATION_ERROR(-20001, v_msg);

    WHEN OTHERS THEN
            v_msg := 'Failure to check journal errors: '||sqlerrm;
            pr_error(2, v_msg, 0, s_proc_name, 'SLR_JRNL_HEADERS_UNPOSTED', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
            -- Fatal so quit
            RAISE_APPLICATION_ERROR(-20001, v_msg);

    END pCheckJournalStatus;


    PROCEDURE pValidateSegmentDiff
    (
        p_process_id IN NUMBER,
        p_seg_no IN NUMBER,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE
    )
    AS
        s_proc_name CONSTANT VARCHAR2(65) := 'SLR_VALIDATE_JOURNALS_PKG.pValidateSegmentDiff';
        lv_sql VARCHAR2(32000);
        vErrorsNumber NUMBER;
        v_header_ids_sql VARCHAR2(4000);
	
    BEGIN
      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_errors',
                                p_process_id    => p_process_id,
                                p_object_name   => 'SLR_JRNL_LINE_ERRORS',
                                p_epg_id        => p_epg_id,
								p_tab_partition => 'P'||p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_uposted',
                                p_process_id    => p_process_id,
                                p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_LINES_UNPOSTED',
                                p_tab_partition => 'P'||p_epg_id,
                                p_sub_partition   => 'P'||p_epg_id||'_SE',
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_header',
                                p_process_id    => p_process_id,
								p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_HEADERS_UNPOSTED',
                                p_tab_partition => 'P'||p_epg_id,
                                p_start_dt      => sysdate,
                                p_status        => 'P');

        lv_sql := 'INSERT INTO SLR_JRNL_LINE_ERRORS
            (
                JLE_JRNL_PROCESS_ID,
                JLE_JRNL_HDR_ID,
                JLE_JRNL_LINE_NUMBER,
                JLE_ERROR_CODE,
                JLE_ERROR_STRING
            )
            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' :p_process_id,
                JLU_JRNL_HDR_ID,
                JLU_JRNL_LINE_NUMBER,
                99999,
                ''Invalid Segment:'||p_seg_no||'''' -- added for consistency, replaces ''||FD_SEGMENT_'||p_seg_no||'_NAME'
            ||' FROM SLR_JRNL_LINES_UNPOSTED
            INNER JOIN SLR_ENTITIES
                ON JLU_ENTITY = ENT_ENTITY
            INNER JOIN SLR_FAK_DEFINITIONS
                on FD_ENTITY = JLU_ENTITY
            LEFT JOIN SLR_FAK_SEGMENT_'||p_seg_no||' FS
                ON JLU_SEGMENT_'||p_seg_no||' =  FS'||p_seg_no||'_SEGMENT_VALUE
                AND ENT_SEGMENT_'||p_seg_no||'_SET = FS'||p_seg_no||'_ENTITY_SET
                AND FS'||p_seg_no||'_STATUS = ''A''
            WHERE
               FS.ROWID IS NULL
               AND (CASE WHEN (FD_SEGMENT_'||p_seg_no||'_TYPE = ''C'') AND  (JLU_SEGMENT_'||p_seg_no||' != ''NVS'') THEN 1
                         WHEN (FD_SEGMENT_'||p_seg_no||'_TYPE = ''C'')  AND  (JLU_SEGMENT_'||p_seg_no||' = ''NVS'') THEN 0
                         WHEN (FD_SEGMENT_'||p_seg_no||'_TYPE = ''M'')  THEN 1
                    ELSE 0
                    END) = 1
                AND JLU_JRNL_STATUS IN (:p_status,''E'')
                AND JLU_EPG_ID = :p_epg_id';

        EXECUTE IMMEDIATE lv_sql USING p_process_id, p_status, p_epg_id;
        IF SQL%ROWCOUNT > 0 THEN
            v_header_ids_sql := '(SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID
                                    FROM SLR_JRNL_LINES_UNPOSTED
                                  INNER JOIN SLR_ENTITIES
                                    ON JLU_ENTITY = ENT_ENTITY
                                  INNER JOIN SLR_FAK_DEFINITIONS
                                    ON FD_ENTITY = JLU_ENTITY
                                  LEFT JOIN SLR_FAK_SEGMENT_'||p_seg_no||' FS
                                    ON JLU_SEGMENT_'||p_seg_no||' =  FS'||p_seg_no||'_SEGMENT_VALUE
                                AND ENT_SEGMENT_'||p_seg_no||'_SET = FS'||p_seg_no||'_ENTITY_SET
                                AND FS'||p_seg_no||'_STATUS = ''A''
                                  WHERE
                                  FS.ROWID IS NULL
                                  AND (CASE WHEN (FD_SEGMENT_'||p_seg_no||'_TYPE = ''C'') AND  (JLU_SEGMENT_'||p_seg_no||' != ''NVS'') THEN 1
                                          WHEN (FD_SEGMENT_'||p_seg_no||'_TYPE = ''C'')  AND  (JLU_SEGMENT_'||p_seg_no||' = ''NVS'') THEN 0
                                          WHEN (FD_SEGMENT_'||p_seg_no||'_TYPE = ''M'')  THEN 1
                                          ELSE 0
                                        END) = 1
                                AND JLU_JRNL_STATUS = :p_status
                                AND JLU_EPG_ID = :p_epg_id)';

            EXECUTE IMMEDIATE 'SELECT count(distinct JLU_JRNL_HDR_ID) FROM ' || v_header_ids_sql INTO vErrorsNumber USING p_status, p_epg_id;
            gErrorsNumber := NVL(gErrorsNumber, 0) + vErrorsNumber;

            IF p_UseHeaders THEN
                lv_sql := ' UPDATE SLR_JRNL_HEADERS_UNPOSTED'
                                ||' SET JHU_JRNL_STATUS  =   ''E'','
                                    ||' JHU_AMENDED_BY   =  USER,'
                                    ||' JHU_AMENDED_ON   =  SYSDATE,'
									||' JHU_JRNL_PROCESS_ID   =  :p_process_id'
                              ||' WHERE (JHU_JRNL_ID) IN

                                :HeaderIds
                              ';
                SLR_ADMIN_PKG.Debug('Update headers query', lv_sql);
                EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_process_id, p_status, p_epg_id;
            END IF;

            lv_sql := '
                UPDATE SLR_JRNL_LINES_UNPOSTED
                SET JLU_JRNL_STATUS = ''E'',
                JLU_AMENDED_BY = USER,
                JLU_AMENDED_ON = SYSDATE,
                JLU_JRNL_PROCESS_ID = :p_process_id,
                JLU_JRNL_STATUS_TEXT = ''Invalid Segment:'||p_seg_no||'''
                WHERE JLU_JRNL_HDR_ID IN
                :HeaderIds';

            SLR_ADMIN_PKG.Debug('Update lines query', lv_sql);
            EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_process_id, p_status, p_epg_id;
        END IF;
        COMMIT;
 
	
       pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                           p_stage         => LOWER(s_proc_name)||'_errors',
                                           p_process_id    => p_process_id);
       pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                           p_stage         => LOWER(s_proc_name)||'_uposted',
                                           p_process_id    => p_process_id);
       pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                           p_stage         => LOWER(s_proc_name)||'_header',
                                           p_process_id    => p_process_id);

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            pWriteLogError(s_proc_name, 'SLR_FAK_SEGMENT_'||p_seg_no,
                'Error during validating segment ' || p_seg_no || ': ' || SQLERRM, p_process_id,p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Error during validating segment ' || p_seg_no || ': ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop execution

    END pValidateSegmentDiff;



   PROCEDURE pValidateSegment
    (
      p_process_id IN NUMBER,
      p_seg_no IN NUMBER,
      p_seg_type IN VARCHAR2,
      p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_status IN CHAR := 'U',
      p_UseHeaders IN BOOLEAN := FALSE
    ) IS
      s_proc_name CONSTANT VARCHAR2(65) := 'SLR_VALIDATE_JOURNALS_PKG.pValidateSegment';
      lv_sql VARCHAR2(32000);
      vErrorsNumber NUMBER;
      v_header_ids_sql VARCHAR2(4000);
	  
    BEGIN

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_errors',
                                p_process_id    => p_process_id,
                                p_object_name   => 'SLR_JRNL_LINE_ERRORS',
                                p_epg_id        => p_epg_id,
								p_tab_partition => 'P'||p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_uposted',
                                p_process_id    => p_process_id,
                                p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_LINES_UNPOSTED',
                                p_tab_partition => 'P'||p_epg_id,
                                p_sub_partition   => 'P'||p_epg_id||'_SE',
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_header',
                                p_process_id    => p_process_id,
                                p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_HEADERS_UNPOSTED',
                                p_start_dt      => sysdate,
                                p_status        => 'P');

            lv_sql := 'INSERT INTO SLR_JRNL_LINE_ERRORS
        (
          JLE_JRNL_PROCESS_ID,
          JLE_JRNL_HDR_ID,
          JLE_JRNL_LINE_NUMBER,
          JLE_ERROR_CODE,
          JLE_ERROR_STRING
        )
          SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' :p_process_id,
          JLU_JRNL_HDR_ID,
          JLU_JRNL_LINE_NUMBER,
          99999,
          ''Invalid Segment:'||p_seg_no||'''' -- added for consistency, replaces ''||FD_SEGMENT_'||p_seg_no||'_NAME'
          ||' FROM SLR_JRNL_LINES_UNPOSTED
          INNER JOIN SLR_ENTITIES 
            ON JLU_ENTITY = ENT_ENTITY
          LEFT JOIN SLR_FAK_SEGMENT_'||p_seg_no||' FS
            ON JLU_SEGMENT_'||p_seg_no||' =  FS'||p_seg_no||'_SEGMENT_VALUE
            AND ENT_SEGMENT_'||p_seg_no||'_SET = FS'||p_seg_no||'_ENTITY_SET
            AND FS'||p_seg_no||'_STATUS = ''A''
          WHERE 
            FS.ROWID IS NULL
            AND JLU_JRNL_STATUS IN (:p_status,''E'')
            AND JLU_EPG_ID = :p_epg_id ';

        IF p_seg_type = 'C' THEN  -- Conditional segment: only validate when not NVS (TTP91/TTP143).
          lv_sql := lv_sql || ' AND JLU_SEGMENT_'||p_seg_no||' != ''NVS''';
        END IF;

        SLR_ADMIN_PKG.Debug('Validation. Segment: '||p_seg_no || ' validated.', lv_sql);
        EXECUTE IMMEDIATE lv_sql USING p_process_id, p_status, p_epg_id;

        IF SQL%ROWCOUNT > 0 THEN
          v_header_ids_sql := '( SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID
                FROM SLR_JRNL_LINES_UNPOSTED
                INNER JOIN SLR_ENTITIES
                  ON JLU_ENTITY = ENT_ENTITY
                LEFT JOIN SLR_FAK_SEGMENT_'||p_seg_no||' FS
                  ON JLU_SEGMENT_'||p_seg_no||' =  FS'||p_seg_no||'_SEGMENT_VALUE
                  AND ENT_SEGMENT_'||p_seg_no||'_SET = FS'||p_seg_no||'_ENTITY_SET
                  AND FS'||p_seg_no||'_STATUS = ''A''
                WHERE
                  FS.ROWID IS NULL
                  AND JLU_JRNL_STATUS  = :p_status
                  AND JLU_EPG_ID = :p_epg_id ';

          IF p_seg_type = 'C' THEN  -- Conditional segment: only validate when not NVS (TTP91/TTP143).
            v_header_ids_sql := v_header_ids_sql || ' AND JLU_SEGMENT_'||p_seg_no||' != ''NVS'')';
          ELSE
            v_header_ids_sql := v_header_ids_sql || ')';
          END IF;

          EXECUTE IMMEDIATE 'SELECT count(distinct JLU_JRNL_HDR_ID) FROM ' || v_header_ids_sql INTO vErrorsNumber USING p_status, p_epg_id;
          gErrorsNumber := NVL(gErrorsNumber, 0) + vErrorsNumber;

          IF p_UseHeaders THEN
              lv_sql := ' UPDATE SLR_JRNL_HEADERS_UNPOSTED
              SET JHU_JRNL_STATUS  =   ''E'',
                  JHU_AMENDED_BY   =  USER,
                  JHU_AMENDED_ON   =  SYSDATE,
                  JHU_JRNL_PROCESS_ID   =  :p_process_id
              WHERE (JHU_JRNL_ID) IN
                  :HeaderIds';

             SLR_ADMIN_PKG.Debug('Update headers query', lv_sql);
             EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_process_id, p_status, p_epg_id;
          END IF;

          lv_sql := '
            UPDATE SLR_JRNL_LINES_UNPOSTED
              SET JLU_JRNL_STATUS = ''E'',
              JLU_AMENDED_BY = USER,
              JLU_AMENDED_ON = SYSDATE,
              JLU_JRNL_PROCESS_ID = :p_process_id,
              JLU_JRNL_STATUS_TEXT = ''Invalid Segment:'||p_seg_no||'''
            WHERE JLU_JRNL_HDR_ID IN
            :HeaderIds
            AND JLU_EPG_ID = :p_epg_id AND JLU_JRNL_STATUS = :p_status';

          SLR_ADMIN_PKG.Debug('Update lines query', lv_sql);
          EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_process_id, p_status, p_epg_id,  p_epg_id, p_status;
        END IF;

        COMMIT;

       pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                            p_stage         => LOWER(s_proc_name)||'_errors',
                                            p_process_id    => p_process_id);
       pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                            p_stage         => LOWER(s_proc_name)||'_uposted',
                                            p_process_id    => p_process_id);
       pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                            p_stage         => LOWER(s_proc_name)||'_header',
                                            p_process_id    => p_process_id);

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            pWriteLogError(s_proc_name, '', 'Error during validating segments ' || p_seg_no || ': ' || SQLERRM, p_process_id,p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Error during validating segment ' || p_seg_no || ': ' || SQLERRM, dbms_utility.format_error_backtrace);
            RAISE e_internal_processing_error; -- raised to stop execution

    END pValidateSegment;


  PROCEDURE pValidateBalanceDiff
    (
        p_process_id IN NUMBER,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE
    )
    AS
        s_proc_name CONSTANT VARCHAR2(65) := 'SLR_VALIDATE_JOURNALS_PKG.pValidateBalanceDiff';
        lv_sql VARCHAR2(32000);
		v_header_ids_sql VARCHAR2(4000);
    	vErrorsNumber NUMBER;

    TYPE cur_type IS REF CURSOR;
    cValidateRows cur_type;
    v_jlu_entity SLR.SLR_FAK_DEFINITIONS.FD_ENTITY%TYPE;
    v_SEGMENT_1_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_1_BALANCE_CHECK%TYPE;
    v_SEGMENT_2_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_2_BALANCE_CHECK%TYPE;
    v_SEGMENT_3_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_3_BALANCE_CHECK%TYPE;
    v_SEGMENT_4_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_4_BALANCE_CHECK%TYPE;
    v_SEGMENT_5_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_5_BALANCE_CHECK%TYPE;
    v_SEGMENT_6_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_6_BALANCE_CHECK%TYPE;
    v_SEGMENT_7_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_7_BALANCE_CHECK%TYPE;
    v_SEGMENT_8_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_8_BALANCE_CHECK%TYPE;
    v_SEGMENT_9_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_9_BALANCE_CHECK%TYPE;
    v_SEGMENT_10_BALANCE_CHECK SLR_FAK_DEFINITIONS.FD_SEGMENT_10_BALANCE_CHECK%TYPE;
    v_Rank integer;
    v_curr_rank integer := 1;
    v_GROUP_ENTITY VARCHAR2(32000) := '';
    v_GROUP_SEGMENT VARCHAR2(5000) := '';
    v_GROUP_FLAG boolean := FALSE;
    v_CURR  VARCHAR2(1) := 0;

BEGIN
      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_errors',
                                p_process_id    => p_process_id,
								p_epg_id        => p_epg_id,
								p_tab_partition => 'P'||p_epg_id,
                                p_object_name   => 'SLR_JRNL_LINE_ERRORS',
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_uposted',
                                p_process_id    => p_process_id,
                                p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_LINES_UNPOSTED',
                                p_tab_partition => 'P'||p_epg_id,
                                p_sub_partition   => 'P'||p_epg_id||'_SE',
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_header',
                                p_process_id    => p_process_id,
								p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_HEADERS_UNPOSTED',
                                p_start_dt      => sysdate,
                                p_status        => 'P');

lv_sql := '
        SELECT
        DISTINCT
           FD_ENTITY, FD_SEGMENT_1_BALANCE_CHECK,FD_SEGMENT_2_BALANCE_CHECK, FD_SEGMENT_3_BALANCE_CHECK,FD_SEGMENT_4_BALANCE_CHECK,FD_SEGMENT_5_BALANCE_CHECK, FD_SEGMENT_6_BALANCE_CHECK,FD_SEGMENT_7_BALANCE_CHECK,FD_SEGMENT_8_BALANCE_CHECK,FD_SEGMENT_9_BALANCE_CHECK,FD_SEGMENT_10_BALANCE_CHECK,
           DENSE_RANK() OVER (order by FD_SEGMENT_1_BALANCE_CHECK,FD_SEGMENT_2_BALANCE_CHECK, FD_SEGMENT_3_BALANCE_CHECK,FD_SEGMENT_4_BALANCE_CHECK,FD_SEGMENT_5_BALANCE_CHECK, FD_SEGMENT_6_BALANCE_CHECK,FD_SEGMENT_7_BALANCE_CHECK,FD_SEGMENT_8_BALANCE_CHECK,FD_SEGMENT_9_BALANCE_CHECK,FD_SEGMENT_10_BALANCE_CHECK) AS RV_RANK
        FROM SLR_FAK_DEFINITIONS
		INNER JOIN SLR_ENTITY_PROC_GROUP
		ON EPG_ENTITY = FD_ENTITY
		WHERE EPG_ID = ''' || p_epg_id || '''
		ORDER BY RV_RANK
    ';

        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_entity, v_SEGMENT_1_BALANCE_CHECK, v_SEGMENT_2_BALANCE_CHECK, v_SEGMENT_3_BALANCE_CHECK, v_SEGMENT_4_BALANCE_CHECK, v_SEGMENT_5_BALANCE_CHECK, v_SEGMENT_6_BALANCE_CHECK, v_SEGMENT_7_BALANCE_CHECK, v_SEGMENT_8_BALANCE_CHECK, v_SEGMENT_9_BALANCE_CHECK, v_SEGMENT_10_BALANCE_CHECK, v_Rank;
            EXIT WHEN cValidateRows%NOTFOUND;
            v_CURR := 1;

            IF (v_Rank <> v_curr_rank) then
            v_curr_rank := v_Rank;
            v_GROUP_ENTITY := TRIM(LEADING ',' FROM v_GROUP_ENTITY);
            lv_sql := 'INSERT INTO SLR_JRNL_LINE_ERRORS
                (
                    JLE_JRNL_PROCESS_ID,
                    JLE_JRNL_HDR_ID,
                    JLE_JRNL_LINE_NUMBER,
                    JLE_ERROR_CODE,
                    JLE_ERROR_STRING
                )
                SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' DISTINCT
                    :process_id,
                    JLU_JRNL_HDR_ID,
                    0,
                    99999,
                    ''Journal does not balance ''||TO_CHAR(SUM(JLU_TRAN_AMOUNT))
                FROM SLR_JRNL_LINES_UNPOSTED
                WHERE JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                AND JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS IN (''U'',''E'')
                GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE ' || v_GROUP_SEGMENT || ', JLU_TRAN_CCY
                HAVING SUM(JLU_TRAN_AMOUNT) != 0';


			EXECUTE IMMEDIATE lv_sql USING p_process_id, p_epg_id;
              IF SQL%ROWCOUNT > 0 THEN
              
                v_header_ids_sql := '(  SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' DISTINCT    JLU_JRNL_HDR_ID
                                        FROM SLR_JRNL_LINES_UNPOSTED
                                        WHERE
                                        JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                        AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                                        GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE ' || v_GROUP_SEGMENT || ', JLU_TRAN_CCY
                                        HAVING SUM(JLU_TRAN_AMOUNT) != 0)';

                EXECUTE IMMEDIATE 'SELECT count(JLU_JRNL_HDR_ID) FROM ' || v_header_ids_sql INTO vErrorsNumber USING p_epg_id, p_status;
                gErrorsNumber := NVL(gErrorsNumber, 0) + vErrorsNumber;
                                        
                IF p_UseHeaders = TRUE THEN
                    -- old logic for GUI screens compatibility
                        lv_sql :=    'UPDATE SLR_JRNL_HEADERS_UNPOSTED
                                    SET JHU_JRNL_STATUS  =   ''E'',
                                    JHU_AMENDED_BY   =  USER,
                                    JHU_AMENDED_ON   =  SYSDATE
                                    WHERE (JHU_JRNL_ID) IN
                                    :HeaderIds';
                    SLR_ADMIN_PKG.Debug('Update headers query', lv_sql);
                    EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_epg_id, p_status;
                END IF;

                lv_sql := 'update SLR_JRNL_LINES_UNPOSTED
                    SET JLU_JRNL_STATUS = ''E'',
                        JLU_JRNL_STATUS_TEXT = ''Balance'',
                        JLU_AMENDED_BY = USER,
                        JLU_AMENDED_ON = SYSDATE,
                        JLU_JRNL_PROCESS_ID = :process_id
                    where JLU_JRNL_HDR_ID IN
                        :HeaderIds
						AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                        AND JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status ';

                SLR_ADMIN_PKG.Debug('Update lines query', lv_sql);
                EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_process_id, p_epg_id, p_status, p_epg_id, p_status;

                COMMIT;
            END IF;

          v_GROUP_SEGMENT := '';
          v_GROUP_ENTITY := '';
          v_GROUP_FLAG := FALSE;
        END IF;

         IF (NOT v_GROUP_FLAG) then

                IF v_SEGMENT_1_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_1';
                END IF;

                IF v_SEGMENT_2_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_2';
                END IF;

               IF v_SEGMENT_3_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_3';
                END IF;

               IF v_SEGMENT_4_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_4';
                END IF;

               IF v_SEGMENT_5_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_5';
                END IF;

               IF v_SEGMENT_6_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_6';
                END IF;

               IF v_SEGMENT_7_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_7';
                END IF;

                IF v_SEGMENT_8_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_8';
                END IF;

               IF v_SEGMENT_9_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_9';
               END IF;

               IF v_SEGMENT_10_BALANCE_CHECK  = 'Y' then
               v_GROUP_SEGMENT :=v_GROUP_SEGMENT ||  ', JLU_SEGMENT_10';
               END IF;

            v_GROUP_FLAG := TRUE;
            END IF;

            v_GROUP_ENTITY := v_GROUP_ENTITY ||',''' || v_jlu_entity || '''';
        END LOOP;
        CLOSE cValidateRows;


    IF (v_CURR = 1) THEN
    v_GROUP_ENTITY := TRIM(LEADING ',' FROM v_GROUP_ENTITY);
    lv_sql := 'INSERT INTO SLR_JRNL_LINE_ERRORS
                (
                    JLE_JRNL_PROCESS_ID,
                    JLE_JRNL_HDR_ID,
                    JLE_JRNL_LINE_NUMBER,
                    JLE_ERROR_CODE,
                    JLE_ERROR_STRING
                )
                SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' DISTINCT
                   :process_id,
                    JLU_JRNL_HDR_ID,
                    0,
                    99999,
                    ''Journal does not balance ''||TO_CHAR(SUM(JLU_TRAN_AMOUNT))
                FROM SLR_JRNL_LINES_UNPOSTED
                WHERE JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                AND JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS IN (''U'',''E'')
                GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE ' || v_GROUP_SEGMENT || ', JLU_TRAN_CCY
                HAVING SUM(JLU_TRAN_AMOUNT) != 0';
            EXECUTE IMMEDIATE lv_sql USING p_process_id, p_epg_id;

			IF SQL%ROWCOUNT > 0 THEN

                v_header_ids_sql := '(  SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' DISTINCT JLU_JRNL_HDR_ID
                                        FROM SLR_JRNL_LINES_UNPOSTED
                                        WHERE
                                        JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                        AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                                        GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE ' || v_GROUP_SEGMENT || ', JLU_TRAN_CCY
                                        HAVING SUM(JLU_TRAN_AMOUNT) != 0)';

                EXECUTE IMMEDIATE 'SELECT count(JLU_JRNL_HDR_ID) FROM ' || v_header_ids_sql INTO vErrorsNumber USING p_epg_id, p_status;
                gErrorsNumber := NVL(gErrorsNumber, 0) + vErrorsNumber;

                IF p_UseHeaders = TRUE THEN
                    -- old logic for GUI screens compatibility

                        lv_sql :=  'UPDATE SLR_JRNL_HEADERS_UNPOSTED
                                    SET JHU_JRNL_STATUS  =   ''E'',
                                    JHU_AMENDED_BY   =  USER,
                                    JHU_AMENDED_ON   =  SYSDATE
                                    WHERE (JHU_JRNL_ID) IN
                                    :HeaderIds';
                    SLR_ADMIN_PKG.Debug('Update headers query', lv_sql);
                    EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_epg_id, p_status;
                END IF;

                lv_sql := 'update SLR_JRNL_LINES_UNPOSTED
                    SET JLU_JRNL_STATUS = ''E'',
                        JLU_JRNL_STATUS_TEXT = ''Balance'',
                        JLU_AMENDED_BY = USER,
                        JLU_AMENDED_ON = SYSDATE,
                        JLU_JRNL_PROCESS_ID = :process_id
                    where JLU_JRNL_HDR_ID IN
                        :HeaderIds
                        AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                        AND JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status ';

                SLR_ADMIN_PKG.Debug('Update lines query', lv_sql);
                EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_process_id, p_epg_id, p_status, p_epg_id, p_status;

                COMMIT;
          END IF;
    END IF;
		SLR_ADMIN_PKG.Debug('Validation. Balances for different configuration - validated.');

    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         => LOWER(s_proc_name)||'_errors',
                                        p_process_id    => p_process_id);
    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         => LOWER(s_proc_name)||'_uposted',
                                        p_process_id    => p_process_id);
    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         => LOWER(s_proc_name)||'_header',
                                        p_process_id    => p_process_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED',
                'Error during validating balances: ' || SQLERRM, p_process_id,p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Error during validating balances: ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop execution
    END pValidateBalanceDiff;


   PROCEDURE pValidateBalance
    (
        p_process_id IN NUMBER,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE,
    lv_sql_group_by IN VARCHAR2

    )
    AS
        s_proc_name CONSTANT VARCHAR2(65) := 'SLR_VALIDATE_JOURNALS_PKG.pValidateBalance';
        lv_sql VARCHAR2(32000);
		 vErrorsNumber NUMBER;
        v_header_ids_sql VARCHAR2(4000);        

    BEGIN
      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_errors',
                                p_process_id    => p_process_id,
								p_epg_id        => p_epg_id,
								p_tab_partition => 'P'||p_epg_id,
                                p_object_name   => 'SLR_JRNL_LINE_ERRORS',
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_uposted',
                                p_process_id    => p_process_id,
                                p_epg_id        => p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_LINES_UNPOSTED',
                                p_tab_partition => 'P'||p_epg_id,
                                p_sub_partition   => 'P'||p_epg_id||'_SE',
                                p_start_dt      => sysdate,
                                p_status        => 'P');

      pg_process_state.log_proc(p_conf_group    => 'SLR',
                                p_stage         => LOWER(s_proc_name)||'_header',
                                p_process_id    => p_process_id,
								p_epg_id        => p_epg_id,
								p_tab_partition => 'P'||p_epg_id,
								p_business_date => slr_post_journals_pkg.gp_business_date,
								p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                                p_object_name   => 'SLR_JRNL_HEADERS_UNPOSTED',
                                p_start_dt      => sysdate,
                                p_status        => 'P');
                        lv_sql := 'INSERT INTO SLR_JRNL_LINE_ERRORS
                (
                    JLE_JRNL_PROCESS_ID,
                    JLE_JRNL_HDR_ID,
                    JLE_JRNL_LINE_NUMBER,
                    JLE_ERROR_CODE,
                    JLE_ERROR_STRING
                )
                SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' DISTINCT
                    :process_id,
                    JLU_JRNL_HDR_ID,
                    0,
                    99999,
                    ''Journal does not balance ''||TO_CHAR(SUM(JLU_TRAN_AMOUNT))
                FROM SLR_JRNL_LINES_UNPOSTED, SLR_ENTITIES
                WHERE JLU_ENTITY = ENT_ENTITY
                AND JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS IN (:p_status,''E'')
                GROUP BY ENT_ENTITY, ' || lv_sql_group_by || '
                HAVING SUM(JLU_TRAN_AMOUNT) != 0';
            EXECUTE IMMEDIATE lv_sql USING p_process_id, p_epg_id, p_status;

            IF SQL%ROWCOUNT > 0 THEN
                v_header_ids_sql := '(  SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' DISTINCT
                                        JLU_JRNL_HDR_ID
                                        FROM SLR_JRNL_LINES_UNPOSTED, SLR_ENTITIES
                                        WHERE
                                        JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                        AND JLU_ENTITY = ENT_ENTITY
                                        GROUP BY ENT_ENTITY, ' || lv_sql_group_by ||
                                        ' HAVING SUM(JLU_TRAN_AMOUNT) != 0)';

                EXECUTE IMMEDIATE 'SELECT count(JLU_JRNL_HDR_ID) FROM ' || v_header_ids_sql INTO vErrorsNumber USING p_epg_id, p_status;
                gErrorsNumber := NVL(gErrorsNumber, 0) + vErrorsNumber;

                IF p_UseHeaders = TRUE THEN
                    -- old logic for GUI screens compatibility

                        lv_sql :=    'UPDATE SLR_JRNL_HEADERS_UNPOSTED
                                    SET JHU_JRNL_STATUS  =   ''E'',
                                    JHU_AMENDED_BY   =  USER,
                                    JHU_AMENDED_ON   =  SYSDATE
                                    WHERE (JHU_JRNL_ID) IN
                                    :HeaderIds';
                    SLR_ADMIN_PKG.Debug('Update headers query', lv_sql);
                    EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_epg_id, p_status;
                END IF;

                lv_sql := 'update SLR_JRNL_LINES_UNPOSTED
                    SET JLU_JRNL_STATUS = ''E'',
                        JLU_JRNL_STATUS_TEXT = ''Balance'',
                        JLU_AMENDED_BY = USER,
                        JLU_AMENDED_ON = SYSDATE,
                        JLU_JRNL_PROCESS_ID = :process_id
                    where JLU_JRNL_HDR_ID IN
                        :HeaderIds
                        AND JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status ';

                SLR_ADMIN_PKG.Debug('Update lines query', lv_sql);
                EXECUTE IMMEDIATE replace(lv_sql, ':HeaderIds', v_header_ids_sql) USING p_process_id, p_epg_id, p_status, p_epg_id, p_status;
                COMMIT;
            END IF;

      SLR_ADMIN_PKG.Debug('Validation. Balances for the same configuration - validated.');
      pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                          p_stage         => LOWER(s_proc_name)||'_errors',
                                          p_process_id    => p_process_id);
      pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                          p_stage         => LOWER(s_proc_name)||'_uposted',
                                          p_process_id    => p_process_id);
      pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                          p_stage         => LOWER(s_proc_name)||'_header',
                                          p_process_id    => p_process_id);
  EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED',
                'Error during validating balances: ' || SQLERRM, p_process_id,p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Error during validating balances: ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop execution
    END pValidateBalance;

--------------------------------------------------------------------------------

    PROCEDURE pValidateFuturePeriod
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_status IN CHAR:= 'U',
        p_UseHeaders IN BOOLEAN := FALSE
    ) IS
      CURSOR cur_missing_future_period IS
        SELECT ent.ent_entity
        FROM slr_entities ent
          JOIN slr_entity_proc_group epg ON ent.ent_entity = epg.epg_entity
          LEFT JOIN slr_entity_periods ep ON ep.ep_entity = ent.ent_entity AND ent.ent_business_date BETWEEN ep.ep_bus_period_start AND ep.ep_bus_period_end AND ep.ep_status = 'O'
          LEFT JOIN slr_entity_periods ep_next ON ep_next.ep_entity = ent.ent_entity and ep_next.ep_status = 'O'
            AND ep_next.ep_bus_period = (
              CASE
                WHEN ep.ep_bus_period >= 12 THEN 1
                ELSE ep.ep_bus_period + 1
              END
            ) AND ep_next.ep_bus_year = (
              CASE
                WHEN ep.ep_bus_period >= 12 THEN ep.ep_bus_year+1
                ELSE ep.ep_bus_year
              END
            )
        WHERE epg.epg_id=p_epg_id
          AND ep_next.ep_bus_period_start IS NULL;

    BEGIN
      FOR rec_missing_future_period IN cur_missing_future_period LOOP
        pWriteLineError(
          rec_missing_future_period.ent_entity, p_process_id, 'Future Period', 'Missing future Period for Entity [' || rec_missing_future_period.ent_entity || '] ',
          ' AND JLU_ENTITY = ''' || rec_missing_future_period.ent_entity || '''', p_epg_id, p_status, p_UseHeaders
        );
      END LOOP;
    END pValidateFuturePeriod;

--------------------------------------------------------------------------------

    PROCEDURE pDeleteLineErrors
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_status IN CHAR
    )
    AS
        s_proc_name CONSTANT VARCHAR2(65) := 'SLR_VALIDATE_JOURNALS_PKG.pDeleteLineErrors';
    BEGIN
        EXECUTE IMMEDIATE '
            DELETE ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'DELETE_LINE_ERRORS') || ' FROM SLR_JRNL_LINE_ERRORS
            WHERE JLE_JRNL_HDR_ID IN
            (
                SELECT JLU_JRNL_HDR_ID
                FROM SLR_JRNL_LINES_UNPOSTED
                WHERE JLU_JRNL_STATUS = ''' || p_status || '''
                AND JLU_EPG_ID = ''' || p_epg_id || '''
            )
        ';

        COMMIT;
        SLR_ADMIN_PKG.Info('Line errors deleted');
    EXCEPTION
        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINE_ERRORS',
                'Error during deleting line errors.', p_process_id,p_epg_id);
            SLR_ADMIN_PKG.Error('Error during deleting line errors: ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop execution
    END pDeleteLineErrors;

--------------------------------------------------------------------------------


 PROCEDURE pUpdateJLUPeriods(pEpgId in slr_jrnl_lines_unposted.jlu_epg_id%type,p_process_id IN NUMBER,p_status IN CHAR)
  AS
    s_proc_name CONSTANT VARCHAR2(65) := 'SLR_VALIDATE_JOURNALS_PKG.pUpdateJLUPeriods';
  begin

      EXECUTE IMMEDIATE  'UPDATE '|| SLR_UTILITIES_PKG.fHint(pEpgId, 'UPDATE_JLU_PERIODS') || '
      (SELECT  JLU_PERIOD_MONTH,
          JLU_PERIOD_YEAR,
          JLU_PERIOD_LTD,
          (select EP_BUS_PERIOD
            from SLR_ENTITY_PERIODS
            where JLU_EFFECTIVE_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
            AND EP_ENTITY = JLU_ENTITY AND EP_PERIOD_TYPE <> 0
          ) EP_BUS_PERIOD,
           (select EP_BUS_YEAR
            from SLR_ENTITY_PERIODS
            where JLU_EFFECTIVE_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
            AND EP_ENTITY = JLU_ENTITY AND EP_PERIOD_TYPE <> 0
          ) EP_BUS_YEAR,
          (select CASE WHEN EA_ACCOUNT_TYPE_FLAG = ''P'' THEN EP_BUS_YEAR ELSE 1 END
            from slr_entities,  slr_entity_accounts, SLR_ENTITY_PERIODS
            where EA_ACCOUNT = JLU_ACCOUNT and  JLU_EFFECTIVE_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
            AND EP_ENTITY = JLU_ENTITY AND EP_PERIOD_TYPE <> 0 AND EA_ENTITY_SET = ENT_ACCOUNTS_SET AND ENT_ENTITY = JLU_ENTITY
          ) EP_BUS_LTD
      FROM slr_jrnl_lines_unposted
         WHERE JLU_EPG_ID = ''' || pEpgId || ''' AND JLU_JRNL_STATUS = ''' || p_status || ''' ) UNPOSTED
      SET UNPOSTED.JLU_PERIOD_MONTH = UNPOSTED.EP_BUS_PERIOD, UNPOSTED.JLU_PERIOD_YEAR = UNPOSTED.EP_BUS_YEAR, UNPOSTED.JLU_PERIOD_LTD = EP_BUS_LTD
      WHERE (JLU_PERIOD_YEAR IS NULL OR JLU_PERIOD_MONTH IS NULL OR JLU_PERIOD_LTD IS NULL)';

    exception
     WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'slr_jrnl_lines_unposted',
                'Error during updating slr_jrnl_lines_unposted.', p_process_id,pEpgId);
            SLR_ADMIN_PKG.Error('Error during updating slr_jrnl_lines_unposted ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop execution

  END pUpdateJLUPeriods;

--------------------------------------------------------------------------------
  PROCEDURE pInsertFakEbaCombinations
  (
      p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_process_id IN NUMBER,
      p_status IN VARCHAR2
  )
  IS
      s_proc_name VARCHAR2(80) := 'SLR_VALIDATE_JOURNLAS_PKG.pInsertFakEbaCombinations';
      lv_START_TIME   PLS_INTEGER := 0;
      lv_sql VARCHAR2(32000);
  BEGIN

    pg_process_state.log_proc(p_conf_group    => 'SLR',
                              p_stage         => s_proc_name||'_fak',
                              p_process_id    => p_process_id,
                              p_object_name   => 'SLR_FAK_COMBINATIONS',
                              p_epg_id        => p_epg_id,
							  p_business_date => slr_post_journals_pkg.gp_business_date,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                              p_tab_partition => 'P'||p_epg_id,
                              p_start_dt      => sysdate,
                              p_status        => 'P');


      lv_sql := '
          INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'MERGE_FAK') || ' INTO SLR_FAK_COMBINATIONS PARTITION FOR ('''||p_epg_id||''')
          (
              FC_EPG_ID,
              FC_ENTITY,
              FC_ACCOUNT,
              FC_CCY,
              FC_SEGMENT_1,
              FC_SEGMENT_2,
              FC_SEGMENT_3,
              FC_SEGMENT_4,
              FC_SEGMENT_5,
              FC_SEGMENT_6,
              FC_SEGMENT_7,
              FC_SEGMENT_8,
              FC_SEGMENT_9,
              FC_SEGMENT_10,
              FC_FAK_ID,
        FC_PROCESS_ID
          )
          WITH ROWS_TO_INSERT AS
          (
              SELECT DISTINCT
                  JLU_EPG_ID,
                  JLU_ENTITY,
                  JLU_ACCOUNT,
                  JLU_TRAN_CCY,
                  JLU_SEGMENT_1,
                  JLU_SEGMENT_2,
                  JLU_SEGMENT_3,
                  JLU_SEGMENT_4,
                  JLU_SEGMENT_5,
                  JLU_SEGMENT_6,
                  JLU_SEGMENT_7,
                  JLU_SEGMENT_8,
                  JLU_SEGMENT_9,
                  JLU_SEGMENT_10,
                  JLU_FAK_ID
              FROM SLR_JRNL_LINES_UNPOSTED SUBPARTITION FOR ('''||p_epg_id||''', '''||p_status||''')
              MINUS
                  SELECT
                      FC_EPG_ID, FC_ENTITY, FC_ACCOUNT, FC_CCY,
                      FC_SEGMENT_1, FC_SEGMENT_2, FC_SEGMENT_3, FC_SEGMENT_4,
                      FC_SEGMENT_5, FC_SEGMENT_6, FC_SEGMENT_7, FC_SEGMENT_8,
                      FC_SEGMENT_9, FC_SEGMENT_10, FC_FAK_ID
                  FROM SLR_FAK_COMBINATIONS
                  WHERE FC_EPG_ID = ''' || p_epg_id || '''
          )
          SELECT
              JLU_EPG_ID,
              JLU_ENTITY,
              JLU_ACCOUNT,
              JLU_TRAN_CCY,
              JLU_SEGMENT_1,
              JLU_SEGMENT_2,
              JLU_SEGMENT_3,
              JLU_SEGMENT_4,
              JLU_SEGMENT_5,
              JLU_SEGMENT_6,
              JLU_SEGMENT_7,
              JLU_SEGMENT_8,
              JLU_SEGMENT_9,
              JLU_SEGMENT_10,
              JLU_FAK_ID,
        '||p_process_id||'
          FROM ROWS_TO_INSERT
      ';
      lv_START_TIME := DBMS_UTILITY.GET_TIME();
      EXECUTE IMMEDIATE lv_sql;
      COMMIT;

    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         =>  s_proc_name||'_fak',
                                        p_process_id    => p_process_id);

    pg_process_state.log_proc(p_conf_group    => 'SLR',
                              p_stage         => s_proc_name||'_eba',
                              p_process_id    => p_process_id,
                              p_object_name   => 'SLR_EBA_COMBINATIONS',
                              p_epg_id        => p_epg_id,
							  p_business_date => slr_post_journals_pkg.gp_business_date,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                              p_tab_partition => 'P'||p_epg_id,
                              p_start_dt      => sysdate,
                              p_status        => 'P');

      SLR_ADMIN_PKG.PerfInfo( 'FAKC. FAK combination query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
      SLR_ADMIN_PKG.Info('New FAK combinations inserted');

      lv_sql := '
          INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'MERGE_EBA') || ' INTO SLR_EBA_COMBINATIONS PARTITION FOR ('''||p_epg_id||''')
          (
              EC_EPG_ID,
              EC_FAK_ID,
              EC_EBA_ID,
              EC_ATTRIBUTE_1,
              EC_ATTRIBUTE_2,
              EC_ATTRIBUTE_3,
              EC_ATTRIBUTE_4,
              EC_ATTRIBUTE_5,
        EC_PROCESS_ID
          )
          WITH ROWS_TO_INSERT AS
          (
              SELECT DISTINCT
                  JLU_EPG_ID,
                  JLU_ATTRIBUTE_1,
                  JLU_ATTRIBUTE_2,
                  JLU_ATTRIBUTE_3,
                  JLU_ATTRIBUTE_4,
                  JLU_ATTRIBUTE_5,
                  JLU_FAK_ID,
                  JLU_EBA_ID
              FROM SLR_JRNL_LINES_UNPOSTED SUBPARTITION FOR (''' || p_epg_id || ''', '''||p_status||''')
              WHERE NOT EXISTS (
                SELECT  ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'MERGE_EBA_EXISTS') || ' 1 FROM SLR_EBA_COMBINATIONS PARTITION FOR (''' || p_epg_id || ''')
                WHERE JLU_EPG_ID = EC_EPG_ID
                    AND JLU_ATTRIBUTE_1 = EC_ATTRIBUTE_1
                    AND JLU_ATTRIBUTE_2 = EC_ATTRIBUTE_2
                    AND JLU_ATTRIBUTE_3 = EC_ATTRIBUTE_3
                    AND JLU_ATTRIBUTE_4 = EC_ATTRIBUTE_4
                    AND JLU_ATTRIBUTE_5 = EC_ATTRIBUTE_5
                    AND EC_FAK_ID = JLU_FAK_ID
              )
          )
          SELECT
            JLU_EPG_ID,
            JLU_FAK_ID,
            JLU_EBA_ID,
            JLU_ATTRIBUTE_1,
            JLU_ATTRIBUTE_2,
            JLU_ATTRIBUTE_3,
            JLU_ATTRIBUTE_4,
            JLU_ATTRIBUTE_5,
      '||p_process_id||'
          FROM ROWS_TO_INSERT
      ';
    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         =>  s_proc_name||'_eba',
                                        p_process_id    => p_process_id);
      lv_START_TIME := DBMS_UTILITY.GET_TIME();
      EXECUTE IMMEDIATE lv_sql;
      COMMIT;
      SLR_ADMIN_PKG.PerfInfo( 'EBAC. EBA combination query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
      SLR_ADMIN_PKG.Info('New EBA combinations inserted');

  EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
          pWriteLogError(s_proc_name, 'SLR_FAK/EBA_COMBINATIONS', 'Error during inserting new combinations to SLR_FAK/EBA_COMBINATIONS', p_process_id, p_epg_id);
          SLR_ADMIN_PKG.Error('Error during inserting new combinations to SLR_FAK/EBA_COMBINATIONS', dbms_utility.format_error_backtrace);
          RAISE e_internal_processing_error; -- raised to stop processing

  END pInsertFakEbaCombinations;

END SLR_VALIDATE_JOURNALS_PKG;
/************************************ End of Package *******************************************/
/

