CREATE OR REPLACE PACKAGE BODY SLR."SLR_VALIDATE_JOURNALS_PKG" AS
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
    gErrorsNumber                NUMBER;

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

PROCEDURE pValidateJournals
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_status IN CHAR := 'U',
    p_UseHeaders IN BOOLEAN := FALSE,
    p_rate_set IN slr_entities.ent_rate_set%TYPE
)
AS
    lv_entity_configuration SLR_ENTITIES%ROWTYPE;
    lv_fak_definition SLR_FAK_DEFINITIONS%ROWTYPE;
    lv_sql VARCHAR2(32000);
    lv_sql_group_by VARCHAR2(500);
    lv_found NUMBER(2);

    v_msg             VARCHAR2(1000);
    s_proc_name       VARCHAR2(50) := 'SLR_VALIDATE_JOURNALS_PKG.pValidateJournals';
    e_bad_status      EXCEPTION;

    v_rev_err_msg varchar2(1500);
    v_ent_business_date                timestamp(6);
    v_ent_next_business_date        timestamp(6);
    v_rev_compare_start_date                 timestamp(6);
    v_rev_compare_end_date                 timestamp(6);
    lvPeriodStartDate                         timestamp(6);
    v_rev_compare_date                 timestamp(6);
    lvPeriodEndDate                         timestamp(6);
    lvPrevBusDate                                 timestamp(6);
    lvNextBusDate                                 timestamp(6);
    lvNextPeriodEndDate                timestamp(6);
    lvNextPeriodStartDate                timestamp(6);
    lvPrevPeriodEndDate                timestamp(6);
    lvPrevPeriodStartDate    timestamp(6);
    v_sqlcode SMALLINT;
    gv_msg                 varchar2(4000);
    val varchar2(60);
    v_epg_validation SMALLINT := 0;

    TYPE cur_type IS REF CURSOR;
    cValidateRows cur_type;
    v_counter INTEGER;
    v_definition varchar2(1000);
    lv_segment varchar2(500);
    lv_allSegments varchar2(1000);
    v_defin varchar2(100);
    v_def BOOLEAN;

BEGIN


    SLR_ADMIN_PKG.InitLog(p_epg_id, p_process_id);
    SLR_ADMIN_PKG.Info('Validation start');

    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';


    pInitializeProcedure(p_epg_id, p_process_id);

    pDeleteLineErrors(p_epg_id, p_process_id, p_status);

    -- EPG validation
    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
            jlu_entity, jlu_epg_id
        FROM
            slr_jrnl_lines_unposted where jlu_epg_id = ''' || p_epg_id || '''

        MINUS

        SELECT
            epg_entity, epg_id
        FROM
            slr_entity_proc_group where epg_id = ''' || p_epg_id || '''
    ';

    DECLARE
        v_jlu_epg_id SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EPG_ID%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_entity, v_jlu_epg_id;
            EXIT WHEN cValidateRows%NOTFOUND;
            v_epg_validation := 1;
            gv_msg := 'Missing entity definition in SLR_ENTITY_PROC_GROUP for epg_id [' || v_jlu_epg_id || '] and entity [' || v_jlu_entity || ']';
            slr.PR_ERROR(1,gv_msg, 1,'pValidateJournals', 'SLR_ENTITY_PROC_GROUP', null, null,null,'PL/SQL', null, null, null, null, null,'', null);
        END LOOP;
        CLOSE cValidateRows;
    END;

    IF(v_epg_validation = 1) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during SLR_ENTITY_PROC_GROUP validation');
    END IF;

    SLR_ADMIN_PKG.Debug('Validation. EPG configuration validated.', lv_sql);

    --FAK DEFINITION validation
    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
            jlu_entity
        FROM
            slr_jrnl_lines_unposted where jlu_epg_id = ''' || p_epg_id || '''

        MINUS

        SELECT
            FD_ENTITY
        FROM
            slr_fak_definitions where fd_entity IN (SELECT epg_entity from slr_entity_proc_group where EPG_ID =  ''' || p_epg_id || ''' )
    ';

    DECLARE
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            v_epg_validation := 1;
            gv_msg := 'Missing entity definition in SLR_FAK_DEFINITIONS for epg_id [' || p_epg_id || '] and entity [' || v_jlu_entity || ']';
            slr.PR_ERROR(1,gv_msg, 1,'pValidateJournals', 'SLR_FAK_DEFINITIONS', null, null,null,'PL/SQL', null, null, null, null, null,'', null);
        END LOOP;
        CLOSE cValidateRows;
    END;

    IF(v_epg_validation = 1) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during SLR_FAK_DEFINITIONS validation');
    END IF;

    SLR_ADMIN_PKG.Debug('Validation.SLR_FAK_DEFINITIONS configuration validated.', lv_sql);



    -- Validation in External types table
    BEGIN
     gv_msg := 'No data found in SLR_EXT_JRNL_TYPES';

     SELECT max(ejt_type) INTO val
    FROM
        slr.SLR_EXT_JRNL_TYPES;

     EXCEPTION
        WHEN OTHERS THEN
        slr.PR_ERROR(1,gv_msg, 1,'pValidateJournals', 'SLR_EXT_JRNL_TYPES', null, null,null,'PL/SQL', null, null, null, null, null,'', null);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during SLR_EXT_JRNL_TYPES validation');
     END;

        SLR_ADMIN_PKG.Debug('Validation. Records in SLR_EXT_JRNL_TYPES exist.');

  -- Move future records ( > Business date) to W partition

        lv_sql:=
        'MERGE
            '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'MERGE_MV_FUT_UNPOST_REC') ||'
        INTO SLR_JRNL_LINES_UNPOSTED JLU
        USING
            (
            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
                SLR_JRNL_LINES_UNPOSTED.ROWID AS REC_ID
                FROM
                SLR_JRNL_LINES_UNPOSTED
            WHERE
                JLU_EPG_ID          = :p_epg_id AND
                JLU_JRNL_STATUS     = ''U''  AND
                JLU_EFFECTIVE_DATE > :p_business_date
          ) JLU1
          ON
          (
              JLU.ROWID = JLU1.REC_ID
          )
          WHEN MATCHED THEN UPDATE SET jlu.JLU_JRNL_STATUS = ''W''';

    EXECUTE IMMEDIATE lv_sql USING p_epg_id,SLR_UTILITIES_PKG.fEntityGroupCurrBusDate(p_epg_id);
    commit;
    SLR_ADMIN_PKG.Debug('Validation. Future records moved.', lv_sql);

  -- Periods
    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
        DISTINCT JLU_EFFECTIVE_DATE, JLU_ENTITY
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_EPG_ID = ''' || p_epg_id || '''
            AND JLU_JRNL_STATUS = ''' || p_status || '''
        AND NOT EXISTS
        (
            SELECT NULL FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = JLU_ENTITY
            AND JLU_EFFECTIVE_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
            AND EP_STATUS = ''O''
        )
    ';
    DECLARE
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
        v_jlu_effective_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO  v_jlu_effective_date, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Period',
                'Invalid Period: [' || v_jlu_effective_date || '] not valid in Period table for Entity [' || v_jlu_entity || '] ',
                ' AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''', p_epg_id, p_status, p_UseHeaders);

        END LOOP;

        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Periods validated.', lv_sql);


  -- Event Class Periods
  
    lv_sql := '
            SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
        DISTINCT JLU_EFFECTIVE_DATE, fgl_hier.LK_LOOKUP_VALUE3
        FROM SLR_JRNL_LINES_UNPOSTED
        join fdr.fr_general_lookup fgl_hier on JLU_ATTRIBUTE_4 = fgl_hier.LK_MATCH_KEY1
             and fgl_hier.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_HIERARCHY''
        WHERE JLU_EPG_ID = ''' || p_epg_id || '''
            AND JLU_JRNL_STATUS = ''' || p_status || '''
        AND NOT EXISTS
        (
            SELECT NULL from fdr.fr_general_lookup fgl_period 
            where fgl_period.LK_LKT_LOOKUP_TYPE_CODE = ''EVENT_CLASS_PERIOD''
            AND FGL_HIER.LK_LOOKUP_VALUE3 = FGL_PERIOD.LK_MATCH_KEY1
            AND JLU_EFFECTIVE_DATE BETWEEN TO_DATE(FGL_PERIOD.LK_LOOKUP_VALUE2,''DD-MON-YYYY'') and TO_DATE(FGL_PERIOD.LK_LOOKUP_VALUE3,''DD-MON-YYYY'') 
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


    --REVERSING DATE
    lv_sql := '
    SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
    DISTINCT
          jlu.JLU_EFFECTIVE_DATE
        , jlu.JLU_JRNL_REV_DATE
        , jlu.JLU_ENTITY
        FROM  SLR_JRNL_LINES_UNPOSTED jlu
            , SLR_ENTITIES ent
            ,slr.SLR_EXT_JRNL_TYPES ext
            ,slr.SLR_JRNL_TYPES typ
        WHERE
        jlu.JLU_EPG_ID = ''' || p_epg_id || '''
        AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
        AND jlu.jlu_jrnl_type = ext.ejt_type
        AND ext.ejt_jt_type = typ.JT_TYPE
        AND jlu.JLU_ENTITY = ent.ENT_ENTITY
        AND typ.jt_reverse_flag = ''Y''
        AND jlu.JLU_JRNL_REV_DATE IS NOT NULL
        AND jlu.JLU_JRNL_REV_DATE <= jlu.JLU_EFFECTIVE_DATE' -- validate Reverse Date
    ;
    DECLARE
        v_jlu_effective_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
        v_jlu_jrnl_rev_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_REV_DATE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_effective_date, v_jlu_jrnl_rev_date, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Rev Date',
                'The Reversing Date: [' || v_jlu_jrnl_rev_date || '] must be greater than the Effective Date: [' || v_jlu_effective_date || '] .',
                ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''   AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || ''' ', p_epg_id, p_status, null);
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Reversing Date < Effective Date - validated.', lv_sql);




  -- Dates
    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
        DISTINCT JLU_EFFECTIVE_DATE, JLU_ENTITY
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_EPG_ID = ''' || p_epg_id || '''
        AND JLU_JRNL_STATUS = ''' || p_status || '''
        AND NOT EXISTS
        (
            SELECT  NULL FROM SLR_ENTITY_DAYS
            WHERE ED_ENTITY_SET = (SELECT ENT_PERIODS_AND_DAYS_SET FROM SLR_ENTITIES WHERE ENT_ENTITY = JLU_ENTITY)
            AND ED_DATE = JLU_EFFECTIVE_DATE
            AND ED_STATUS = ''O''
        )
    ';

    DECLARE
        v_jlu_effective_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_effective_date, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Eff Date',
                'Invalid Effective Date: [' || v_jlu_effective_date || '] not valid in entity days table',
                ' AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''', p_epg_id, p_status, p_UseHeaders);
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Dates validated.', lv_sql);


--Translation date
    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
        DISTINCT
            jlu.JLU_TRANSLATION_DATE
           ,jlu.JLU_ENTITY
        FROM  SLR_JRNL_LINES_UNPOSTED jlu
            , SLR_ENTITIES ent
        WHERE
            jlu.JLU_EPG_ID = ''' || p_epg_id || '''
        AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
        AND jlu.JLU_ENTITY = ent.ENT_ENTITY
        AND jlu.JLU_TRANSLATION_DATE IS NOT NULL
        AND NOT EXISTS
        (
            SELECT 1
            FROM  SLR_ENTITY_DAYS ed
            WHERE
                ed.ED_ENTITY_SET    = ent.ENT_PERIODS_AND_DAYS_SET
            AND ed.ED_DATE          = jlu.JLU_TRANSLATION_DATE
            AND ed.ED_STATUS        = ''O''
        )
    ';

    DECLARE
        v_jlu_translation_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_TRANSLATION_DATE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_translation_date, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Trans Date',
                'Invalid Translation Date: [' || v_jlu_translation_date || '] not valid in entity days table',
                ' AND JLU_TRANSLATION_DATE = ''' || v_jlu_translation_date || '''', p_epg_id, p_status, NULL);
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Translation Dates validated.', lv_sql);

--Value date
    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
        DISTINCT
            jlu.jlu_value_date
           ,jlu.JLU_ENTITY
        FROM  SLR_JRNL_LINES_UNPOSTED jlu
            , SLR_ENTITIES ent
        WHERE
            jlu.JLU_EPG_ID = ''' || p_epg_id || '''
        AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
        AND jlu.JLU_ENTITY = ent.ENT_ENTITY
        AND ent.ENT_POST_VAL_DATE=''Y''
        AND NOT EXISTS
        (SELECT 1
            FROM    slr.slr_entity_days
            WHERE
                ed_entity_set  = ent.ent_periods_and_days_set
            AND     ed_date        = jlu_value_date
            AND     ed_status      = ''O'')
    ';

    DECLARE
        v_jlu_value_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_VALUE_DATE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_value_date, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Value Date',
                'Value Date  [' || v_jlu_value_date || ']  is invalid or is not open.',
                ' AND jlu_value_date = ''' || v_jlu_value_date || '''', p_epg_id, p_status, NULL);
        END LOOP;
        CLOSE cValidateRows;
    END;
    SLR_ADMIN_PKG.Debug('Validation.Value Date validated.', lv_sql);

    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
        DISTINCT
            jlu.jlu_value_date
           ,jlu.JLU_ENTITY
        FROM SLR_JRNL_LINES_UNPOSTED jlu
            ,SLR_ENTITIES ent
        WHERE
            jlu.JLU_EPG_ID = ''' || p_epg_id || '''
            AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
            AND jlu.JLU_ENTITY = ent.ENT_ENTITY
            AND ent.ENT_POST_VAL_DATE=''Y''
            AND NOT EXISTS (SELECT 1
                            FROM   slr.slr_entity_periods
                            WHERE
                                jlu_value_date >= ep_bus_period_start '  --TO_DATE('01/'||ep_month||'/'||ep_year, 'DD/MM/YYYY')
                            || 'AND    jlu_value_date <= ep_bus_period_end '  --ep_month_end
                            || 'AND    ep_entity = ent.ent_entity '  -- gEntityConfiguration.ent_periods_and_days_set
                            || 'AND    ep_status = ''O'')
    ';

    DECLARE
        v_jlu_value_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_VALUE_DATE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_value_date, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Value Date',
                'Period containing Value Date  [' || v_jlu_value_date || ']  is invalid or is closed.',
                ' AND jlu_value_date = ''' || v_jlu_value_date || '''', p_epg_id, p_status, NULL);
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation.Period containing Value Date validated.', lv_sql);
    -------------------------------------------

    --External type

    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
        DISTINCT
            jlu.jlu_jrnl_type,
            jlu.JLU_ENTITY,
            ext.ejt_rev_ejtr_code
        FROM SLR_JRNL_LINES_UNPOSTED jlu
            ,SLR_ENTITIES ent
            ,slr.SLR_EXT_JRNL_TYPES ext
            ,slr.SLR_JRNL_TYPES typ
        WHERE
            jlu.JLU_EPG_ID = ''' || p_epg_id || '''
            AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
            AND jlu.JLU_ENTITY = ent.ENT_ENTITY
            AND jlu.JLU_JRNL_REV_DATE is null
            AND jlu.jlu_jrnl_type = ext.ejt_type
            AND ext.ejt_jt_type = typ.JT_TYPE
            AND jlu.JLU_JRNL_REF_ID is null
            AND typ.jt_reverse_flag = ''Y''
            AND ext.ejt_rev_ejtr_code = ''NONE''
    ';

    DECLARE
        v_jlu_jrnl_type SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TYPE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
        v_ext_ejt_rev_ejtr_code SLR.SLR_EXT_JRNL_TYPES.EJT_REV_EJTR_CODE%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_jrnl_type, v_jlu_entity, v_ext_ejt_rev_ejtr_code;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Ext type: NONE',
                'Invalid type: '|| v_jlu_jrnl_type ||' and Rule: ' || v_ext_ejt_rev_ejtr_code || ' for Reversing Date calculation.',
                ' AND jlu_jrnl_type = '''|| v_jlu_jrnl_type || ''' ', p_epg_id, p_status, NULL);
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. External type: None - validated.', lv_sql);


    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
        DISTINCT
        jlu_jrnl_type,
        JLU_ENTITY,
        ext.ejt_rev_ejtr_code,
        rul.ejtr_code
    FROM SLR_JRNL_LINES_UNPOSTED jlu
        ,SLR_ENTITIES ent
        ,slr.SLR_EXT_JRNL_TYPES ext
        ,slr.SLR_JRNL_TYPES typ
        ,slr.SLR_EXT_JRNL_TYPE_RULE rul
    WHERE
        jlu.JLU_ENTITY = ent.ENT_ENTITY
        AND jlu.JLU_EPG_ID = ''' || p_epg_id || '''
        AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
        AND rul.ejtr_code = ext.ejt_rev_ejtr_code
        AND jlu.JLU_JRNL_REV_DATE is null
        AND jlu.jlu_jrnl_type = ext.ejt_type
        AND ext.ejt_jt_type = typ.JT_TYPE
        AND jlu.JLU_JRNL_REF_ID is null
        AND typ.jt_reverse_flag = ''Y''
        AND (rul.ejtr_type = ''BETWEEN'' OR rul.ejtr_PERIOD_DATE = ''B'' OR  rul.ejtr_PRIOR_NEXT_CURRENT = ''B'')
    ';

    DECLARE
        v_jlu_jrnl_type SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TYPE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
        v_ext_ejt_rev_ejtr_code SLR.SLR_EXT_JRNL_TYPES.EJT_REV_EJTR_CODE%TYPE;
        v_rul_ejtr_code SLR.SLR_EXT_JRNL_TYPE_RULE.EJTR_CODE%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_jrnl_type, v_jlu_entity, v_ext_ejt_rev_ejtr_code, v_rul_ejtr_code;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id,  'Ext type: BETWEEN',
                'Invalid type: ' || v_jlu_jrnl_type || ' and Rule: ' || v_rul_ejtr_code || ' for Reversing Date calculation.',
                ' AND jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ', p_epg_id, p_status, null);
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. External type:BETWEEN - validated.', lv_sql);



    lv_sql := '
    SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
    DISTINCT
        jlu.jlu_jrnl_type,
        jlu.JLU_ENTITY
    FROM SLR_JRNL_LINES_UNPOSTED jlu
        ,SLR_ENTITIES ent
    WHERE
        jlu.JLU_ENTITY = ent.ENT_ENTITY
        AND jlu.JLU_EPG_ID = ''' || p_epg_id || '''
        AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
        AND NOT EXISTS
            (
                SELECT 1 FROM
                    SLR_EXT_JRNL_TYPES ejt,
                    SLR_JRNL_TYPES jt
                WHERE
                    ejt.EJT_JT_TYPE = jt.JT_TYPE
                    AND ejt.EJT_TYPE = jlu.JLU_JRNL_TYPE
            )
    ';

    DECLARE
        v_jlu_jrnl_type SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TYPE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows for lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_jrnl_type, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id,  'Invalid Ext type',
                'No data found in SLR_EXT_JRNL_TYPES, SLR_JRNL_TYPES for Journal Type: ' || v_jlu_jrnl_type,
                ' AND jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ', p_epg_id, p_status, null);
        END LOOP;
        CLOSE cValidateRows;
    END;


    SLR_ADMIN_PKG.Debug('Validation. External type - validated.', lv_sql);


    --
    lv_sql := '
    SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
    DISTINCT
           jlu.JLU_EFFECTIVE_DATE,
        jlu.JLU_JRNL_REV_DATE,
        ent.ENT_BUSINESS_DATE,
        jlu.JLU_ENTITY
    FROM SLR_JRNL_LINES_UNPOSTED jlu
        ,SLR_ENTITIES ent
        ,slr.SLR_EXT_JRNL_TYPES ext
        ,slr.SLR_JRNL_TYPES typ
    WHERE
        jlu.JLU_EPG_ID = ''' || p_epg_id || '''
        AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
        AND jlu.JLU_ENTITY = ent.ENT_ENTITY
        AND jlu.jlu_jrnl_type = ext.ejt_type
        AND ext.ejt_jt_type = typ.JT_TYPE
        AND typ.jt_reverse_flag = ''Y''
        AND jlu.JLU_JRNL_REV_DATE IS NOT NULL
        AND NOT EXISTS
        (
            SELECT 1
            FROM  SLR_ENTITY_DAYS ed
            WHERE
                ed.ED_ENTITY_SET    = ent.ENT_PERIODS_AND_DAYS_SET
            AND ed.ED_DATE          = jlu.JLU_JRNL_REV_DATE
            AND ed.ED_STATUS        = ''O''
        )
    ';

    DECLARE
        v_jlu_effective_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
        v_jlu_jrnl_rev_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_REV_DATE%TYPE;
        v_ent_ent_business_date SLR.SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_effective_date, v_jlu_jrnl_rev_date, v_ent_ent_business_date, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Rev Date',
                    'Invalid Reversing Date: [' || v_jlu_jrnl_rev_date || '] not valid in entity days table',
                    ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''  AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  ',
                    p_epg_id, p_status, Null);
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Reversing Date - validated.', lv_sql);


    --Validate Reverse date with ejt_rev_validation_flag = 'Y'
    ------
    lv_sql := '
    SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
    DISTINCT
        jlu.JLU_EFFECTIVE_DATE,
        ent.ENT_PERIODS_AND_DAYS_SET
        ,jlu.JLU_JRNL_REV_DATE
        ,jlu.JLU_JRNL_TYPE
        ,jlu.JLU_ENTITY
        ,jlu.JLU_JRNL_STATUS
        ,msg.EM_ERROR_MESSAGE
        ,rul.ejtr_prior_next_current
        ,rul.ejtr_period_date
        ,rul.ejtr_type
    FROM SLR_JRNL_LINES_UNPOSTED jlu
        , SLR_ENTITIES ent
        , slr.SLR_EXT_JRNL_TYPES ext
        , slr.SLR_JRNL_TYPES typ
        , slr.SLR_ERROR_MESSAGE msg
        , slr.SLR_EXT_JRNL_TYPE_RULE rul
    WHERE
        jlu.JLU_EPG_ID = ''' || p_epg_id || '''
        AND jlu.JLU_JRNL_STATUS = ''' || p_status || '''
        AND rul.ejtr_code = ext.ejt_rev_ejtr_code
    AND jlu.JLU_ENTITY = ent.ENT_ENTITY
        AND msg.EM_ERROR_CODE = rul.ejtr_em_error_code
        AND jlu.jlu_jrnl_type = ext.ejt_type
        AND ext.ejt_jt_type = typ.JT_TYPE
        AND typ.jt_reverse_flag = ''Y''
        AND jlu.JLU_JRNL_REV_DATE IS NOT NULL
    AND ext.ejt_rev_validation_flag = ''Y''
    ';

    DECLARE
        v_jlu_effective_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
        v_ent_periods_and_days_set SLR_ENTITIES.ENT_PERIODS_AND_DAYS_SET%TYPE;
        v_jlu_jrnl_rev_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_REV_DATE%TYPE;
        v_jlu_jrnl_type SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TYPE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
        v_jlu_status SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_STATUS%TYPE;
        v_em_error_message SLR.SLR_ERROR_MESSAGE.EM_ERROR_MESSAGE%TYPE;
        v_rev_prior_next_both SLR.SLR_EXT_JRNL_TYPE_RULE.EJTR_PRIOR_NEXT_CURRENT%TYPE;
        v_rev_period_day SLR.SLR_EXT_JRNL_TYPE_RULE.EJTR_PERIOD_DATE%TYPE;
        v_rev_rul_typ SLR.SLR_EXT_JRNL_TYPE_RULE.EJTR_TYPE%TYPE;

    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows
            INTO
                v_jlu_effective_date,
                v_ent_periods_and_days_set,
                v_jlu_jrnl_rev_date,
                v_jlu_jrnl_type,
                v_jlu_entity,
                v_jlu_status,
                v_em_error_message,
                v_rev_prior_next_both,
                v_rev_period_day,
                v_rev_rul_typ;
            EXIT WHEN cValidateRows%NOTFOUND;

            GUI_MANUAL_JOURNAL.prui_get_calendar_details(v_jlu_effective_date,
                                      v_ent_periods_and_days_set,
                                      v_jlu_entity,
                                      lvPrevPeriodStartDate,
                                      lvPrevPeriodEndDate,
                                      lvPeriodStartDate,
                                      lvPrevBusDate,
                                      lvNextBusDate,
                                      lvPeriodEndDate,
                                      lvNextPeriodEndDate,
                                      lvNextPeriodStartDate
                                      );

            v_rev_err_msg :=  REPLACE(v_em_error_message, '%2', 'current business day');

            IF (v_rev_prior_next_both IS NOT NULL AND v_rev_period_day IS NOT NULL) THEN
                v_rev_err_msg := REPLACE(v_em_error_message, '%1', 'Reversing date');

                IF (v_rev_prior_next_both = 'P') THEN
                    v_rev_compare_start_date := lvPrevPeriodStartDate;
                    v_rev_compare_end_date := lvPrevPeriodEndDate;
                ELSIF (v_rev_prior_next_both = 'C') THEN
                    v_rev_compare_start_date := lvPeriodStartDate;
                    v_rev_compare_end_date := lvPeriodEndDate;
                ELSIF (v_rev_prior_next_both = 'N') THEN
                    v_rev_compare_end_date := lvNextPeriodEndDate;
                    v_rev_compare_start_date := lvNextPeriodStartDate;
                END IF;

                IF (v_rev_period_day = 'S') THEN

                    IF (v_rev_rul_typ = '=' AND v_jlu_jrnl_rev_date <> v_rev_compare_start_date) THEN
                        v_rev_err_msg := REPLACE(v_em_error_message, '%1', 'Reversing date');
                        SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                            'Valid Rev Date',
                            v_rev_err_msg,
                            ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''   AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                            p_epg_id, p_status, null
                            );
                            --set o_lvSuccess = 0;
                    ELSIF ((v_rev_rul_typ = '>' AND v_jlu_jrnl_rev_date <= v_rev_compare_start_date) OR
                           (v_rev_rul_typ = '<' AND v_jlu_jrnl_rev_date >= v_rev_compare_start_date)) THEN
                        SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                            'Valid Rev Date',
                            v_rev_err_msg,
                            ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''   AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                            p_epg_id, p_status, null
                            );
                    END IF;

                ELSIF (v_rev_period_day = 'E') THEN

                    IF ((v_rev_rul_typ = '=' AND v_jlu_jrnl_rev_date <> v_rev_compare_end_date) OR
                        (v_rev_rul_typ = '>' AND v_jlu_jrnl_rev_date <= v_rev_compare_end_date) OR
                        (v_rev_rul_typ = '<' AND v_jlu_jrnl_rev_date >= v_rev_compare_end_date)) THEN
                        SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                            'Valid Rev Date',
                            v_rev_err_msg,
                            ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''   AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                            p_epg_id, p_status, null
                            );
                    END IF;

                ELSIF (v_rev_period_day = 'B') THEN

                    IF (v_rev_rul_typ = 'BETWEEN' AND NOT v_jlu_jrnl_rev_date BETWEEN v_rev_compare_start_date AND v_rev_compare_end_date) THEN
                       SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                            'Valid Rev Date',
                            v_rev_err_msg,
                            ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''   AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                            p_epg_id, p_status, null
                            );
                    END IF;
                END IF;

            ELSIF (v_rev_prior_next_both IS NOT NULL AND v_rev_period_day IS NULL) THEN

                v_rev_err_msg := REPLACE(v_em_error_message, '%1', 'Reversing date');
                IF (v_rev_prior_next_both = 'P') THEN

                    v_rev_compare_date := lvPrevBusDate;
                    IF ((v_rev_rul_typ = '=' AND v_jlu_jrnl_rev_date <> v_rev_compare_date) OR
                        (v_rev_rul_typ = '>' AND v_jlu_jrnl_rev_date <= v_rev_compare_date) OR
                        (v_rev_rul_typ = '<' AND v_jlu_jrnl_rev_date >= v_rev_compare_date)) THEN
                        SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                            'Valid Rev Date',
                            v_rev_err_msg,
                            ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''   AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                            p_epg_id, p_status, null
                            );
                    END IF;

                ELSIF (v_rev_prior_next_both = 'C') THEN

                    v_rev_compare_date := v_ent_business_date;
                    IF ((v_rev_rul_typ = '=' AND v_jlu_jrnl_rev_date <> v_rev_compare_date) OR
                        (v_rev_rul_typ = '>' AND v_jlu_jrnl_rev_date <= v_rev_compare_date) OR
                        (v_rev_rul_typ = '<' AND v_jlu_jrnl_rev_date >= v_rev_compare_date)) THEN
                        SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                            'Valid Rev Date',
                            v_rev_err_msg,
                            ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''   AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                            p_epg_id, p_status, null
                            );
                    END IF;

                ELSIF (v_rev_prior_next_both = 'N') THEN

                    v_rev_compare_date := lvNextBusDate;

                    IF ((v_rev_rul_typ = '=' AND v_jlu_jrnl_rev_date <> v_rev_compare_date) OR
                        (v_rev_rul_typ = '>' AND v_jlu_jrnl_rev_date <= v_rev_compare_date) OR
                        (v_rev_rul_typ = '<' AND v_jlu_jrnl_rev_date >= v_rev_compare_date)) THEN
                        SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                            'Valid Rev Date',
                            v_rev_err_msg,
                            ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''  AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                            p_epg_id, p_status, null
                            );
                    END IF;

                END IF;

            ELSIF (v_rev_prior_next_both IS NULL  AND v_rev_period_day IS NOT NULL) THEN

                v_rev_err_msg := REPLACE(v_em_error_message, '%1', 'Reversing date');

            ELSE
                v_rev_err_msg := REPLACE(v_em_error_message, '%1', 'Reversing date');
                v_rev_compare_date := v_ent_business_date;

                IF ((v_rev_rul_typ = '=' AND v_jlu_jrnl_rev_date <> v_rev_compare_date) OR
                    (v_rev_rul_typ = '>' AND v_jlu_jrnl_rev_date <= v_rev_compare_date) OR
                    (v_rev_rul_typ = '<' AND v_jlu_jrnl_rev_date >= v_rev_compare_date)) THEN
                     SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(v_jlu_entity, p_process_id,
                        'Valid Rev Date',
                        v_rev_err_msg,
                        ' AND JLU_JRNL_REV_DATE = ''' || v_jlu_jrnl_rev_date || '''  AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || '''  and jlu_jrnl_type = ''' || v_jlu_jrnl_type || ''' ',
                        p_epg_id, p_status, null
                        );
                END IF;

            END IF;

            SLR_ADMIN_PKG.Debug('Validation. Reversing Date for type: [' || v_jlu_jrnl_type ||'] and date [' || v_jlu_effective_date || '] - validated.');
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Reversing Date rules - validated.', lv_sql);

    -- Currencies

    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
        DISTINCT
            TRIM(JLU_TRAN_CCY) JLU_TRAN_CCY,
            JLU_EFFECTIVE_DATE,
            JLU_ENTITY,
            JLU_JRNL_ENT_RATE_SET,
            JLU_TRANSLATION_DATE
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_EPG_ID = ''' || p_epg_id || '''
        AND JLU_JRNL_STATUS = ''' || p_status || '''
    ';
    DECLARE
        v_jlu_tran_ccy SLR.SLR_JRNL_LINES_UNPOSTED.JLU_TRAN_CCY%TYPE;
        v_jlu_effective_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
        v_jlu_jrnl_ent_rate_set SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_ENT_RATE_SET%TYPE;
        v_jlu_translation_date SLR.SLR_JRNL_LINES_UNPOSTED.JLU_TRANSLATION_DATE%TYPE;
    BEGIN
        OPEN cValidateRows for lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_tran_ccy, v_jlu_effective_date, v_jlu_entity, v_jlu_jrnl_ent_rate_set, v_jlu_translation_date;
            EXIT WHEN cValidateRows%NOTFOUND;
            BEGIN
                SELECT * INTO lv_entity_configuration FROM SLR_ENTITIES
                WHERE ENT_ENTITY = v_jlu_entity;

                -- when not valid exception NO_DATA_FOUND is raised
                SELECT 1 INTO lv_found FROM SLR_ENTITY_CURRENCIES
                WHERE EC_ENTITY_SET = lv_entity_configuration.ENT_CURRENCY_SET
                AND TRIM(EC_CCY) = v_jlu_tran_ccy
                AND EC_STATUS = 'A';

                IF ( lv_entity_configuration.ENT_APPLY_FX_TRANSLATION = 'Y' AND
                     v_jlu_effective_date <= lv_entity_configuration.ENT_BUSINESS_DATE ) THEN

                    BEGIN
                        SELECT 1 INTO lv_found FROM SLR_ENTITY_RATES, SLR_ENTITIES
                        WHERE ER_ENTITY_SET = nvl(p_rate_set, nvl(v_jlu_jrnl_ent_rate_set, lv_entity_configuration.ENT_RATE_SET))
                            AND ENT_ENTITY = v_jlu_entity
                            AND TRIM(ER_CCY_FROM) = v_jlu_tran_ccy
                            AND TRIM(ER_CCY_TO) = TRIM(ENT_LOCAL_CCY)
                            AND ER_DATE = nvl(v_jlu_translation_date, v_jlu_effective_date)
                            AND ER_RATE > 0;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            pWriteLineError(v_jlu_entity, p_process_id, 'FX Rate',
                                'No local FX Rate for source currency [' || v_jlu_tran_ccy || '] and entity [' || v_jlu_entity || '] and date [' || nvl(v_jlu_translation_date, v_jlu_effective_date) || ']',
                                ' AND JLU_TRAN_CCY = ''' || v_jlu_tran_ccy || ''' AND JLU_ENTITY = ''' || v_jlu_entity || ''' AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || ''' and JLU_TRANSLATION_DATE ' || case when v_jlu_translation_date is null then ' is null ' else ' = ''' || v_jlu_translation_date || '''' end, p_epg_id, p_status, p_UseHeaders);
                        WHEN OTHERS THEN
                            pWriteLineError(v_jlu_entity, p_process_id, 'FX Rate',
                                'FX local rate error for source currency [' || v_jlu_tran_ccy || '] and entity [' || v_jlu_entity || '] and date [' || nvl(v_jlu_translation_date, v_jlu_effective_date) || ']',
                                ' AND JLU_TRAN_CCY = ''' || v_jlu_tran_ccy || ''' AND JLU_ENTITY = ''' || v_jlu_entity || ''' AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || ''' and JLU_TRANSLATION_DATE '|| case when v_jlu_translation_date is null then ' is null ' else ' = ''' || v_jlu_translation_date ||'''' end, p_epg_id, p_status, p_UseHeaders);
                    END;

                    BEGIN
                        SELECT 1 INTO lv_found FROM SLR_ENTITY_RATES, SLR_ENTITIES
                        WHERE ER_ENTITY_SET = nvl(p_rate_set, nvl(v_jlu_jrnl_ent_rate_set, lv_entity_configuration.ENT_RATE_SET))
                            AND ENT_ENTITY = v_jlu_entity
                            AND TRIM(ER_CCY_FROM) = v_jlu_tran_ccy
                            AND TRIM(ER_CCY_TO) = TRIM(ENT_BASE_CCY)
                            AND ER_DATE = nvl(v_jlu_translation_date, v_jlu_effective_date)
                            AND ER_RATE > 0;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            pWriteLineError(v_jlu_entity, p_process_id, 'FX Rate',
                                'No base FX Rate for source currency [' || v_jlu_tran_ccy || '] and entity [' || v_jlu_entity || '] and date [' || nvl(v_jlu_translation_date, v_jlu_effective_date) || ']',
                                ' AND JLU_TRAN_CCY = ''' || v_jlu_tran_ccy || ''' AND JLU_ENTITY = ''' || v_jlu_entity || ''' AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || ''' and JLU_TRANSLATION_DATE ' || case when v_jlu_translation_date is null then ' is null ' else ' = ''' || v_jlu_translation_date || '''' end, p_epg_id, p_status, p_UseHeaders);
                        WHEN OTHERS THEN
                            pWriteLineError(v_jlu_entity, p_process_id, 'FX Rate',
                                'FX base rate error for source currency [' || v_jlu_tran_ccy || '] and entity [' || v_jlu_entity || '] and date [' || nvl(v_jlu_translation_date, v_jlu_effective_date) || ']',
                                ' AND JLU_TRAN_CCY = ''' || v_jlu_tran_ccy || ''' AND JLU_ENTITY = ''' || v_jlu_entity || ''' AND JLU_EFFECTIVE_DATE = ''' || v_jlu_effective_date || ''' and JLU_TRANSLATION_DATE ' || case when v_jlu_translation_date is null then ' is null ' else ' = ''' || v_jlu_translation_date || '''' end, p_epg_id, p_status, p_UseHeaders);
                    END;

                END IF;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    pWriteLineError(v_jlu_entity, p_process_id, 'Currency',
                        'Invalid transaction currency: ' || v_jlu_tran_ccy, ' AND JLU_TRAN_CCY = ''' || v_jlu_tran_ccy || '''', p_epg_id, p_status, p_UseHeaders);
            END;
                SLR_ADMIN_PKG.Debug('Validation. FX Rate for source currency: [' ||v_jlu_tran_ccy|| '] and entity [' || v_jlu_entity || '] and date [' || nvl(v_jlu_translation_date, v_jlu_effective_date) || '] validated.' );
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Currency validated.', lv_sql);

    -- Balances

    BEGIN
    v_def := TRUE;
    FOR loop_counter IN 1..10
    LOOP
        lv_sql:= 'SELECT case when COUNT(DISTINCT FD_SEGMENT_'||loop_counter||'_BALANCE_CHECK) = 1 AND MAX(FD_SEGMENT_'||loop_counter||'_BALANCE_CHECK) = ''Y'' THEN '',JLU_SEGMENT_'||loop_counter||''' else '''' end, case when COUNT(DISTINCT FD_SEGMENT_'||loop_counter||'_BALANCE_CHECK) <> 1 THEN ''FALSE'' else '' '' END
                    FROM SLR_FAK_DEFINITIONS
                        INNER JOIN SLR_ENTITY_PROC_GROUP
                        ON fd_entity = epg_entity
                        WHERE epg_id = ''' || p_epg_id || ''' '
                       ;

        EXECUTE IMMEDIATE lv_sql INTO lv_segment, v_defin ;

        lv_allSegments := lv_allSegments || lv_segment;

        IF (v_defin = 'FALSE') THEN
            v_def := FALSE;
        END IF;
    END LOOP;

    lv_allSegments := 'JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE' || lv_allSegments || ', JLU_TRAN_CCY ';


    IF (v_def = FALSE) THEN
    pValidateBalanceDiff(p_process_id, p_epg_id, p_status, p_UseHeaders);
    ELSE
    pValidateBalance(p_process_id, p_epg_id, p_status, p_UseHeaders, lv_allSegments);
    END IF;

    END;
    SLR_ADMIN_PKG.Debug('Validation. Balances validated.');

    -- Adjustment Balances

    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS_JLU') || '
        DISTINCT
            JLU.JLU_JRNL_TYPE,
            ENT.ENT_ENTITY_SHORT_CODE,
            ENT.ENT_ENTITY
        FROM    SLR_JRNL_LINES_UNPOSTED JLU
                , SLR_ENTITIES ENT
        WHERE
            JLU.JLU_JRNL_PROCESS_ID = ' || p_process_id || '
            AND JLU.JLU_ENTITY = ENT.ENT_ENTITY
            AND JLU.JLU_EPG_ID = ''' || p_epg_id || '''
            AND JLU.JLU_JRNL_STATUS = ''' || p_status || '''
            AND EXISTS (
                SELECT
                    1
                FROM
                    SLR.SLR_EXT_JRNL_TYPES
                WHERE
                    EJT_TYPE = JLU.JLU_JRNL_TYPE
                    AND ((EJT_BALANCE_TYPE_1 = 20 AND EJT_BALANCE_TYPE_2 IS NULL)
                        OR (EJT_BALANCE_TYPE_2 = 20 AND EJT_BALANCE_TYPE_1 IS NULL))
            )
            AND ENT.ENT_ADJUSTMENT_FLAG = ''N''
    ';

    DECLARE
        v_jlu_jrnl_type SLR.SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TYPE%TYPE;
        v_ent_entity_short_code SLR.SLR_ENTITIES.ENT_ENTITY_SHORT_CODE%TYPE;
        v_ent_entity SLR.SLR_ENTITIES.ENT_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_jrnl_type, v_ent_entity_short_code, v_ent_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_ent_entity, p_process_id, 'Account',
                'The entity [' || v_ent_entity_short_code || '] does not allow adjustments to be processed.' ,
                'AND jlu_jrnl_type = ''' || v_jlu_jrnl_type|| ''' AND jlu_entity = ''' || v_ent_entity || '''', p_epg_id, p_status, p_UseHeaders);

        SLR_ADMIN_PKG.Debug('Validation. Adjustment Balances for entity: ' ||v_ent_entity_short_code||' and jlu_jrnl_type: ' ||v_jlu_jrnl_type|| ' validated.');
        END LOOP;
        CLOSE cValidateRows;
    END;

    SLR_ADMIN_PKG.Debug('Validation. Adjustment Balances validated.', lv_sql);

    -- Accounts
    lv_sql := '
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || '
        DISTINCT
            JLU_ACCOUNT,
            JLU_ENTITY
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_EPG_ID = ''' || p_epg_id || '''
        AND  JLU_JRNL_STATUS = ''' || p_status || '''
        AND NOT EXISTS
        (
            SELECT NULL FROM SLR_ENTITY_ACCOUNTS
            WHERE EA_ENTITY_SET = (SELECT ENT_ACCOUNTS_SET FROM SLR_ENTITIES WHERE ENT_ENTITY = JLU_ENTITY)
            AND EA_STATUS = ''A''
            AND EA_ACCOUNT = JLU_ACCOUNT
        )
    ';

    DECLARE
        v_jlu_account SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ACCOUNT%TYPE;
        v_jlu_entity SLR.SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE;
    BEGIN
        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_jlu_account, v_jlu_entity;
            EXIT WHEN cValidateRows%NOTFOUND;
            pWriteLineError(v_jlu_entity, p_process_id, 'Account',
                'Invalid Account: ' || v_jlu_account ,
                ' AND JLU_ACCOUNT = ''' || v_jlu_account || '''', p_epg_id, p_status, p_UseHeaders);
            SLR_ADMIN_PKG.Debug('Validation. Account for entity: ' ||v_jlu_entity||' validated.');
        END LOOP;
        CLOSE cValidateRows;
    END;


    SLR_ADMIN_PKG.Debug('Validation. Accounts validated.', lv_sql);

-- Segments

 FOR loop_counter IN 1..10
  LOOP

    BEGIN
      lv_sql := 'SELECT COUNT(DISTINCT FD_SEGMENT_'||loop_counter||'_TYPE), MAX(FD_SEGMENT_'||loop_counter||'_TYPE)
                    FROM SLR_FAK_DEFINITIONS
                        INNER JOIN SLR_ENTITY_PROC_GROUP
                        ON fd_entity = epg_entity
                        WHERE epg_id = ''' || p_epg_id || ''' ';



      EXECUTE IMMEDIATE lv_sql
      INTO v_counter, v_definition ;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    v_counter := 0;
    v_definition := 'I';
    END;


        IF v_counter = 1 and v_definition IN ('M', 'C') THEN
            pValidateSegment(p_process_id, loop_counter, v_definition, p_epg_id, p_status, p_UseHeaders);
        ELSIF v_counter > 1 THEN
            pValidateSegmentDiff(p_process_id, loop_counter, p_epg_id, p_status, p_UseHeaders);
        END IF;

    SLR_ADMIN_PKG.Debug('Validation. Segment:'||loop_counter || ' validated.');
   -- END;
END LOOP;

    SLR_ADMIN_PKG.Debug('Validation. Segments validated.', lv_sql);

    pUpdateJLUPeriods(p_epg_id, p_process_id, p_status);
    SLR_ADMIN_PKG.Debug('Validation. JLU periods updated.');

    pSetValidationStatistics(p_process_id);
    COMMIT;

    --EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';

    SLR_ADMIN_PKG.Info('Validation end');

EXCEPTION
    WHEN e_internal_processing_error THEN
        -- error was handled in procedure which raised it
        RETURN;

    WHEN OTHERS THEN
        ROLLBACK;
        pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED',
            'Error during journal lines validation', p_process_id,null,null);
        SLR_ADMIN_PKG.Error('ERROR in procedure pValidateJournals');
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during journal lines validation: ' || SQLERRM);

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
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', 'There are ' || gErrorsNumber || ' journal lines in error for Process Id [' || p_process_id || ']. More detailed description can be found in SLR_JRNL_LINE_ERRORS');
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
        s_proc_name CONSTANT VARCHAR2(80):= 'SLR_VALIDATE_JOURNALS_PKG.fInitializeProcedure';
        s_SID VARCHAR2(256);
        s_business_date date;
    BEGIN


        select sys_context('userenv','SID') SID
        into s_SID
        from DUAL;


        SELECT ENT_BUSINESS_DATE
            INTO s_business_date
                FROM SLR_ENTITIES
                WHERE ENT_ENTITY =
                (
                    SELECT EPG_ENTITY
                    FROM SLR_ENTITY_PROC_GROUP
                    WHERE EPG_ID =p_epg_id
                        AND ROWNUM = 1
                );


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
                WHERE JLU_ENTITY = :p_entity
                AND JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS IN (:p_status,''E'') '
                || p_sql;

        EXECUTE IMMEDIATE v_sql USING p_process_id, p_entity, p_epg_id, p_status;

        IF p_UseHeaders THEN

             v_sql := 'UPDATE SLR_JRNL_HEADERS_UNPOSTED'
                        ||' SET    JHU_JRNL_STATUS = ''E'','
                        ||'        JHU_AMENDED_BY = :id,'
                        ||'        JHU_AMENDED_ON = SYSDATE,'
                        ||'        JHU_JRNL_PROCESS_ID = :process_id'
                        ||' WHERE   (JHU_JRNL_ID) IN
                (
                    SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                    WHERE JLU_ENTITY = :p_entity
                    AND JLU_EPG_ID = :p_epg_id
                    AND JLU_JRNL_STATUS = :p_status '
                        || p_sql || '
                )';

            EXECUTE IMMEDIATE v_sql USING USER,p_process_id, p_entity, p_epg_id, p_status ;
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
                WHERE JLU_ENTITY = :p_entity
                AND JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS = :p_status '
                    || p_sql || '
            )
         AND JLU_EPG_ID = :p_epg_id
         AND JLU_JRNL_STATUS = :p_status';

        EXECUTE IMMEDIATE v_sql USING p_status_text, USER,p_process_id, p_entity, p_epg_id, p_status, p_epg_id, p_status;

        gErrorsNumber:=NVL(gErrorsNumber, 0) + SQL%ROWCOUNT;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINE_ERRORS',
                'Failure to write errors to log and unposted journals for process id ['||p_process_id||'] ',
                p_process_id,p_entity, p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Failure to write errors to log and unposted journals for process id ['||p_process_id||'] ');
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pWriteLineError: ' || SQLERRM);

    END pWriteLineError;


   -- ---------------------------------------------------------------------------
    -- Procedure:    pWriteLineErrorEventClass
    -- Description:  Custom procedure to write journal errors based on Event Class.
    -- Author:      Janet Hine
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
        p_UseHeaders IN BOOLEAN := FALSE

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

    v_msg           SLR_JRNL_LINE_ERRORS.JLE_ERROR_STRING%TYPE;
    s_proc_name     VARCHAR2(80) := 'SLR_VALIDATE_JOURNALS_PKG.pSetJournalToError';
    s_UpdatedBy      SLR_ENTITIES.ENT_CREATED_BY%TYPE := USER;
    d_WhenUpdated    SLR_ENTITIES.ENT_CREATED_ON%TYPE := SYSDATE;

    BEGIN
    --dbms_output.put_line('--> pSetJournalToError');
        gv_table_name := 'SLR_JRNL_LINES_UNPOSTED';

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

                UPDATE     SLR_JRNL_HEADERS_UNPOSTED
                SET        JHU_JRNL_STATUS = 'E',
                        JHU_AMENDED_BY = s_UpdatedBy,
                        JHU_AMENDED_ON = d_WhenUpdated
                WHERE      (JHU_JRNL_ID) IN
                    (
                        SELECT JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                        WHERE JLU_EPG_ID = p_epg_id
                        AND JLU_JRNL_STATUS = p_status );

          UPDATE     SLR_JRNL_LINES_UNPOSTED
            SET        JLU_JRNL_STATUS = 'E',
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

    end if;
    IF p_entity IS NOT NULL THEN
       ---quick fix for Issue #10954
                    -- old logic for GUI screens compatibility
                    gv_table_name := 'SLR_JRNL_HEADERS_UNPOSTED';

                    UPDATE     SLR_JRNL_HEADERS_UNPOSTED
                    SET        JHU_JRNL_STATUS = 'E',
                            JHU_AMENDED_BY = s_UpdatedBy,
                            JHU_AMENDED_ON = d_WhenUpdated
                    WHERE      (JHU_JRNL_ID) IN
                        (
                            SELECT JLU_JRNL_HDR_ID FROM SLR_JRNL_LINES_UNPOSTED
                            WHERE JLU_ENTITY = p_entity
                            AND JLU_EPG_ID = p_epg_id
                            AND JLU_JRNL_STATUS = p_status );

     UPDATE     SLR_JRNL_LINES_UNPOSTED
            SET        JLU_JRNL_STATUS = 'E',
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
    BEGIN


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

            IF p_UseHeaders THEN
                lv_sql := ' UPDATE SLR_JRNL_HEADERS_UNPOSTED'
                                ||' SET JHU_JRNL_STATUS  =   ''E'','
                                    ||' JHU_AMENDED_BY   =  USER,'
                                    ||' JHU_AMENDED_ON   =  SYSDATE,'
                                    ||' JHU_JRNL_PROCESS_ID   =  :p_process_id'
                              ||' WHERE (JHU_JRNL_ID) IN
                              (
                                SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID
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
                            AND JLU_EPG_ID = :p_epg_id )';


                EXECUTE IMMEDIATE lv_sql using p_process_id, p_status, p_epg_id;

            END IF;

            lv_sql := '
                UPDATE SLR_JRNL_LINES_UNPOSTED
                SET JLU_JRNL_STATUS = ''E'',
                JLU_AMENDED_BY = USER,
                JLU_AMENDED_ON = SYSDATE,
                JLU_JRNL_PROCESS_ID = :p_process_id,
                JLU_JRNL_STATUS_TEXT = ''Invalid Segment:'||p_seg_no||'''
                WHERE JLU_JRNL_HDR_ID IN
                (
                    SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID
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
                  AND JLU_EPG_ID = :p_epg_id )';

            gErrorsNumber:=NVL(gErrorsNumber, 0) + SQL%ROWCOUNT;

            EXECUTE IMMEDIATE lv_sql using p_process_id, p_status, p_epg_id;

        END IF;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
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
    )
    AS
        s_proc_name CONSTANT VARCHAR2(65) := 'SLR_VALIDATE_JOURNALS_PKG.pValidateSegment';
        lv_sql VARCHAR2(32000);
    BEGIN
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


        EXECUTE IMMEDIATE lv_sql USING p_process_id, p_status, p_epg_id;

        IF SQL%ROWCOUNT > 0 THEN

            IF p_UseHeaders THEN
                lv_sql := ' UPDATE SLR_JRNL_HEADERS_UNPOSTED'
                                ||' SET JHU_JRNL_STATUS  =   ''E'','
                                    ||' JHU_AMENDED_BY   =  USER,'
                                    ||' JHU_AMENDED_ON   =  SYSDATE,'
                                    ||' JHU_JRNL_PROCESS_ID   =  :p_process_id'
                              ||' WHERE (JHU_JRNL_ID) IN
                              (
                                SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID
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
                    lv_sql := lv_sql || ' AND JLU_SEGMENT_'||p_seg_no||' != ''NVS'')';
                ELSE
                    lv_sql := lv_sql || ')';
                END IF;

                EXECUTE IMMEDIATE lv_sql using p_process_id, p_status, p_epg_id;

            END IF;

            lv_sql := '
                UPDATE SLR_JRNL_LINES_UNPOSTED
                SET JLU_JRNL_STATUS = ''E'',
                JLU_AMENDED_BY = USER,
                JLU_AMENDED_ON = SYSDATE,
                JLU_JRNL_PROCESS_ID = :p_process_id,
                JLU_JRNL_STATUS_TEXT = ''Invalid Segment:'||p_seg_no||'''
                WHERE JLU_JRNL_HDR_ID IN
                (
                    SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'SELECT_LINE_ERRORS') || ' JLU_JRNL_HDR_ID
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

            gErrorsNumber:=NVL(gErrorsNumber, 0) + SQL%ROWCOUNT;

              IF p_seg_type = 'C' THEN  -- Conditional segment: only validate when not NVS (TTP91/TTP143).
                lv_sql := lv_sql || ' AND JLU_SEGMENT_'||p_seg_no||' != ''NVS'')   AND JLU_EPG_ID = :p_epg_id AND JLU_JRNL_STATUS = :p_status ';
            ELSE
                lv_sql := lv_sql || ')  AND JLU_EPG_ID = :p_epg_id AND JLU_JRNL_STATUS = :p_status ';
            END IF;

            EXECUTE IMMEDIATE lv_sql using p_process_id, p_status, p_epg_id,  p_epg_id, p_status;

        END IF;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pWriteLogError(s_proc_name, 'SLR_FAK_SEGMENT_'||p_seg_no,
                'Error during validating segment ' || p_seg_no || ': ' || SQLERRM, p_process_id,p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Error during validating segment ' || p_seg_no || ': ' || SQLERRM);
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
                IF p_UseHeaders = TRUE THEN
                    -- old logic for GUI screens compatibility
                        lv_sql :=    'UPDATE SLR_JRNL_HEADERS_UNPOSTED
                                    SET JHU_JRNL_STATUS  =   ''E'',
                                    JHU_AMENDED_BY   =  USER,
                                    JHU_AMENDED_ON   =  SYSDATE
                                    WHERE (JHU_JRNL_ID) IN
                                    (
                                        SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' DISTINCT
                                        JLU_JRNL_HDR_ID
                                        FROM
                                        SLR_JRNL_LINES_UNPOSTED
                                        WHERE
                                        JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                        AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                                        GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE ' || v_GROUP_SEGMENT || ', JLU_TRAN_CCY
                                        HAVING SUM(JLU_TRAN_AMOUNT) != 0)';

                    EXECUTE IMMEDIATE lv_sql USING p_epg_id, p_status;
                END IF;

                lv_sql := 'update SLR_JRNL_LINES_UNPOSTED
                    SET JLU_JRNL_STATUS = ''E'',
                        JLU_JRNL_STATUS_TEXT = ''Balance'',
                        JLU_AMENDED_BY = USER,
                        JLU_AMENDED_ON = SYSDATE,
                        JLU_JRNL_PROCESS_ID = :process_id
                    where JLU_JRNL_HDR_ID IN
                        (
                            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' JLU_JRNL_HDR_ID
                            FROM SLR_JRNL_LINES_UNPOSTED
                            WHERE JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                            AND JLU_EPG_ID = :p_epg_id
                            AND JLU_JRNL_STATUS = :p_status
                            GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE '  || v_GROUP_SEGMENT ||', JLU_TRAN_CCY
                            HAVING SUM(JLU_TRAN_AMOUNT) != 0
                        )
                        AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                        AND JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status ';

               EXECUTE IMMEDIATE lv_sql USING p_process_id, p_epg_id, p_status, p_epg_id, p_status;
                gErrorsNumber:=NVL(gErrorsNumber, 0) + SQL%ROWCOUNT;
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
                IF p_UseHeaders = TRUE THEN
                    -- old logic for GUI screens compatibility

                        lv_sql :=    'UPDATE SLR_JRNL_HEADERS_UNPOSTED
                                    SET JHU_JRNL_STATUS  =   ''E'',
                                    JHU_AMENDED_BY   =  USER,
                                    JHU_AMENDED_ON   =  SYSDATE
                                    WHERE (JHU_JRNL_ID) IN
                                    (
                                        SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' DISTINCT
                                        JLU_JRNL_HDR_ID
                                        FROM
                                        SLR_JRNL_LINES_UNPOSTED
                                        WHERE
                                        JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                        AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                                        GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE ' || v_GROUP_SEGMENT || ', JLU_TRAN_CCY
                                        HAVING SUM(JLU_TRAN_AMOUNT) != 0)';

                    EXECUTE IMMEDIATE lv_sql USING p_epg_id, p_status;
                END IF;

                lv_sql := 'update SLR_JRNL_LINES_UNPOSTED
                    SET JLU_JRNL_STATUS = ''E'',
                        JLU_JRNL_STATUS_TEXT = ''Balance'',
                        JLU_AMENDED_BY = USER,
                        JLU_AMENDED_ON = SYSDATE,
                        JLU_JRNL_PROCESS_ID = :process_id
                    where JLU_JRNL_HDR_ID IN
                        (
                            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' JLU_JRNL_HDR_ID
                            FROM SLR_JRNL_LINES_UNPOSTED
                            WHERE JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                            AND JLU_EPG_ID = :p_epg_id
                            AND JLU_JRNL_STATUS = :p_status
                            GROUP BY JLU_JRNL_HDR_ID, JLU_EFFECTIVE_DATE '  || v_GROUP_SEGMENT ||', JLU_TRAN_CCY
                            HAVING SUM(JLU_TRAN_AMOUNT) != 0
                        )
                        AND JLU_ENTITY IN ('||v_GROUP_ENTITY||')
                        AND JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status ';
                EXECUTE IMMEDIATE lv_sql USING p_process_id, p_epg_id, p_status, p_epg_id, p_status;
                gErrorsNumber:=NVL(gErrorsNumber, 0) + SQL%ROWCOUNT;
                COMMIT;
          END IF;
    END IF;
        SLR_ADMIN_PKG.Debug('Validation. Balances for different configuration - validated.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
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
    BEGIN

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
                IF p_UseHeaders = TRUE THEN
                    -- old logic for GUI screens compatibility

                        lv_sql :=    'UPDATE SLR_JRNL_HEADERS_UNPOSTED
                                    SET JHU_JRNL_STATUS  =   ''E'',
                                    JHU_AMENDED_BY   =  USER,
                                    JHU_AMENDED_ON   =  SYSDATE
                                    WHERE (JHU_JRNL_ID) IN
                                    (
                                        SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' DISTINCT
                                        JLU_JRNL_HDR_ID
                                        FROM
                                        SLR_JRNL_LINES_UNPOSTED, SLR_ENTITIES
                                        WHERE
                                        JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                        AND JLU_ENTITY = ENT_ENTITY
                                        GROUP BY ENT_ENTITY, ' || lv_sql_group_by ||
                                        ' HAVING SUM(JLU_TRAN_AMOUNT) != 0)';

                    EXECUTE IMMEDIATE lv_sql USING p_epg_id, p_status;
                END IF;

                lv_sql := 'update SLR_JRNL_LINES_UNPOSTED
                    SET JLU_JRNL_STATUS = ''E'',
                        JLU_JRNL_STATUS_TEXT = ''Balance'',
                        JLU_AMENDED_BY = USER,
                        JLU_AMENDED_ON = SYSDATE,
                        JLU_JRNL_PROCESS_ID = :process_id
                    where JLU_JRNL_HDR_ID IN
                        (
                            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'JOURNAL_VALIDATIONS') || ' JLU_JRNL_HDR_ID
                            FROM SLR_JRNL_LINES_UNPOSTED, SLR_ENTITIES
                            WHERE JLU_ENTITY =  ENT_ENTITY
                            AND JLU_EPG_ID = :p_epg_id
                            AND JLU_JRNL_STATUS = :p_status
                            GROUP BY ENT_ENTITY, ' || lv_sql_group_by || '
                            HAVING SUM(JLU_TRAN_AMOUNT) != 0
                        )
                        AND JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status ';
                EXECUTE IMMEDIATE lv_sql USING p_process_id, p_epg_id, p_status, p_epg_id, p_status;
                gErrorsNumber:=NVL(gErrorsNumber, 0) + SQL%ROWCOUNT;
                COMMIT;
            END IF;
            SLR_ADMIN_PKG.Debug('Validation. Balances for the same configuration - validated.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED',
                'Error during validating balances: ' || SQLERRM, p_process_id,p_epg_id,p_status);
            SLR_ADMIN_PKG.Error('Error during validating balances: ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop execution
    END pValidateBalance;
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

    EXECUTE IMMEDIATE '
    UPDATE '|| SLR_UTILITIES_PKG.fHint(pEpgId, 'UPDATE_JLU_PERIODS') || ' slr_jrnl_lines_unposted lu
    SET (jlu_period_month,jlu_period_year,jlu_period_ltd) =
        (SELECT EP_BUS_PERIOD,EP_BUS_YEAR,CASE WHEN EA_ACCOUNT_TYPE_FLAG = ''P'' THEN EP_BUS_YEAR ELSE 1 END
              FROM slr_entities,SLR_ENTITY_PERIODS,slr_entity_accounts
              WHERE
                  ent_entity = lu.jlu_entity
              AND lu.jlu_effective_date BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
              AND EP_ENTITY = ent_entity
              AND EP_PERIOD_TYPE <> 0
              AND EA_ACCOUNT = lu.jlu_account
              AND EA_ENTITY_SET = ENT_ACCOUNTS_SET)
    WHERE lu.jlu_epg_id = ''' || pEpgId || '''
    and  lu.JLU_JRNL_STATUS = ''' || p_status || '''
    and exists (SELECT 1
              FROM slr_entities,SLR_ENTITY_PERIODS,slr_entity_accounts
              WHERE
                  ent_entity = lu.jlu_entity
              AND lu.jlu_effective_date BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
              AND EP_ENTITY = ent_entity
              AND EP_PERIOD_TYPE <> 0
              AND EA_ACCOUNT = lu.jlu_account
              AND EA_ENTITY_SET = ENT_ACCOUNTS_SET)
    ';
    exception
     WHEN OTHERS THEN
            pWriteLogError(s_proc_name, 'slr_jrnl_lines_unposted',
                'Error during updating slr_jrnl_lines_unposted.', p_process_id,pEpgId);
            SLR_ADMIN_PKG.Error('Error during updating slr_jrnl_lines_unposted ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop execution

  END pUpdateJLUPeriods;





END SLR_VALIDATE_JOURNALS_PKG;
/************************************ End of Package *******************************************/
/