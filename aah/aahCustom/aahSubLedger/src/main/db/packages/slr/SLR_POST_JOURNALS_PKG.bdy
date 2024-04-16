CREATE OR REPLACE PACKAGE BODY SLR.SLR_POST_JOURNALS_PKG AS
/******************************************************************************
--446
--  Id: $Id: slr_post_journals_pkg.sql,v 1.10 2005/05/31 07:48:14 pfrench Exp $
--
--  Description: Package Body for Posting Journals
-- ----------------------------------------------------------------------------
-- Key Comments
-- 1) The process does not process internally by journal. It simply process all
--    data within the input parameters as one logical block of data. Any
--    unhandled error simply rolls all data back to the last commit.
-- 2) There is only one COMMIT at the very end of this process. It is assumed
--    that the undo tablespace is suitably sized for the quantity of data being
--    processed.
-- 3) Balance Posting is done by aggregated KEYS, this makes the process INSERT
--    friendly for BATCH processig. It does however mean that we cannot process
--    journal. This may be an issue for some cutomers.
-- 4) The slowest part of the process appears to be transitioning the data from
--    U - p then p - P. It would be good if this could be done in parallel.
--    Oracle 9i has a limitation that a COMMIT must be issues after any
--    DML statement. This stops us from using this functionality. It may be
--    possible to write our own decoupled (autono) method of inserting  the
--    journals to the posted tables while they balances are still being posted.
--    this obvioulsy needs to be rolled back in the event of a posting error but
--    could save us 20% of execution time.
-- 5) Process assumes that FX Rates are present. If FX rates are not present
--    then the process fails and rolls all processing back. Logic to check
--    if rates are present should be included in the process wrapper.
-- -------------------------------------------------------------------------------
--    Table Dependancies
--      SLR.SLR_EBA_COMBINATIONS
--      SLR.SLR_EBA_DAILY_BALANCES
--      SLR.SLR_ENTITIES
--      SLR.SLR_FAK_COMBINATIONS
--      SLR.SLR_FAK_DAILY_BALANCES
--      SLR.SLR_FAK_DEFINITIONS
--      SLR.SLR_JOB_STATISTICS
--      SLR.SLR_JRNL_HEADERS
--      SLR.SLR_JRNL_HEADERS_UNPOSTED
--      SLR.SLR_JRNL_LINES
--      SLR.SLR_JRNL_LINES_UNPOSTED
--      SLR.SLR_JRNL_LINE_ERRORS
--      SYS.DUAL
--    Procedure and Function Dependancies
--      SLR.SLR_POST_JOURNALS_PKG
--      SLR.SLR_UTILITIES_PKG
--      SLR.FVALIDATEPROCEDURE
--      SLR.DBMS_OUTPUT
--      SLR.SLR_POST_JOURNALS_PKG
--      SLR.SLR_TRANSLATE_JOURNALS_PKG
--      SYS.DBMS_OUTPUT
--      SYS.DBMS_STANDARD
-- ----------------------------------------------------------------------------
-- Entry to the program is pPostJournals. Parameters are self explanatory.
--
-- Step 1. Initialize Procedure Variables
-- Step 2. Validate the Journal Date
-- Step 3. Set FAK Deinitions
-- Step 4. Update journal Header and Line to 'p'
-- Step 5. Apply FX Translation Process
-- Step 6. Post FAK Numbers to the Balances
-- Step 7. Post EBA Numbers to the Balances
-- Step 8. Update journal Header and Line to 'P'
-- Step 9. Calculate Posting Statistics
-- Step 10. Set end time of the process
--
******************************************************************************/
    /**************************************************************************
     * Declare private procedures and functions
     **************************************************************************/


    FUNCTION fInitializeProcedure
    (
        p_epg_id        IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id    IN NUMBER,
        p_business_date IN SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE
    )
    RETURN BOOLEAN;

    FUNCTION fSetPostingStatistics
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER
    )
    RETURN BOOLEAN;


    PROCEDURE pWriteLogError( p_proc_name     in VARCHAR2,
                              p_table_name    in VARCHAR2,
                              p_msg           in VARCHAR2,
                              p_process_id    in SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
                              p_epg_id        IN  SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
                              p_status        IN  CHAR := 'U',
                              p_entity        IN  slr_entities.ent_entity%TYPE:=NULL);

    PROCEDURE pGenerateEBADailyBalances
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_business_date IN DATE,
        p_oldest_backdate IN DATE,
        p_status IN CHAR := 'U'
    );

    PROCEDURE pGenerateFAKDailyBalances
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_business_date IN DATE,
        p_oldest_backdate IN DATE,
        p_status IN CHAR := 'U'
    );

    PROCEDURE pGenerateEBADailyBalancesMerge
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_business_date IN DATE,
        p_oldest_backdate IN DATE,
        p_status IN CHAR := 'U'
    );

    PROCEDURE pGenerateFAKDailyBalancesMerge
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_business_date IN DATE,
        p_oldest_backdate IN DATE,
        p_status IN CHAR := 'U'
    );

    PROCEDURE pGenerateEBADailyBalances
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_business_date IN DATE,
        p_status IN CHAR := 'U'
    );

    PROCEDURE pGenerateFAKDailyBalances
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_business_date IN DATE,
        p_status IN CHAR := 'U'
    );

    PROCEDURE pEbaBalancesRollback
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER
    );

    PROCEDURE pFakBalancesRollback
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER
    );

    FUNCTION pValidateEntityProcGroup
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER
    )
    RETURN BOOLEAN;


    /**************************************************************************
     * Declare private global attributes
     **************************************************************************/

    /* Declare Working Global Variables                                         */
    gEntityConfiguration        SLR_ENTITIES%ROWTYPE;
    gJournalEntity              SLR_JRNL_HEADERS.JH_JRNL_ENTITY%TYPE;
    gJournalType                SLR_JRNL_HEADERS.JH_JRNL_TYPE%TYPE;
    gJournalDate                SLR_JRNL_HEADERS.JH_JRNL_DATE%TYPE;
    gFromJrnlId                 NUMBER;
    gToJrnlId                   NUMBER;
    gUseHeaders                 BOOLEAN;
    gCurBusYear                 SLR_ENTITY_PERIODS.EP_BUS_YEAR%TYPE;

    gJrnlNumLines               NUMBER;                 -- TTP1038
    gNumLinesTrigParallel       NUMBER := 0;            -- TTP1038
    gForAllArrayLimit           NUMBER;                 -- TTP1038

    /* Declare Journal Type Variables                                           */
    gJournalTypes               SLR_JRNL_TYPES%ROWTYPE;

    /* Operational Variables                                                    */
    gSTART_BLOCK_GETS           NUMBER(38);
    gSTART_CONSISTENT_GETS      NUMBER(38);
    gSTART_PHYSICAL_READS       NUMBER(38);
    gSTART_BLOCK_CHANGES        NUMBER(38);
    gSTART_CONSISTENT_CHANGES   NUMBER(38);
    gEND_BLOCK_GETS             NUMBER(38);
    gEND_CONSISTENT_GETS        NUMBER(38);
    gEND_PHYSICAL_READS         NUMBER(38);
    gEND_BLOCK_CHANGES          NUMBER(38);
    gEND_CONSISTENT_CHANGES     NUMBER(38);
    gRESULT_BLOCK_GETS          NUMBER(38);
    gRESULT_CONSISTENT_GETS     NUMBER(38);
    gRESULT_PHYSICAL_READS      NUMBER(38);
    gRESULT_BLOCK_CHANGES       NUMBER(38);
    gRESULT_CONSISTENT_CHANGES  NUMBER(38);
    gROWCNT_LIMIT_NUMBER NUMBER(38);

    /* Declare Statistics Global Variables                                      */
    gPostStartTime              DATE;
    gPostEndTime                DATE;

    -- Error logging attributes
    gv_table_name               VARCHAR2(30);
    gv_msg                      VARCHAR2(1000);
    gs_stage                    CHAR(3) := 'SLR';
    gv_marked_posting           BOOLEAN;

    -- For new way of posting
    gv_local_index_eba BOOLEAN := FALSE;
    gv_local_index_fak BOOLEAN := FALSE;
    gv_global_index_eba BOOLEAN := FALSE;
    gv_global_index_fak BOOLEAN := FALSE;

    gv_eba_balances_gen_mode INT := 2;
    gv_fak_balances_gen_mode INT := 2;

    gv_gen_last_bal_for_BD       BOOLEAN := FALSE;

    e_internal_processing_error EXCEPTION;
    e_lock_acquire_error EXCEPTION;
    e_fak_daily_balances_error EXCEPTION;
    e_wrong_posting_date_flag EXCEPTION;

    c_lock_request_timeout CONSTANT NUMBER := 300; -- seconds
    c_process_name CONSTANT VARCHAR2(10) := 'Post';
    c_unused_date_for_lb CONSTANT DATE := TO_DATE('1972-01-01', 'YYYY-MM-DD');

    /**************************************************************************
    * Processing
    **************************************************************************/
    -- ------------------------------------------------------------------------
    -- Procecure:    pPostJournals
    -- Description: Control procedure to Post Journals
    -- ------------------------------------------------------------------------
PROCEDURE pPostJournals
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE,
    p_rate_set IN slr_entities.ent_rate_set%TYPE
    )
    IS
        s_proc_name VARCHAR2(65) := 'SLR_POST_JOURNALS_PKG.pPostJournals';
        lv_business_date SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE;
        lv_oldest_backdate SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
        lv_oldest_backdate_max SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE;
        lv_post_fak_balances SLR_ENTITIES.ENT_POST_FAK_BALANCES%TYPE;
        lv_entity_config SLR_ENTITIES%ROWTYPE;
        lv_rollback_eba BOOLEAN := FALSE;
        lv_rollback_fak BOOLEAN := FALSE;
        lv_start_time   PLS_INTEGER := 0;
        e_bad_journals  EXCEPTION;
        e_no_rows EXCEPTION;
        e_others        EXCEPTION;
        lv_rate_set VARCHAR2(2500);  --- for check p_rate_set
        vCount NUMBER;
        lv_balance_counter NUMBER;
        lv_balance_counter_old_bd NUMBER;
      lv_cursor    NUMBER ;
        lv_countrows NUMBER;
      lv_sql Varchar2 (32000);
      v_bus_date_flag SLR_SYSTEM_CONFIG.PARAM_VALUE%TYPE;
        lv_entity SLR_ENTITIES.ENT_ENTITY%TYPE;

    BEGIN
        SLR_ADMIN_PKG.InitLog(p_epg_id, p_process_id);
        SLR_ADMIN_PKG.Debug(s_proc_name || ' - begin');
        gp_process_id:= p_process_id;

        -- ----------------------------------------------------------------------
        -- PACKAGE REGISTRATION
        -- ----------------------------------------------------------------------

        EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
        EXECUTE IMMEDIATE 'ALTER SESSION SET DDL_LOCK_TIMEOUT = ' || SLR_UTILITIES_PKG.fGetDdlLockTimeout();

        IF NOT pValidateEntityProcGroup(p_epg_id, p_process_id) THEN
            RAISE e_others;
        END IF;

        SELECT count(PARAM_VALUE)
        INTO vCount
        FROM SLR_SYSTEM_CONFIG
        WHERE PARAM_NAME = 'POSTING_DATE_DERIVATION';

        IF vCount = 1 THEN
            SELECT PARAM_VALUE
            INTO v_bus_date_flag
            FROM SLR_SYSTEM_CONFIG
            WHERE PARAM_NAME = 'POSTING_DATE_DERIVATION';
        ELSE
            v_bus_date_flag := 'E';
        END IF;

        IF v_bus_date_flag = 'E' THEN
            SELECT ENT_BUSINESS_DATE, ENT_POST_FAK_BALANCES
            INTO lv_business_date, lv_post_fak_balances
            FROM SLR_ENTITIES
            WHERE ENT_ENTITY =
            (
                SELECT EPG_ENTITY
                FROM SLR_ENTITY_PROC_GROUP
                WHERE EPG_ID = p_epg_id
                AND ROWNUM = 1
            );
        ELSIF v_bus_date_flag = 'G' THEN
            SELECT ENT_POST_FAK_BALANCES
            INTO lv_post_fak_balances
            FROM SLR_ENTITIES
            WHERE ENT_ENTITY =
                  (
                      SELECT EPG_ENTITY
                      FROM SLR_ENTITY_PROC_GROUP
                      WHERE EPG_ID = p_epg_id
                        AND ROWNUM = 1
                  );

            SELECT EPG_ENTITY INTO lv_entity
            FROM SLR_ENTITY_PROC_GROUP
            WHERE EPG_ID = p_epg_id
            AND ROWNUM = 1;

            SELECT GP_TODAYS_BUS_DATE
            INTO lv_business_date
            FROM FR_GLOBAL_PARAMETER
                LEFT OUTER JOIN FR_LPG_CONFIG
                ON NVL(LC_LPG_ID, 1) = LPG_ID
            WHERE NVL(LC_GRP_CODE, lv_entity) = lv_entity
            AND NVL(LC_LPG_ID,1) = LPG_ID;
        ELSE
            RAISE e_wrong_posting_date_flag;
        END IF;

        -- ----------------------------------------------------------------------
        -- Set Starting Statistics
        -- ----------------------------------------------------------------------
        IF NOT fInitializeProcedure(p_epg_id, p_process_id, lv_business_date) THEN
            RAISE e_others;
        END IF;
        if gp_business_date is null then 
		  gp_business_date:=lv_business_date;
		ENd if;


        SELECT /*+ PARALLEL(SLR_JRNL_LINES_UNPOSTED, 5)*/  MIN(JLU_EFFECTIVE_DATE)
        INTO lv_oldest_backdate
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_EPG_ID = p_epg_id
            AND JLU_JRNL_STATUS = p_status ;

         IF lv_oldest_backdate IS NULL THEN
       IF NOT fSetPostingStatistics(p_epg_id, p_process_id) THEN
         RAISE e_others;
       END IF;
      COMMIT;
      RAISE e_no_rows; -- no rows to process
        END IF;

    ----- #13336
        If p_rate_set is null then lv_rate_set := null;
        else lv_rate_set := p_rate_set;
        end if;



        SLR_ADMIN_PKG.Debug('Oldest backdate: ' || TO_CHAR(lv_oldest_backdate, 'YYYY-MM-DD'));
        pCreate_reversing_journal(NULL, p_epg_id, p_status,null);
        SLR_ADMIN_PKG.Debug('Reversing journals created');


        -- ----------------------------------------------------------------------
        -- FX Translate
        -- ----------------------------------------------------------------------
        << ApplyFXTranslationProcess >>
        BEGIN
          SLR_TRANSLATE_JOURNALS_PKG.pTranslateJournals(pEpgId => p_epg_id, pRateSet => p_rate_set, pStatus => p_status);
          SLR_ADMIN_PKG.Debug('FX Translate done');

        EXCEPTION
          WHEN SLR_TRANSLATE_JOURNALS_PKG.ge_bad_translate THEN
            -- Fatal, some journals may be valid
            pr_error(1, 'pTranslateJournals: Failed to translate some or all journals. Processing stopped. ', 0, s_proc_name, null, p_process_id, 'Process Id', gs_stage, 'PL/SQL');
            RAISE e_bad_journals;

            WHEN OTHERS THEN
                -- FATAL
				Rollback;
				pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
                gv_msg := 'pTranslateJournals: Failure during translate journals. ';
                pr_error(1, gv_msg || SQLERRM, 0, s_proc_name, null, p_process_id, 'Process Id', gs_stage, 'PL/SQL');
                RAISE e_bad_journals;
        END ApplyFXTranslationProcess;


        -- ----------------------------------------------------------------------
        -- Prepare to Post
        -- ----------------------------------------------------------------------

        FOR r IN
        (
            SELECT /*+ PARALLEL(SLR_LAST_BALANCES_INDEX,5)*/ DISTINCT LBI_GENERATED_FOR FROM SLR_LAST_BALANCES_INDEX
            WHERE LBI_GENERATED_FOR >= lv_oldest_backdate
                AND LBI_EPG_ID = p_epg_id
        )
        LOOP
          DELETE FROM SLR_LAST_BALANCES_INDEX WHERE LBI_EPG_ID = p_epg_id AND LBI_GENERATED_FOR= r.LBI_GENERATED_FOR;
          EXECUTE IMMEDIATE 'ALTER TABLE SLR_LAST_BALANCES TRUNCATE SUBPARTITION '|| SLR_UTILITIES_PKG.fSubpartitionName(p_epg_id, r.LBI_GENERATED_FOR);
        END LOOP;

        pGenerateLastBalances(p_epg_id, p_process_id, lv_oldest_backdate - 1);

        SLR_ADMIN_PKG.Info('Last Balances generated');


        -- ----------------------------------------------------------------------
        -- Clear SLR_FAK_LAST_BALANCES table
        -- ----------------------------------------------------------------------

        IF lv_post_fak_balances = 'Y' THEN

            FOR r IN
            (
                SELECT /*+PARALLEL(SLR_FAK_LAST_BALANCES_INDEX)*/ DISTINCT LFI_GENERATED_FOR FROM SLR_FAK_LAST_BALANCES_INDEX
                WHERE LFI_GENERATED_FOR >= lv_oldest_backdate
                    AND LFI_EPG_ID = p_epg_id
            )
            LOOP
              DELETE FROM SLR_FAK_LAST_BALANCES_INDEX WHERE LFI_EPG_ID = p_epg_id AND LFI_GENERATED_FOR= r.LFI_GENERATED_FOR;
              EXECUTE IMMEDIATE 'ALTER TABLE SLR_FAK_LAST_BALANCES TRUNCATE SUBPARTITION '|| SLR_UTILITIES_PKG.fSubpartitionName(p_epg_id, r.LFI_GENERATED_FOR);
            END LOOP;

        END IF;

        -- ----------------------------------------------------------------------
        -- Generate EBA Balances
        -- ----------------------------------------------------------------------
        SELECT COUNT(edb_eba_id) INTO lv_balance_counter
        FROM slr_eba_daily_balances
        WHERE slr_eba_daily_balances.edb_balance_date = lv_business_date
          AND slr_eba_daily_balances.edb_epg_id = p_epg_id
          AND rownum = 1;

        SELECT COUNT(edb_eba_id) INTO lv_balance_counter_old_bd
        FROM slr_eba_daily_balances
        WHERE slr_eba_daily_balances.edb_balance_date >= lv_oldest_backdate
          AND slr_eba_daily_balances.edb_epg_id = p_epg_id
          AND rownum = 1;

        SELECT /*+ PARALLEL(SLR_JRNL_LINES_UNPOSTED, 5)*/
             MAX(jlu_effective_date) INTO lv_oldest_backdate_max
        FROM slr_jrnl_lines_unposted
        WHERE jlu_epg_id = p_epg_id
          AND jlu_jrnl_status = p_status;


        IF lv_oldest_backdate = lv_business_date AND lv_balance_counter = 0 THEN
          SLR_ADMIN_PKG.Debug('EBA Balances generation mode: 3');
          pGenerateEBADailyBalances(p_epg_id, p_process_id, lv_business_date, p_status);
        ELSIF lv_oldest_backdate = lv_oldest_backdate_max AND lv_balance_counter_old_bd = 0 THEN
            slr_admin_pkg.debug('EBA Balances generation mode: 3');
            pgenerateebadailybalances(p_epg_id,
                                      p_process_id,
                                      lv_oldest_backdate,
                                      p_status);
        ELSE
          CASE gv_eba_balances_gen_mode
              WHEN 1 THEN
                  SLR_ADMIN_PKG.Debug('EBA Balances generation mode: 1');
                  pGenerateEBADailyBalances(p_epg_id, p_process_id, lv_business_date, lv_oldest_backdate, p_status);
                  lv_rollback_eba := TRUE;
              WHEN 2 THEN
                  SLR_ADMIN_PKG.Debug('EBA Balances generation mode: 2');
                  pGenerateEBADailyBalancesMerge(p_epg_id, p_process_id, lv_business_date, lv_oldest_backdate, p_status);
          END CASE;
        END IF;
        SLR_ADMIN_PKG.Debug('EBA Daily Balances generated');

        -- ----------------------------------------------------------------------
        -- Generate FAK Balances
        -- ----------------------------------------------------------------------
        IF lv_post_fak_balances = 'Y' THEN

          IF lv_oldest_backdate = lv_business_date AND lv_balance_counter = 0 THEN
            SLR_ADMIN_PKG.Debug('FAK Balances generation mode: 3');
            pGenerateFAKDailyBalances(p_epg_id, p_process_id, lv_business_date, p_status);
          ELSIF lv_oldest_backdate = lv_oldest_backdate_max AND lv_balance_counter_old_bd = 0   THEN
            SLR_ADMIN_PKG.Debug('FAK Balances generation mode: 3');
            pGenerateFAKDailyBalances(p_epg_id,
                                      p_process_id,
                                      lv_oldest_backdate,
                                      p_status);
          ELSE
            CASE gv_fak_balances_gen_mode
                WHEN 1 THEN
                    SLR_ADMIN_PKG.Debug('FAK Balances generation mode: 1');
                    pGenerateFAKDailyBalances(p_epg_id, p_process_id, lv_business_date, lv_oldest_backdate, p_status);
                    lv_rollback_fak := TRUE;
                WHEN 2 THEN
                    SLR_ADMIN_PKG.Debug('FAK Balances generation mode: 2');
                    pGenerateFAKDailyBalancesMerge(p_epg_id, p_process_id, lv_business_date, lv_oldest_backdate, p_status);
            END CASE;
            SLR_ADMIN_PKG.Debug('FAK Daily Balances generated');
          END IF;
        END IF;

        -- ---------------------------------------------------------------------
        -- Obtaining date from FR_GLOBAL_PARAMETER
        -- ---------------------------------------------------------------------

        -- It is important that the MAH date is used for the journal header date
        -- instead of the current SLR date as the dates are rolled at different times.
        -- If you want to be able to pick up all journals posted since the last batch
        -- you need the MAH date as the SLR date is rolled at the start of the batch
        -- and the MAH date is rolled at the end of the batch.
        pg_process_state.log_proc(p_conf_group   => 'SLR',
                                  p_stage         => 'slr_post_journals.postjournals_slr_jrnl_headers',
                                  p_process_id    => p_process_id,
                                  p_epg_id        => p_epg_id,
								  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
								  p_business_date => gp_business_date,
                                  p_object_name   => 'SLR_JRNL_HEADERS',
                                  p_start_dt      => sysdate,
                                  p_status        => 'P');


        lv_START_TIME:=DBMS_UTILITY.GET_TIME();
        lv_sql :='
            INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'POSTING_HEADERS') || ' INTO SLR_JRNL_HEADERS
            (
                JH_JRNL_ID,
                JH_JRNL_TYPE,
                JH_JRNL_DATE,
                JH_JRNL_ENTITY,
                JH_JRNL_EPG_ID,
                JH_JRNL_STATUS,
                JH_JRNL_STATUS_TEXT,
                JH_JRNL_PROCESS_ID,
                JH_JRNL_DESCRIPTION,
                JH_JRNL_SOURCE,
                JH_JRNL_SOURCE_JRNL_ID,
                JH_JRNL_PREF_STATIC_SRC,
                JH_JRNL_REF_ID,
                JH_JRNL_REV_DATE,
                JH_JRNL_AUTHORISED_BY,
                JH_JRNL_AUTHORISED_ON,
                JH_JRNL_VALIDATED_BY,
                JH_JRNL_VALIDATED_ON,
                JH_JRNL_POSTED_BY,
                JH_JRNL_POSTED_ON,
                JH_JRNL_TOTAL_HASH_DEBIT,
                JH_JRNL_TOTAL_HASH_CREDIT,
                JH_JRNL_TOTAL_LINES,
                JH_CREATED_BY,
                JH_CREATED_ON,
                JH_AMENDED_BY,
                JH_AMENDED_ON,
                JH_BUS_POSTING_DATE,
                JH_JRNL_INTERNAL_PERIOD_FLAG,
                JH_JRNL_ENT_RATE_SET,
                JH_JRNL_TRANSLATION_DATE
            )
            SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'POSTING_HEADERS_SUBSELECT') || '
                JLU_JRNL_HDR_ID,
                MAX(JLU_JRNL_TYPE),
                MAX(JLU_EFFECTIVE_DATE),
                MAX(JLU_ENTITY),
                MAX(JLU_EPG_ID),
                ''P'',
                NULL,
                MAX(NVL(:p_process_id ,JLU_JRNL_PROCESS_ID)),
                MAX(JLU_JRNL_DESCRIPTION),
                MAX(JLU_JRNL_SOURCE),
                MAX(JLU_JRNL_SOURCE_JRNL_ID),
                MAX(JLU_JRNL_PREF_STATIC_SRC),
                MAX(JLU_JRNL_REF_ID),
                MAX(JLU_JRNL_REV_DATE),
                MAX(JLU_JRNL_AUTHORISED_BY),
                MAX(JLU_JRNL_AUTHORISED_ON),
                MAX(JLU_JRNL_VALIDATED_BY),
                MAX(JLU_JRNL_VALIDATED_ON),
                NVL(MAX(JLU_JRNL_POSTED_BY),USER),
                NVL(MAX(JLU_JRNL_POSTED_ON),SYSDATE),
                SUM (
                  CASE WHEN ROUND(JLU_TRAN_AMOUNT,2) > 0.00 THEN JLU_TRAN_AMOUNT ELSE 0 END
                ) AS JLU_JRNL_TOTAL_HASH_DEBIT,
                SUM (
                  CASE WHEN ROUND(JLU_TRAN_AMOUNT,2) < 0.00 THEN JLU_TRAN_AMOUNT ELSE 0 END
                ) AS JLU_JRNL_TOTAL_HASH_CREDIT,
                COUNT(*), --ADD AGGREGATION
                MAX(JLU_CREATED_BY),
                MAX(JLU_CREATED_ON),
                NVL(MAX(JLU_AMENDED_BY),USER),
                NVL(MAX(JLU_AMENDED_ON),SYSDATE),
                 :lv_business_date,
                MAX(JLU_JRNL_INTERNAL_PERIOD_FLAG),
                MAX(JLU_JRNL_ENT_RATE_SET),
                MAX(JLU_TRANSLATION_DATE)
            FROM SLR_JRNL_LINES_UNPOSTED
            WHERE JLU_EPG_ID = :p_epg_id
                AND JLU_JRNL_STATUS = :p_status
            GROUP BY JLU_JRNL_HDR_ID
        ';
    lv_cursor := dbms_sql.open_cursor;
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':lv_business_date',lv_business_date);
    dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);
    dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );
    SLR_ADMIN_PKG.PerfInfo( 'JH. Journal Header query execution elapsed time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
        SLR_ADMIN_PKG.Debug('Headers inserted into SLR_JRNL_HEADERS');

    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         => 'slr_post_journals.postjournals_slr_jrnl_headers',
                                        p_process_id    => p_process_id);

        -- ----------------------------------------------------------------------
        -- Post Lines
        -- ----------------------------------------------------------------------
    pg_process_state.log_proc(p_conf_group   => 'SLR',
                              p_stage        => 'slr_post_journals.postjournals_slr_jrnl_lines',
                              p_process_id   => p_process_id,
                              p_epg_id       => p_epg_id,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
							  p_business_date => gp_business_date,
                              p_object_name  => 'SLR_JRNL_LINES',
                              p_start_dt     => sysdate,
                              p_status       => 'P');

    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
       lv_sql :='
            INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'POSTING_LINES') || ' INTO SLR_JRNL_LINES
            (
                JL_JRNL_HDR_ID,
                JL_JRNL_LINE_NUMBER,
                JL_FAK_ID,
                JL_EBA_ID,
                JL_JRNL_STATUS,
                JL_JRNL_STATUS_TEXT,
                JL_JRNL_PROCESS_ID,
                JL_DESCRIPTION,
                JL_SOURCE_JRNL_ID,
                JL_EFFECTIVE_DATE,
                JL_VALUE_DATE,
                JL_ENTITY,
                JL_EPG_ID,
                JL_ACCOUNT,
                JL_SEGMENT_1,
                JL_SEGMENT_2,
                JL_SEGMENT_3,
                JL_SEGMENT_4,
                JL_SEGMENT_5,
                JL_SEGMENT_6,
                JL_SEGMENT_7,
                JL_SEGMENT_8,
                JL_SEGMENT_9,
                JL_SEGMENT_10,
                JL_ATTRIBUTE_1,
                JL_ATTRIBUTE_2,
                JL_ATTRIBUTE_3,
                JL_ATTRIBUTE_4,
                JL_ATTRIBUTE_5,
                JL_REFERENCE_1,
                JL_REFERENCE_2,
                JL_REFERENCE_3,
                JL_REFERENCE_4,
                JL_REFERENCE_5,
                JL_REFERENCE_6,
                JL_REFERENCE_7,
                JL_REFERENCE_8,
                JL_REFERENCE_9,
                JL_REFERENCE_10,
                JL_TRAN_CCY,
                JL_TRAN_AMOUNT,
                JL_BASE_RATE,
                JL_BASE_CCY,
                JL_BASE_AMOUNT,
                JL_LOCAL_RATE,
                JL_LOCAL_CCY,
                JL_LOCAL_AMOUNT,
                JL_CREATED_BY,
                JL_CREATED_ON,
                JL_AMENDED_BY,
                JL_AMENDED_ON,
                JL_TRANSLATION_DATE,
                JL_BUS_POSTING_DATE,
                JL_PERIOD_MONTH,
                JL_PERIOD_YEAR,
                JL_PERIOD_LTD,
        JL_TYPE
            )
            SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'POSTING_LINES_SUBSELECT') || '
                JLU_JRNL_HDR_ID,
                JLU_JRNL_LINE_NUMBER,
                JLU_FAK_ID,
                JLU_EBA_ID,
                ''P'',
                NULL,
                NVL(:p_process_id ,JLU_JRNL_PROCESS_ID),
                JLU_DESCRIPTION,
                JLU_SOURCE_JRNL_ID,
                JLU_EFFECTIVE_DATE,
                JLU_VALUE_DATE,
                JLU_ENTITY,
                JLU_EPG_ID,
                JLU_ACCOUNT,
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
                JLU_ATTRIBUTE_1,
                JLU_ATTRIBUTE_2,
                JLU_ATTRIBUTE_3,
                JLU_ATTRIBUTE_4,
                JLU_ATTRIBUTE_5,
                JLU_REFERENCE_1,
                JLU_REFERENCE_2,
                JLU_REFERENCE_3,
                JLU_REFERENCE_4,
                JLU_REFERENCE_5,
                JLU_REFERENCE_6,
                JLU_REFERENCE_7,
                JLU_REFERENCE_8,
                JLU_REFERENCE_9,
                JLU_REFERENCE_10,
                JLU_TRAN_CCY,
                JLU_TRAN_AMOUNT,
                JLU_BASE_RATE,
                JLU_BASE_CCY,
                JLU_BASE_AMOUNT,
                JLU_LOCAL_RATE,
                JLU_LOCAL_CCY,
                JLU_LOCAL_AMOUNT,
                JLU_CREATED_BY,
                JLU_CREATED_ON,
                NVL(JLU_AMENDED_BY,USER),
                NVL(JLU_AMENDED_ON,SYSDATE),
                JLU_TRANSLATION_DATE,
                :lv_business_date  AS JL_BUS_POSTING_DATE,
                JLU_PERIOD_MONTH,
                JLU_PERIOD_YEAR,
                JLU_PERIOD_LTD,
                JLU_TYPE
            FROM V_SLR_JRNL_LINES_UNPOSTED_JT
            WHERE JLU_EPG_ID = :p_epg_id
              AND JLU_JRNL_STATUS = :p_status
              AND JT_BALANCE_TYPE_NUMBER = 1
        ';
        lv_cursor := dbms_sql.open_cursor;
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
        dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
        dbms_sql.bind_variable( lv_cursor, ':lv_business_date',lv_business_date);
        dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);
        dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
        lv_CountRows := dbms_sql.execute( lv_cursor );
        dbms_sql.close_cursor( lv_cursor );
        SLR_ADMIN_PKG.PerfInfo( 'JL. Journal lines query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
        SLR_ADMIN_PKG.Debug('Lines inserted into SLR_JRNL_LINES');

        pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                            p_stage         => 'slr_post_journals.postjournals_slr_jrnl_lines',
                                            p_process_id    => p_process_id);

        -- ----------------------------------------------------------------------
        -- Clear Posted Data
        -- ----------------------------------------------------------------------
        IF p_UseHeaders THEN -- means processing for manuals
            DELETE
            FROM SLR_JRNL_HEADERS_UNPOSTED
            WHERE
            EXISTS (SELECT 1
                    FROM SLR_JRNL_LINES_UNPOSTED
                    WHERE
                        JLU_EPG_ID = p_epg_id
                        AND JLU_JRNL_STATUS = p_status
            )
           AND  JHU_EPG_ID = p_epg_id
           AND  JHU_JRNL_STATUS = p_status;
        END IF;


        COMMIT;
        lv_rollback_eba := FALSE;
        lv_rollback_fak := FALSE;
        SLR_ADMIN_PKG.Info('Committed: (1) generating FAK/EBA daily balances; (2) inserting records into SLR_JRNL_LINES and SLR_JRNL_HEADERS.');

        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE SLR_JRNL_LINES_UNPOSTED TRUNCATE SUBPARTITION
                P' || p_epg_id || '_S' || p_status;
        EXCEPTION
            WHEN OTHERS THEN
                pWriteLogError(s_proc_name, 'SLR_JRNL_LINES',
                    'Posting done, but records not removed from SLR_JRNL_LINES_UNPOSTED', p_process_id,p_epg_id , p_status );
                SLR_ADMIN_PKG.Error('Posting done, but records not removed from SLR_JRNL_LINES_UNPOSTED');
        END;

        IF  (gv_gen_last_bal_for_BD) THEN
            SLR_ADMIN_PKG.Info('Generating Last Balances for the current Bussiness date.');
            pGenerateLastBalances(p_epg_id, p_process_id, SLR_UTILITIES_PKG.fEntityGroupCurrBusDate(p_epg_id) );
        END IF;

        -- ----------------------------------------------------------------------
        -- Update Posting Statistics
        -- ----------------------------------------------------------------------
        IF NOT fSetPostingStatistics(p_epg_id, p_process_id) THEN
            RAISE e_others;
        END IF;
        COMMIT;
       pg_process_state.Set_Process_Finished(p_process_id => p_process_id);
       slr_admin_pkg.droppart(p_table_name => 'SLR_JRNL_LINES_UNPOSTED_TMP', p_part_name => 'P' || p_epg_id);
        --EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';

        SLR_ADMIN_PKG.Debug(s_proc_name || ' - end');

    EXCEPTION
        WHEN e_no_rows THEN
            --EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
            pr_error(0, 'No rows to post for EPG ' || p_epg_id, 1, s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', p_process_id, 'Process Id', 'SLR', 'PL/SQL');
            SLR_ADMIN_PKG.Info('No rows to post');

        WHEN e_internal_processing_error THEN
            gv_msg := 'Internal processing error. Please check fr_log for details.';
           -- EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
            SLR_ADMIN_PKG.Error('Error during posting journals (e_internal_processing_error).');
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            RAISE_APPLICATION_ERROR(-20001, gv_msg);

        WHEN e_fak_daily_balances_error THEN
            IF lv_rollback_eba = TRUE THEN
                pEbaBalancesRollback(p_epg_id, p_process_id);
            END IF;
            --EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
            SLR_ADMIN_PKG.Error('Error during posting journals (e_fak_daily_balances_error).');
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            RAISE_APPLICATION_ERROR(-20001, 'Error during posting journals.');

        WHEN e_wrong_posting_date_flag THEN
            gv_msg := 'Wrong Posting Date Derivation flag. It should be either E or G. Instead value ' || v_bus_date_flag || ' is set in the SLR_SYSTEM_CONFIG table.';
           -- EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
            SLR_ADMIN_PKG.Error('Error during posting journals (e_wrong_posting_date_flag).');
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            RAISE_APPLICATION_ERROR(-20001, gv_msg);

        WHEN OTHERS THEN
            SLR_ADMIN_PKG.Info('Rollback');
            ROLLBACK;
            IF lv_rollback_eba = TRUE THEN
                pEbaBalancesRollback(p_epg_id, p_process_id);
            END IF;
            IF lv_rollback_fak = TRUE THEN
                pFakBalancesRollback(p_epg_id, p_process_id);
            END IF;
            pWriteLogError(s_proc_name, 'SLR_JRNL_LINES', 'Error during posting journals.',
                p_process_id,p_epg_id , p_status );
            SLR_ADMIN_PKG.Error('Error during posting journals');
            --EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
            pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
            RAISE_APPLICATION_ERROR(-20001, 'Error during posting journals. : ' || SQLERRM);

    END pPostJournals;


    PROCEDURE pSetEbaIndexes(p_local BOOLEAN, p_global BOOLEAN)
    AS
    BEGIN
        gv_local_index_eba := p_local;
        gv_global_index_eba := p_global;
    END;



    PROCEDURE pSetFakIndexes(p_local BOOLEAN, p_global BOOLEAN)
    AS
    BEGIN
        gv_local_index_fak := p_local;
        gv_global_index_fak := p_global;
    END;



    PROCEDURE pEbaBalancesGenerationMode(p_mode INT)
    AS
    BEGIN
        gv_eba_balances_gen_mode := p_mode;
    END;



    PROCEDURE pFakBalancesGenerationMode(p_mode INT)
    AS
    BEGIN
        gv_fak_balances_gen_mode := p_mode;
    END;


    PROCEDURE pStatusGenLastBalForBD(p_generate BOOLEAN)
    AS
    BEGIN
        gv_gen_last_bal_for_BD := p_generate;
    END;

    -- ------------------------------------------------------------------------
    -- Function to Initialize Variables and Defaults
    -- ------------------------------------------------------------------------
    -- Straight forward procedure to setup variables and statistics for the
    -- process.
    --
    -- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2
    -- BJP 17-AUG-2007 Added setting of current entity business year pCurBusYear
    -- ------------------------------------------------------------------------
      FUNCTION fInitializeProcedure
    ( p_epg_id        IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_process_id    IN NUMBER,
      p_business_date IN SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE
       )
     RETURN BOOLEAN
    IS
        s_proc_name  VARCHAR2(80) := 'SLR_POST_JOURNALS_PKG.fInitializeProcedure';
        s_SID VARCHAR2(256);


    BEGIN

        -- Set start time of the process
        -- ------------------------------------------------------------------------
        gPostStartTime     := SYSDATE;

        -- Step 1. Set start IO for the session
        -- ------------------------------------------------------------------------
        gv_table_name := 'V$SESSION';

        SELECT  i.BLOCK_GETS,CONSISTENT_GETS,PHYSICAL_READS,BLOCK_CHANGES,CONSISTENT_CHANGES
        INTO    gSTART_BLOCK_GETS,gSTART_CONSISTENT_GETS,gSTART_PHYSICAL_READS,gSTART_BLOCK_CHANGES,gSTART_CONSISTENT_CHANGES
        FROM    V$SESSION s,  V$SESS_IO i
        WHERE s.sid = SYS_CONTEXT('userenv','sid') AND i.SID = s.SID;

    select sys_context('userenv','SID') SID
    into s_SID
    from DUAL;

        -- Step 2. Insert record to the Job statistics table
        -- ------------------------------------------------------------------------
        gv_table_name := 'SLR_JOB_STATISTICS';

        INSERT INTO SLR_JOB_STATISTICS (
                                        JS_PROCESS_ID,
                                        JS_PROCESS_NAME,
                                        JS_EPG_ID,
                                        JS_START_TIME,
                    JS_SID,
                    JS_BUSINESS_DATE
                                        )
                                  VALUES(
                                         p_process_id,
                                         c_process_name,
                                         p_epg_id,
                                         gPostStartTime,
                     s_SID,
                     p_business_date
                     );

        COMMIT;

        -- Step 3. Enable Parallel processing by Oracle
        -- ------------------------------------------------------------------------

        -- commented out, because it's already done in pPostJournals
        -- EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
            pWriteLogError(s_proc_name, gv_table_name, 'Failure to initialise procedure for entity processing group ['||p_epg_id||'] '
            , null /*p_process_id*/,null);
            SLR_ADMIN_PKG.Error('Failure to initialise procedure');
            RETURN FALSE;

    END fInitializeProcedure;
    -- ------------------------------------------------------------------------
    -- Function to Set Posting Statistics
    --
    -- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2
    -- ------------------------------------------------------------------------
    FUNCTION fSetPostingStatistics
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER
    )
    RETURN BOOLEAN IS

        s_proc_name  VARCHAR2(80) := 'SLR_POST_JOURNALS_PKG.fSetPostingStatistics';

    BEGIN

        -- Set IO Stats
        -- --------------------------------------------------------------------
        gv_table_name := 'V$SESSION';

        SELECT  i.BLOCK_GETS,CONSISTENT_GETS,PHYSICAL_READS,BLOCK_CHANGES,CONSISTENT_CHANGES
        INTO    gEND_BLOCK_GETS,gEND_CONSISTENT_GETS,gEND_PHYSICAL_READS,gEND_BLOCK_CHANGES,gEND_CONSISTENT_CHANGES
        FROM    V$SESSION s,  V$SESS_IO i
        WHERE s.sid = SYS_CONTEXT('userenv','sid') AND i.SID = s.SID;

        gRESULT_BLOCK_GETS          := gEND_BLOCK_GETS        - gSTART_BLOCK_GETS;
        gRESULT_CONSISTENT_GETS     := gEND_CONSISTENT_GETS   - gSTART_CONSISTENT_GETS;
        gRESULT_PHYSICAL_READS      := gEND_PHYSICAL_READS    - gSTART_PHYSICAL_READS;
        gRESULT_BLOCK_CHANGES       := gEND_BLOCK_CHANGES     - gSTART_BLOCK_CHANGES;
        gRESULT_CONSISTENT_CHANGES  := gEND_CONSISTENT_CHANGES- gSTART_CONSISTENT_CHANGES;

        gv_table_name := 'SLR_JOB_STATISTICS';

        UPDATE SLR_JOB_STATISTICS
        SET     JS_END_TIME         = SYSDATE,
                RESULT_BLOCK_GETS           = gRESULT_BLOCK_GETS,
                RESULT_CONSISTENT_GETS      = gRESULT_CONSISTENT_GETS,
                RESULT_PHYSICAL_READS       = gRESULT_PHYSICAL_READS,
                RESULT_BLOCK_CHANGES        = gRESULT_BLOCK_CHANGES,
                RESULT_CONSISTENT_CHANGES   = gRESULT_CONSISTENT_CHANGES
        WHERE   JS_PROCESS_ID = p_process_id
        AND     JS_PROCESS_NAME = c_process_name;

        RETURN TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- non fatal error
            pr_error(1, 'No session data. ', 0, s_proc_name, 0, gv_table_name, p_process_id, 'Process Id', gs_stage, 'PL/SQL', SQLCODE);
            SLR_ADMIN_PKG.Info('No session data in SLR_JOB_STATISTICS');
            RETURN TRUE;

        WHEN OTHERS THEN
            ROLLBACK;
            pWriteLogError(s_proc_name, gv_table_name, 'Failure to set posting statistics. '||sqlerrm
            , null /*p_process_id*/,null);
            SLR_ADMIN_PKG.Error('Error: Failure to set posting statistics. ' || sqlerrm);
            RETURN FALSE;

    END fSetPostingStatistics;

    -- ---------------------------------------------------------------------------
    -- Procedure:    pWriteLogError
    -- Description:  Wrap writing to the error log to set up common params.
    -- Note:         pr_error is an autonomous transaction to permit error logging
    --               while rolling back other updates.
    -- Author:      Tony Watton
    -- ---------------------------------------------------------------------------
    PROCEDURE pWriteLogError
    (
        p_proc_name in VARCHAR2,
        p_table_name in VARCHAR2,
        p_msg in VARCHAR2,
        p_process_id in SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
        p_epg_id        IN  SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status        IN  CHAR := 'U',
        p_entity        IN  slr_entities.ent_entity%TYPE:=NULL
    )
    IS
    BEGIN
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(p_proc_name, p_table_name, p_msg, p_process_id,p_epg_id,p_status,p_entity);

    END pWriteLogError;

--------------------------------------------------------------------------------


PROCEDURE pGenerateLastBalances
(
  p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
  p_day DATE -- last balances will be generated for this day
)
AS
    s_proc_name VARCHAR2(65) := 'SLR_POST_JOURNALS_PKG.pGenerateLastBalances';
  lv_sql_create_lb VARCHAR2(32000);
  lv_table_name VARCHAR2(32);
  lv_last_correct_lb DATE;
  lv_START_TIME   PLS_INTEGER := 0;
  lv_BusDate  DATE;
  lv_sql VARCHAR2(32000);
  lv_inserted BOOLEAN := FALSE;
  lv_cursor    NUMBER ;
  lv_countrows NUMBER;
BEGIN

  SELECT MAX(LBI_GENERATED_FOR)
  INTO lv_last_correct_lb
  FROM SLR_LAST_BALANCES_INDEX
    WHERE LBI_EPG_ID = p_epg_id
        AND LBI_GENERATED_FOR <= p_day;

    lv_BusDate:= SLR_UTILITIES_PKG.fEntityGroupCurrBusDate(p_epg_id);

  lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    IF lv_last_correct_lb IS NULL THEN
        lv_sql:= '
            INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'GENERATE_LAST_BALANCES') || ' INTO SLR_LAST_BALANCES
            (
                LB_FAK_ID,
                LB_EBA_ID,
                LB_BALANCE_DATE,
                LB_BALANCE_TYPE,
                LB_TRAN_DAILY_MOVEMENT,
                LB_TRAN_MTD_BALANCE,
                LB_TRAN_QTD_BALANCE,
                LB_TRAN_YTD_BALANCE,
                LB_TRAN_LTD_BALANCE,
                LB_BASE_DAILY_MOVEMENT,
                LB_BASE_MTD_BALANCE,
                LB_BASE_QTD_BALANCE,
                LB_BASE_YTD_BALANCE,
                LB_BASE_LTD_BALANCE,
                LB_LOCAL_DAILY_MOVEMENT,
                LB_LOCAL_MTD_BALANCE,
                LB_LOCAL_QTD_BALANCE,
                LB_LOCAL_YTD_BALANCE,
                LB_LOCAL_LTD_BALANCE,
                LB_ENTITY,
                LB_EPG_ID,
                LB_PERIOD_MONTH,
                LB_PERIOD_QTR,
                LB_PERIOD_YEAR,
                LB_PERIOD_LTD,
                LB_GENERATED_FOR
            )
            SELECT
                EDB_FAK_ID,
                EDB_EBA_ID,
                EDB_BALANCE_DATE,
                EDB_BALANCE_TYPE,
                EDB_TRAN_DAILY_MOVEMENT,
                EDB_TRAN_MTD_BALANCE,
                EDB_TRAN_QTD_BALANCE,
                EDB_TRAN_YTD_BALANCE,
                EDB_TRAN_LTD_BALANCE,
                EDB_BASE_DAILY_MOVEMENT,
                EDB_BASE_MTD_BALANCE,
                EDB_BASE_QTD_BALANCE,
                EDB_BASE_YTD_BALANCE,
                EDB_BASE_LTD_BALANCE,
                EDB_LOCAL_DAILY_MOVEMENT,
                EDB_LOCAL_MTD_BALANCE,
                EDB_LOCAL_QTD_BALANCE,
                EDB_LOCAL_YTD_BALANCE,
                EDB_LOCAL_LTD_BALANCE,
                EDB_ENTITY,
                EDB_EPG_ID,
                EDB_PERIOD_MONTH,
                EDB_PERIOD_QTR,
                EDB_PERIOD_YEAR,
                EDB_PERIOD_LTD,
                :p_day
            FROM
            (
                SELECT
                    EDB_FAK_ID,
                    EDB_EBA_ID,
                    EDB_BALANCE_DATE,
                    EDB_BALANCE_TYPE,
                    EDB_TRAN_DAILY_MOVEMENT,
                    EDB_TRAN_MTD_BALANCE,
                    EDB_TRAN_QTD_BALANCE,
                    EDB_TRAN_YTD_BALANCE,
                    EDB_TRAN_LTD_BALANCE,
                    EDB_BASE_DAILY_MOVEMENT,
                    EDB_BASE_MTD_BALANCE,
                    EDB_BASE_QTD_BALANCE,
                    EDB_BASE_YTD_BALANCE,
                    EDB_BASE_LTD_BALANCE,
                    EDB_LOCAL_DAILY_MOVEMENT,
                    EDB_LOCAL_MTD_BALANCE,
                    EDB_LOCAL_QTD_BALANCE,
                    EDB_LOCAL_YTD_BALANCE,
                    EDB_LOCAL_LTD_BALANCE,
                    EDB_ENTITY,
                    EDB_EPG_ID,
                    EDB_PERIOD_MONTH,
                    EDB_PERIOD_QTR,
                    EDB_PERIOD_YEAR,
                    EDB_PERIOD_LTD,
                    ROW_NUMBER () OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE DESC) rn
                FROM SLR_EBA_DAILY_BALANCES
                WHERE EDB_BALANCE_DATE <= :p_day
                    AND EDB_EPG_ID = :p_epg_id
            )
            WHERE rn = 1
        ';
    lv_cursor:= dbms_sql.open_cursor;
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
        dbms_sql.bind_variable( lv_cursor, ':p_day',p_day);
        dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
        lv_CountRows := dbms_sql.execute( lv_cursor );
        dbms_sql.close_cursor( lv_cursor );


    IF lv_CountRows > 0 THEN
      lv_inserted := TRUE;
    END IF;
    ELSE
        IF lv_last_correct_lb < p_day THEN
            lv_sql:='
                INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'GENERATE_LAST_BALANCES') || ' INTO SLR_LAST_BALANCES
                (
                    LB_FAK_ID,
                    LB_EBA_ID,
                    LB_BALANCE_DATE,
                    LB_BALANCE_TYPE,
                    LB_TRAN_DAILY_MOVEMENT,
                    LB_TRAN_MTD_BALANCE,
                    LB_TRAN_QTD_BALANCE,
                    LB_TRAN_YTD_BALANCE,
                    LB_TRAN_LTD_BALANCE,
                    LB_BASE_DAILY_MOVEMENT,
                    LB_BASE_MTD_BALANCE,
                    LB_BASE_QTD_BALANCE,
                    LB_BASE_YTD_BALANCE,
                    LB_BASE_LTD_BALANCE,
                    LB_LOCAL_DAILY_MOVEMENT,
                    LB_LOCAL_MTD_BALANCE,
                    LB_LOCAL_QTD_BALANCE,
                    LB_LOCAL_YTD_BALANCE,
                    LB_LOCAL_LTD_BALANCE,
                    LB_ENTITY,
                    LB_EPG_ID,
                    LB_PERIOD_MONTH,
                    LB_PERIOD_QTR,
                    LB_PERIOD_YEAR,
                    LB_PERIOD_LTD,
                    LB_GENERATED_FOR
                )
                SELECT
                    EDB_FAK_ID,
                    EDB_EBA_ID,
                    EDB_BALANCE_DATE,
                    EDB_BALANCE_TYPE,
                    EDB_TRAN_DAILY_MOVEMENT,
                    EDB_TRAN_MTD_BALANCE,
                    EDB_TRAN_QTD_BALANCE,
                    EDB_TRAN_YTD_BALANCE,
                    EDB_TRAN_LTD_BALANCE,
                    EDB_BASE_DAILY_MOVEMENT,
                    EDB_BASE_MTD_BALANCE,
                    EDB_BASE_QTD_BALANCE,
                    EDB_BASE_YTD_BALANCE,
                    EDB_BASE_LTD_BALANCE,
                    EDB_LOCAL_DAILY_MOVEMENT,
                    EDB_LOCAL_MTD_BALANCE,
                    EDB_LOCAL_QTD_BALANCE,
                    EDB_LOCAL_YTD_BALANCE,
                    EDB_LOCAL_LTD_BALANCE,
                    EDB_ENTITY,
                    EDB_EPG_ID,
                    EDB_PERIOD_MONTH,
                    EDB_PERIOD_QTR,
                    EDB_PERIOD_YEAR,
                    EDB_PERIOD_LTD,
                    :p_day
                FROM
                (
                    SELECT
                        EDB_BALANCE_DATE,
                        EDB_FAK_ID,
                        EDB_EBA_ID,
                        EDB_TRAN_DAILY_MOVEMENT,
                        EDB_TRAN_MTD_BALANCE,
                        EDB_TRAN_QTD_BALANCE,
                        EDB_TRAN_YTD_BALANCE,
                        EDB_TRAN_LTD_BALANCE,
                        EDB_BASE_DAILY_MOVEMENT,
                        EDB_BASE_MTD_BALANCE,
                        EDB_BASE_QTD_BALANCE,
                        EDB_BASE_YTD_BALANCE,
                        EDB_BASE_LTD_BALANCE,
                        EDB_LOCAL_DAILY_MOVEMENT,
                        EDB_LOCAL_MTD_BALANCE,
                        EDB_LOCAL_QTD_BALANCE,
                        EDB_LOCAL_YTD_BALANCE,
                        EDB_LOCAL_LTD_BALANCE,
                        EDB_BALANCE_TYPE,
                        EDB_ENTITY,
                        EDB_EPG_ID,
                        EDB_PERIOD_MONTH,
                        EDB_PERIOD_QTR,
                        EDB_PERIOD_YEAR,
                        EDB_PERIOD_LTD,
                        ROW_NUMBER () OVER (partition by EDB_BALANCE_TYPE, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE DESC) rn
                    FROM
                    (
                        SELECT
                            LB_BALANCE_DATE AS EDB_BALANCE_DATE,
                            LB_FAK_ID AS EDB_FAK_ID,
                            LB_EBA_ID AS EDB_EBA_ID,
                            LB_TRAN_DAILY_MOVEMENT AS EDB_TRAN_DAILY_MOVEMENT,
                            LB_TRAN_MTD_BALANCE AS EDB_TRAN_MTD_BALANCE,
                            LB_TRAN_QTD_BALANCE AS EDB_TRAN_QTD_BALANCE,
                            LB_TRAN_YTD_BALANCE AS EDB_TRAN_YTD_BALANCE,
                            LB_TRAN_LTD_BALANCE AS EDB_TRAN_LTD_BALANCE,
                            LB_BASE_DAILY_MOVEMENT AS EDB_BASE_DAILY_MOVEMENT,
                            LB_BASE_MTD_BALANCE AS EDB_BASE_MTD_BALANCE,
                            LB_BASE_QTD_BALANCE AS EDB_BASE_QTD_BALANCE,
                            LB_BASE_YTD_BALANCE AS EDB_BASE_YTD_BALANCE,
                            LB_BASE_LTD_BALANCE AS EDB_BASE_LTD_BALANCE,
                            LB_LOCAL_DAILY_MOVEMENT AS EDB_LOCAL_DAILY_MOVEMENT,
                            LB_LOCAL_MTD_BALANCE AS EDB_LOCAL_MTD_BALANCE,
                            LB_LOCAL_QTD_BALANCE AS EDB_LOCAL_QTD_BALANCE,
                            LB_LOCAL_YTD_BALANCE AS EDB_LOCAL_YTD_BALANCE,
                            LB_LOCAL_LTD_BALANCE AS EDB_LOCAL_LTD_BALANCE,
                            LB_BALANCE_TYPE AS EDB_BALANCE_TYPE,
                            LB_ENTITY AS EDB_ENTITY,
                            LB_EPG_ID AS EDB_EPG_ID,
                            LB_PERIOD_MONTH AS EDB_PERIOD_MONTH,
                            LB_PERIOD_QTR AS EDB_PERIOD_QTR,
                            LB_PERIOD_YEAR AS EDB_PERIOD_YEAR,
                            LB_PERIOD_LTD AS EDB_PERIOD_LTD
                        FROM SLR_LAST_BALANCES
                        WHERE LB_GENERATED_FOR = :lv_last_correct_lb
                            AND LB_EPG_ID = :p_epg_id
                        UNION ALL
                        SELECT
                            EDB_BALANCE_DATE,
                            EDB_FAK_ID,
                            EDB_EBA_ID,
                            EDB_TRAN_DAILY_MOVEMENT,
                            EDB_TRAN_MTD_BALANCE,
                            EDB_TRAN_QTD_BALANCE,
                            EDB_TRAN_YTD_BALANCE,
                            EDB_TRAN_LTD_BALANCE,
                            EDB_BASE_DAILY_MOVEMENT,
                            EDB_BASE_MTD_BALANCE,
                            EDB_BASE_QTD_BALANCE,
                            EDB_BASE_YTD_BALANCE,
                            EDB_BASE_LTD_BALANCE,
                            EDB_LOCAL_DAILY_MOVEMENT,
                            EDB_LOCAL_MTD_BALANCE,
                            EDB_LOCAL_QTD_BALANCE,
                            EDB_LOCAL_YTD_BALANCE,
                            EDB_LOCAL_LTD_BALANCE,
                            EDB_BALANCE_TYPE,
                            EDB_ENTITY,
                            EDB_EPG_ID,
                            EDB_PERIOD_MONTH,
                            EDB_PERIOD_QTR,
                            EDB_PERIOD_YEAR,
                            EDB_PERIOD_LTD
                        FROM SLR_EBA_DAILY_BALANCES
                        WHERE EDB_BALANCE_DATE > :lv_last_correct_lb
                            AND EDB_BALANCE_DATE <= :p_day
                            AND EDB_EPG_ID =:p_epg_id
                    )
                )
                WHERE rn = 1
            ';
    lv_cursor:= dbms_sql.open_cursor;
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
        dbms_sql.bind_variable( lv_cursor, ':lv_last_correct_lb',lv_last_correct_lb);
    dbms_sql.bind_variable( lv_cursor, ':p_day',p_day);
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
        lv_CountRows := dbms_sql.execute( lv_cursor );
        dbms_sql.close_cursor( lv_cursor );


      IF lv_CountRows > 0 THEN
        lv_inserted := TRUE;
      END IF;
        END IF;
  END IF;

  /* need to insert here, even if lv_inserted := FALSE, as SLR_LAST_BALANCE_HELPER is used by reporting views as a pointer to SLR_EBA_DAILY_BALANCES */
    MERGE INTO SLR_LAST_BALANCE_HELPER LBH1
    USING (
      SELECT p_epg_id as LBH_EPG_ID FROM dual
    ) LBH2
    ON
    (
       LBH1.LBH_EPG_ID = LBH2.LBH_EPG_ID
    )
    WHEN MATCHED THEN UPDATE SET LBH_GENERATED_FOR = p_day, LBH_BUSSINESS_DATE=lv_BusDate
    WHEN NOT MATCHED THEN INSERT (LBH1.LBH_EPG_ID,LBH1.LBH_GENERATED_FOR,LBH1.LBH_BUSSINESS_DATE) VALUES (p_epg_id,p_day,lv_BusDate);

  /*the content of SLR_LAST_BALANCES_INDEX should match SLR_LAST_BALANCES */
  IF lv_inserted = TRUE THEN
    MERGE INTO SLR_LAST_BALANCES_INDEX LBI1
    USING (
      SELECT p_epg_id as LBI_EPG_ID, p_day as LBI_GENERATED_FOR FROM dual
    ) LBI2
    ON
    (
      LBI1.LBI_EPG_ID = LBI2.LBI_EPG_ID AND LBI1.LBI_GENERATED_FOR = LBI2.LBI_GENERATED_FOR
    )
    WHEN NOT MATCHED THEN INSERT (LBI1.LBI_EPG_ID,LBI1.LBI_GENERATED_FOR) VALUES (p_epg_id,p_day);
  END IF;
    COMMIT;
    SLR_ADMIN_PKG.Debug('Last balances generated.', lv_sql);
  SLR_ADMIN_PKG.PerfInfo( 'LB. Last Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

EXCEPTION
  WHEN OTHERS THEN
     pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
        ROLLBACK;
    pWriteLogError(s_proc_name, 'SLR_LAST_BALANCES',
      'Error during generating SLR_LAST_BALANCES table: ' || SQLERRM,
      p_process_id,p_epg_id );
        SLR_ADMIN_PKG.Error('Error during generating SLR_LAST_BALANCES table: '|| SQLERRM);
        RAISE e_internal_processing_error; -- raised to stop execution

END pGenerateLastBalances;

--------------------------------------------------------------------------------

PROCEDURE pGenerateEBADailyBalances
(
  p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
  p_business_date IN DATE,
  p_oldest_backdate IN DATE,
  p_status IN CHAR := 'U'
)
AS
    s_proc_name VARCHAR2(65) := 'SLR_POST_JOURNALS_PKG.pGenerateEBADailyBalances';
  lv_sql VARCHAR2(32000);
  lv_date DATE;
    lv_lock_handle VARCHAR2(100);
    lv_lock_result INTEGER;
    lv_table_name VARCHAR2(30) := 'SLR_EBA_CLC_' || p_epg_id;
    lv_part_move_table_name VARCHAR2(30) := 'SLR_EBA_PM_' || p_epg_id;
    lv_subpartition_name VARCHAR2(30);
    lv_rollback_exchange BOOLEAN := FALSE;
    lv_including_indexes VARCHAR2(100) := NULL;
    lv_update_indexes VARCHAR2(100) := NULL;
    lv_START_TIME   PLS_INTEGER := 0;
    lv_cursor    NUMBER := dbms_sql.open_cursor;
    lv_countrows NUMBER;

BEGIN
   pg_process_state.log_proc(p_conf_group    => 'SLR',
                             p_stage         => 'slr_post_journals.pGenerateEBADailyBalances_p_epg_id',
                             p_process_id    => p_process_id,
                             p_epg_id        => p_epg_id,
							 p_business_date => gp_business_date,
                             p_object_name   => 'SLR_EBA_PM_' || p_epg_id,
                             p_start_dt      => sysdate,
                             p_status        => 'P');


    lv_sql := '
    INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'EBA_DAILY_BALANCES_INSERT') || ' INTO ' || lv_table_name || '
    (
        EDB_FAK_ID,
        EDB_EBA_ID,
        EDB_BALANCE_DATE,
        EDB_BALANCE_TYPE,
        EDB_TRAN_DAILY_MOVEMENT,
        EDB_TRAN_MTD_BALANCE,
        EDB_TRAN_QTD_BALANCE,
        EDB_TRAN_YTD_BALANCE,
        EDB_TRAN_LTD_BALANCE,
        EDB_BASE_DAILY_MOVEMENT,
        EDB_BASE_MTD_BALANCE,
        EDB_BASE_QTD_BALANCE,
        EDB_BASE_YTD_BALANCE,
        EDB_BASE_LTD_BALANCE,
        EDB_LOCAL_DAILY_MOVEMENT,
        EDB_LOCAL_MTD_BALANCE,
        EDB_LOCAL_QTD_BALANCE,
        EDB_LOCAL_YTD_BALANCE,
        EDB_LOCAL_LTD_BALANCE,
        EDB_ENTITY,
        EDB_EPG_ID,
        EDB_PERIOD_MONTH,
        EDB_PERIOD_QTR,
        EDB_PERIOD_YEAR,
        EDB_PERIOD_LTD,
        EDB_PROCESS_ID,
        EDB_AMENDED_ON
    )
    SELECT
        EDB_FAK_ID,
        EDB_EBA_ID,
        EDB_BALANCE_DATE,
        EDB_BALANCE_TYPE,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_TRAN_DAILY_MOVEMENT END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_TRAN_MTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_TRAN_QTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_TRAN_YTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' and EDB_PERIOD_LTD <> 1 THEN 0 ELSE EDB_TRAN_LTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_BASE_DAILY_MOVEMENT END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_BASE_MTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_BASE_QTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_BASE_YTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' and EDB_PERIOD_LTD <> 1 THEN 0 ELSE EDB_BASE_LTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_LOCAL_DAILY_MOVEMENT END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_LOCAL_MTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_LOCAL_QTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE EDB_LOCAL_YTD_BALANCE END,
        CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' and EDB_PERIOD_LTD <> 1 THEN 0 ELSE EDB_LOCAL_LTD_BALANCE END,
        EDB_ENTITY,
        EDB_EPG_ID,
        EDB_PERIOD_MONTH,
        EDB_PERIOD_QTR,
        EDB_PERIOD_YEAR,
        EDB_PERIOD_LTD,
        EDB_PROCESS_ID,
        EDB_AMENDED_ON
  FROM
  (
    (
      SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'EBA_DAILY_BALANCES_ALL') || '
        EDB_FAK_ID,
        EDB_EBA_ID,
        EDB_BALANCE_DATE,
        EDB_BALANCE_TYPE,
        EDB_TRAN_DAILY_MOVEMENT,
        EDB_TRAN_MTD_BALANCE,
        EDB_TRAN_QTD_BALANCE,
        EDB_TRAN_YTD_BALANCE,
        EDB_TRAN_LTD_BALANCE,
        EDB_BASE_DAILY_MOVEMENT,
        EDB_BASE_MTD_BALANCE,
        EDB_BASE_QTD_BALANCE,
        EDB_BASE_YTD_BALANCE,
        EDB_BASE_LTD_BALANCE,
        EDB_LOCAL_DAILY_MOVEMENT,
        EDB_LOCAL_MTD_BALANCE,
        EDB_LOCAL_QTD_BALANCE,
        EDB_LOCAL_YTD_BALANCE,
        EDB_LOCAL_LTD_BALANCE,
        EDB_ENTITY,
        EDB_EPG_ID,
        EDB_PERIOD_MONTH,
        EDB_PERIOD_QTR,
        EDB_PERIOD_YEAR,
        EDB_PERIOD_LTD,
        ''N'' EDB_JRNL_INTERNAL_PERIOD_FLAG,
                :p_process_id EDB_PROCESS_ID,
                EDB_AMENDED_ON
      FROM SLR_EBA_DAILY_BALANCES, SLR_ENTITIES ent
      WHERE EDB_EPG_ID = :p_epg_id
        AND EDB_BALANCE_DATE >= :p_oldest_backdate
        AND ent.ENT_ENTITY = EDB_ENTITY
        AND ((EDB_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR EDB_BALANCE_TYPE <> ''20'')
        AND EDB_EBA_ID NOT IN
          (
                        SELECT JLU_EBA_ID FROM SLR_JRNL_LINES_UNPOSTED, SLR_EXT_JRNL_TYPES jt
                        WHERE JLU_EPG_ID = :p_epg_id
            AND JLU_JRNL_STATUS = :p_status
            AND JLU_JRNL_TYPE = jt.EJT_TYPE
                        and (EDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_1 or EDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_2)
                    )
    )
    UNION ALL
        SELECT * FROM
        (
            SELECT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'EBA_DAILY_BALANCES_CALC') || '
                EDB_FAK_ID,
                EDB_EBA_ID,
                EDB_BALANCE_DATE,
                EDB_BALANCE_TYPE EDB_BALANCE_TYPE,
                CAST(EDB_TRAN_DAILY_MOVEMENT AS NUMBER(38,3)) EDB_TRAN_DAILY_MOVEMENT,
                CAST(SUM(EDB_TRAN_MTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_MONTH, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_MTD_BALANCE,
                CAST(SUM(EDB_TRAN_QTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_QTR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_QTD_BALANCE,
                CAST(SUM(EDB_TRAN_YTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_YTD_BALANCE,
                CAST(SUM(CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''N'' THEN EDB_TRAN_LTD_BALANCE ELSE EDB_TRAN_LTD_BALANCE_IP END ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_LTD, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_LTD_BALANCE,
                CAST(EDB_BASE_DAILY_MOVEMENT AS NUMBER(38,3)) EDB_BASE_DAILY_MOVEMENT,
                CAST(SUM(EDB_BASE_MTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_MONTH, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_MTD_BALANCE,
                CAST(SUM(EDB_BASE_QTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_QTR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_QTD_BALANCE,
                CAST(SUM(EDB_BASE_YTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_YTD_BALANCE,
                CAST(SUM(CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''N'' THEN EDB_BASE_LTD_BALANCE ELSE EDB_BASE_LTD_BALANCE_IP END ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_LTD, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_LTD_BALANCE,
                CAST(EDB_LOCAL_DAILY_MOVEMENT AS NUMBER(38,3)) EDB_LOCAL_DAILY_MOVEMENT,
                CAST(SUM(EDB_LOCAL_MTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_MONTH, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_MTD_BALANCE,
                CAST(SUM(EDB_LOCAL_QTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_QTR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_QTD_BALANCE,
                CAST(SUM(EDB_LOCAL_YTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_YTD_BALANCE,
                CAST(SUM(CASE WHEN EDB_JRNL_INTERNAL_PERIOD_FLAG = ''N'' THEN EDB_LOCAL_LTD_BALANCE ELSE EDB_LOCAL_LTD_BALANCE_IP END ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_LTD, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_LTD_BALANCE,
                EDB_ENTITY,
                EDB_EPG_ID,
                EDB_PERIOD_MONTH,
                EDB_PERIOD_QTR,
                EDB_PERIOD_YEAR,
                EDB_PERIOD_LTD,
                EDB_JRNL_INTERNAL_PERIOD_FLAG,
                :p_process_id EDB_PROCESS_ID,
                EDB_AMENDED_ON
            FROM
            (
                SELECT /*+ NO_MERGE */
                    EDB_FAK_ID,
                    EDB_EBA_ID,
                    EDB_BALANCE_DATE,
                    EDB_BALANCE_TYPE,
                    SUM(EDB_TRAN_DAILY_MOVEMENT) EDB_TRAN_DAILY_MOVEMENT,
                    SUM(EDB_TRAN_DAILY_MOVEMENT) EDB_TRAN_MTD_BALANCE,
                    SUM(EDB_TRAN_DAILY_MOVEMENT) EDB_TRAN_QTD_BALANCE,
                    SUM(EDB_TRAN_DAILY_MOVEMENT) EDB_TRAN_YTD_BALANCE,
                    SUM(EDB_TRAN_DAILY_MOVEMENT) EDB_TRAN_LTD_BALANCE,
                    SUM(EDB_TRAN_LTD_BALANCE_IP) EDB_TRAN_LTD_BALANCE_IP,
                    SUM(EDB_BASE_DAILY_MOVEMENT) EDB_BASE_DAILY_MOVEMENT,
                    SUM(EDB_BASE_DAILY_MOVEMENT) EDB_BASE_MTD_BALANCE,
                    SUM(EDB_BASE_DAILY_MOVEMENT) EDB_BASE_QTD_BALANCE,
                    SUM(EDB_BASE_DAILY_MOVEMENT) EDB_BASE_YTD_BALANCE,
                    SUM(EDB_BASE_DAILY_MOVEMENT) EDB_BASE_LTD_BALANCE,
                    SUM(EDB_BASE_LTD_BALANCE_IP) EDB_BASE_LTD_BALANCE_IP,
                    SUM(EDB_LOCAL_DAILY_MOVEMENT) EDB_LOCAL_DAILY_MOVEMENT,
                    SUM(EDB_LOCAL_DAILY_MOVEMENT) EDB_LOCAL_MTD_BALANCE,
                    SUM(EDB_LOCAL_DAILY_MOVEMENT) EDB_LOCAL_QTD_BALANCE,
                    SUM(EDB_LOCAL_DAILY_MOVEMENT) EDB_LOCAL_YTD_BALANCE,
                    SUM(EDB_LOCAL_DAILY_MOVEMENT) EDB_LOCAL_LTD_BALANCE,
                    SUM(EDB_LOCAL_LTD_BALANCE_IP) EDB_LOCAL_LTD_BALANCE_IP,
                    EDB_ENTITY,
                    EDB_EPG_ID,
                    EDB_PERIOD_MONTH,
                    EDB_PERIOD_QTR,
                    EDB_PERIOD_YEAR,
                    EDB_PERIOD_LTD,
                    MAX(EDB_JRNL_INTERNAL_PERIOD_FLAG) AS EDB_JRNL_INTERNAL_PERIOD_FLAG,
                    MAX(EDB_AMENDED_ON) AS EDB_AMENDED_ON
                FROM
                (
                    SELECT
                        EDB_FAK_ID,
                        EDB_EBA_ID,
                        EDB_BALANCE_DATE,
                        EDB_BALANCE_TYPE,
                        EDB_TRAN_DAILY_MOVEMENT,
                        EDB_TRAN_LTD_BALANCE_IP,
                        EDB_BASE_DAILY_MOVEMENT,
                        EDB_BASE_LTD_BALANCE_IP,
                        EDB_LOCAL_DAILY_MOVEMENT,
                        EDB_LOCAL_LTD_BALANCE_IP,
                        EDB_ENTITY,
                        EDB_EPG_ID,
                        EDB_PERIOD_MONTH,
                        EDB_PERIOD_QTR,
                        EDB_PERIOD_YEAR,
                        EDB_PERIOD_LTD,
                        EDB_JRNL_INTERNAL_PERIOD_FLAG,
                        EDB_AMENDED_ON
          FROM
          (
            SELECT
              EDB_FAK_ID, EDB_EBA_ID,
              EDB_BALANCE_DATE, EDB_BALANCE_TYPE,
              EDB_TRAN_DAILY_MOVEMENT,EDB_TRAN_LTD_BALANCE EDB_TRAN_LTD_BALANCE_IP,
              EDB_BASE_DAILY_MOVEMENT,EDB_BASE_LTD_BALANCE EDB_BASE_LTD_BALANCE_IP,
                            EDB_LOCAL_DAILY_MOVEMENT,EDB_LOCAL_LTD_BALANCE EDB_LOCAL_LTD_BALANCE_IP,
                            EDB_ENTITY,
                            EDB_EPG_ID, EDB_PERIOD_MONTH, EDB_PERIOD_QTR,
                            EDB_PERIOD_YEAR, EDB_PERIOD_LTD,
                            ''N'' EDB_JRNL_INTERNAL_PERIOD_FLAG,
                            EDB_AMENDED_ON
            FROM SLR_EBA_DAILY_BALANCES, SLR_ENTITIES ent
            WHERE EDB_EPG_ID = :p_epg_id
              AND EDB_BALANCE_DATE >= :p_oldest_backdate
              AND ent.ENT_ENTITY = EDB_ENTITY
              AND ((EDB_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR EDB_BALANCE_TYPE <> ''20'')
              AND EDB_EBA_ID IN
                (
                                    SELECT JLU_EBA_ID FROM SLR_JRNL_LINES_UNPOSTED
                                    WHERE JLU_EPG_ID = :p_epg_id
                  AND JLU_JRNL_STATUS = :p_status
                                )
                        UNION ALL
                        SELECT
                            JLU_FAK_ID EDB_FAK_ID, JLU_EBA_ID EDB_EBA_ID,
                            JLU_EFFECTIVE_DATE EDB_BALANCE_DATE, JT_BALANCE_TYPE EDB_BALANCE_TYPE,
                            JLU_TRAN_AMOUNT EDB_TRAN_DAILY_MOVEMENT, JLU_TRAN_AMOUNT EDB_TRAN_LTD_BALANCE_IP,
                            JLU_BASE_AMOUNT EDB_BASE_DAILY_MOVEMENT, JLU_BASE_AMOUNT EDB_BASE_LTD_BALANCE_IP,
                            JLU_LOCAL_AMOUNT EDB_LOCAL_DAILY_MOVEMENT, JLU_LOCAL_AMOUNT EDB_LOCAL_LTD_BALANCE_IP,
                            JLU_ENTITY EDB_ENTITY,
                            JLU_EPG_ID EDB_EPG_ID, JLU_PERIOD_MONTH EDB_PERIOD_MONTH, JLU_PERIOD_QTR EDB_PERIOD_QTR,
                            JLU_PERIOD_YEAR EDB_PERIOD_YEAR, JLU_PERIOD_LTD EDB_PERIOD_LTD,
                            NVL(JLU_JRNL_INTERNAL_PERIOD_FLAG,''N'') EDB_JRNL_INTERNAL_PERIOD_FLAG,
                            SYSDATE EDB_AMENDED_ON
            FROM V_SLR_JRNL_LINES_UNPOSTED_JT, SLR_ENTITIES ent
            WHERE JLU_EPG_ID = :p_epg_id
             AND ent.ENT_ENTITY = JLU_ENTITY
             AND ((JT_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR JT_BALANCE_TYPE <> ''20'')
              AND JLU_JRNL_STATUS =  :p_status
          )
        )
        GROUP BY EDB_BALANCE_DATE, EDB_EBA_ID, EDB_FAK_ID, EDB_BALANCE_TYPE, EDB_ENTITY, EDB_EPG_ID, EDB_PERIOD_YEAR, EDB_PERIOD_MONTH, EDB_PERIOD_QTR, EDB_PERIOD_LTD
        UNION ALL
        SELECT /*+ NO_MERGE */
          LB_FAK_ID EDB_FAK_ID, LB_EBA_ID EDB_EBA_ID,
          :c_unused_date_for_lb EDB_BALANCE_DATE, LB_BALANCE_TYPE EDB_BALANCE_TYPE,
                    0 EDB_TRAN_DAILY_MOVEMENT, LB_TRAN_MTD_BALANCE EDB_TRAN_MTD_BALANCE, LB_TRAN_QTD_BALANCE EDB_TRAN_QTD_BALANCE,
          LB_TRAN_YTD_BALANCE EDB_TRAN_YTD_BALANCE, LB_TRAN_LTD_BALANCE EDB_TRAN_LTD_BALANCE, LB_TRAN_LTD_BALANCE EDB_TRAN_LTD_BALANCE_IP,
                    0 EDB_BASE_DAILY_MOVEMENT, LB_BASE_MTD_BALANCE EDB_BASE_MTD_BALANCE, LB_BASE_QTD_BALANCE EDB_BASE_QTD_BALANCE,
          LB_BASE_YTD_BALANCE EDB_BASE_YTD_BALANCE, LB_BASE_LTD_BALANCE EDB_BASE_LTD_BALANCE, LB_BASE_LTD_BALANCE EDB_BASE_LTD_BALANCE_IP,
                    0 EDB_LOCAL_DAILY_MOVEMENT, LB_LOCAL_MTD_BALANCE EDB_LOCAL_MTD_BALANCE, LB_LOCAL_QTD_BALANCE EDB_LOCAL_QTD_BALANCE,
          LB_LOCAL_YTD_BALANCE EDB_LOCAL_YTD_BALANCE, LB_LOCAL_LTD_BALANCE EDB_LOCAL_LTD_BALANCE, LB_LOCAL_LTD_BALANCE EDB_LOCAL_LTD_BALANCE_IP,
          LB_ENTITY EDB_ENTITY, LB_EPG_ID EDB_EPG_ID,
                    LB_PERIOD_MONTH EDB_PERIOD_MONTH, LB_PERIOD_QTR EDB_PERIOD_QTR, LB_PERIOD_YEAR EDB_PERIOD_YEAR,
          LB_PERIOD_LTD EDB_PERIOD_LTD, ''N'' EDB_JRNL_INTERNAL_PERIOD_FLAG, :c_unused_date_for_lb EDB_AMENDED_ON
        FROM SLR_LAST_BALANCES, SLR_ENTITIES ent
        WHERE LB_GENERATED_FOR =  (:p_oldest_backdate - 1)
          AND LB_EPG_ID =  :p_epg_id
          AND ent.ENT_ENTITY = LB_ENTITY
             AND ((LB_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR LB_BALANCE_TYPE <> ''20'')
                    AND LB_EBA_ID IN
                    (
                        SELECT JLU_EBA_ID FROM SLR_JRNL_LINES_UNPOSTED
                        WHERE JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status                     )

      )
    )
        WHERE EDB_BALANCE_DATE > :c_unused_date_for_lb
    AND EDB_EBA_ID IN
                    (
                        SELECT JLU_EBA_ID FROM SLR_JRNL_LINES_UNPOSTED, SLR_EXT_JRNL_TYPES jt
                        WHERE JLU_EPG_ID =  :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status
                        AND JLU_JRNL_TYPE = jt.EJT_TYPE
                        and (EDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_1 or EDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_2)
                    )
  )
  ';
    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
    dbms_sql.bind_variable( lv_cursor, ':c_unused_date_for_lb',c_unused_date_for_lb);
    dbms_sql.bind_variable( lv_cursor, ':p_oldest_backdate',p_oldest_backdate);
  dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);


    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );


    COMMIT;
    SLR_ADMIN_PKG.PerfInfo( 'EBA. EBA Daily Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
    SLR_ADMIN_PKG.Debug('EBA daily balances inserted into CLC table', lv_sql);

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || lv_part_move_table_name;
    lv_date := p_oldest_backdate;
    WHILE lv_date <= p_business_date LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE SLR_EBA_BALANCES_ROLLBACK
            TRUNCATE SUBPARTITION ' || SLR_UTILITIES_PKG.fSubpartitionName(p_epg_id, lv_date);
        lv_date := lv_date + 1;
    END LOOP;

    IF gv_local_index_eba = TRUE THEN
        lv_including_indexes := ' INCLUDING INDEXES ';
    END IF;

    IF gv_global_index_eba = TRUE THEN
        lv_update_indexes := ' UPDATE INDEXES ';
    END IF;

    DBMS_LOCK.ALLOCATE_UNIQUE('MAH_SLR_EBA_BALANCES', lv_lock_handle);
    lv_lock_result := DBMS_LOCK.REQUEST(lv_lock_handle, DBMS_LOCK.X_MODE, c_lock_request_timeout);
    IF lv_lock_result != 0 THEN
        RAISE e_lock_acquire_error;
    END IF;

    lv_date := p_oldest_backdate;
    lv_rollback_exchange := TRUE;
    WHILE lv_date <= p_business_date LOOP
        lv_subpartition_name := SLR_UTILITIES_PKG.fSubpartitionName(p_epg_id, lv_date);

        EXECUTE IMMEDIATE 'ALTER TABLE ' || lv_table_name || '
        EXCHANGE PARTITION P' || TO_CHAR(lv_date, 'YYYYMMDD') || '
            WITH TABLE ' || lv_part_move_table_name || lv_including_indexes || ' WITHOUT VALIDATION ' || lv_update_indexes;

        EXECUTE IMMEDIATE 'ALTER TABLE SLR_EBA_DAILY_BALANCES
            EXCHANGE SUBPARTITION ' || lv_subpartition_name || '
            WITH TABLE ' || lv_part_move_table_name || lv_including_indexes || ' WITHOUT VALIDATION ' || lv_update_indexes;

        -- creating backup copy for rollback
        EXECUTE IMMEDIATE 'ALTER TABLE SLR_EBA_BALANCES_ROLLBACK
            EXCHANGE SUBPARTITION ' || lv_subpartition_name || '
            WITH TABLE ' || lv_part_move_table_name || lv_including_indexes || ' WITHOUT VALIDATION ' || lv_update_indexes;

        lv_date := lv_date + 1;
    END LOOP;

    lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);

    SLR_ADMIN_PKG.Info('EBA daily balances generated');
    pg_process_state.log_proc_completed(p_conf_group    => 'SLR',
                                        p_stage         => 'slr_post_journals.pGenerateEBADailyBalances_p_epg_id',
                                        p_process_id    => p_process_id);


EXCEPTION
    WHEN e_lock_acquire_error THEN
        pWriteLogError(s_proc_name, 'SLR_EBA_DAILY_BALANCES',
      'Error during generating EBA daily balances: can''t acquire lock to exchange partitions',
      p_process_id,p_epg_id , p_status );
        SLR_ADMIN_PKG.Error('Error during generating EBA daily balances: can''t acquire lock to exchange partitions');
        pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
	    RAISE e_internal_processing_error; -- raised to stop execution

  WHEN OTHERS THEN
        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
        pWriteLogError(s_proc_name, 'SLR_EBA_DAILY_BALANCES',
      'Error during generating EBA daily balances: '|| SQLERRM,
            p_process_id,p_epg_id , p_status );
        SLR_ADMIN_PKG.Error('Error during generating EBA daily balances: '|| SQLERRM);
        IF lv_rollback_exchange = TRUE THEN
            pEbaBalancesRollback(p_epg_id, p_process_id);
        END IF;
        pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
		RAISE e_internal_processing_error;

END pGenerateEBADailyBalances;



PROCEDURE pGenerateEBADailyBalancesMerge
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_business_date IN DATE,
    p_oldest_backdate IN DATE,
    p_status IN CHAR := 'U'
)
AS
    lv_sql VARCHAR2(32000);
  lv_START_TIME   PLS_INTEGER := 0;
  lv_cursor    NUMBER(19) := dbms_sql.open_cursor;
  lv_countrows NUMBER;
BEGIN


    pg_process_state.log_proc(p_conf_group  => 'SLR',
                              p_stage       => 'slr_post_journals.pGenerateEBADailyBalancesMerge',
                              p_process_id  => p_process_id,
                              p_epg_id      => p_epg_id,
							  p_business_date => gp_business_date,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                              p_object_name => 'SLR_EBA_DAILY_BALANCES',
                              p_start_dt    => sysdate,
                              p_status      => 'P');


    lv_sql := '
        MERGE ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'EBA_DAILY_BALANCES_MERGE') || ' INTO SLR_EBA_DAILY_BALANCES B USING
        (
            SELECT * FROM
            (
                SELECT
                    EDB_FAK_ID,
                    EDB_EBA_ID,
                    EDB_BALANCE_DATE,
                    EDB_BALANCE_TYPE EDB_BALANCE_TYPE,
                    CAST(EDB_TRAN_DAILY_MOVEMENT AS NUMBER(38,3)) EDB_TRAN_DAILY_MOVEMENT,
                    CAST(SUM(EDB_TRAN_MTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_MONTH, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_MTD_BALANCE,
                    CAST(SUM(EDB_TRAN_QTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_QTR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_QTD_BALANCE,
                    CAST(SUM(EDB_TRAN_YTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_YTD_BALANCE,
                    CAST(SUM(CASE WHEN BAL_EXISTS = 1 THEN -PREV_TRAN_LTD + EDB_TRAN_LTD_BALANCE ELSE EDB_TRAN_LTD_BALANCE END) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_TRAN_LTD_BALANCE,
                    CAST(EDB_BASE_DAILY_MOVEMENT AS NUMBER(38,3)) EDB_BASE_DAILY_MOVEMENT,
                    CAST(SUM(EDB_BASE_MTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_MONTH, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_MTD_BALANCE,
                    CAST(SUM(EDB_BASE_QTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_QTR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_QTD_BALANCE,
                    CAST(SUM(EDB_BASE_YTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_YTD_BALANCE,
                    CAST(SUM(CASE WHEN BAL_EXISTS = 1 THEN -PREV_BASE_LTD + EDB_BASE_LTD_BALANCE ELSE EDB_BASE_LTD_BALANCE END) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_BASE_LTD_BALANCE,
                    CAST(EDB_LOCAL_DAILY_MOVEMENT  AS NUMBER(38,3)) EDB_LOCAL_DAILY_MOVEMENT,
                    CAST(SUM(EDB_LOCAL_MTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_MONTH, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_MTD_BALANCE,
                    CAST(SUM(EDB_LOCAL_QTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_PERIOD_QTR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_QTD_BALANCE,
                    CAST(SUM(EDB_LOCAL_YTD_BALANCE ) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_PERIOD_YEAR, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_YTD_BALANCE,
                    CAST(SUM(CASE WHEN BAL_EXISTS = 1 THEN -PREV_LOCAL_LTD + EDB_LOCAL_LTD_BALANCE ELSE EDB_LOCAL_LTD_BALANCE END) OVER (PARTITION BY EDB_BALANCE_TYPE, EDB_EBA_ID ORDER BY EDB_BALANCE_DATE) AS NUMBER(38,3)) EDB_LOCAL_LTD_BALANCE,
                    EDB_ENTITY,
                    EDB_EPG_ID,
                    EDB_PERIOD_MONTH,
                    EDB_PERIOD_QTR,
                    EDB_PERIOD_YEAR,
                    :p_process_id AS EDB_PROCESS_ID,
                    EDB_AMENDED_ON
                FROM
                (   SELECT data_set.*,
                        LAG(TRAN_LTD,1,0) OVER(PARTITION BY EDB_BALANCE_TYPE, EDB_EBA_ID, BAL_EXISTS ORDER BY EDB_BALANCE_DATE) PREV_TRAN_LTD,
                        LAG(BASE_LTD,1,0) OVER(PARTITION BY EDB_BALANCE_TYPE, EDB_EBA_ID, BAL_EXISTS ORDER BY EDB_BALANCE_DATE) PREV_BASE_LTD,
                        LAG(LOCAL_LTD,1,0) OVER(PARTITION BY EDB_BALANCE_TYPE, EDB_EBA_ID, BAL_EXISTS ORDER BY EDB_BALANCE_DATE) PREV_LOCAL_LTD
                    FROM
                        (
                        SELECT
                            EDB_FAK_ID,
                            EDB_EBA_ID,
                            EDB_BALANCE_DATE,
                            EDB_BALANCE_TYPE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_TRAN_DAILY_MOVEMENT end) EDB_TRAN_DAILY_MOVEMENT,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_TRAN_DAILY_MOVEMENT end) EDB_TRAN_MTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_TRAN_DAILY_MOVEMENT end) EDB_TRAN_QTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_TRAN_DAILY_MOVEMENT end) EDB_TRAN_YTD_BALANCE,
                            SUM(EDB_TRAN_LTD_BALANCE) EDB_TRAN_LTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_BASE_DAILY_MOVEMENT end) EDB_BASE_DAILY_MOVEMENT,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_BASE_DAILY_MOVEMENT end) EDB_BASE_MTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_BASE_DAILY_MOVEMENT end) EDB_BASE_QTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_BASE_DAILY_MOVEMENT end) EDB_BASE_YTD_BALANCE,
                            SUM(EDB_BASE_LTD_BALANCE) EDB_BASE_LTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_LOCAL_DAILY_MOVEMENT end) EDB_LOCAL_DAILY_MOVEMENT,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_LOCAL_DAILY_MOVEMENT end) EDB_LOCAL_MTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_LOCAL_DAILY_MOVEMENT end) EDB_LOCAL_QTD_BALANCE,
                            SUM(case when EDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else EDB_LOCAL_DAILY_MOVEMENT end) EDB_LOCAL_YTD_BALANCE,
                            SUM(EDB_LOCAL_LTD_BALANCE) EDB_LOCAL_LTD_BALANCE,
                            EDB_ENTITY,
                            EDB_EPG_ID,
                            EDB_PERIOD_MONTH,
                            EDB_PERIOD_QTR,
                            EDB_PERIOD_YEAR,
                            MAX(EDB_AMENDED_ON) AS EDB_AMENDED_ON,
                            SUM(TRAN_LTD) TRAN_LTD,
                            SUM(BASE_LTD) BASE_LTD,
                            SUM(LOCAL_LTD) LOCAL_LTD,
                            SUM(BAL_EXISTS) BAL_EXISTS
                        FROM
                        (
                            SELECT
                                EDB_FAK_ID,
                                EDB_EBA_ID,
                                EDB_BALANCE_DATE,
                                EDB_BALANCE_TYPE,
                                EDB_TRAN_DAILY_MOVEMENT,
                                EDB_TRAN_LTD_BALANCE,
                                EDB_BASE_DAILY_MOVEMENT,
                                EDB_BASE_LTD_BALANCE,
                                EDB_LOCAL_DAILY_MOVEMENT,
                                EDB_LOCAL_LTD_BALANCE,
                                EDB_ENTITY,
                                EDB_EPG_ID,
                                EDB_PERIOD_MONTH,
                                EDB_PERIOD_QTR,
                                EDB_PERIOD_YEAR,
                                EDB_JRNL_INTERNAL_PERIOD_FLAG,
                                EDB_AMENDED_ON,
                                TRAN_LTD,
                                BASE_LTD,
                                LOCAL_LTD,
                                BAL_EXISTS
                            FROM
                            (
                                SELECT
                                    EDB_FAK_ID, EDB_EBA_ID,
                                    EDB_BALANCE_DATE, EDB_BALANCE_TYPE,
                                    EDB_TRAN_DAILY_MOVEMENT,EDB_TRAN_LTD_BALANCE,
                                    EDB_BASE_DAILY_MOVEMENT,EDB_BASE_LTD_BALANCE,
                                    EDB_LOCAL_DAILY_MOVEMENT,EDB_LOCAL_LTD_BALANCE,
                                    EDB_ENTITY,
                                    EDB_EPG_ID, EDB_PERIOD_MONTH, EDB_PERIOD_QTR,
                                    EDB_PERIOD_YEAR,
                                    ''N'' EDB_JRNL_INTERNAL_PERIOD_FLAG,
                                    EDB_AMENDED_ON,
                                    EDB_TRAN_LTD_BALANCE TRAN_LTD,
                                    EDB_BASE_LTD_BALANCE BASE_LTD,
                                    EDB_LOCAL_LTD_BALANCE LOCAL_LTD,
                                    1 BAL_EXISTS
                                FROM SLR_EBA_DAILY_BALANCES
                                WHERE EDB_EPG_ID = :p_epg_id
                                    AND EDB_BALANCE_DATE >= :p_oldest_backdate
                                    AND EDB_EBA_ID IN
                                    (
                                        SELECT JLU_EBA_ID FROM SLR_JRNL_LINES_UNPOSTED
                                        WHERE JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                    )
                                UNION ALL
                                SELECT
                                    JLU_FAK_ID EDB_FAK_ID, JLU_EBA_ID EDB_EBA_ID,
                                    JLU_EFFECTIVE_DATE EDB_BALANCE_DATE, JT_BALANCE_TYPE EDB_BALANCE_TYPE,
                                    JLU_TRAN_AMOUNT EDB_TRAN_DAILY_MOVEMENT,
                                    JLU_TRAN_AMOUNT EDB_TRAN_LTD_BALANCE,
                                    JLU_BASE_AMOUNT EDB_BASE_DAILY_MOVEMENT,
                                    JLU_BASE_AMOUNT EDB_BASE_LTD_BALANCE,
                                    JLU_LOCAL_AMOUNT EDB_LOCAL_DAILY_MOVEMENT,
                                    JLU_LOCAL_AMOUNT EDB_LOCAL_LTD_BALANCE,
                                    JLU_ENTITY EDB_ENTITY,
                                    JLU_EPG_ID EDB_EPG_ID, JLU_PERIOD_MONTH EDB_PERIOD_MONTH, JLU_PERIOD_QTR EDB_PERIOD_QTR,
                                    JLU_PERIOD_YEAR EDB_PERIOD_YEAR,
                                    NVL(JLU_JRNL_INTERNAL_PERIOD_FLAG,''N'') EDB_JRNL_INTERNAL_PERIOD_FLAG,
                                    SYSDATE EDB_AMENDED_ON,
                                    0 TRAN_LTD,
                                    0 BASE_LTD,
                                    0 LOCAL_LTD,
                                    0 BAL_EXISTS
                                FROM V_SLR_JRNL_LINES_UNPOSTED_JT
                                WHERE JLU_EPG_ID =:p_epg_id
                                    AND JLU_JRNL_STATUS = :p_status
                            )
                        )
                        GROUP BY EDB_BALANCE_DATE, EDB_EBA_ID, EDB_FAK_ID, EDB_BALANCE_TYPE, EDB_ENTITY, EDB_EPG_ID, EDB_PERIOD_MONTH, EDB_PERIOD_QTR, EDB_PERIOD_YEAR
                        UNION ALL
                        SELECT
                            LB_FAK_ID EDB_FAK_ID, LB_EBA_ID EDB_EBA_ID,
                            :c_unused_date_for_lb EDB_BALANCE_DATE, LB_BALANCE_TYPE EDB_BALANCE_TYPE,
                            0 EDB_TRAN_DAILY_MOVEMENT, LB_TRAN_MTD_BALANCE EDB_TRAN_MTD_BALANCE, LB_TRAN_QTD_BALANCE EDB_TRAN_QTD_BALANCE,
                            LB_TRAN_YTD_BALANCE EDB_TRAN_YTD_BALANCE, LB_TRAN_LTD_BALANCE EDB_TRAN_LTD_BALANCE,
                            0 EDB_BASE_DAILY_MOVEMENT, LB_BASE_MTD_BALANCE EDB_BASE_MTD_BALANCE, LB_BASE_QTD_BALANCE EDB_BASE_QTD_BALANCE,
                            LB_BASE_YTD_BALANCE EDB_BASE_YTD_BALANCE, LB_BASE_LTD_BALANCE EDB_BASE_LTD_BALANCE,
                            0 EDB_LOCAL_DAILY_MOVEMENT, LB_LOCAL_MTD_BALANCE EDB_LOCAL_MTD_BALANCE, LB_LOCAL_QTD_BALANCE EDB_LOCAL_QTD_BALANCE,
                            LB_LOCAL_YTD_BALANCE EDB_LOCAL_YTD_BALANCE, LB_LOCAL_LTD_BALANCE EDB_LOCAL_LTD_BALANCE,
                            LB_ENTITY EDB_ENTITY, LB_EPG_ID EDB_EPG_ID,
                            LB_PERIOD_MONTH EDB_PERIOD_MONTH, LB_PERIOD_QTR EDB_PERIOD_QTR, LB_PERIOD_YEAR EDB_PERIOD_YEAR,
                            :c_unused_date_for_lb EDB_AMENDED_ON,
                            LB_TRAN_LTD_BALANCE TRAN_LTD,
                            LB_BASE_LTD_BALANCE BASE_LTD,
                            LB_LOCAL_LTD_BALANCE LOCAL_LTD,
                            1 BAL_EXISTS
                        FROM SLR_LAST_BALANCES
                        WHERE LB_GENERATED_FOR =  (:p_oldest_backdate - 1)
                            AND LB_EPG_ID = :p_epg_id
                            AND LB_EBA_ID IN
                            (
                                SELECT JLU_EBA_ID FROM SLR_JRNL_LINES_UNPOSTED
                                WHERE JLU_EPG_ID = :p_epg_id
                                AND JLU_JRNL_STATUS = :p_status
                            )
                        ) data_set
                )
            )
            WHERE EDB_BALANCE_DATE > :c_unused_date_for_lb
                AND EDB_EBA_ID IN
                (
                    SELECT JLU_EBA_ID FROM SLR_JRNL_LINES_UNPOSTED, SLR_EXT_JRNL_TYPES jt
                    WHERE JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status
                        AND EDB_EBA_ID = JLU_EBA_ID
                        AND EDB_BALANCE_DATE >= JLU_EFFECTIVE_DATE
                        AND JLU_JRNL_TYPE = jt.EJT_TYPE
                        AND (EDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_1 or EDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_2)
                )
        ) CLC
        ON
        (
            CLC.EDB_BALANCE_DATE = B.EDB_BALANCE_DATE
            AND CLC.EDB_PERIOD_YEAR=B.EDB_PERIOD_YEAR
            AND CLC.EDB_PERIOD_MONTH=B.EDB_PERIOD_MONTH
            AND CLC.EDB_EBA_ID = B.EDB_EBA_ID
            AND CLC.EDB_BALANCE_TYPE = B.EDB_BALANCE_TYPE
            AND CLC.EDB_EPG_ID = B.EDB_EPG_ID
            AND B.EDB_BALANCE_DATE >= :p_oldest_backdate
            AND B.EDB_EPG_ID = :p_epg_id
        )
        WHEN MATCHED THEN UPDATE SET
            B.EDB_TRAN_DAILY_MOVEMENT = CLC.EDB_TRAN_DAILY_MOVEMENT,
            B.EDB_TRAN_MTD_BALANCE = CLC.EDB_TRAN_MTD_BALANCE,
            B.EDB_TRAN_QTD_BALANCE = CLC.EDB_TRAN_QTD_BALANCE,
            B.EDB_TRAN_YTD_BALANCE = CLC.EDB_TRAN_YTD_BALANCE,
            B.EDB_TRAN_LTD_BALANCE = CLC.EDB_TRAN_LTD_BALANCE,
            B.EDB_BASE_DAILY_MOVEMENT = CLC.EDB_BASE_DAILY_MOVEMENT,
            B.EDB_BASE_MTD_BALANCE = CLC.EDB_BASE_MTD_BALANCE,
            B.EDB_BASE_QTD_BALANCE = CLC.EDB_BASE_QTD_BALANCE,
            B.EDB_BASE_YTD_BALANCE = CLC.EDB_BASE_YTD_BALANCE,
            B.EDB_BASE_LTD_BALANCE = CLC.EDB_BASE_LTD_BALANCE,
            B.EDB_LOCAL_DAILY_MOVEMENT = CLC.EDB_LOCAL_DAILY_MOVEMENT,
            B.EDB_LOCAL_MTD_BALANCE = CLC.EDB_LOCAL_MTD_BALANCE,
            B.EDB_LOCAL_QTD_BALANCE = CLC.EDB_LOCAL_QTD_BALANCE,
            B.EDB_LOCAL_YTD_BALANCE = CLC.EDB_LOCAL_YTD_BALANCE,
            B.EDB_LOCAL_LTD_BALANCE = CLC.EDB_LOCAL_LTD_BALANCE,
            B.EDB_PROCESS_ID = CLC.EDB_PROCESS_ID,
            B.EDB_AMENDED_ON = CLC.EDB_AMENDED_ON
        WHEN NOT MATCHED THEN INSERT
        (
            EDB_FAK_ID,
            EDB_EBA_ID,
            EDB_BALANCE_DATE,
            EDB_BALANCE_TYPE,
            EDB_TRAN_DAILY_MOVEMENT,
            EDB_TRAN_MTD_BALANCE,
            EDB_TRAN_QTD_BALANCE,
            EDB_TRAN_YTD_BALANCE,
            EDB_TRAN_LTD_BALANCE,
            EDB_BASE_DAILY_MOVEMENT,
            EDB_BASE_MTD_BALANCE,
            EDB_BASE_QTD_BALANCE,
            EDB_BASE_YTD_BALANCE,
            EDB_BASE_LTD_BALANCE,
            EDB_LOCAL_DAILY_MOVEMENT,
            EDB_LOCAL_MTD_BALANCE,
            EDB_LOCAL_QTD_BALANCE,
            EDB_LOCAL_YTD_BALANCE,
            EDB_LOCAL_LTD_BALANCE,
            EDB_ENTITY,
            EDB_EPG_ID,
            EDB_PERIOD_MONTH,
            EDB_PERIOD_QTR,
            EDB_PERIOD_YEAR,
            EDB_PERIOD_LTD,
            EDB_PROCESS_ID,
            EDB_AMENDED_ON
        )
        VALUES
        (
            CLC.EDB_FAK_ID,
            CLC.EDB_EBA_ID,
            CLC.EDB_BALANCE_DATE,
            CLC.EDB_BALANCE_TYPE,
            CLC.EDB_TRAN_DAILY_MOVEMENT,
            CLC.EDB_TRAN_MTD_BALANCE,
            CLC.EDB_TRAN_QTD_BALANCE,
            CLC.EDB_TRAN_YTD_BALANCE,
            CLC.EDB_TRAN_LTD_BALANCE,
            CLC.EDB_BASE_DAILY_MOVEMENT,
            CLC.EDB_BASE_MTD_BALANCE,
            CLC.EDB_BASE_QTD_BALANCE,
            CLC.EDB_BASE_YTD_BALANCE,
            CLC.EDB_BASE_LTD_BALANCE,
            CLC.EDB_LOCAL_DAILY_MOVEMENT,
            CLC.EDB_LOCAL_MTD_BALANCE,
            CLC.EDB_LOCAL_QTD_BALANCE,
            CLC.EDB_LOCAL_YTD_BALANCE,
            CLC.EDB_LOCAL_LTD_BALANCE,
            CLC.EDB_ENTITY,
            CLC.EDB_EPG_ID,
            CLC.EDB_PERIOD_MONTH,
            CLC.EDB_PERIOD_QTR,
            CLC.EDB_PERIOD_YEAR,
            1,
            CLC.EDB_PROCESS_ID,
            CLC.EDB_AMENDED_ON
        )';
/*-----------UPGRADE 22.1.1 MERGE START-----------*/
--lines added above to the ON condition
--            AND CLC.EDB_PERIOD_YEAR=B.EDB_PERIOD_YEAR
--            AND CLC.EDB_PERIOD_MONTH=B.EDB_PERIOD_MONTH
/*-----------UPGRADE 22.1.1 MERGE END-----------*/
  lv_START_TIME:=DBMS_UTILITY.GET_TIME();
  dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
  dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
  dbms_sql.bind_variable( lv_cursor, ':p_oldest_backdate',p_oldest_backdate);
  dbms_sql.bind_variable( lv_cursor, ':c_unused_date_for_lb',c_unused_date_for_lb);

  dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);
  dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
  lv_CountRows := dbms_sql.execute( lv_cursor );
  dbms_sql.close_cursor( lv_cursor );

/*-----------UPGRADE 22.1.1 MERGE START-----------*/
  SLR_ADMIN_PKG.Debug('EBA Daily Balances generated (Merge).', lv_sql);
--line move from the bottom
/*-----------UPGRADE 22.1.1 MERGE END-----------*/						   
 -- EXECUTE IMMEDIATE lv_sql USING p_process_id, p_oldest_backdate, p_oldest_backdate, p_oldest_backdate;
    SLR_ADMIN_PKG.PerfInfo( 'EBAM. Merge EBA Daily Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

   pg_process_state.log_proc_completed(p_conf_group   => 'SLR',
                                       p_stage        => 'slr_post_journals.pGenerateEBADailyBalancesMerge',
                                       p_process_id   => p_process_id);
   EXCEPTION WHEN OTHERS THEN
        pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
    RAISE;

END pGenerateEBADailyBalancesMerge;

PROCEDURE pGenerateEBADailyBalances
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_business_date IN DATE,
    p_status IN CHAR := 'U'
) IS
  lv_sql VARCHAR2(32000);
  lv_start_time pls_integer := 0;
  lv_cursor    NUMBER := dbms_sql.open_cursor;
  lv_countrows NUMBER;
BEGIN
    pg_process_state.log_proc(p_conf_group   => 'SLR',
                              p_stage        => 'slr_post_journals.pGenerateEBADailyBalances',
                              p_process_id   => p_process_id,
                              p_epg_id        => p_epg_id,
							  p_business_date => gp_business_date,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
                              p_object_name  => 'SLR_EBA_DAILY_BALANCES',
                              p_sub_partition  => 'P'||to_char(p_business_date, 'yyyymmdd')||'_S'||p_epg_id,
                              p_start_dt     =>  sysdate,
                              p_status       => 'P');


  lv_sql:= '
    insert /*+ append */ into slr_eba_daily_balances subpartition for (date '''||to_char(p_business_date, 'yyyy-mm-dd')||''', '''||p_epg_id||''') (
    edb_fak_id,
    edb_eba_id,
    edb_balance_date,
    edb_balance_type,
    edb_tran_daily_movement,
    edb_tran_mtd_balance,
    edb_tran_qtd_balance,
    edb_tran_ytd_balance,
    edb_tran_ltd_balance,
    edb_base_daily_movement,
    edb_base_mtd_balance,
    edb_base_qtd_balance,
    edb_base_ytd_balance,
    edb_base_ltd_balance,
    edb_local_daily_movement,
    edb_local_mtd_balance,
    edb_local_qtd_balance,
    edb_local_ytd_balance,
    edb_local_ltd_balance,
    edb_entity,
    edb_epg_id,
    edb_period_month,
    edb_period_qtr,
    edb_period_year,
    edb_period_ltd,
    edb_process_id,
    edb_amended_on
    ) with lbi as (
        select --+ no_merge
          lbi_generated_for, coalesce(lead(lbi_generated_for) over (order by lbi_generated_for), date '''||to_char(p_business_date, 'yyyy-mm-dd')||''') as next_generated_for from slr_last_balances_index where lbi_epg_id='''||p_epg_id||'''
      ), jlu as (
        select ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'EBA_DAILY_BALANCES_NO_BACKDATES') || '
          jlu_fak_id, jlu_eba_id, jlu_effective_date, jt_balance_type as jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year, nvl(jlu_jrnl_internal_period_flag, ''N'') as jlu_jrnl_internal_period_flag,
          (case when jlu_jrnl_internal_period_flag=''Y'' then 0 else jlu_tran_amount end) as jlu_tran_amount,
          (case when jlu_jrnl_internal_period_flag=''Y'' then 0 else jlu_base_amount end) as jlu_base_amount,
          (case when jlu_jrnl_internal_period_flag=''Y'' then 0 else jlu_local_amount end) as jlu_local_amount,
          (jlu_tran_amount) as jlu_tran_amount_ltd,
          (jlu_base_amount) as jlu_base_amount_ltd,
          (jlu_local_amount) as jlu_local_amount_ltd
        from v_slr_jrnl_lines_unposted_jt
        where jlu_epg_id = :p_epg_id and jlu_jrnl_status = :p_status
      ), jlu_aggr as (
        select --+ no_merge
          jlu_fak_id, jlu_eba_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year,
          sum(jlu_tran_amount) as jlu_tran_amount,
          sum(jlu_base_amount) as jlu_base_amount,
          sum(jlu_local_amount) as jlu_local_amount,
          sum(jlu_tran_amount_ltd) as jlu_tran_amount_ltd,
          sum(jlu_base_amount_ltd) as jlu_base_amount_ltd,
          sum(jlu_local_amount_ltd) as jlu_local_amount_ltd
        from jlu
        group by jlu_fak_id, jlu_eba_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year
      ), bal as (
        select --+ no_merge
          jlu_fak_id, jlu_eba_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year,
          jlu_tran_amount,
          jlu_base_amount,
          jlu_local_amount,
          case
            when lb_period_month=jlu_period_month and lb_period_year=jlu_period_year then coalesce(lb_tran_mtd_balance, 0)+jlu_tran_amount
            else jlu_tran_amount
          end as jlu_tran_mtd_balance,
          case
            when lb_period_month=jlu_period_month and lb_period_year=jlu_period_year then coalesce(lb_base_mtd_balance, 0)+jlu_base_amount
            else jlu_base_amount
          end as jlu_base_mtd_balance,
          case
            when lb_period_month=jlu_period_month and lb_period_year=jlu_period_year then coalesce(lb_local_mtd_balance, 0)+jlu_local_amount
            else jlu_local_amount
          end as jlu_local_mtd_balance,
          case
            when lb_period_qtr=jlu_period_qtr and lb_period_year=jlu_period_year then coalesce(lb_tran_qtd_balance, 0)+jlu_tran_amount
            else jlu_tran_amount
          end as jlu_tran_qtd_balance,
          case
            when lb_period_qtr=jlu_period_qtr and lb_period_year=jlu_period_year then coalesce(lb_base_qtd_balance, 0)+jlu_base_amount
            else jlu_base_amount
          end as jlu_base_qtd_balance,
          case
            when lb_period_qtr=jlu_period_qtr and lb_period_year=jlu_period_year then coalesce(lb_local_qtd_balance, 0)+jlu_local_amount
            else jlu_local_amount
          end as jlu_local_qtd_balance,
          case
            when lb_period_year=jlu_period_year then coalesce(lb_tran_ytd_balance, 0)+jlu_tran_amount
            else jlu_tran_amount
          end as jlu_tran_ytd_balance,
          case
            when lb_period_year=jlu_period_year then coalesce(lb_base_ytd_balance, 0)+jlu_base_amount
            else jlu_base_amount
          end as jlu_base_ytd_balance,
          case
            when lb_period_year=jlu_period_year then coalesce(lb_local_ytd_balance, 0)+jlu_local_amount
            else jlu_local_amount
          end as jlu_local_ytd_balance,
          coalesce(lb_tran_ltd_balance, 0)+jlu_tran_amount_ltd as jlu_tran_ltd_balance,
          coalesce(lb_base_ltd_balance, 0)+jlu_base_amount_ltd as jlu_base_ltd_balance,
          coalesce(lb_local_ltd_balance, 0)+jlu_local_amount_ltd as jlu_local_ltd_balance
        from jlu_aggr
          left join lbi on jlu_effective_date=next_generated_for
          left join slr_last_balances on lb_generated_for=lbi_generated_for and lb_epg_id=:p_epg_id and lb_eba_id=jlu_eba_id and lb_generated_for>=date '''||to_char(p_business_date, 'yyyy-mm-dd')||'''-1 and lb_balance_type=jlu_balance_type
      )
    select
      jlu_fak_id,
      jlu_eba_id,
      jlu_effective_date,
      jlu_balance_type,
      jlu_tran_amount,
      jlu_tran_mtd_balance,
      jlu_tran_qtd_balance,
      jlu_tran_ytd_balance,
      jlu_tran_ltd_balance,
      jlu_base_amount,
      jlu_base_mtd_balance,
      jlu_base_qtd_balance,
      jlu_base_ytd_balance,
      jlu_base_ltd_balance,
      jlu_local_amount,
      jlu_local_mtd_balance,
      jlu_local_qtd_balance,
      jlu_local_ytd_balance,
      jlu_local_ltd_balance,
      jlu_entity,
      :p_epg_id,
      jlu_period_month,
      jlu_period_qtr,
      jlu_period_year,
      1,
      :p_process_id,
      sysdate from bal';


    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
  dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);
    dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );



    --EXECUTE IMMEDIATE lv_sql;
    SLR_ADMIN_PKG.PerfInfo( 'EBAI. Insert EBA Daily Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
    SLR_ADMIN_PKG.Debug('EBA Daily Balances generated (Insert).', lv_sql);

	pg_process_state.log_proc_completed(p_conf_group   => 'SLR',
                                        p_stage        => 'slr_post_journals.pGenerateEBADailyBalances',
                                        p_process_id   => p_process_id);
   EXCEPTION WHEN OTHERS THEN
        pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
    RAISE;


END pGenerateEBADailyBalances;

PROCEDURE pGenerateFAKDailyBalances
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_business_date IN DATE,
    p_status IN CHAR := 'U'
) IS
  lv_sql VARCHAR2(32000);
  lv_start_time pls_integer := 0;
  lv_cursor    NUMBER := dbms_sql.open_cursor;
  lv_countrows NUMBER;
BEGIN

    pg_process_state.log_proc(p_conf_group   => 'SLR',
                              p_stage        => 'slr_post_journals.pGenerateFAKDailyBalances_sub',
                              p_process_id   => p_process_id,
                              p_object_name  => 'SLR_FAK_DAILY_BALANCES',
                              p_epg_id        => p_epg_id,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
							  p_business_date => gp_business_date,
                              p_sub_partition  => 'P'||to_char(p_business_date, 'yyyymmdd')||'_S'||p_epg_id,
                              p_start_dt     =>  sysdate,
                              p_status       => 'P');


  lv_sql:= '
    insert /*+ append */ into slr_fak_daily_balances subpartition for (date '''||to_char(p_business_date, 'yyyy-mm-dd')||''', '''||p_epg_id||''') (
      fdb_fak_id,
      fdb_balance_date,
      fdb_balance_type,
      fdb_tran_daily_movement,
      fdb_tran_mtd_balance,
      fdb_tran_qtd_balance,
      fdb_tran_ytd_balance,
      fdb_tran_ltd_balance,
      fdb_base_daily_movement,
      fdb_base_mtd_balance,
      fdb_base_qtd_balance,
      fdb_base_ytd_balance,
      fdb_base_ltd_balance,
      fdb_local_daily_movement,
      fdb_local_mtd_balance,
      fdb_local_qtd_balance,
      fdb_local_ytd_balance,
      fdb_local_ltd_balance,
      fdb_entity,
      fdb_epg_id,
      fdb_period_month,
      fdb_period_qtr,
      fdb_period_year,
      fdb_period_ltd,
      fdb_process_id,
      fdb_amended_on
    ) with lbi as (
        select --+ no_merge
          lbi_generated_for, coalesce(lead(lbi_generated_for) over (order by lbi_generated_for), date '''||to_char(p_business_date, 'yyyy-mm-dd')||''') as next_generated_for from slr_last_balances_index where lbi_epg_id='''||p_epg_id||'''
      ), jlu as (
        select ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'FAK_DAILY_BALANCES_NO_BACKDATES') || '
          jlu_fak_id, jlu_eba_id, jlu_effective_date, jt_balance_type as jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year,
          (case when jlu_jrnl_internal_period_flag=''Y'' then 0 else jlu_tran_amount end) as jlu_tran_amount,
          (case when jlu_jrnl_internal_period_flag=''Y'' then 0 else jlu_base_amount end) as jlu_base_amount,
          (case when jlu_jrnl_internal_period_flag=''Y'' then 0 else jlu_local_amount end) as jlu_local_amount,
          (jlu_tran_amount) as jlu_tran_amount_ltd,
          (jlu_base_amount) as jlu_base_amount_ltd,
          (jlu_local_amount) as jlu_local_amount_ltd
        from v_slr_jrnl_lines_unposted_jt
        where jlu_epg_id = :p_epg_id and jlu_jrnl_status = :p_status
      ), jlu_aggr as (
        select --+ no_merge
          jlu_fak_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year,
          sum(jlu_tran_amount) as jlu_tran_amount,
          sum(jlu_base_amount) as jlu_base_amount,
          sum(jlu_local_amount) as jlu_local_amount,
          sum(jlu_tran_amount_ltd) as jlu_tran_amount_ltd,
          sum(jlu_base_amount_ltd) as jlu_base_amount_ltd,
          sum(jlu_local_amount_ltd) as jlu_local_amount_ltd
        from jlu
        group by jlu_fak_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year
      ), bal as (
        select --+ no_merge
          jlu_aggr.*, lb.*, coalesce(row_number() over (partition by jlu_fak_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_year order by lb_period_month, lb_period_year), 1) as counter
        from jlu_aggr
          left join lbi on jlu_effective_date=next_generated_for
          left join (
            select lb_generated_for, lb_fak_id, lb_period_month, lb_period_qtr, lb_period_year, lb_balance_type,
              sum(lb_tran_mtd_balance) as lb_tran_mtd_balance, sum(lb_base_mtd_balance) as lb_base_mtd_balance, sum(lb_local_mtd_balance) as lb_local_mtd_balance,
              sum(lb_tran_qtd_balance) as lb_tran_qtd_balance, sum(lb_base_qtd_balance) as lb_base_qtd_balance, sum(lb_local_qtd_balance) as lb_local_qtd_balance,
              sum(lb_tran_ytd_balance) as lb_tran_ytd_balance, sum(lb_base_ytd_balance) as lb_base_ytd_balance, sum(lb_local_ytd_balance) as lb_local_ytd_balance,
              sum(lb_tran_ltd_balance) as lb_tran_ltd_balance, sum(lb_base_ltd_balance) as lb_base_ltd_balance, sum(lb_local_ltd_balance) as lb_local_ltd_balance
            from slr_last_balances
            where lb_epg_id=:p_epg_id and lb_generated_for>=date '''||to_char(p_business_date, 'yyyy-mm-dd')||'''-1
            group by lb_generated_for, lb_fak_id, lb_period_month, lb_period_qtr, lb_period_year, lb_balance_type
          ) lb on lb.lb_generated_for=lbi_generated_for and lb.lb_balance_type=jlu_balance_type and jlu_fak_id=lb.lb_fak_id
      ), group_bal as (
        select
          jlu_fak_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr ,jlu_period_year,
          sum(decode(counter, 1, jlu_tran_amount, 0)) as jlu_tran_amount,
          sum(decode(counter, 1, jlu_base_amount, 0)) as jlu_base_amount,
          sum(decode(counter, 1, jlu_local_amount, 0)) as jlu_local_amount,
          sum(case
            when lb_period_month=jlu_period_month and lb_period_year=jlu_period_year then coalesce(lb_tran_mtd_balance, 0)+decode(counter, 1, jlu_tran_amount, 0)
            else decode(counter, 1, jlu_tran_amount, 0)
          end) as jlu_tran_mtd_balance,
          sum(case
            when lb_period_month=jlu_period_month and lb_period_year=jlu_period_year then coalesce(lb_base_mtd_balance, 0)+decode(counter, 1, jlu_base_amount, 0)
            else decode(counter, 1, jlu_base_amount, 0)
          end) as jlu_base_mtd_balance,
          sum(case
            when lb_period_month=jlu_period_month and lb_period_year=jlu_period_year then coalesce(lb_local_mtd_balance, 0)+decode(counter, 1, jlu_local_amount, 0)
            else decode(counter, 1, jlu_local_amount, 0)
          end) as jlu_local_mtd_balance,
          sum(case
            when lb_period_qtr=jlu_period_qtr and lb_period_year=jlu_period_year then coalesce(lb_tran_qtd_balance, 0)+decode(counter, 1, jlu_tran_amount, 0)
            else decode(counter, 1, jlu_tran_amount, 0)
          end) as jlu_tran_qtd_balance,
          sum(case
            when lb_period_qtr=jlu_period_qtr and lb_period_year=jlu_period_year then coalesce(lb_base_qtd_balance, 0)+decode(counter, 1, jlu_base_amount, 0)
            else decode(counter, 1, jlu_base_amount, 0)
          end) as jlu_base_qtd_balance,
          sum(case
            when lb_period_qtr=jlu_period_qtr and lb_period_year=jlu_period_year then coalesce(lb_local_qtd_balance, 0)+decode(counter, 1, jlu_local_amount, 0)
            else decode(counter, 1, jlu_local_amount, 0)
          end) as jlu_local_qtd_balance,
          sum(case
            when lb_period_year=jlu_period_year then coalesce(lb_tran_ytd_balance, 0)+decode(counter, 1, jlu_tran_amount, 0)
            else decode(counter, 1, jlu_tran_amount, 0)
          end) as jlu_tran_ytd_balance,
          sum(case
            when lb_period_year=jlu_period_year then coalesce(lb_base_ytd_balance, 0)+decode(counter, 1, jlu_base_amount, 0)
            else decode(counter, 1, jlu_base_amount, 0)
          end) as jlu_base_ytd_balance,
          sum(case
            when lb_period_year=jlu_period_year then coalesce(lb_local_ytd_balance, 0)+decode(counter, 1, jlu_local_amount, 0)
            else decode(counter, 1, jlu_local_amount, 0)
          end) as jlu_local_ytd_balance,
          sum(coalesce(lb_tran_ltd_balance, 0)+decode(counter, 1, jlu_tran_amount_ltd, 0)) as jlu_tran_ltd_balance,
          sum(coalesce(lb_base_ltd_balance, 0)+decode(counter, 1, jlu_base_amount_ltd, 0)) as jlu_base_ltd_balance,
          sum(coalesce(lb_local_ltd_balance, 0)+decode(counter, 1, jlu_local_amount_ltd, 0)) as jlu_local_ltd_balance
        from bal
        group by jlu_fak_id, jlu_effective_date, jlu_balance_type, jlu_entity, jlu_period_month, jlu_period_qtr, jlu_period_year
      )
    select
      jlu_fak_id,
      jlu_effective_date,
      jlu_balance_type,
      jlu_tran_amount,
      jlu_tran_mtd_balance,
      jlu_tran_qtd_balance,
      jlu_tran_ytd_balance,
      jlu_tran_ltd_balance,
      jlu_base_amount,
      jlu_base_mtd_balance,
      jlu_base_qtd_balance,
      jlu_base_ytd_balance,
      jlu_base_ltd_balance,
      jlu_local_amount,
      jlu_local_mtd_balance,
      jlu_local_qtd_balance,
      jlu_local_ytd_balance,
      jlu_local_ltd_balance,
      jlu_entity,
      :p_epg_id,
      jlu_period_month,
      jlu_period_qtr,
      jlu_period_year,
      1,
      :p_process_id,
      sysdate from group_bal';

  lv_START_TIME:=DBMS_UTILITY.GET_TIME();
  --EXECUTE IMMEDIATE lv_sql;
      dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);
    dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );
  SLR_ADMIN_PKG.PerfInfo( 'FBAI. Insert FAK Daily Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
  SLR_ADMIN_PKG.Debug('FAK Daily Balances generated (Insert).', lv_sql);

  pg_process_state.log_proc_completed(p_conf_group   => 'SLR',
                                      p_stage        => 'slr_post_journals.pGenerateFAKDailyBalances_sub',
                                      p_process_id   => p_process_id);
  EXCEPTION WHEN OTHERS THEN
        pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
    RAISE;


END pGenerateFAKDailyBalances;

PROCEDURE pGenerateFAKDailyBalances
(
  p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
  p_business_date IN DATE,
  p_oldest_backdate IN DATE,
  p_status IN CHAR := 'U'
)
AS
    s_proc_name VARCHAR2(65) := 'SLR_POST_JOURNALS_PKG.pGenerateFAKDailyBalances';
  lv_sql VARCHAR2(32000);
  lv_date DATE;
    lv_lock_handle VARCHAR2(100);
    lv_lock_result INTEGER;
    lv_table_name VARCHAR2(30) := 'SLR_FAK_CLC_' || p_epg_id;
    lv_part_move_table_name VARCHAR2(30) := 'SLR_FAK_PM_' || p_epg_id;
    lv_subpartition_name VARCHAR2(30);
    lv_rollback_exchange BOOLEAN := FALSE;
    lv_including_indexes VARCHAR2(100) := NULL;
    lv_update_indexes VARCHAR2(100) := NULL;
    lv_START_TIME   PLS_INTEGER := 0;
    lv_cursor    NUMBER ;
    lv_countrows NUMBER;
BEGIN

  pg_process_state.log_proc(p_conf_group   => 'SLR',
                            p_stage        => 'slr_post_journals.pGenerateFAKDailyBalances_epg_id',
                            p_process_id   => p_process_id,
                            p_object_name  =>'SLR_FAK_CLC_' || p_epg_id,
                            p_epg_id        => p_epg_id,
							p_rate_set      => slr_post_journals_pkg.gp_rate_set,
							p_business_date => gp_business_date,
                            p_start_dt     =>  sysdate,
                            p_status       => 'P');


    lv_sql := '
    INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'FAK_DAILY_BALANCES_INSERT') || ' INTO ' || lv_table_name || '
    (
        FDB_FAK_ID,
        FDB_BALANCE_DATE,
        FDB_BALANCE_TYPE,
        FDB_TRAN_DAILY_MOVEMENT,
        FDB_TRAN_MTD_BALANCE,
        FDB_TRAN_QTD_BALANCE,
        FDB_TRAN_YTD_BALANCE,
        FDB_TRAN_LTD_BALANCE,
        FDB_BASE_DAILY_MOVEMENT,
        FDB_BASE_MTD_BALANCE,
        FDB_BASE_QTD_BALANCE,
        FDB_BASE_YTD_BALANCE,
        FDB_BASE_LTD_BALANCE,
        FDB_LOCAL_DAILY_MOVEMENT,
        FDB_LOCAL_MTD_BALANCE,
        FDB_LOCAL_QTD_BALANCE,
        FDB_LOCAL_YTD_BALANCE,
        FDB_LOCAL_LTD_BALANCE,
        FDB_ENTITY,
        FDB_EPG_ID,
        FDB_PERIOD_MONTH,
        FDB_PERIOD_QTR,
        FDB_PERIOD_YEAR,
        FDB_PERIOD_LTD,
        FDB_PROCESS_ID,
        FDB_AMENDED_ON
  )
    SELECT
        FDB_FAK_ID,
        FDB_BALANCE_DATE,
        FDB_BALANCE_TYPE,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_TRAN_DAILY_MOVEMENT END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_TRAN_MTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_TRAN_QTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_TRAN_YTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' and FDB_PERIOD_LTD <> 1 THEN 0 ELSE FDB_TRAN_LTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_BASE_DAILY_MOVEMENT END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_BASE_MTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_BASE_QTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_BASE_YTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' and FDB_PERIOD_LTD <> 1 THEN 0 ELSE FDB_BASE_LTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_LOCAL_DAILY_MOVEMENT END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_LOCAL_MTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_LOCAL_QTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' THEN 0 ELSE FDB_LOCAL_YTD_BALANCE END,
        CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' and FDB_PERIOD_LTD <> 1 THEN 0 else FDB_LOCAL_LTD_BALANCE end,
        FDB_ENTITY,
        FDB_EPG_ID,
        FDB_PERIOD_MONTH,
        FDB_PERIOD_QTR,
        FDB_PERIOD_YEAR,
        FDB_PERIOD_LTD,
        FDB_PROCESS_ID,
        FDB_AMENDED_ON
  FROM
  (
    (
      SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'FAK_DAILY_BALANCES_ALL') || '
        FDB_FAK_ID,
        FDB_BALANCE_DATE,
        FDB_BALANCE_TYPE ,
        FDB_TRAN_DAILY_MOVEMENT,
        FDB_TRAN_MTD_BALANCE,
                FDB_TRAN_QTD_BALANCE,
        FDB_TRAN_YTD_BALANCE,
        FDB_TRAN_LTD_BALANCE,
        FDB_BASE_DAILY_MOVEMENT,
        FDB_BASE_MTD_BALANCE,
                FDB_BASE_QTD_BALANCE,
        FDB_BASE_YTD_BALANCE,
        FDB_BASE_LTD_BALANCE,
        FDB_LOCAL_DAILY_MOVEMENT,
        FDB_LOCAL_MTD_BALANCE,
                FDB_LOCAL_QTD_BALANCE,
        FDB_LOCAL_YTD_BALANCE,
        FDB_LOCAL_LTD_BALANCE,
        FDB_ENTITY,
        FDB_EPG_ID,
        FDB_PERIOD_MONTH,
                FDB_PERIOD_QTR,
        FDB_PERIOD_YEAR,
        FDB_PERIOD_LTD,
        ''N'' FDB_JRNL_INTERNAL_PERIOD_FLAG,
                :p_process_id FDB_PROCESS_ID,
                FDB_AMENDED_ON
      FROM SLR_FAK_DAILY_BALANCES, SLR_ENTITIES ent
      WHERE FDB_EPG_ID = :p_epg_id
     AND ent.ENT_ENTITY = FDB_ENTITY
      AND ((FDB_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR FDB_BALANCE_TYPE <> ''20'')
        AND FDB_BALANCE_DATE >= :p_oldest_backdate
        AND FDB_FAK_ID NOT IN
          (
                        SELECT JLU_FAK_ID FROM SLR_JRNL_LINES_UNPOSTED, SLR_EXT_JRNL_TYPES jt
                        WHERE JLU_EPG_ID = :p_epg_id
            AND JLU_JRNL_STATUS = :p_status
            AND JLU_JRNL_TYPE = jt.EJT_TYPE
                        and (FDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_1 or FDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_2)
                    )
    )
    UNION ALL
        SELECT * FROM
    (
      SELECT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'FAK_DAILY_BALANCES_CALC') || '
        FDB_FAK_ID,
        FDB_BALANCE_DATE,
        FDB_BALANCE_TYPE,
        CAST(FDB_TRAN_DAILY_MOVEMENT AS NUMBER(38,3)) FDB_TRAN_DAILY_MOVEMENT,
        CAST(SUM(FDB_TRAN_MTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_MONTH, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_MTD_BALANCE,
        CAST(SUM(FDB_TRAN_QTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_QTR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_QTD_BALANCE,
        CAST(SUM(FDB_TRAN_YTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_YTD_BALANCE,
        CAST(SUM(CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''N'' THEN FDB_TRAN_LTD_BALANCE ELSE FDB_TRAN_LTD_BALANCE_IP END ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_LTD, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_LTD_BALANCE,
        CAST(FDB_BASE_DAILY_MOVEMENT AS NUMBER(38,3)) FDB_BASE_DAILY_MOVEMENT,
        CAST(SUM(FDB_BASE_MTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_MONTH, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_MTD_BALANCE,
        CAST(SUM(FDB_BASE_QTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_QTR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_QTD_BALANCE,
        CAST(SUM(FDB_BASE_YTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_YTD_BALANCE,
        CAST(SUM(CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''N'' THEN FDB_BASE_LTD_BALANCE ELSE FDB_BASE_LTD_BALANCE_IP END ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_LTD, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_LTD_BALANCE,
        CAST(FDB_LOCAL_DAILY_MOVEMENT  AS NUMBER(38,3)) FDB_LOCAL_DAILY_MOVEMENT,
        CAST(SUM(FDB_LOCAL_MTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_MONTH, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_MTD_BALANCE,
        CAST(SUM(FDB_LOCAL_QTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_QTR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_QTD_BALANCE,
        CAST(SUM(FDB_LOCAL_YTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_YTD_BALANCE,
        CAST(SUM(CASE WHEN FDB_JRNL_INTERNAL_PERIOD_FLAG = ''N'' THEN FDB_LOCAL_LTD_BALANCE ELSE FDB_LOCAL_LTD_BALANCE_IP END ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_LTD, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_LTD_BALANCE,
        FDB_ENTITY,
        FDB_EPG_ID,
        FDB_PERIOD_MONTH,
                FDB_PERIOD_QTR,
        FDB_PERIOD_YEAR,
        FDB_PERIOD_LTD,
        FDB_JRNL_INTERNAL_PERIOD_FLAG,
                :p_process_id FDB_PROCESS_ID,
                FDB_AMENDED_ON
      FROM
      (
        SELECT /*+ NO_MERGE */
          FDB_FAK_ID,
          FDB_BALANCE_DATE,
          FDB_BALANCE_TYPE,
          SUM(FDB_TRAN_DAILY_MOVEMENT) FDB_TRAN_DAILY_MOVEMENT,
          SUM(FDB_TRAN_DAILY_MOVEMENT) FDB_TRAN_MTD_BALANCE,
          SUM(FDB_TRAN_DAILY_MOVEMENT) FDB_TRAN_QTD_BALANCE,
          SUM(FDB_TRAN_DAILY_MOVEMENT) FDB_TRAN_YTD_BALANCE,
          SUM(FDB_TRAN_DAILY_MOVEMENT) FDB_TRAN_LTD_BALANCE,
          SUM(FDB_TRAN_LTD_BALANCE_IP) FDB_TRAN_LTD_BALANCE_IP,
          SUM(FDB_BASE_DAILY_MOVEMENT) FDB_BASE_DAILY_MOVEMENT,
          SUM(FDB_BASE_DAILY_MOVEMENT) FDB_BASE_MTD_BALANCE,
          SUM(FDB_BASE_DAILY_MOVEMENT) FDB_BASE_QTD_BALANCE,
          SUM(FDB_BASE_DAILY_MOVEMENT) FDB_BASE_YTD_BALANCE,
          SUM(FDB_BASE_DAILY_MOVEMENT) FDB_BASE_LTD_BALANCE,
          SUM(FDB_BASE_LTD_BALANCE_IP) FDB_BASE_LTD_BALANCE_IP,
          SUM(FDB_LOCAL_DAILY_MOVEMENT) FDB_LOCAL_DAILY_MOVEMENT,
          SUM(FDB_LOCAL_DAILY_MOVEMENT) FDB_LOCAL_MTD_BALANCE,
          SUM(FDB_LOCAL_DAILY_MOVEMENT) FDB_LOCAL_QTD_BALANCE,
          SUM(FDB_LOCAL_DAILY_MOVEMENT) FDB_LOCAL_YTD_BALANCE,
          SUM(FDB_LOCAL_DAILY_MOVEMENT) FDB_LOCAL_LTD_BALANCE,
          SUM(FDB_LOCAL_LTD_BALANCE_IP) FDB_LOCAL_LTD_BALANCE_IP,
          FDB_ENTITY,
          FDB_EPG_ID,
          FDB_PERIOD_MONTH,
          FDB_PERIOD_QTR,
          FDB_PERIOD_YEAR,
          FDB_PERIOD_LTD,
          MAX(FDB_JRNL_INTERNAL_PERIOD_FLAG) AS FDB_JRNL_INTERNAL_PERIOD_FLAG,
          MAX(FDB_AMENDED_ON) AS FDB_AMENDED_ON
        FROM
        (
          SELECT
            FDB_FAK_ID,
            FDB_BALANCE_DATE,
            FDB_BALANCE_TYPE,
            FDB_TRAN_DAILY_MOVEMENT,
            FDB_TRAN_LTD_BALANCE_IP,
            FDB_BASE_DAILY_MOVEMENT,
            FDB_BASE_LTD_BALANCE_IP,
            FDB_LOCAL_DAILY_MOVEMENT,
            FDB_LOCAL_LTD_BALANCE_IP,
            FDB_ENTITY,
            FDB_EPG_ID,
            FDB_PERIOD_MONTH,
            FDB_PERIOD_QTR,
            FDB_PERIOD_YEAR,
            FDB_PERIOD_LTD,
            FDB_JRNL_INTERNAL_PERIOD_FLAG,
                        FDB_AMENDED_ON
          FROM
          (
            SELECT
              FDB_FAK_ID, FDB_BALANCE_DATE,
              FDB_BALANCE_TYPE,
              FDB_TRAN_DAILY_MOVEMENT, FDB_TRAN_LTD_BALANCE FDB_TRAN_LTD_BALANCE_IP,
              FDB_BASE_DAILY_MOVEMENT, FDB_BASE_LTD_BALANCE FDB_BASE_LTD_BALANCE_IP,
                            FDB_LOCAL_DAILY_MOVEMENT, FDB_LOCAL_LTD_BALANCE FDB_LOCAL_LTD_BALANCE_IP,
              FDB_ENTITY, FDB_EPG_ID,
              FDB_PERIOD_MONTH, FDB_PERIOD_QTR, FDB_PERIOD_YEAR,
              FDB_PERIOD_LTD, ''N'' FDB_JRNL_INTERNAL_PERIOD_FLAG, FDB_AMENDED_ON
            FROM SLR_FAK_DAILY_BALANCES, SLR_ENTITIES ent
            WHERE FDB_EPG_ID = :p_epg_id
            AND ent.ENT_ENTITY = FDB_ENTITY
              AND ((FDB_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR FDB_BALANCE_TYPE <> ''20'')
              AND FDB_BALANCE_DATE >= :p_oldest_backdate
              AND FDB_FAK_ID IN
                (
                                    SELECT JLU_FAK_ID FROM SLR_JRNL_LINES_UNPOSTED
                                    WHERE JLU_EPG_ID = :p_epg_id
                  AND JLU_JRNL_STATUS = :p_status
                                )
            UNION ALL
            SELECT
              JLU_FAK_ID FDB_FAK_ID, JLU_EFFECTIVE_DATE FDB_BALANCE_DATE,
              JT_BALANCE_TYPE FDB_BALANCE_TYPE,
              JLU_TRAN_AMOUNT FDB_TRAN_DAILY_MOVEMENT,JLU_TRAN_AMOUNT FDB_TRAN_LTD_BALANCE_IP,
              JLU_BASE_AMOUNT FDB_BASE_DAILY_MOVEMENT,JLU_BASE_AMOUNT FDB_BASE_LTD_BALANCE_IP,
              JLU_LOCAL_AMOUNT FDB_LOCAL_DAILY_MOVEMENT,JLU_LOCAL_AMOUNT FDB_LOCAL_LTD_BALANCE_IP,
              JLU_ENTITY FDB_ENTITY, JLU_EPG_ID FDB_EPG_ID,
              JLU_PERIOD_MONTH FDB_PERIOD_MONTH, JLU_PERIOD_QTR FDB_PERIOD_QTR, JLU_PERIOD_YEAR FDB_PERIOD_YEAR,
              JLU_PERIOD_LTD FDB_PERIOD_LTD,NVL(JLU_JRNL_INTERNAL_PERIOD_FLAG,''N'') FDB_JRNL_INTERNAL_PERIOD_FLAG, SYSDATE FDB_AMENDED_ON
            FROM V_SLR_JRNL_LINES_UNPOSTED_JT, SLR_ENTITIES ent
            WHERE JLU_EPG_ID = :p_epg_id
            AND ent.ENT_ENTITY = JLU_ENTITY
              AND ((JT_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR JT_BALANCE_TYPE <> ''20'')
              AND JLU_JRNL_STATUS = :p_status
          )
        )
        GROUP BY FDB_BALANCE_DATE, FDB_FAK_ID, FDB_BALANCE_TYPE, FDB_ENTITY, FDB_EPG_ID, FDB_PERIOD_MONTH, FDB_PERIOD_QTR, FDB_PERIOD_YEAR, FDB_PERIOD_LTD
        UNION ALL
        SELECT /*+ NO_MERGE */
          LB_FAK_ID FDB_FAK_ID, :c_unused_date_for_lb FDB_BALANCE_DATE,
          LB_BALANCE_TYPE FDB_BALANCE_TYPE, 0 FDB_TRAN_DAILY_MOVEMENT,
          LB_TRAN_MTD_BALANCE FDB_TRAN_MTD_BALANCE, LB_TRAN_QTD_BALANCE FDB_TRAN_QTD_BALANCE, LB_TRAN_YTD_BALANCE FDB_TRAN_YTD_BALANCE,
          LB_TRAN_LTD_BALANCE FDB_TRAN_LTD_BALANCE, LB_TRAN_LTD_BALANCE FDB_TRAN_LTD_BALANCE_IP,
          0 FDB_BASE_DAILY_MOVEMENT,
          LB_BASE_MTD_BALANCE FDB_BASE_MTD_BALANCE, LB_BASE_QTD_BALANCE FDB_BASE_QTD_BALANCE, LB_BASE_YTD_BALANCE FDB_BASE_YTD_BALANCE,
          LB_BASE_LTD_BALANCE FDB_BASE_LTD_BALANCE, LB_BASE_LTD_BALANCE FDB_BASE_LTD_BALANCE_IP,
          0 FDB_LOCAL_DAILY_MOVEMENT,
          LB_LOCAL_MTD_BALANCE FDB_LOCAL_MTD_BALANCE,    LB_LOCAL_QTD_BALANCE FDB_LOCAL_QTD_BALANCE,LB_LOCAL_YTD_BALANCE FDB_LOCAL_YTD_BALANCE,
          LB_LOCAL_LTD_BALANCE FDB_LOCAL_LTD_BALANCE, LB_LOCAL_LTD_BALANCE FDB_LOCAL_LTD_BALANCE_IP,
          LB_ENTITY FDB_ENTITY,
          LB_EPG_ID FDB_EPG_ID, LB_PERIOD_MONTH FDB_PERIOD_MONTH, LB_PERIOD_QTR FDB_PERIOD_QTR,
          LB_PERIOD_YEAR FDB_PERIOD_YEAR, LB_PERIOD_LTD FDB_PERIOD_LTD, ''N'' FDB_JRNL_INTERNAL_PERIOD_FLAG,
                    :c_unused_date_for_lb FDB_AMENDED_ON
        FROM SLR_LAST_BALANCES, SLR_ENTITIES ent
        WHERE LB_EPG_ID = :p_epg_id
          AND ent.ENT_ENTITY = LB_ENTITY
          AND ((LB_BALANCE_TYPE = ''20'' AND ent.ENT_ADJUSTMENT_FLAG = ''Y'') OR LB_BALANCE_TYPE <> ''20'')
          AND LB_GENERATED_FOR = (:p_oldest_backdate - 1)
                    AND LB_FAK_ID IN
                    (
                        SELECT JLU_FAK_ID FROM SLR_JRNL_LINES_UNPOSTED
                        WHERE JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status
                    )
      )
    )
        WHERE FDB_BALANCE_DATE > :c_unused_date_for_lb
    AND FDB_FAK_ID IN
                    (
                        SELECT JLU_FAK_ID FROM SLR_JRNL_LINES_UNPOSTED, SLR_EXT_JRNL_TYPES jt
                        WHERE JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status
                        AND JLU_JRNL_TYPE = jt.EJT_TYPE
                        and (FDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_1 or FDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_2)
                    )
  )
  ';

    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    lv_cursor    := dbms_sql.open_cursor;
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':p_oldest_backdate',p_oldest_backdate);
    dbms_sql.bind_variable( lv_cursor, ':c_unused_date_for_lb',c_unused_date_for_lb);
    dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);
    dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );
 -- EXECUTE IMMEDIATE lv_sql USING p_process_id, p_oldest_backdate, p_process_id, p_oldest_backdate, p_oldest_backdate;
    COMMIT;
    SLR_ADMIN_PKG.PerfInfo( 'FAK. FAK Daily Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
    SLR_ADMIN_PKG.Debug('FAK Daily Balances inserted into CLC table.', lv_sql);

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || lv_part_move_table_name;
    lv_date := p_oldest_backdate;
    WHILE lv_date <= p_business_date LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE SLR_FAK_BALANCES_ROLLBACK
            TRUNCATE SUBPARTITION ' || SLR_UTILITIES_PKG.fSubpartitionName(p_epg_id, lv_date);
        lv_date := lv_date + 1;
    END LOOP;

    IF gv_local_index_fak = TRUE THEN
        lv_including_indexes := ' INCLUDING INDEXES ';
    END IF;

    IF gv_global_index_fak = TRUE THEN
        lv_update_indexes := ' UPDATE INDEXES ';
    END IF;

    DBMS_LOCK.ALLOCATE_UNIQUE('MAH_SLR_FAK_BALANCES', lv_lock_handle);
    lv_lock_result := DBMS_LOCK.REQUEST(lv_lock_handle, DBMS_LOCK.X_MODE, c_lock_request_timeout);
    IF lv_lock_result != 0 THEN
        RAISE e_lock_acquire_error;
    END IF;

    lv_date := p_oldest_backdate;
    lv_rollback_exchange := TRUE;
    WHILE lv_date <= p_business_date LOOP
        lv_subpartition_name := SLR_UTILITIES_PKG.fSubpartitionName(p_epg_id, lv_date);

        EXECUTE IMMEDIATE 'ALTER TABLE ' || lv_table_name || '
            EXCHANGE PARTITION P' || TO_CHAR(lv_date, 'YYYYMMDD') || '
            WITH TABLE ' || lv_part_move_table_name || lv_including_indexes || ' WITHOUT VALIDATION ' || lv_update_indexes;

        EXECUTE IMMEDIATE 'ALTER TABLE SLR_FAK_DAILY_BALANCES
            EXCHANGE SUBPARTITION ' || lv_subpartition_name || '
            WITH TABLE ' || lv_part_move_table_name || lv_including_indexes || ' WITHOUT VALIDATION ' || lv_update_indexes;

        -- creating backup copy for rollback
        EXECUTE IMMEDIATE 'ALTER TABLE SLR_FAK_BALANCES_ROLLBACK
            EXCHANGE SUBPARTITION ' || lv_subpartition_name || '
            WITH TABLE ' || lv_part_move_table_name || lv_including_indexes || ' WITHOUT VALIDATION ' || lv_update_indexes;

        lv_date := lv_date + 1;
    END LOOP;

    lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);

    SLR_ADMIN_PKG.Info('FAK daily balances inserted into CLC table');
    pg_process_state.log_proc_completed(p_conf_group   => 'SLR',
                              p_stage        => 'slr_post_journals.pGenerateFAKDailyBalances_epg_id',
                              p_process_id   => p_process_id);

EXCEPTION
    WHEN e_lock_acquire_error THEN
        pWriteLogError(s_proc_name, 'SLR_FAK_DAILY_BALANCES',
      'Error during generating FAK daily balances: can''t acquire lock to exchange partitions',
      p_process_id,p_epg_id , p_status );
        SLR_ADMIN_PKG.Error('Error during generating FAK daily balances: can''t acquire lock to exchange partitions');
		pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
        RAISE e_internal_processing_error; -- raised to stop execution
  WHEN OTHERS THEN
        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
        pWriteLogError(s_proc_name, 'SLR_FAK_DAILY_BALANCES',
      'Error during generating FAK daily balances ', p_process_id,p_epg_id , p_status );
        SLR_ADMIN_PKG.Error('Error during generating FAK daily balances ');
        IF lv_rollback_exchange = TRUE THEN
            pFakBalancesRollback(p_epg_id, p_process_id);
        END IF;
		pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
        RAISE e_fak_daily_balances_error;

END pGenerateFAKDailyBalances;



PROCEDURE pGenerateFAKDailyBalancesMerge
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_business_date IN DATE,
    p_oldest_backdate IN DATE,
    p_status IN CHAR := 'U'
)
AS
    lv_sql VARCHAR2(32000);
  lv_START_TIME   PLS_INTEGER := 0;
  lv_cursor    NUMBER := dbms_sql.open_cursor;
  lv_countrows NUMBER;
BEGIN

    pg_process_state.log_proc(p_conf_group   => 'SLR',
                              p_stage        => 'slr_post_journals.pGenerateFAKDailyBalancesMerge',
                              p_process_id   => p_process_id,
                              p_object_name  => 'SLR_FAK_DAILY_BALANCES',
                              p_epg_id        => p_epg_id,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
							  p_business_date => gp_business_date,
                              p_sub_partition  => 'P'||to_char(p_business_date, 'yyyymmdd')||'_S'||p_epg_id,
                              p_start_dt     =>  sysdate,
                              p_status       => 'P');

    lv_sql := '
        MERGE ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'FAK_DAILY_BALANCES_MERGE') || ' INTO SLR_FAK_DAILY_BALANCES B USING
        (
            SELECT * FROM
            (
                SELECT
                    FDB_FAK_ID,
                    FDB_BALANCE_DATE,
                    FDB_BALANCE_TYPE,
                    CAST(FDB_TRAN_DAILY_MOVEMENT AS NUMBER(38,3)) FDB_TRAN_DAILY_MOVEMENT,
                    CAST(SUM(FDB_TRAN_MTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_MONTH, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_MTD_BALANCE,
                    CAST(SUM(FDB_TRAN_QTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_QTR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_QTD_BALANCE,
                    CAST(SUM(FDB_TRAN_YTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_YTD_BALANCE,
                    CAST(SUM(CASE WHEN BAL_EXISTS = 1 THEN -PREV_TRAN_LTD + FDB_TRAN_LTD_BALANCE ELSE FDB_TRAN_LTD_BALANCE END) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_TRAN_LTD_BALANCE,
                    CAST(FDB_BASE_DAILY_MOVEMENT AS NUMBER(38,3)) FDB_BASE_DAILY_MOVEMENT,
                    CAST(SUM(FDB_BASE_MTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_MONTH, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_MTD_BALANCE,
                    CAST(SUM(FDB_BASE_QTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_QTR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_QTD_BALANCE,
                    CAST(SUM(FDB_BASE_YTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_YTD_BALANCE,
                    CAST(SUM(CASE WHEN BAL_EXISTS = 1 THEN -PREV_BASE_LTD + FDB_BASE_LTD_BALANCE ELSE FDB_BASE_LTD_BALANCE END) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_BASE_LTD_BALANCE,
                    CAST(FDB_LOCAL_DAILY_MOVEMENT  AS NUMBER(38,3)) FDB_LOCAL_DAILY_MOVEMENT,
                    CAST(SUM(FDB_LOCAL_MTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_MONTH, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_MTD_BALANCE,
                    CAST(SUM(FDB_LOCAL_QTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_PERIOD_QTR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_QTD_BALANCE,
                    CAST(SUM(FDB_LOCAL_YTD_BALANCE ) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_PERIOD_YEAR, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_YTD_BALANCE,
                    CAST(SUM(CASE WHEN BAL_EXISTS = 1 THEN -PREV_LOCAL_LTD + FDB_LOCAL_LTD_BALANCE ELSE FDB_LOCAL_LTD_BALANCE END) OVER (PARTITION BY FDB_BALANCE_TYPE, FDB_FAK_ID ORDER BY FDB_BALANCE_DATE) AS NUMBER(38,3)) FDB_LOCAL_LTD_BALANCE,
                    FDB_ENTITY,
                    FDB_EPG_ID,
                    FDB_PERIOD_MONTH,
                    FDB_PERIOD_QTR,
                    FDB_PERIOD_YEAR,
                    :p_process_id AS FDB_PROCESS_ID,
                    FDB_AMENDED_ON
                FROM
                (   SELECT data_set.*,
                        CASE WHEN LAST_BAL = 1 THEN 0 ELSE LAG(TRAN_LTD,1,0) OVER(PARTITION BY FDB_BALANCE_TYPE, FDB_FAK_ID, BAL_EXISTS ORDER BY FDB_BALANCE_DATE) END PREV_TRAN_LTD,
                        CASE WHEN LAST_BAL = 1 THEN 0 ELSE LAG(BASE_LTD,1,0) OVER(PARTITION BY FDB_BALANCE_TYPE, FDB_FAK_ID, BAL_EXISTS ORDER BY FDB_BALANCE_DATE) END PREV_BASE_LTD,
                        CASE WHEN LAST_BAL = 1 THEN 0 ELSE LAG(LOCAL_LTD,1,0) OVER(PARTITION BY FDB_BALANCE_TYPE, FDB_FAK_ID, BAL_EXISTS ORDER BY FDB_BALANCE_DATE) END PREV_LOCAL_LTD
                    FROM
                        (
                        SELECT
                            FDB_FAK_ID,
                            FDB_BALANCE_DATE,
                            FDB_BALANCE_TYPE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_TRAN_DAILY_MOVEMENT end) FDB_TRAN_DAILY_MOVEMENT,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_TRAN_DAILY_MOVEMENT end) FDB_TRAN_MTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_TRAN_DAILY_MOVEMENT end) FDB_TRAN_QTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_TRAN_DAILY_MOVEMENT end) FDB_TRAN_YTD_BALANCE,
                            SUM(FDB_TRAN_LTD_BALANCE) FDB_TRAN_LTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_BASE_DAILY_MOVEMENT end) FDB_BASE_DAILY_MOVEMENT,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_BASE_DAILY_MOVEMENT end) FDB_BASE_MTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_BASE_DAILY_MOVEMENT end) FDB_BASE_QTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_BASE_DAILY_MOVEMENT end) FDB_BASE_YTD_BALANCE,
                            SUM(FDB_BASE_LTD_BALANCE) FDB_BASE_LTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_LOCAL_DAILY_MOVEMENT end) FDB_LOCAL_DAILY_MOVEMENT,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_LOCAL_DAILY_MOVEMENT end) FDB_LOCAL_MTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_LOCAL_DAILY_MOVEMENT end) FDB_LOCAL_QTD_BALANCE,
                            SUM(case when FDB_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' then 0 else FDB_LOCAL_DAILY_MOVEMENT end) FDB_LOCAL_YTD_BALANCE,
                            SUM(FDB_LOCAL_LTD_BALANCE) FDB_LOCAL_LTD_BALANCE,
                            FDB_ENTITY,
                            FDB_EPG_ID,
                            FDB_PERIOD_MONTH,
                            FDB_PERIOD_QTR,
                            FDB_PERIOD_YEAR,
                            MAX(FDB_AMENDED_ON) AS FDB_AMENDED_ON,
                            SUM(TRAN_LTD) TRAN_LTD,
                            SUM(BASE_LTD) BASE_LTD,
                            SUM(LOCAL_LTD) LOCAL_LTD,
                            SUM(BAL_EXISTS) BAL_EXISTS,
                            0 LAST_BAL
                        FROM
                        (
                            SELECT
                                FDB_FAK_ID,
                                FDB_BALANCE_DATE,
                                FDB_BALANCE_TYPE,
                                FDB_TRAN_DAILY_MOVEMENT,
                                FDB_TRAN_LTD_BALANCE,
                                FDB_BASE_DAILY_MOVEMENT,
                                FDB_BASE_LTD_BALANCE,
                                FDB_LOCAL_DAILY_MOVEMENT,
                                FDB_LOCAL_LTD_BALANCE,
                                FDB_ENTITY,
                                FDB_EPG_ID,
                                FDB_PERIOD_MONTH,
                                FDB_PERIOD_QTR,
                                FDB_PERIOD_YEAR,
                                FDB_JRNL_INTERNAL_PERIOD_FLAG,
                                FDB_AMENDED_ON,
                                TRAN_LTD,
                                BASE_LTD,
                                LOCAL_LTD,
                                BAL_EXISTS
                            FROM
                            (
                                SELECT
                                    FDB_FAK_ID,
                                    FDB_BALANCE_DATE, FDB_BALANCE_TYPE,
                                    FDB_TRAN_DAILY_MOVEMENT, FDB_TRAN_LTD_BALANCE,
                                    FDB_BASE_DAILY_MOVEMENT, FDB_BASE_LTD_BALANCE,
                                    FDB_LOCAL_DAILY_MOVEMENT, FDB_LOCAL_LTD_BALANCE,
                                    FDB_ENTITY,
                                    FDB_EPG_ID, FDB_PERIOD_MONTH, FDB_PERIOD_QTR,
                                    FDB_PERIOD_YEAR,
                                    ''N'' FDB_JRNL_INTERNAL_PERIOD_FLAG,
                                    FDB_AMENDED_ON,
                                    FDB_TRAN_LTD_BALANCE TRAN_LTD,
                                    FDB_BASE_LTD_BALANCE BASE_LTD,
                                    FDB_LOCAL_LTD_BALANCE LOCAL_LTD,
                                    1 BAL_EXISTS
                                FROM SLR_FAK_DAILY_BALANCES
                                WHERE FDB_EPG_ID = :p_epg_id
                                    AND FDB_BALANCE_DATE >= :p_oldest_backdate
                                    AND FDB_FAK_ID IN
                                    (
                                        SELECT JLU_FAK_ID FROM SLR_JRNL_LINES_UNPOSTED
                                        WHERE JLU_EPG_ID = :p_epg_id
                                        AND JLU_JRNL_STATUS = :p_status
                                    )
                                UNION ALL
                                SELECT
                                    JLU_FAK_ID FDB_FAK_ID,
                                    JLU_EFFECTIVE_DATE FDB_BALANCE_DATE, JT_BALANCE_TYPE FDB_BALANCE_TYPE,
                                    JLU_TRAN_AMOUNT FDB_TRAN_DAILY_MOVEMENT,
                                    JLU_TRAN_AMOUNT FDB_TRAN_LTD_BALANCE,
                                    JLU_BASE_AMOUNT FDB_BASE_DAILY_MOVEMENT,
                                    JLU_BASE_AMOUNT FDB_BASE_LTD_BALANCE,
                                    JLU_LOCAL_AMOUNT FDB_LOCAL_DAILY_MOVEMENT,
                                    JLU_LOCAL_AMOUNT FDB_LOCAL_LTD_BALANCE,
                                    JLU_ENTITY FDB_ENTITY,
                                    JLU_EPG_ID FDB_EPG_ID, JLU_PERIOD_MONTH FDB_PERIOD_MONTH, JLU_PERIOD_QTR FDB_PERIOD_QTR,
                                    JLU_PERIOD_YEAR FDB_PERIOD_YEAR,
                                    NVL(JLU_JRNL_INTERNAL_PERIOD_FLAG,''N'') FDB_JRNL_INTERNAL_PERIOD_FLAG,
                                    SYSDATE FDB_AMENDED_ON,
                                    0 TRAN_LTD,
                                    0 BASE_LTD,
                                    0 LOCAL_LTD,
                                    0 BAL_EXISTS
                                FROM V_SLR_JRNL_LINES_UNPOSTED_JT
                                WHERE JLU_EPG_ID = :p_epg_id
                                    AND JLU_JRNL_STATUS = :p_status
                            )
                        )
                        GROUP BY FDB_BALANCE_DATE, FDB_FAK_ID, FDB_BALANCE_TYPE, FDB_ENTITY, FDB_EPG_ID, FDB_PERIOD_MONTH, FDB_PERIOD_QTR, FDB_PERIOD_YEAR
                        UNION ALL
                        SELECT
                            LB_FAK_ID FDB_FAK_ID,
                            :c_unused_date_for_lb FDB_BALANCE_DATE,
                            LB_BALANCE_TYPE FDB_BALANCE_TYPE,
                            0 FDB_TRAN_DAILY_MOVEMENT,
                            sum(LB_TRAN_MTD_BALANCE) FDB_TRAN_MTD_BALANCE,
                            sum(LB_TRAN_QTD_BALANCE) FDB_TRAN_QTD_BALANCE,
                            sum(LB_TRAN_YTD_BALANCE) FDB_TRAN_YTD_BALANCE,
                            sum(LB_TRAN_LTD_BALANCE) FDB_TRAN_LTD_BALANCE,
                            0 FDB_BASE_DAILY_MOVEMENT,
                            sum(LB_BASE_MTD_BALANCE) FDB_BASE_MTD_BALANCE,
                            sum(LB_BASE_QTD_BALANCE) FDB_BASE_QTD_BALANCE,
                            sum(LB_BASE_YTD_BALANCE) FDB_BASE_YTD_BALANCE,
                            sum(LB_BASE_LTD_BALANCE) FDB_BASE_LTD_BALANCE,
                            0 FDB_LOCAL_DAILY_MOVEMENT,
                            sum(LB_LOCAL_MTD_BALANCE) FDB_LOCAL_MTD_BALANCE,
                            sum(LB_LOCAL_QTD_BALANCE) FDB_LOCAL_QTD_BALANCE,
                            sum(LB_LOCAL_YTD_BALANCE) FDB_LOCAL_YTD_BALANCE,
                            sum(LB_LOCAL_LTD_BALANCE) FDB_LOCAL_LTD_BALANCE,
                            LB_ENTITY FDB_ENTITY,
                            LB_EPG_ID FDB_EPG_ID,
                            LB_PERIOD_MONTH FDB_PERIOD_MONTH, LB_PERIOD_QTR FDB_PERIOD_QTR,
                            LB_PERIOD_YEAR FDB_PERIOD_YEAR,
                            :c_unused_date_for_lb FDB_AMENDED_ON,
                            SUM(sum(LB_TRAN_LTD_BALANCE)) OVER(PARTITION BY LB_BALANCE_TYPE, LB_FAK_ID) TRAN_LTD,
                            SUM(sum(LB_BASE_LTD_BALANCE)) OVER(PARTITION BY LB_BALANCE_TYPE, LB_FAK_ID) BASE_LTD,
                            SUM(sum(LB_LOCAL_LTD_BALANCE)) OVER(PARTITION BY LB_BALANCE_TYPE, LB_FAK_ID) LOCAL_LTD,
                            1 BAL_EXISTS,
                            1 LAST_BAL
                        FROM SLR_LAST_BALANCES
                        WHERE LB_GENERATED_FOR =  (:p_oldest_backdate - 1)
                            AND LB_EPG_ID = :p_epg_id
                            AND LB_FAK_ID IN
                            (
                                SELECT JLU_FAK_ID FROM SLR_JRNL_LINES_UNPOSTED
                                WHERE JLU_EPG_ID = :p_epg_id
                                AND JLU_JRNL_STATUS = :p_status
                            )
                        GROUP BY LB_FAK_ID, LB_BALANCE_TYPE, LB_ENTITY, LB_EPG_ID, LB_PERIOD_MONTH, LB_PERIOD_QTR, LB_PERIOD_YEAR
                        ) data_set
                )
            )
            WHERE FDB_BALANCE_DATE > :c_unused_date_for_lb
                AND FDB_FAK_ID IN
                (
                    SELECT JLU_FAK_ID FROM SLR_JRNL_LINES_UNPOSTED, SLR_EXT_JRNL_TYPES jt
                    WHERE JLU_EPG_ID = :p_epg_id
                        AND JLU_JRNL_STATUS = :p_status
                        AND FDB_FAK_ID = JLU_FAK_ID
                        AND FDB_BALANCE_DATE >= JLU_EFFECTIVE_DATE
                        AND JLU_JRNL_TYPE = jt.EJT_TYPE
                        AND (FDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_1 or FDB_BALANCE_TYPE = jt.EJT_BALANCE_TYPE_2)
                )
        ) CLC
        ON
        (
            CLC.FDB_BALANCE_DATE = B.FDB_BALANCE_DATE
            AND CLC.FDB_PERIOD_YEAR=B.FDB_PERIOD_YEAR
            AND CLC.FDB_PERIOD_MONTH=B.FDB_PERIOD_MONTH
            AND CLC.FDB_FAK_ID = B.FDB_FAK_ID
            AND CLC.FDB_BALANCE_TYPE = B.FDB_BALANCE_TYPE
            AND CLC.FDB_EPG_ID = B.FDB_EPG_ID
            AND B.FDB_BALANCE_DATE >= :p_oldest_backdate
            AND B.FDB_EPG_ID = :p_epg_id
        )
        WHEN MATCHED THEN UPDATE SET
            B.FDB_TRAN_DAILY_MOVEMENT = CLC.FDB_TRAN_DAILY_MOVEMENT,
            B.FDB_TRAN_MTD_BALANCE = CLC.FDB_TRAN_MTD_BALANCE,
            B.FDB_TRAN_QTD_BALANCE = CLC.FDB_TRAN_QTD_BALANCE,
            B.FDB_TRAN_YTD_BALANCE = CLC.FDB_TRAN_YTD_BALANCE,
            B.FDB_TRAN_LTD_BALANCE = CLC.FDB_TRAN_LTD_BALANCE,
            B.FDB_BASE_DAILY_MOVEMENT = CLC.FDB_BASE_DAILY_MOVEMENT,
            B.FDB_BASE_MTD_BALANCE = CLC.FDB_BASE_MTD_BALANCE,
            B.FDB_BASE_QTD_BALANCE = CLC.FDB_BASE_QTD_BALANCE,
            B.FDB_BASE_YTD_BALANCE = CLC.FDB_BASE_YTD_BALANCE,
            B.FDB_BASE_LTD_BALANCE = CLC.FDB_BASE_LTD_BALANCE,
            B.FDB_LOCAL_DAILY_MOVEMENT = CLC.FDB_LOCAL_DAILY_MOVEMENT,
            B.FDB_LOCAL_MTD_BALANCE = CLC.FDB_LOCAL_MTD_BALANCE,
            B.FDB_LOCAL_QTD_BALANCE = CLC.FDB_LOCAL_QTD_BALANCE,
            B.FDB_LOCAL_YTD_BALANCE = CLC.FDB_LOCAL_YTD_BALANCE,
            B.FDB_LOCAL_LTD_BALANCE = CLC.FDB_LOCAL_LTD_BALANCE,
            B.FDB_PROCESS_ID = CLC.FDB_PROCESS_ID,
            B.FDB_AMENDED_ON = CLC.FDB_AMENDED_ON
        WHEN NOT MATCHED THEN INSERT
        (
            FDB_FAK_ID,
            FDB_BALANCE_DATE,
            FDB_BALANCE_TYPE,
            FDB_TRAN_DAILY_MOVEMENT,
            FDB_TRAN_MTD_BALANCE,
            FDB_TRAN_QTD_BALANCE,
            FDB_TRAN_YTD_BALANCE,
            FDB_TRAN_LTD_BALANCE,
            FDB_BASE_DAILY_MOVEMENT,
            FDB_BASE_MTD_BALANCE,
            FDB_BASE_QTD_BALANCE,
            FDB_BASE_YTD_BALANCE,
            FDB_BASE_LTD_BALANCE,
            FDB_LOCAL_DAILY_MOVEMENT,
            FDB_LOCAL_MTD_BALANCE,
            FDB_LOCAL_QTD_BALANCE,
            FDB_LOCAL_YTD_BALANCE,
            FDB_LOCAL_LTD_BALANCE,
            FDB_ENTITY,
            FDB_EPG_ID,
            FDB_PERIOD_MONTH,
            FDB_PERIOD_QTR,
            FDB_PERIOD_YEAR,
            FDB_PERIOD_LTD,
            FDB_PROCESS_ID,
            FDB_AMENDED_ON
        )
        VALUES
        (
            CLC.FDB_FAK_ID,
            CLC.FDB_BALANCE_DATE,
            CLC.FDB_BALANCE_TYPE,
            CLC.FDB_TRAN_DAILY_MOVEMENT,
            CLC.FDB_TRAN_MTD_BALANCE,
            CLC.FDB_TRAN_QTD_BALANCE,
            CLC.FDB_TRAN_YTD_BALANCE,
            CLC.FDB_TRAN_LTD_BALANCE,
            CLC.FDB_BASE_DAILY_MOVEMENT,
            CLC.FDB_BASE_MTD_BALANCE,
            CLC.FDB_BASE_QTD_BALANCE,
            CLC.FDB_BASE_YTD_BALANCE,
            CLC.FDB_BASE_LTD_BALANCE,
            CLC.FDB_LOCAL_DAILY_MOVEMENT,
            CLC.FDB_LOCAL_MTD_BALANCE,
            CLC.FDB_LOCAL_QTD_BALANCE,
            CLC.FDB_LOCAL_YTD_BALANCE,
            CLC.FDB_LOCAL_LTD_BALANCE,
            CLC.FDB_ENTITY,
            CLC.FDB_EPG_ID,
            CLC.FDB_PERIOD_MONTH,
            CLC.FDB_PERIOD_QTR,
            CLC.FDB_PERIOD_YEAR,
            1,
            CLC.FDB_PROCESS_ID,
            CLC.FDB_AMENDED_ON
        )';
/*-----------UPGRADE 22.1.1 MERGE START-----------*/
--lines added above to the ON condition
--            AND CLC.EDB_PERIOD_YEAR=B.EDB_PERIOD_YEAR
--            AND CLC.EDB_PERIOD_MONTH=B.EDB_PERIOD_MONTH
/*-----------UPGRADE 22.1.1 MERGE END-----------*/
  lv_START_TIME:=DBMS_UTILITY.GET_TIME();
     dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':p_oldest_backdate',p_oldest_backdate);
    dbms_sql.bind_variable( lv_cursor, ':p_status',p_status);
  dbms_sql.bind_variable( lv_cursor, ':c_unused_date_for_lb',c_unused_date_for_lb);

    dbms_sql.bind_variable( lv_cursor, ':p_process_id',p_process_id);
    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );


 -- EXECUTE IMMEDIATE lv_sql USING p_process_id, p_oldest_backdate, p_oldest_backdate, p_oldest_backdate;
    SLR_ADMIN_PKG.PerfInfo( 'MFAK. Merge FAK Daily Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
    SLR_ADMIN_PKG.Debug('FAK Daily Balances generated (Merge).', lv_sql);
    pg_process_state.log_proc_completed(p_conf_group   => 'SLR',
                                        p_stage        => 'slr_post_journals.pGenerateFAKDailyBalancesMerge',
                                        p_process_id   => p_process_id);
   EXCEPTION WHEN OTHERS THEN
        pg_process_state.Set_Process_Failed(p_process_id  => p_process_id,p_info=> SQLERRM);
    RAISE;

END pGenerateFAKDailyBalancesMerge;

PROCEDURE pEbaBalancesRollback
(
  p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER
)
AS
BEGIN
    --EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';

    SLR_ADMIN_PKG.Debug('pEbaBalancesRollback - begin');

    FOR d IN
    (
        SELECT DISTINCT EDB_BALANCE_DATE FROM SLR_EBA_DAILY_BALANCES
        WHERE EDB_EPG_ID = p_epg_id
            AND EDB_PROCESS_ID = p_process_id
    )
    LOOP
        EXECUTE IMMEDIATE '
            INSERT INTO SLR_EBA_DAILY_BALANCES
            SELECT * FROM
            (
                SELECT * FROM SLR_EBA_BALANCES_ROLLBACK
                WHERE EDB_EPG_ID = :entity_proc_group
                    AND EDB_BALANCE_DATE = :balance_date
            )
            UNION ALL
            (
                SELECT * FROM SLR_EBA_PM_' || p_epg_id || '
                WHERE EDB_EPG_ID = :entity_proc_group
                    AND EDB_BALANCE_DATE = :balance_date
            )
        '
        USING p_epg_id, d.EDB_BALANCE_DATE, p_epg_id, d.EDB_BALANCE_DATE;
    END LOOP;

    DELETE SLR_EBA_DAILY_BALANCES
    WHERE EDB_EPG_ID = p_epg_id
        AND EDB_PROCESS_ID = p_process_id;

    COMMIT;

    SLR_ADMIN_PKG.Info('EBA Balances rollback - done');

    SLR_ADMIN_PKG.Debug('pEbaBalancesRollback - end');

END pEbaBalancesRollback;

--------------------------------------------------------------------------------


PROCEDURE pFakBalancesRollback
(
  p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER
)
AS
BEGIN
   -- EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';

    SLR_ADMIN_PKG.Debug('pFakBalancesRollback - begin');

    FOR d IN
    (
        SELECT DISTINCT FDB_BALANCE_DATE FROM SLR_FAK_DAILY_BALANCES
        WHERE FDB_EPG_ID = p_epg_id
            AND FDB_PROCESS_ID = p_process_id
    )
    LOOP
        EXECUTE IMMEDIATE '
            INSERT INTO SLR_FAK_DAILY_BALANCES
            SELECT * FROM
            (
                SELECT * FROM SLR_FAK_BALANCES_ROLLBACK
                WHERE FDB_EPG_ID = :entity_proc_group
                    AND FDB_BALANCE_DATE = :balance_date
            )
            UNION ALL
            (
                SELECT * FROM SLR_FAK_PM_' || p_epg_id || '
                WHERE FDB_EPG_ID = :entity_proc_group
                    AND FDB_BALANCE_DATE = :balance_date
            )
        '
        USING p_epg_id, d.FDB_BALANCE_DATE, p_epg_id, d.FDB_BALANCE_DATE;
    END LOOP;

    DELETE SLR_FAK_DAILY_BALANCES
    WHERE FDB_EPG_ID = p_epg_id
        AND FDB_PROCESS_ID = p_process_id;

    COMMIT;

    SLR_ADMIN_PKG.Info('FAK Balances rollback - done');

    SLR_ADMIN_PKG.Debug('pFakBalancesRollback - end');

END pFakBalancesRollback;


PROCEDURE pCreateRevJournalTmpTable (p_epg VARCHAR2, p_process_id NUMBER) IS

    v_sql                CLOB := q'{
    insert into  SLR_JRNL_LINES_UNPOSTED_TMP :p_partition :p_hint_crterevjournaltmptable
WITH periods AS
  ( select
   CASE WHEN per.EP_BUS_PERIOD >1   THEN
      ( SELECT PriorStart.EP_BUS_PERIOD_START
           FROM slr.SLR_ENTITY_PERIODS PriorStart
              WHERE PriorStart.EP_ENTITY = per.EP_ENTITY
               AND  PriorStart.EP_BUS_YEAR = per.EP_BUS_YEAR
               AND  PriorStart.EP_BUS_PERIOD = per.EP_BUS_PERIOD - 1 AND PriorStart.EP_STATUS  = 'O' )
    ELSE
       ( SELECT PriorStart.EP_BUS_PERIOD_START FROM slr.SLR_ENTITY_PERIODS PriorStart
              WHERE PriorStart.EP_ENTITY = per.EP_ENTITY AND  PriorStart.EP_BUS_YEAR = per.EP_BUS_YEAR-1
              AND PriorStart.EP_BUS_PERIOD = 12   AND PriorStart.EP_STATUS  = 'O' )

         END AS  PriorEnd_EP_BUS_PERIOD_START,

     CASE WHEN per.EP_BUS_PERIOD >1   THEN
        (SELECT PriorEnd.EP_BUS_PERIOD_END
           FROM slr.SLR_ENTITY_PERIODS PriorEnd
               WHERE PriorEnd.EP_ENTITY = per.EP_ENTITY
                AND PriorEnd.EP_BUS_YEAR = per.EP_BUS_YEAR
                AND PriorEnd.EP_BUS_PERIOD = per.EP_BUS_PERIOD - 1 and PriorEnd.EP_STATUS  = 'O' )
        ELSE
         (SELECT PriorEnd.EP_BUS_PERIOD_END
           FROM slr.SLR_ENTITY_PERIODS PriorEnd
               WHERE PriorEnd.EP_ENTITY = per.EP_ENTITY
                AND PriorEnd.EP_BUS_YEAR = per.EP_BUS_YEAR-1
                AND PriorEnd.EP_BUS_PERIOD = 12 and PriorEnd.EP_STATUS  = 'O' )  -- and PriorEnd.EP_STATUS  = 'O'
        END as PriorEnd_EP_BUS_PERIOD_END,

     CASE WHEN per.EP_BUS_PERIOD <12  THEN
       (SELECT NextStart.EP_BUS_PERIOD_START
         FROM slr.SLR_ENTITY_PERIODS NextStart
             WHERE NextStart.EP_ENTITY = per.EP_ENTITY
               AND NextStart.EP_BUS_YEAR = per.EP_BUS_YEAR
               AND NextStart.EP_BUS_PERIOD = per.EP_BUS_PERIOD + 1 and NextStart.EP_STATUS  = 'O' )
      ELSE
        (SELECT NextStart.EP_BUS_PERIOD_START
          FROM slr.SLR_ENTITY_PERIODS NextStart
            WHERE NextStart.EP_ENTITY = per.EP_ENTITY
               AND NextStart.EP_BUS_YEAR = per.EP_BUS_YEAR+1
               AND NextStart.EP_BUS_PERIOD = 1 and NextStart.EP_STATUS  = 'O' )
      END as NextStart_EP_BUS_PERIOD_START,
     CASE WHEN per.EP_BUS_PERIOD <12  THEN
       ( SELECT NextEnd.EP_BUS_PERIOD_END
          FROM slr.SLR_ENTITY_PERIODS NextEnd
           WHERE NextEnd.EP_ENTITY = per.EP_ENTITY
             AND NextEnd.EP_BUS_YEAR = per.EP_BUS_YEAR
             AND NextEnd.EP_BUS_PERIOD = per.EP_BUS_PERIOD + 1
             AND NextEnd.EP_STATUS  = 'O' )
       ELSE
           (SELECT NextEnd.EP_BUS_PERIOD_END
             FROM slr.SLR_ENTITY_PERIODS NextEnd
              WHERE NextEnd.EP_ENTITY = per.EP_ENTITY
                AND NextEnd.EP_BUS_YEAR = per.EP_BUS_YEAR+1
                AND NextEnd.EP_BUS_PERIOD =  1
                AND NextEnd.EP_STATUS  = 'O' )
       END   AS NextStart_EP_BUS_PERIOD_END,

   per.EP_BUS_PERIOD_START      as per_EP_BUS_PERIOD_START,
   per.EP_BUS_PERIOD_END      as per_EP_BUS_PERIOD_END,
   per.EP_BUS_PERIOD            as per_EP_BUS_PERIOD ,
   per.EP_BUS_YEAR   as per_EP_BUS_YEAR ,
   per.ep_entity as per_ep_entity
    FROM slr.slr_entity_periods per where per.ep_status = 'O'),
journals as
 (SELECT :p_hint_createrevjournaltmptable_jr  per_ep_entity,
  CASE WHEN jlu.JLU_JRNL_REV_DATE IS NOT NULL
       THEN JLU_JRNL_REV_DATE
  ELSE
    CASE WHEN rul.ejtr_period_date IS NOT NULL THEN
             CASE WHEN ejtr_prior_next_current = 'P' THEN
                       CASE WHEN ejtr_period_date  = 'S' THEN
                                PriorEnd_EP_BUS_PERIOD_START
                            WHEN ejtr_period_date  = 'E' THEN
                                PriorEnd_EP_BUS_PERIOD_END
                            END
                  WHEN ejtr_prior_next_current = 'N' THEN
                       CASE WHEN ejtr_period_date  = 'S' THEN
                             NextStart_EP_BUS_PERIOD_START
                           WHEN ejtr_period_date  = 'E' THEN
                             NextStart_EP_BUS_PERIOD_END
                        END
                  ELSE
                     CASE WHEN ejtr_period_date  = 'S' THEN   per_EP_BUS_PERIOD_START
                          WHEN ejtr_period_date  = 'E' THEN   per_EP_BUS_PERIOD_END
                     END
             END
         WHEN rul.ejtr_prior_next_current IS NOT NULL and rul.ejtr_prior_next_current  = 'P'  THEN mmd.max_edate
         ELSE mmd.min_edate
    END
  END AS ED_DAT,
   jlu.jlu_jrnl_hdr_id,
       jlu.jlu_jrnl_line_number,
       jlu.jlu_fak_id,
       jlu.jlu_eba_id,
       jlu.jlu_description,
       trim(TRAILING '.' FROM trim(jlu.JLU_JRNL_HDR_ID)) as JLU_SOURCE_JRNL_ID_Q,
       jlu.jlu_entity,
       jlu_epg_id,
       jlu_account,
       jlu_segment_1,
       jlu_segment_2,
       jlu_segment_3,
       jlu_segment_4,
       jlu_segment_5,
       jlu_segment_6,
       jlu_segment_7,
       jlu_segment_8,
       jlu_segment_9,
       jlu_segment_10,
       jlu_attribute_1,
       jlu_attribute_2,
       jlu_attribute_3,
       jlu_attribute_4,
       jlu_attribute_5,
       jlu_reference_1,
       jlu_reference_2,
       jlu_reference_3,
       jlu_reference_4,
       jlu_reference_5,
       jlu_reference_6,
       jlu_reference_7,
       jlu_reference_8,
       jlu_reference_9,
       jlu_reference_10,
       jlu_tran_ccy,
       (-1)*JLU_TRAN_AMOUNT AS JLU_TRAN_AMOUNT,
       jlu_base_rate,
       jlu_base_ccy,
         (-1)*JLU_BASE_AMOUNT AS JLU_BASE_AMOUNT,
       jlu_local_rate,
       jlu_local_ccy,
       (-1)*JLU_LOCAL_AMOUNT AS JLU_LOCAL_AMOUNT,
       jlu_created_by,
       current_timestamp AS JLU_CREATED_ON,
       jlu_amended_by,
       current_timestamp AS JLU_AMENDED_ON,
       jlu_jrnl_type,
       jlu_jrnl_description,
        trim(JLU_JRNL_SOURCE) AS JLU_JRNL_SOURCE,
       trim(trailing '.' from trim(jlu.JLU_JRNL_HDR_ID)) AS JLU_JRNL_SOURCE_JRNL_ID,
       COALESCE(jlu.JLU_JRNL_AUTHORISED_BY, 'AUTO') AS JLU_JRNL_AUTHORISED_BY,
       jlu_jrnl_authorised_on,
       jlu_jrnl_validated_by,
       jlu_jrnl_validated_on,
       jlu_jrnl_posted_by,
       jlu_jrnl_posted_on,
       jlu_jrnl_total_hash_debit,
       jlu_jrnl_total_hash_credit,
       jlu_jrnl_pref_static_src,
       jlu.JLU_JRNL_HDR_ID AS JLU_JRNL_REF_ID,
       jlu_jrnl_rev_date,
       JLU_VALUE_DATE,
       JLU_JRNL_PROCESS_ID,
	   ext.ejt_translation_date_derived_from,
	   NVL(jlu.JLU_TRANSLATION_DATE, jlu.JLU_EFFECTIVE_DATE) AS TRANSLATION_DATE,

       JLU_JRNL_STATUS_TEXT,
       jlu_jrnl_internal_period_flag,
       jlu_jrnl_ent_rate_set,
       jlu_type,jlu.rowid as row_id,
       ent.ENT_BUSINESS_DATE AS BUSINESS_DATE,
       per_EP_BUS_PERIOD,
       per_EP_BUS_YEAR,
  	   jlu.JLU_JRNL_REV_DATE as jlu_jrnl_par_rev_date
   FROM slr.slr_jrnl_lines_unposted :p_subpartition jlu
   INNER JOIN periods   ON per_ep_entity = jlu.jlu_entity  and jlu.jlu_jrnl_ref_id IS NULL
                          and jlu.jlu_effective_date BETWEEN per_EP_BUS_PERIOD_START AND  per_EP_BUS_PERIOD_END :p_process_sql
   INNER JOIN slr.slr_ext_jrnl_types ext  ON jlu.jlu_jrnl_type = ext.ejt_type
   INNER JOIN slr.slr_jrnl_types typ      ON ext.ejt_jt_type = typ.jt_type  and ( typ.jt_reverse_flag = 'Y' OR typ.jt_reverse_flag = 'C' AND jlu.jlu_jrnl_rev_date IS NOT NULL )
   INNER JOIN slr.slr_ext_jrnl_type_rule rul  ON rul.ejtr_code = ext.ejt_rev_ejtr_code
   INNER JOIN slr.slr_entities ent        ON jlu.jlu_entity = ent.ent_entity   AND ent.ent_status = 'A'
                                          AND ent.ent_entity = per_ep_entity
   INNER JOIN SLR_MIN_MAX_ENTITY_DATES_TMP mmd ON  mmd.ED_ENTITY_SET  = ent.ENT_PERIODS_AND_DAYS_SET and    jlu.jlu_effective_date  =    mmd.ED_DATE
    WHERE
    NOT EXISTS (SELECT 1
             FROM slr.slr_jrnl_lines_waiting jlw
            WHERE jlu.jlu_jrnl_hdr_id = jlw.jlw_jrnl_ref_id
              AND jlu.jlu_effective_date = jlw.JLW_EFFECTIVE_DATE
              AND jlu.jlu_epg_id = jlw.jlw_epg_id
              AND jlu.jlu_entity = jlw.jlw_entity)
        AND NOT EXISTS
    (SELECT /*+ parallel(12) */  1 JLU_JRNL_HDR_ID, JLU_JRNL_LINE_NUMBER
             FROM slr.slr_jrnl_lines_unposted :p_partition jlu_rev
            WHERE jlu_rev.jlu_jrnl_ref_id =jlu.jlu_jrnl_hdr_id
           --  AND  pomyslec nad JLU_REV.JLU_JRNL_REF_ID is not null   indeks  JLU_JRNL_REF_ID ,JLU_ENTITY ?
              and  jlu_rev.jlu_jrnl_ref_id IS NOT NULL
              AND jlu_rev.jlu_entity = jlu.jlu_entity)
    )
select  :p_hint_createrevjournaltmptable_mi
   STANDARD_HASH(JLU_JRNL_HDR_ID, 'MD5') AS JLU_JRNL_HDR_ID_new,
   JLU_JRNL_LINE_NUMBER,
    JLU_FAK_ID,
    JLU_EBA_ID,
   CASE WHEN ED_DAT > BUSINESS_DATE THEN 'W' ELSE 'U' END AS JLU_JRNL_STATUS,
    JLU_JRNL_STATUS_TEXT                 ,
    CASE WHEN ED_DAT > BUSINESS_DATE THEN 0 ELSE JLU_JRNL_PROCESS_ID END AS  JLU_JRNL_PROCESS_ID,
    JLU_DESCRIPTION,
    JLU_SOURCE_JRNL_ID_Q,
    ED_DAT,
    ED_DAT,
    JLU_ENTITY,
    JLU_EPG_ID,
    JLU_ACCOUNT,
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
    JLU_ATTRIBUTE_1,
    JLU_ATTRIBUTE_2,
    JLU_ATTRIBUTE_3,
    JLU_ATTRIBUTE_4,
    JLU_ATTRIBUTE_5,
    JLU_REFERENCE_1,
    JLU_REFERENCE_2,
    JLU_REFERENCE_3,
    JLU_REFERENCE_4,
    JLU_REFERENCE_5,
    JLU_REFERENCE_6,
    JLU_REFERENCE_7,
    JLU_REFERENCE_8,
    JLU_REFERENCE_9,
    JLU_REFERENCE_10,
    JLU_TRAN_CCY,
    JLU_TRAN_AMOUNT,
    JLU_BASE_RATE,
    JLU_BASE_CCY,
    JLU_BASE_AMOUNT,
    JLU_LOCAL_RATE,
    JLU_LOCAL_CCY,
    JLU_LOCAL_AMOUNT,
    JLU_CREATED_BY,
    JLU_CREATED_ON,
    JLU_AMENDED_BY,
    JLU_AMENDED_ON,
    JLU_JRNL_TYPE,
    ED_DAT,
    JLU_JRNL_DESCRIPTION,
    JLU_JRNL_SOURCE,
    JLU_JRNL_SOURCE_JRNL_ID,
    JLU_JRNL_AUTHORISED_BY,
    JLU_JRNL_AUTHORISED_ON,
    JLU_JRNL_VALIDATED_BY,
    JLU_JRNL_VALIDATED_ON,
    JLU_JRNL_POSTED_BY,
    JLU_JRNL_POSTED_ON,
    JLU_JRNL_TOTAL_HASH_DEBIT,
    JLU_JRNL_TOTAL_HASH_CREDIT,
    JLU_JRNL_PREF_STATIC_SRC,
    JLU_JRNL_REF_ID,
    null,
    	CASE
        WHEN ejt_translation_date_derived_from='Reversing' THEN
           ED_DAT
        ELSE
           TRANSLATION_DATE
    END as   TRANSLATION_DATE,
    epp.EP_BUS_PERIOD,
    epp.EP_BUS_YEAR,
    1,
    JLU_JRNL_INTERNAL_PERIOD_FLAG,
    JLU_JRNL_ENT_RATE_SET,
    JLU_TYPE,
    row_id,
    rownum as jlu_rownum,
    'P'||JLU_EPG_ID as  jlu_process_part,
	:process_id,
	jlu_jrnl_par_rev_date
 from journals jl
  inner join SLR_ENTITY_PERIODS epp
  on epp.EP_ENTITY = jl.JLU_ENTITY
  and jl.ED_DAT between epp.EP_BUS_PERIOD_START and epp.EP_BUS_PERIOD_END  }';
    v_count              PLS_INTEGER;
    v_max_effective_date DATE;
    v_process_sql        VARCHAR2(200);
    vcompare             VARCHAR2(200);
    v_subpartition       VARCHAR2(200);
    v_partition          VARCHAR2(200);
    v_part_name_value   VARCHAR2(200) := 'P' || p_epg;


  BEGIN
    SLR_ADMIN_PKG.Debug('pcreate_rev_journal_tmp_table',null);
    IF p_process_id IS NOT NULL THEN
      v_process_sql := ' AND jlu.JLU_JRNL_PROCESS_ID =''' || p_process_id || '''';
    END IF;

    IF p_epg IS NOT NULL THEN
      v_subpartition := 'subpartition ( P' || p_epg || '_SU)';
      v_partition    := 'partition ( P' || p_epg || ')';
      slr_admin_pkg.addlistpart(p_table_name => 'SLR_JRNL_LINES_UNPOSTED_TMP',
                                p_part_name  => v_part_name_value,
                                p_part_value => v_part_name_value);
    END IF;

    v_sql := REPLACE(v_sql, ':p_hint_crterevjournaltmptable', NVL(SLR_UTILITIES_PKG.fHint(p_epg, 'CREATEREVJOURNALTMPTABLE'),'/*+ APPEND NOLOGGING  parallel(12) enable_parallel_dml  */'));
  v_sql := REPLACE(v_sql, ':p_hint_createrevjournaltmptable_jr', NVL(SLR_UTILITIES_PKG.fHint(p_epg, 'CREATEREVJOURNALTMPTABLE_JR'),'/*+ parallel(12) use_hash(jlu_rev) use_hash( periods)  */'));
  v_sql := REPLACE(v_sql, ':p_hint_createrevjournaltmptable_mi', NVL(SLR_UTILITIES_PKG.fHint(p_epg, 'CREATEREVJOURNALTMPTABLE_MI'),'/*+ parallel(12) */'));


  v_sql := REPLACE(v_sql, ':p_subpartition', v_subpartition);
    v_sql := REPLACE(v_sql, ':p_partition', v_partition);
    v_sql := REPLACE(v_sql, ':p_process_sql', v_process_sql);
	v_sql := REPLACE(v_sql, ':process_id', gp_process_id);
    SLR_ADMIN_PKG.Debug('Rev_journal insert slr_min_max_entity_dates_tmp ',null);
    INSERT INTO slr_min_max_entity_dates_tmp
      SELECT s.*,
             (SELECT MIN(ent1.ed_date)
                FROM slr.slr_entity_days ent1
               WHERE ent1.ed_entity_set = s.ed_entity_set
           AND ed_status = 'O'
                 AND ent1.ed_date > s.ed_date) AS min_edate,
             (SELECT MAX(ent1.ed_date)
                FROM slr.slr_entity_days ent1
               WHERE ent1.ed_entity_set = s.ed_entity_set
           AND ed_status = 'O'
                 AND ent1.ed_date < s.ed_date) max_edate
        FROM (SELECT ed_entity_set, ed_date
                FROM slr.slr_entity_days sed
               INNER JOIN slr.slr_entities se
                  ON se.ent_status = 'A'
                 AND sed.ed_entity_set = se.ent_periods_and_days_set
                 AND sed.ed_status = 'O'              GROUP BY ed_entity_set, ed_date
               ORDER BY ed_date, ed_entity_set) s;
      SLR_ADMIN_PKG.Debug('Rev_journal insert SLR_JRNL_LINES_UNPOSTED_TMP ',v_sql);
       -- dbms_output.put_line(v_sql);

    EXECUTE IMMEDIATE (v_sql);
    COMMIT;
    SLR_ADMIN_PKG.Debug('Rev_journal END SLR_JRNL_LINES_UNPOSTED_TMP ',null);


  END;

PROCEDURE pInsertJournal(p_epg_id in  varchar2) IS
  v_sql clob ;
BEGIN
  v_sql := '
  INSERT   :p_hint_pinsertjournal
  INTO slr_jrnl_lines_unposted
    (jlu_jrnl_hdr_id,
     jlu_jrnl_line_number,
     jlu_fak_id,
     jlu_eba_id,
     jlu_jrnl_status,
     jlu_jrnl_status_text,
     jlu_jrnl_process_id,
     jlu_description,
     jlu_source_jrnl_id,
     jlu_effective_date,
     jlu_value_date,
     jlu_entity,
     jlu_epg_id,
     jlu_account,
     jlu_segment_1,
     jlu_segment_2,
     jlu_segment_3,
     jlu_segment_4,
     jlu_segment_5,
     jlu_segment_6,
     jlu_segment_7,
     jlu_segment_8,
     jlu_segment_9,
     jlu_segment_10,
     jlu_attribute_1,
     jlu_attribute_2,
     jlu_attribute_3,
     jlu_attribute_4,
     jlu_attribute_5,
     jlu_reference_1,
     jlu_reference_2,
     jlu_reference_3,
     jlu_reference_4,
     jlu_reference_5,
     jlu_reference_6,
     jlu_reference_7,
     jlu_reference_8,
     jlu_reference_9,
     jlu_reference_10,
     jlu_tran_ccy,
     jlu_tran_amount,
     jlu_base_rate,
     jlu_base_ccy,
     jlu_base_amount,
     jlu_local_rate,
     jlu_local_ccy,
     jlu_local_amount,
     jlu_created_by,
     jlu_created_on,
     jlu_amended_by,
     jlu_amended_on,
     jlu_jrnl_type,
     jlu_jrnl_date,
     jlu_jrnl_description,
     jlu_jrnl_source,
     jlu_jrnl_source_jrnl_id,
     jlu_jrnl_authorised_by,
     jlu_jrnl_authorised_on,
     jlu_jrnl_validated_by,
     jlu_jrnl_validated_on,
     jlu_jrnl_posted_by,
     jlu_jrnl_posted_on,
     jlu_jrnl_total_hash_debit,
     jlu_jrnl_total_hash_credit,
     jlu_jrnl_pref_static_src,
     jlu_jrnl_ref_id,
     jlu_jrnl_rev_date,
     jlu_translation_date,
     jlu_period_month,
     jlu_period_year,
     jlu_period_ltd,
     jlu_jrnl_internal_period_flag,
     jlu_jrnl_ent_rate_set,
     jlu_type)
    SELECT :p_hint_insertjournal_sel
     jlu_jrnl_hdr_id,
     jlu_jrnl_line_number,
     jlu_fak_id,
     jlu_eba_id,
     jlu_jrnl_status,
     jlu_jrnl_status_text,
     jlu_jrnl_process_id,
     jlu_description,
     jlu_source_jrnl_id,
     jlu_effective_date,
     jlu_value_date,
     jlu_entity,
     jlu_epg_id,
     jlu_account,
     jlu_segment_1,
     jlu_segment_2,
     jlu_segment_3,
     jlu_segment_4,
     jlu_segment_5,
     jlu_segment_6,
     jlu_segment_7,
     jlu_segment_8,
     jlu_segment_9,
     jlu_segment_10,
     jlu_attribute_1,
     jlu_attribute_2,
     jlu_attribute_3,
     jlu_attribute_4,
     jlu_attribute_5,
     jlu_reference_1,
     jlu_reference_2,
     jlu_reference_3,
     jlu_reference_4,
     jlu_reference_5,
     jlu_reference_6,
     jlu_reference_7,
     jlu_reference_8,
     jlu_reference_9,
     jlu_reference_10,
     jlu_tran_ccy,
     jlu_tran_amount,
     jlu_base_rate,
     jlu_base_ccy,
     jlu_base_amount,
     jlu_local_rate,
     jlu_local_ccy,
     jlu_local_amount,
     jlu_created_by,
     jlu_created_on,
     jlu_amended_by,
     jlu_amended_on,
     jlu_jrnl_type,
     jlu_jrnl_date,
     jlu_jrnl_description,
     jlu_jrnl_source,
     jlu_jrnl_source_jrnl_id,
     jlu_jrnl_authorised_by,
     jlu_jrnl_authorised_on,
     jlu_jrnl_validated_by,
     jlu_jrnl_validated_on,
     jlu_jrnl_posted_by,
     jlu_jrnl_posted_on,
     jlu_jrnl_total_hash_debit,
     jlu_jrnl_total_hash_credit,
     jlu_jrnl_pref_static_src,
     jlu_jrnl_ref_id,
     jlu_jrnl_rev_date,
     jlu_translation_date,
     jlu_period_month,
     jlu_period_year,
     jlu_period_ltd,
     jlu_jrnl_internal_period_flag,
     jlu_jrnl_ent_rate_set,
     jlu_type
      FROM slr_jrnl_lines_unposted_tmp PARTITION( P' || p_epg_id||')';

    v_sql := REPLACE(v_sql, ':p_hint_pinsertjournal', NVL(SLR_UTILITIES_PKG.fHint(p_epg_id, 'PINSERTJOURNAL'),'/*+ APPEND NOLOGGING  parallel(8) enable_parallel_dml*/'));
    v_sql := REPLACE(v_sql, ':p_hint_insertjournal_sel', NVL(SLR_UTILITIES_PKG.fHint(p_epg_id, 'INSERTJOURNAL_SEL'),'/*+ parallel(8)  */'));

    SLR_ADMIN_PKG.Debug('Rev_journal start insert_journal ',v_sql);
    execute immediate v_sql;
    COMMIT;
    SLR_ADMIN_PKG.Debug('Rev_journal end insert_journal ',null);

END;

  PROCEDURE pUpdateJournal(p_part_process     IN VARCHAR2,
                           p_start_row       IN NUMBER,
                           p_end_row         IN NUMBER,
                           p_bulk_processing IN VARCHAR2,
                           p_epg_id          IN VARCHAR2,
                           p_part_epg        IN VARCHAR2,
                           p_alert           in VARCHAR2,
                           p_rollback        in VARCHAR2) IS

   CURSOR Updrow is
       SELECT /*+ parallel(8)  */
         t.jlu_effective_date, t.jlu_rowid,t.jlu_jrnl_hdr_id
          FROM slr_jrnl_lines_unposted_tmp t
         WHERE t.jlu_rownum BETWEEN p_start_row AND p_end_row   ;

    TYPE Updrecord IS TABLE OF Updrow%ROWTYPE INDEX BY BINARY_INTEGER;
    uprec    Updrecord;
    l_cursor SYS_REFCURSOR;
    v_start_time   PLS_INTEGER := 0;
  v_sql Varchar2(2000):= '
    MERGE :p_hint_updatejournal  INTO slr_jrnl_lines_unposted partition ('||p_part_epg||') post
    USING (
      SELECT :p_hint_pupdatejournal_sel t.jlu_effective_date,t.jlu_rowid
                FROM slr_jrnl_lines_unposted_tmp t
               WHERE  t.jlu_rownum BETWEEN '||p_start_row||' AND '||p_end_row||'
    ) tmp
    ON
    (
       post.rowid = tmp.jlu_rowid
    )
    WHEN MATCHED THEN UPDATE SET post.jlu_jrnl_rev_date = tmp.jlu_effective_date';
  BEGIN
    v_sql := REPLACE(v_sql, ':p_hint_updatejournal', NVL(SLR_UTILITIES_PKG.fHint(p_epg_id, 'PUPDATEJOURNAL'),'/*+ APPEND NOLOGGING  parallel(8) enable_parallel_dml*/'));
    v_sql := REPLACE(v_sql, ':p_hint_pupdatejournal_sel', NVL(SLR_UTILITIES_PKG.fHint(p_epg_id, 'PUPDATEJOURNAL_SEL'),'/*+ parallel(8)  */'));


    v_START_TIME:=DBMS_UTILITY.GET_TIME();
    gROWCNT_LIMIT_NUMBER := 100000;
    IF  p_rollback ='N' THEN
    IF p_bulk_processing = 'N' THEN
      execute immediate (v_sql);

    ELSE
    OPEN Updrow ;
      LOOP
        EXIT WHEN Updrow%NOTFOUND;
        FETCH Updrow BULK COLLECT
          INTO uprec LIMIT growcnt_limit_number;

        FORALL i IN uprec.first .. uprec.last
          UPDATE slr_jrnl_lines_unposted
             SET jlu_jrnl_rev_date = uprec(i).jlu_effective_date
           WHERE rowid = uprec(i).jlu_rowid;

      END LOOP;
    END IF;
    ELSE
    OPEN Updrow ;
      LOOP
        EXIT WHEN Updrow%NOTFOUND;
        FETCH Updrow BULK COLLECT
          INTO uprec LIMIT growcnt_limit_number;

        FORALL i IN uprec.first .. uprec.last
           UPDATE slr_jrnl_lines_unposted
             SET jlu_jrnl_rev_date = null
           WHERE rowid = uprec(i).jlu_rowid;
           FORALL i IN uprec.first .. uprec.last
         DELETE slr_jrnl_lines_unposted
           WHERE jlu_jrnl_hdr_id = uprec(i).jlu_jrnl_hdr_id;


      END LOOP;

    END IF;
    COMMIT;
    slr_admin_pkg.perfinfo('pUpdateJournal reversing journals alert '||p_alert||' query execution time  ' ||
                         (dbms_utility.get_time() - v_start_time) /
                         100.0 || ' s.');
   EXCEPTION WHEN OTHERS THEN
      slr_admin_pkg.error('pUpdateJournal failed '||SQLERRM);
      slr_admin_pkg.Debug(pLog => 'pUpdateJournal failed sql',pLogExt => v_sql||'  '||SQLERRM);
      RAISE;

  END;





FUNCTION fCreateRevJournalBatchCount(orignal_jrnl_id   VARCHAR2,
                                     entity_proc_group VARCHAR2,
                                     status            CHAR,
                                     process_id        NUMBER)
  RETURN NUMBER IS
  vprocname        VARCHAR2(60) DEFAULT 'pCreate_rev_journal_batch';
  vsqltext         VARCHAR2(1030);
  vtype            VARCHAR2(20);
  vsqlcode         INTEGER;
  vsql             VARCHAR2(18500);
  vcompare         VARCHAR2(1000);
  vprocess         VARCHAR2(500);
  vepg             VARCHAR2(1000);
  vepg2            VARCHAR2(1000);
  lv_start_time    PLS_INTEGER := 0;
  v_num_of_reverse NUMERIC(28, 0);
  v_reverse        NUMERIC(28, 0);
  v_sql            CLOB;

BEGIN


  IF process_id IS NOT NULL THEN
    vprocess := ' AND jlu.JLU_JRNL_PROCESS_ID =''' || process_id ||
                '''  AND ';
  ELSE
    vprocess := ' AND ';
  END IF;

  IF orignal_jrnl_id IS NOT NULL THEN
    vcompare := 'AND jlu.jlu_jrnl_hdr_id =' || orignal_jrnl_id || ' ';
  ELSE

    vcompare := '';
  END IF;

  IF entity_proc_group IS NOT NULL THEN
    vepg  := ' AND jlu.jlu_epg_id   = ''' || entity_proc_group ||
             ''' AND ';
    vepg2 := ' AND jlu_rev.jlu_epg_id   = ''' || entity_proc_group || '''';
  ELSE
    vepg2 := '';
    vepg  := ' AND ';
  END IF;

  vsql := 'SELECT' ||
          slr_utilities_pkg.fhint(entity_proc_group, 'SELECT_REVERS_JLU') ||
          ' COUNT(*) FROM
    slr.SLR_JRNL_LINES_UNPOSTED jlu
  , slr.SLR_EXT_JRNL_TYPES ext
  , slr.SLR_JRNL_TYPES typ
  , slr.SLR_ENTITIES ent
  , slr.SLR_ENTITY_PERIODS per
  WHERE
      --JOINS
      jlu.jlu_jrnl_type = ext.ejt_type
      AND ext.ejt_jt_type = typ.JT_TYPE
      AND per.ep_entity = jlu.jlu_entity
      AND jlu.JLU_ENTITY = ent.ENT_ENTITY
      AND ent.ENT_ENTITY = per.EP_ENTITY
     AND per.EP_STATUS  = ''O''
     AND jlu.JLU_EFFECTIVE_DATE BETWEEN per.EP_BUS_PERIOD_START AND per.EP_BUS_PERIOD_END' || vepg ||
          ' (typ.jt_reverse_flag = ''Y''
       OR typ.jt_reverse_flag = ''C''
       AND jlu.JLU_JRNL_REV_DATE is not null)
     AND jlu.JLU_JRNL_REF_ID IS NULL ' || vprocess ||
          ' jlu.JLU_JRNL_STATUS = ''' || status ||
          ''' AND ent.ENT_STATUS = ''A''
         AND not exists (SELECT 1 FROM slr.SLR_JRNL_LINES_WAITING jlw
                            WHERE jlu.JLU_JRNL_HDR_ID = jlw.JLW_JRNL_REF_ID
                              AND jlu.JLU_EPG_ID = jlw.JLW_EPG_ID
                              AND jlu.JLU_ENTITY = jlw.JLW_ENTITY)
         AND not exists (SELECT 1 FROM slr.SLR_JRNL_LINES_UNPOSTED JLU_REV WHERE
                        jlu.JLU_JRNL_HDR_ID  = JLU_REV.JLU_JRNL_REF_ID ' ||
          vepg2 || ' ) ' || vcompare;

  slr_admin_pkg.debug('reversing jrnls.', vsql);

  EXECUTE IMMEDIATE vsql
    INTO v_num_of_reverse;

  slr_admin_pkg.debug('Estimated number of records to insert:' || v_num_of_reverse || ' reversal journal lines.', v_sql);

  RETURN v_num_of_reverse;

END;


PROCEDURE pCreateRevJournalBatchParallel(p_epg_id   VARCHAR2,
                                         process_id NUMBER) IS
  v_count_jrnl      NUMBER(10);
  v_group_jrnl      PLS_INTEGER := 6;
  v_start_time      PLS_INTEGER := 0;

  v_num_of_reverse  NUMERIC(28, 0);
  v_part_name_value VARCHAR2(200) := 'P' || p_epg_id;
  v_sql             VARCHAR2(2000) := q'!BEGIN
        SLR_POST_JOURNALS_PKG.pUpdateJournal(p_part_process     =>':p_epg_id',
                                             p_start_row       => :p_start_row,
                                             p_end_row         => :p_end_row,
                                             p_bulk_processing => 'N',
											 p_epg_id          =>':p_epg_id',
                                             p_part_epg        =>'P:p_epg_id',
                                             p_alert           =>':p_alert_name',
                                             p_rollback        =>'N');
          dbms_alert.Signal(NAME=> ':p_alert_name', Message=>'OK');
          Commit;
      EXCEPTION WHEN OTHERS THEN
        slr_admin_pkg.Error('Scheduler job process :p_alert_name failed epg :p_epg_id scope  from :p_start_row to :p_end_row  process :p_process_id');
        slr_admin_pkg.Debug('Scheduler job process errMsg' , SQLERRM);
	    dbms_alert.Signal(NAME=> ':p_alert_name', Message=>'NOK');
	    Commit;
    END;!';
BEGIN

  v_num_of_reverse := fCreateRevJournalBatchCount(orignal_jrnl_id => NULL, entity_proc_group => p_epg_id, status => 'U', process_id => process_id);

  IF v_num_of_reverse > 0 THEN
    pg_process_state.log_proc(p_conf_group   => 'SLR',
                              p_stage         => 'slr_post_journals.pCreateRevJournalBatchParallel',
                              p_process_id  => gp_process_id,
                              p_epg_id        => p_epg_id,
							  p_rate_set      => slr_post_journals_pkg.gp_rate_set,
							  p_business_date => gp_business_date,
                              p_object_name  => 'SLR_JRNL_LINES_UNPOSTED',
                              p_tab_partition => v_part_name_value,
                              p_start_dt    => sysdate,
                              p_status      => 'P');

    v_sql        := REPLACE(v_sql, ':p_epg_id', p_epg_id);
    v_sql        := REPLACE(v_sql, ':p_process_id', gp_process_id);

    v_start_time := dbms_utility.get_time();
    slr_admin_pkg.droppart(p_table_name => 'SLR_JRNL_LINES_UNPOSTED_TMP', p_part_name => v_part_name_value);

    pCreateRevJournalTmptable(p_epg => p_epg_id, p_process_id => process_id);

    pInsertJournal(p_epg_id =>  p_epg_id);
    SELECT COUNT(1)
      INTO v_count_jrnl
      FROM slr_jrnl_lines_unposted_tmp
     WHERE jlu_process_part = 'P' || p_epg_id;
    pg_scheduler_jobs_utl.run_sql_in_parallel_mode(p_proc_name => p_epg_id || '_' ||
                                                                  gp_process_id, p_sql => v_sql, p_num_rows => v_count_jrnl, p_num_group => v_group_jrnl, p_alert_patern => 'P' ||
                                                                      p_epg_id, p_num_parallel_threads => v_group_jrnl, p_process_id => gp_process_id);

    pg_process_state.log_proc_completed(p_conf_group  => 'SLR',
                                        p_stage       => 'slr_post_journals.pCreateRevJournalBatchParallel',
                                        p_process_id  => gp_process_id);

	--slr_admin_pkg.droppart(p_table_name => 'SLR_JRNL_LINES_UNPOSTED_TMP', p_part_name => v_part_name_value);
    slr_admin_pkg.perfinfo('Create reversal journal lines query execution time pCreate_rev_journal_batch_parallel : ' ||
                           (dbms_utility.get_time() - v_start_time) /
                           100.0 || ' s. '||v_count_jrnl ||  ' Rows inserted');
    SLR_ADMIN_PKG.Debug('All :' ||v_count_jrnl || ' reversal journal lines created.' , null);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    pg_process_state.Set_Process_Failed(p_process_id  => gp_process_id,p_info=> SQLERRM );
  RAISE;

END;

PROCEDURE pcreate_reversing_journal(jrnl_id_list      VARCHAR2,
                                    entity_proc_group VARCHAR2,
                                    status            CHAR,
                                    process_id        NUMBER) IS
BEGIN

  IF jrnl_id_list IS NULL THEN
     -- pCreate_rev_journal_batch(null,entity_proc_group,status,process_id);
    pCreateRevJournalBatchParallel(entity_proc_group, process_id);
  ELSE
    --procedure called from within manual journal package (pg_ui_manual_journal.prui_create_reversing_journal)
    pcreate_reversing_journal_madj(jrnl_id_list, entity_proc_group, status, process_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    slr_admin_pkg.perfinfo('Fatal error during call of pCreate_reversing_journal : ' ||
                           SQLERRM);

    pg_process_state.Set_Process_Failed(p_process_id  => process_id,p_info=> SQLERRM);
	raise_application_error(-20001, 'Fatal error during call of pCreate_reversing_journal: ' ||
                             SQLERRM);

END pcreate_reversing_journal;

PROCEDURE pCreate_rev_journal_batch(orignal_jrnl_id VARCHAR2, entity_proc_group VARCHAR2, status CHAR, process_id number)
  IS
    type v_rev_jrnl_row is record (
        JLU_JRNL_HDR_ID                 SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_HDR_ID%TYPE,
        JLU_JRNL_LINE_NUMBER            SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_LINE_NUMBER%TYPE,
        JLU_FAK_ID                      SLR_JRNL_LINES_UNPOSTED.JLU_FAK_ID%TYPE,
        JLU_EBA_ID                      SLR_JRNL_LINES_UNPOSTED.JLU_EBA_ID%TYPE,
        JLU_JRNL_STATUS                 SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_STATUS%TYPE,
        JLU_JRNL_STATUS_TEXT            SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_STATUS_TEXT%TYPE,
        JLU_JRNL_PROCESS_ID             SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
        JLU_DESCRIPTION                 SLR_JRNL_LINES_UNPOSTED.JLU_DESCRIPTION%TYPE,
        JLU_SOURCE_JRNL_ID              SLR_JRNL_LINES_UNPOSTED.JLU_SOURCE_JRNL_ID%TYPE,
        JLU_EFFECTIVE_DATE              SLR_JRNL_LINES_UNPOSTED.JLU_EFFECTIVE_DATE%TYPE,
        JLU_VALUE_DATE                  SLR_JRNL_LINES_UNPOSTED.JLU_VALUE_DATE%TYPE,
        JLU_ENTITY                      SLR_JRNL_LINES_UNPOSTED.JLU_ENTITY%TYPE,
        JLU_EPG_ID                      SLR_JRNL_LINES_UNPOSTED.JLU_EPG_ID%TYPE,
        JLU_ACCOUNT                     SLR_JRNL_LINES_UNPOSTED.JLU_ACCOUNT%TYPE,
        JLU_SEGMENT_1                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_1%TYPE,
        JLU_SEGMENT_2                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_2%TYPE,
        JLU_SEGMENT_3                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_3%TYPE,
        JLU_SEGMENT_4                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_4%TYPE,
        JLU_SEGMENT_5                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_5%TYPE,
        JLU_SEGMENT_6                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_6%TYPE,
        JLU_SEGMENT_7                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_7%TYPE,
        JLU_SEGMENT_8                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_8%TYPE,
        JLU_SEGMENT_9                   SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_9%TYPE,
        JLU_SEGMENT_10                  SLR_JRNL_LINES_UNPOSTED.JLU_SEGMENT_10%TYPE,
        JLU_ATTRIBUTE_1                 SLR_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_1%TYPE,
        JLU_ATTRIBUTE_2                 SLR_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_2%TYPE,
        JLU_ATTRIBUTE_3                 SLR_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_3%TYPE,
        JLU_ATTRIBUTE_4                 SLR_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_4%TYPE,
        JLU_ATTRIBUTE_5                 SLR_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_5%TYPE,
        JLU_REFERENCE_1                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_1%TYPE,
        JLU_REFERENCE_2                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_2%TYPE,
        JLU_REFERENCE_3                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_3%TYPE,
        JLU_REFERENCE_4                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_4%TYPE,
        JLU_REFERENCE_5                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_5%TYPE,
        JLU_REFERENCE_6                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_6%TYPE,
        JLU_REFERENCE_7                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_7%TYPE,
        JLU_REFERENCE_8                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_8%TYPE,
        JLU_REFERENCE_9                 SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_9%TYPE,
        JLU_REFERENCE_10                SLR_JRNL_LINES_UNPOSTED.JLU_REFERENCE_10%TYPE,
        JLU_TRAN_CCY                    SLR_JRNL_LINES_UNPOSTED.JLU_TRAN_CCY%TYPE,
        JLU_TRAN_AMOUNT                 SLR_JRNL_LINES_UNPOSTED.JLU_TRAN_AMOUNT%TYPE,
        JLU_BASE_RATE                   SLR_JRNL_LINES_UNPOSTED.JLU_BASE_RATE%TYPE,
        JLU_BASE_CCY                    SLR_JRNL_LINES_UNPOSTED.JLU_BASE_CCY%TYPE,
        JLU_BASE_AMOUNT                 SLR_JRNL_LINES_UNPOSTED.JLU_BASE_AMOUNT%TYPE,
        JLU_LOCAL_RATE                  SLR_JRNL_LINES_UNPOSTED.JLU_LOCAL_RATE%TYPE,
        JLU_LOCAL_CCY                   SLR_JRNL_LINES_UNPOSTED.JLU_LOCAL_CCY%TYPE,
        JLU_LOCAL_AMOUNT                SLR_JRNL_LINES_UNPOSTED.JLU_LOCAL_AMOUNT%TYPE,
        JLU_CREATED_BY                  SLR_JRNL_LINES_UNPOSTED.JLU_CREATED_BY%TYPE,
        JLU_CREATED_ON                  SLR_JRNL_LINES_UNPOSTED.JLU_CREATED_ON%TYPE,
        JLU_AMENDED_BY                  SLR_JRNL_LINES_UNPOSTED.JLU_AMENDED_BY%TYPE,
        JLU_AMENDED_ON                  SLR_JRNL_LINES_UNPOSTED.JLU_AMENDED_ON%TYPE,
        JLU_JRNL_TYPE                   SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TYPE%TYPE,
        JLU_JRNL_DATE                   SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_DATE%TYPE,
        JLU_JRNL_DESCRIPTION            SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_DESCRIPTION%TYPE,
        JLU_JRNL_SOURCE                 SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_SOURCE%TYPE,
        JLU_JRNL_SOURCE_JRNL_ID         SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_SOURCE_JRNL_ID%TYPE,
        JLU_JRNL_AUTHORISED_BY          SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_AUTHORISED_BY%TYPE,
        JLU_JRNL_AUTHORISED_ON          SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_AUTHORISED_ON%TYPE,
        JLU_JRNL_VALIDATED_BY           SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_VALIDATED_BY%TYPE,
        JLU_JRNL_VALIDATED_ON           SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_VALIDATED_ON%TYPE,
        JLU_JRNL_POSTED_BY              SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_POSTED_BY%TYPE,
        JLU_JRNL_POSTED_ON              SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_POSTED_ON%TYPE,
        JLU_JRNL_TOTAL_HASH_DEBIT       SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TOTAL_HASH_DEBIT%TYPE,
        JLU_JRNL_TOTAL_HASH_CREDIT      SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_TOTAL_HASH_CREDIT%TYPE,
        JLU_JRNL_PREF_STATIC_SRC        SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PREF_STATIC_SRC%TYPE,
        JLU_JRNL_REF_ID                 SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_REF_ID%TYPE,
        JLU_JRNL_REV_DATE               SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_REV_DATE%TYPE,
        JLU_TRANSLATION_DATE            SLR_JRNL_LINES_UNPOSTED.JLU_TRANSLATION_DATE%TYPE,
        JLU_PERIOD_MONTH                SLR_JRNL_LINES_UNPOSTED.JLU_PERIOD_MONTH%TYPE,
        JLU_PERIOD_YEAR                 SLR_JRNL_LINES_UNPOSTED.JLU_PERIOD_YEAR%TYPE,
        JLU_PERIOD_LTD                  SLR_JRNL_LINES_UNPOSTED.JLU_PERIOD_LTD%TYPE,
        JLU_JRNL_INTERNAL_PERIOD_FLAG   SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_INTERNAL_PERIOD_FLAG%TYPE,
        JLU_JRNL_ENT_RATE_SET           SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_ENT_RATE_SET%TYPE,
        JLU_TYPE                        SLR_JRNL_LINES_UNPOSTED.JLU_TYPE%TYPE,
    row_id urowid);

    TYPE v_revJournals is table of v_rev_jrnl_row;
    vRevJrnlTab v_revJournals := v_revJournals();
    l_cursor  SYS_REFCURSOR;

    vProcName varchar2(60) default 'pCreate_rev_journal_batch';
      vSqlText varchar2(1030);
      vType varchar2(20);
      vSqlcode integer;
      vSQL varchar2(18500);
      vCompare varchar2(1000);
      vProcess varchar2(500);
      vEPG varchar2(1000);
      vEPG2 varchar2(1000);
      lv_START_TIME PLS_INTEGER := 0;
    v_num_of_reverse numeric(28,0);
      v_reverse numeric(28,0);


BEGIN
gROWCNT_LIMIT_NUMBER := 100000;

IF process_id IS NOT NULL THEN
     vProcess := ' AND jlu.JLU_JRNL_PROCESS_ID =''' || process_id ||'''  AND ';
  ELSE
     vProcess := ' AND ';
  END IF;

  IF orignal_jrnl_id IS NOT NULL THEN
     vCompare := 'AND jlu.jlu_jrnl_hdr_id =' || orignal_jrnl_id || ' ';
  ELSE


     vCompare := '';
  END IF;


      IF entity_proc_group IS NOT NULL THEN
     vEPG :=  ' AND jlu.jlu_epg_id   = ''' || entity_proc_group || ''' AND ';
     vEPG2 := ' AND jlu_rev.jlu_epg_id   = ''' || entity_proc_group || '''';
  ELSE
    vEPG2 := '';
     vEPG := ' AND ';
  END IF;



vSQL := 'SELECT' || SLR_UTILITIES_PKG.fHint(entity_proc_group, 'SELECT_REVERS_JLU') || ' COUNT(*) FROM
    slr.SLR_JRNL_LINES_UNPOSTED jlu
  , slr.SLR_EXT_JRNL_TYPES ext
  , slr.SLR_JRNL_TYPES typ
  , slr.SLR_ENTITIES ent
  , slr.SLR_ENTITY_PERIODS per
  WHERE
      --JOINS
      jlu.jlu_jrnl_type = ext.ejt_type
      AND ext.ejt_jt_type = typ.JT_TYPE
      AND per.ep_entity = jlu.jlu_entity
      AND jlu.JLU_ENTITY = ent.ENT_ENTITY
      AND ent.ENT_ENTITY = per.EP_ENTITY
     AND per.EP_STATUS  = ''O''
     AND jlu.JLU_EFFECTIVE_DATE BETWEEN per.EP_BUS_PERIOD_START AND per.EP_BUS_PERIOD_END' || vEPG ||
    ' (typ.jt_reverse_flag = ''Y''
       OR typ.jt_reverse_flag = ''C''
       AND jlu.JLU_JRNL_REV_DATE is not null)
     AND jlu.JLU_JRNL_REF_ID IS NULL ' || vProcess ||
    ' jlu.JLU_JRNL_STATUS = ''' || status ||
    ''' AND ent.ENT_STATUS = ''A''
         AND not exists (SELECT 1 FROM slr.SLR_JRNL_LINES_WAITING jlw
                            WHERE jlu.JLU_JRNL_HDR_ID = jlw.JLW_JRNL_REF_ID
                              AND jlu.JLU_EPG_ID = jlw.JLW_EPG_ID
                              AND jlu.JLU_ENTITY = jlw.JLW_ENTITY)
         AND not exists (SELECT 1 FROM slr.SLR_JRNL_LINES_UNPOSTED JLU_REV WHERE
                        jlu.JLU_JRNL_HDR_ID  = JLU_REV.JLU_JRNL_REF_ID '|| vEPG2 || ' ) '|| vCompare;


  EXECUTE IMMEDIATE vSQL INTO v_num_of_reverse;
  SLR_ADMIN_PKG.Debug('Count of reversals should be: ' ||v_num_of_reverse|| '. Count all reversing jrnls.', vSQL);



IF v_num_of_reverse > 0 THEN

lv_START_TIME := DBMS_UTILITY.GET_TIME();

------------create reverse_journal and calculate reverse_date
  OPEN l_cursor FOR 'with jlu as (SELECT ' || SLR_UTILITIES_PKG.fHint(entity_proc_group, 'SELECT_WITH_REVERS2') || ' JLU_JRNL_HDR_ID,
       jlu.JLU_JRNL_LINE_NUMBER,
       jlu.JLU_FAK_ID,
       jlu.JLU_EBA_ID,
       jlu.JLU_JRNL_STATUS_TEXT,
       jlu.JLU_DESCRIPTION,
       trim(TRAILING ''.'' FROM trim(jlu.JLU_JRNL_HDR_ID)) as JLU_SOURCE_JRNL_ID_Q,
     CASE WHEN jlu.JLU_JRNL_REV_DATE IS NOT NULL THEN JLU_JRNL_REV_DATE
    ELSE
    CASE WHEN rul.ejtr_period_date IS NOT NULL THEN
          CASE WHEN ejtr_prior_next_current = ''P'' THEN
              CASE WHEN ejtr_period_date  = ''S'' THEN
                  CASE WHEN per.EP_BUS_PERIOD > 1 THEN
                    (SELECT PriorStart.EP_BUS_PERIOD_START FROM slr.SLR_ENTITY_PERIODS PriorStart WHERE PriorStart.EP_ENTITY = per.EP_ENTITY AND PriorStart.EP_BUS_YEAR = per.EP_BUS_YEAR AND PriorStart.EP_BUS_PERIOD = per.EP_BUS_PERIOD - 1 AND PriorStart.EP_STATUS  = ''O'' and jlu_jrnl_hdr_id is not null) --header_id is not null, for fix internal 12425
                  ELSE
                    PriorPer.EP_BUS_PERIOD_START
                  END

                 WHEN ejtr_period_date  = ''E'' THEN
                  CASE WHEN per.EP_BUS_PERIOD > 1 THEN
                    (SELECT PriorEnd.EP_BUS_PERIOD_END FROM slr.SLR_ENTITY_PERIODS PriorEnd WHERE PriorEnd.EP_ENTITY = per.EP_ENTITY AND PriorEnd.EP_BUS_YEAR = per.EP_BUS_YEAR AND PriorEnd.EP_BUS_PERIOD = per.EP_BUS_PERIOD - 1 and PriorEnd.EP_STATUS  = ''O'' and jlu_jrnl_hdr_id is not null)
                  ELSE
                    PriorPer.EP_BUS_PERIOD_END
                  END
              END
          WHEN ejtr_prior_next_current = ''N'' THEN
            CASE WHEN ejtr_period_date  = ''S'' THEN
                  CASE WHEN per.EP_BUS_PERIOD < 12 THEN
                     (SELECT NextStart.EP_BUS_PERIOD_START FROM slr.SLR_ENTITY_PERIODS NextStart WHERE NextStart.EP_ENTITY = per.EP_ENTITY AND NextStart.EP_BUS_YEAR = per.EP_BUS_YEAR AND NextStart.EP_BUS_PERIOD = per.EP_BUS_PERIOD + 1 and NextStart.EP_STATUS  = ''O'' and jlu_jrnl_hdr_id is not null)
                  ELSE
                    NextPer.EP_BUS_PERIOD_START
                  END
               WHEN ejtr_period_date  = ''E'' THEN
                  CASE WHEN per.EP_BUS_PERIOD < 12 THEN
                    (SELECT NextEnd.EP_BUS_PERIOD_END FROM slr.SLR_ENTITY_PERIODS NextEnd WHERE NextEnd.EP_ENTITY = per.EP_ENTITY AND NextEnd.EP_BUS_YEAR = per.EP_BUS_YEAR AND NextEnd.EP_BUS_PERIOD = per.EP_BUS_PERIOD + 1 and NextEnd.EP_STATUS  = ''O'' and jlu_jrnl_hdr_id is not null)
                  ELSE
                    NextPer.EP_BUS_PERIOD_END
                  END
               END
          ELSE
            CASE WHEN ejtr_period_date  = ''S'' THEN
                per.EP_BUS_PERIOD_START
               WHEN ejtr_period_date  = ''E'' THEN
                per.EP_BUS_PERIOD_END
            END
          END
      WHEN rul.ejtr_prior_next_current IS NOT NULL THEN
        CASE WHEN rul.ejtr_prior_next_current  = ''N'' THEN
          (SELECT MIN(ent1.ED_DATE)
            FROM slr.SLR_ENTITY_DAYS ent1
              WHERE ent1.ED_ENTITY_SET = ent.ENT_PERIODS_AND_DAYS_SET
                AND ent1.ED_DATE > jlu.JLU_EFFECTIVE_DATE
                AND ed_status = ''O''
              )

             WHEN rul.ejtr_prior_next_current  = ''P'' THEN
            (SELECT  MAX(ent1.ED_DATE)
              FROM    slr.SLR_ENTITY_DAYS ent1
              WHERE   ent1.ED_ENTITY_SET       =      ent.ENT_PERIODS_AND_DAYS_SET
              AND     ent1.ED_DATE             <       jlu.JLU_EFFECTIVE_DATE
              AND ed_status = ''O''
              )
          END

        ELSE
        (SELECT MIN(ent1.ED_DATE)
        FROM slr.SLR_ENTITY_DAYS ent1
        WHERE ent1.ED_ENTITY_SET = ent.ENT_PERIODS_AND_DAYS_SET
        AND ent1.ED_DATE > jlu.JLU_EFFECTIVE_DATE
        AND ed_status = ''O'')
       END
      END AS ED_DAT,
       jlu.JLU_JRNL_PROCESS_ID,
       jlu.JLU_ENTITY,
       jlu.JLU_ACCOUNT,
       jlu.JLU_SEGMENT_1,
       jlu.JLU_SEGMENT_2,
       jlu.JLU_SEGMENT_3,
       jlu.JLU_SEGMENT_4,
       jlu.JLU_SEGMENT_5,
       jlu.JLU_SEGMENT_6,
       jlu.JLU_SEGMENT_7,
       jlu.JLU_SEGMENT_8,
       jlu.JLU_SEGMENT_9,
       jlu.JLU_SEGMENT_10,
       jlu.JLU_ATTRIBUTE_1,
       jlu.JLU_ATTRIBUTE_2,
       jlu.JLU_ATTRIBUTE_3,
       jlu.JLU_ATTRIBUTE_4,
       jlu.JLU_ATTRIBUTE_5,
       jlu.JLU_REFERENCE_1,
       jlu.JLU_REFERENCE_2,
       jlu.JLU_REFERENCE_3,
       jlu.JLU_REFERENCE_4,
       jlu.JLU_REFERENCE_5,
       jlu.JLU_REFERENCE_6,
       jlu.JLU_REFERENCE_7,
       jlu.JLU_REFERENCE_8,
       jlu.JLU_REFERENCE_9,
       jlu.JLU_REFERENCE_10,
       jlu.JLU_TRAN_CCY,
       (-1)*jlu.JLU_TRAN_AMOUNT AS JLU_TRAN_AMOUNT,
       jlu.JLU_BASE_RATE,
       jlu.JLU_BASE_CCY,
       (-1)*jlu.JLU_BASE_AMOUNT AS JLU_BASE_AMOUNT,
       jlu.JLU_LOCAL_RATE,
       jlu.JLU_LOCAL_CCY,
       (-1)*jlu.JLU_LOCAL_AMOUNT AS JLU_LOCAL_AMOUNT,
       jlu.JLU_CREATED_BY,
       current_timestamp AS JLU_CREATED_ON,
       jlu.JLU_AMENDED_BY,
       current_timestamp AS JLU_AMENDED_ON,
       jlu.JLU_JRNL_TYPE,
       jlu.JLU_VALUE_DATE,
       jlu.JLU_JRNL_DESCRIPTION,
       trim(jlu.JLU_JRNL_SOURCE) AS JLU_JRNL_SOURCE,
       trim(trailing ''.'' from trim(jlu.JLU_JRNL_HDR_ID)) AS JLU_JRNL_SOURCE_JRNL_ID,
       COALESCE(jlu.JLU_JRNL_AUTHORISED_BY, ''AUTO'') AS JLU_JRNL_AUTHORISED_BY,
       JLU_JRNL_AUTHORISED_ON,
       jlu.JLU_JRNL_VALIDATED_BY,
       jlu.JLU_JRNL_VALIDATED_ON,
       jlu.JLU_JRNL_POSTED_BY,
       jlu.JLU_JRNL_POSTED_ON,
       jlu.JLU_JRNL_TOTAL_HASH_DEBIT,
       jlu.JLU_JRNL_TOTAL_HASH_CREDIT,
       jlu.JLU_JRNL_PREF_STATIC_SRC,
       jlu.JLU_JRNL_HDR_ID AS JLU_JRNL_REF_ID,   -------------- parent id for reversal journals
       jlu.JLU_JRNL_INTERNAL_PERIOD_FLAG,
       jlu.JLU_JRNL_ENT_RATE_SET,
       CASE
        WHEN jlu.JLU_TRANSLATION_DATE IS NULL THEN
        jlu.JLU_EFFECTIVE_DATE
        ELSE
        jlu.JLU_TRANSLATION_DATE
       END AS TRANSLATION_DATE,
       jlu.JLU_TYPE,
       jlu.jlu_epg_id,
       ent.ENT_BUSINESS_DATE AS BUSINESS_DATE,
       jlu.rowid as row_id
  FROM slr.SLR_JRNL_LINES_UNPOSTED jlu
  , slr.SLR_EXT_JRNL_TYPES ext
  , slr.SLR_JRNL_TYPES typ
  , slr.SLR_EXT_JRNL_TYPE_RULE rul
  , slr.SLR_ENTITIES ent
  , slr.SLR_ENTITY_PERIODS per
  , slr.SLR_ENTITY_PERIODS PriorPer
  , slr.SLR_ENTITY_PERIODS NextPer
  WHERE
      --JOINS
      jlu.jlu_jrnl_type = ext.ejt_type
      AND rul.ejtr_code = ext.ejt_rev_ejtr_code
      AND ext.ejt_jt_type = typ.JT_TYPE
      AND per.ep_entity = jlu.jlu_entity
      AND jlu.JLU_ENTITY = ent.ENT_ENTITY
      AND ent.ENT_ENTITY = per.EP_ENTITY
      --ONE_TO_MANY REDUCTION
     AND per.EP_STATUS  = ''O''
     AND jlu.JLU_EFFECTIVE_DATE BETWEEN per.EP_BUS_PERIOD_START AND per.EP_BUS_PERIOD_END
     AND NextPer.EP_ENTITY = per.EP_ENTITY AND NextPer.EP_BUS_YEAR = per.EP_BUS_YEAR+1 AND NextPer.EP_BUS_PERIOD = 1 '     || vEPG ||
     ' (typ.jt_reverse_flag = ''Y''
        OR typ.jt_reverse_flag = ''C''
        AND jlu.JLU_JRNL_REV_DATE is not null)
     AND PriorPer.EP_ENTITY = per.EP_ENTITY AND PriorPer.EP_BUS_YEAR = per.EP_BUS_YEAR-1 AND PriorPer.EP_BUS_PERIOD = 12
     AND jlu.JLU_JRNL_REF_ID IS NULL ' || vProcess ||
    ' jlu.JLU_JRNL_STATUS = ''' || status ||
    ''' AND ent.ENT_STATUS = ''A''
         AND not exists (SELECT 1 FROM slr.SLR_JRNL_LINES_WAITING jlw
                             WHERE  jlu.JLU_JRNL_HDR_ID = jlw.JLW_JRNL_REF_ID
                                AND jlu.JLU_EPG_ID = jlw.JLW_EPG_ID
                                AND jlu.JLU_ENTITY = jlw.JLW_ENTITY)
         AND not exists (SELECT 1 FROM slr.SLR_JRNL_LINES_UNPOSTED JLU_REV WHERE
                        jlu.JLU_JRNL_HDR_ID  = JLU_REV.JLU_JRNL_REF_ID '|| vEPG2 || ' and  JLU_REV.JLU_JRNL_REF_ID is not null and JLU_REV.JLU_EPG_ID = jlu.JLU_EPG_ID and JLU_REV.JLU_ENTITY = jlu.JLU_ENTITY) '|| vCompare || '
    )
  SELECT STANDARD_HASH(JLU_JRNL_HDR_ID, ''MD5'') AS JLU_JRNL_HDR_ID_new,
    JLU_JRNL_LINE_NUMBER,
    JLU_FAK_ID,
    JLU_EBA_ID,
    CASE WHEN ED_DAT > BUSINESS_DATE THEN ''W'' ELSE ''U'' END AS JLU_JRNL_STATUS,
    JLU_JRNL_STATUS_TEXT                 ,
    CASE WHEN ED_DAT > BUSINESS_DATE THEN 0 ELSE JLU_JRNL_PROCESS_ID END AS  JLU_JRNL_PROCESS_ID,
    JLU_DESCRIPTION,
    JLU_SOURCE_JRNL_ID_Q,
    ED_DAT,
    ED_DAT,
    JLU_ENTITY,
    JLU_EPG_ID,
    JLU_ACCOUNT,
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
    JLU_ATTRIBUTE_1,
    JLU_ATTRIBUTE_2,
    JLU_ATTRIBUTE_3,
    JLU_ATTRIBUTE_4,
    JLU_ATTRIBUTE_5,
    JLU_REFERENCE_1,
    JLU_REFERENCE_2,
    JLU_REFERENCE_3,
    JLU_REFERENCE_4,
    JLU_REFERENCE_5,
    JLU_REFERENCE_6,
    JLU_REFERENCE_7,
    JLU_REFERENCE_8,
    JLU_REFERENCE_9,
    JLU_REFERENCE_10,
    JLU_TRAN_CCY,
    JLU_TRAN_AMOUNT,
    JLU_BASE_RATE,
    JLU_BASE_CCY,
    JLU_BASE_AMOUNT,
    JLU_LOCAL_RATE,
    JLU_LOCAL_CCY,
    JLU_LOCAL_AMOUNT,
    JLU_CREATED_BY,
    JLU_CREATED_ON,
    JLU_AMENDED_BY,
    JLU_AMENDED_ON,
    JLU_JRNL_TYPE,
    ED_DAT,
    JLU_JRNL_DESCRIPTION,
    JLU_JRNL_SOURCE,
    JLU_JRNL_SOURCE_JRNL_ID,
    JLU_JRNL_AUTHORISED_BY,
    JLU_JRNL_AUTHORISED_ON,
    JLU_JRNL_VALIDATED_BY,
    JLU_JRNL_VALIDATED_ON,
    JLU_JRNL_POSTED_BY,
    JLU_JRNL_POSTED_ON,
    JLU_JRNL_TOTAL_HASH_DEBIT,
    JLU_JRNL_TOTAL_HASH_CREDIT,
    JLU_JRNL_PREF_STATIC_SRC,
    JLU_JRNL_REF_ID,
    null,
    TRANSLATION_DATE,
    ep.EP_BUS_PERIOD,
    ep.EP_BUS_YEAR,
    1,
    JLU_JRNL_INTERNAL_PERIOD_FLAG,
    JLU_JRNL_ENT_RATE_SET,
    JLU_TYPE,
    row_id
  FROM jlu
  inner join SLR_ENTITY_PERIODS ep
  on ep.EP_ENTITY = jlu.JLU_ENTITY
  and jlu.ED_DAT between ep.EP_BUS_PERIOD_START and ep.EP_BUS_PERIOD_END' ;

    LOOP
    exit when l_cursor%notfound;
        FETCH l_cursor
        BULK COLLECT INTO vRevJrnlTab limit gROWCNT_LIMIT_NUMBER;


    forall i in vRevJrnlTab.first..vRevJrnlTab.last
    insert into SLR_JRNL_LINES_UNPOSTED (JLU_JRNL_HDR_ID,JLU_JRNL_LINE_NUMBER,JLU_FAK_ID,JLU_EBA_ID,JLU_JRNL_STATUS,JLU_JRNL_STATUS_TEXT,JLU_JRNL_PROCESS_ID,JLU_DESCRIPTION,JLU_SOURCE_JRNL_ID,JLU_EFFECTIVE_DATE,JLU_VALUE_DATE,JLU_ENTITY,JLU_EPG_ID,JLU_ACCOUNT,JLU_SEGMENT_1,JLU_SEGMENT_2,JLU_SEGMENT_3,JLU_SEGMENT_4,JLU_SEGMENT_5,JLU_SEGMENT_6,JLU_SEGMENT_7,JLU_SEGMENT_8,JLU_SEGMENT_9,JLU_SEGMENT_10,JLU_ATTRIBUTE_1,JLU_ATTRIBUTE_2,JLU_ATTRIBUTE_3,JLU_ATTRIBUTE_4,JLU_ATTRIBUTE_5,JLU_REFERENCE_1,JLU_REFERENCE_2,JLU_REFERENCE_3,JLU_REFERENCE_4,JLU_REFERENCE_5,JLU_REFERENCE_6,JLU_REFERENCE_7,JLU_REFERENCE_8,JLU_REFERENCE_9,JLU_REFERENCE_10,JLU_TRAN_CCY,JLU_TRAN_AMOUNT,JLU_BASE_RATE,JLU_BASE_CCY,JLU_BASE_AMOUNT,JLU_LOCAL_RATE,JLU_LOCAL_CCY,JLU_LOCAL_AMOUNT,JLU_CREATED_BY,JLU_CREATED_ON,JLU_AMENDED_BY,JLU_AMENDED_ON,JLU_JRNL_TYPE,JLU_JRNL_DATE,JLU_JRNL_DESCRIPTION,JLU_JRNL_SOURCE,JLU_JRNL_SOURCE_JRNL_ID,JLU_JRNL_AUTHORISED_BY,JLU_JRNL_AUTHORISED_ON,JLU_JRNL_VALIDATED_BY,JLU_JRNL_VALIDATED_ON,JLU_JRNL_POSTED_BY,JLU_JRNL_POSTED_ON,JLU_JRNL_TOTAL_HASH_DEBIT,JLU_JRNL_TOTAL_HASH_CREDIT,JLU_JRNL_PREF_STATIC_SRC,JLU_JRNL_REF_ID,JLU_JRNL_REV_DATE,JLU_TRANSLATION_DATE,JLU_PERIOD_MONTH,JLU_PERIOD_YEAR,JLU_PERIOD_LTD,JLU_JRNL_INTERNAL_PERIOD_FLAG, JLU_TYPE)
    values (vRevJrnlTab(i).JLU_JRNL_HDR_ID,vRevJrnlTab(i).JLU_JRNL_LINE_NUMBER,vRevJrnlTab(i).JLU_FAK_ID,vRevJrnlTab(i).JLU_EBA_ID,vRevJrnlTab(i).JLU_JRNL_STATUS,vRevJrnlTab(i).JLU_JRNL_STATUS_TEXT,vRevJrnlTab(i).JLU_JRNL_PROCESS_ID,vRevJrnlTab(i).JLU_DESCRIPTION,vRevJrnlTab(i).JLU_SOURCE_JRNL_ID,vRevJrnlTab(i).JLU_EFFECTIVE_DATE,vRevJrnlTab(i).JLU_VALUE_DATE,vRevJrnlTab(i).JLU_ENTITY,vRevJrnlTab(i).JLU_EPG_ID,vRevJrnlTab(i).JLU_ACCOUNT,vRevJrnlTab(i).JLU_SEGMENT_1,vRevJrnlTab(i).JLU_SEGMENT_2,vRevJrnlTab(i).JLU_SEGMENT_3,vRevJrnlTab(i).JLU_SEGMENT_4,vRevJrnlTab(i).JLU_SEGMENT_5,vRevJrnlTab(i).JLU_SEGMENT_6,vRevJrnlTab(i).JLU_SEGMENT_7,vRevJrnlTab(i).JLU_SEGMENT_8,vRevJrnlTab(i).JLU_SEGMENT_9,vRevJrnlTab(i).JLU_SEGMENT_10,vRevJrnlTab(i).JLU_ATTRIBUTE_1,vRevJrnlTab(i).JLU_ATTRIBUTE_2,vRevJrnlTab(i).JLU_ATTRIBUTE_3,vRevJrnlTab(i).JLU_ATTRIBUTE_4,vRevJrnlTab(i).JLU_ATTRIBUTE_5,vRevJrnlTab(i).JLU_REFERENCE_1,vRevJrnlTab(i).JLU_REFERENCE_2,vRevJrnlTab(i).JLU_REFERENCE_3,vRevJrnlTab(i).JLU_REFERENCE_4,vRevJrnlTab(i).JLU_REFERENCE_5,vRevJrnlTab(i).JLU_REFERENCE_6,vRevJrnlTab(i).JLU_REFERENCE_7,vRevJrnlTab(i).JLU_REFERENCE_8,vRevJrnlTab(i).JLU_REFERENCE_9,vRevJrnlTab(i).JLU_REFERENCE_10,vRevJrnlTab(i).JLU_TRAN_CCY,vRevJrnlTab(i).JLU_TRAN_AMOUNT,vRevJrnlTab(i).JLU_BASE_RATE,vRevJrnlTab(i).JLU_BASE_CCY,vRevJrnlTab(i).JLU_BASE_AMOUNT,vRevJrnlTab(i).JLU_LOCAL_RATE,vRevJrnlTab(i).JLU_LOCAL_CCY,vRevJrnlTab(i).JLU_LOCAL_AMOUNT,vRevJrnlTab(i).JLU_CREATED_BY,vRevJrnlTab(i).JLU_CREATED_ON,vRevJrnlTab(i).JLU_AMENDED_BY,vRevJrnlTab(i).JLU_AMENDED_ON,vRevJrnlTab(i).JLU_JRNL_TYPE,vRevJrnlTab(i).JLU_JRNL_DATE,vRevJrnlTab(i).JLU_JRNL_DESCRIPTION,vRevJrnlTab(i).JLU_JRNL_SOURCE,vRevJrnlTab(i).JLU_JRNL_SOURCE_JRNL_ID,vRevJrnlTab(i).JLU_JRNL_AUTHORISED_BY,vRevJrnlTab(i).JLU_JRNL_AUTHORISED_ON,vRevJrnlTab(i).JLU_JRNL_VALIDATED_BY,vRevJrnlTab(i).JLU_JRNL_VALIDATED_ON,vRevJrnlTab(i).JLU_JRNL_POSTED_BY,vRevJrnlTab(i).JLU_JRNL_POSTED_ON,vRevJrnlTab(i).JLU_JRNL_TOTAL_HASH_DEBIT,vRevJrnlTab(i).JLU_JRNL_TOTAL_HASH_CREDIT,vRevJrnlTab(i).JLU_JRNL_PREF_STATIC_SRC,vRevJrnlTab(i).JLU_JRNL_REF_ID,vRevJrnlTab(i).JLU_JRNL_REV_DATE,vRevJrnlTab(i).JLU_TRANSLATION_DATE,vRevJrnlTab(i).JLU_PERIOD_MONTH,vRevJrnlTab(i).JLU_PERIOD_YEAR,vRevJrnlTab(i).JLU_PERIOD_LTD,vRevJrnlTab(i).JLU_JRNL_INTERNAL_PERIOD_FLAG, vRevJrnlTab(i).JLU_TYPE)
    ;
  v_reverse := v_reverse + SQL%ROWCOUNT;


  forall i in vRevJrnlTab.first..vRevJrnlTab.last
    UPDATE SLR_JRNL_LINES_UNPOSTED PARENTT
    SET PARENTT.JLU_JRNL_REV_DATE =  vRevJrnlTab(i).JLU_EFFECTIVE_DATE
    WHERE parentt.rowid = vRevJrnlTab(i).row_id;

  END LOOP;

  CLOSE l_cursor;

  COMMIT;

  SLR_ADMIN_PKG.PerfInfo( 'Create reversing journals query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s. ' || v_reverse ||  ' Rows inserted');
  SLR_ADMIN_PKG.Debug('All :' ||v_reverse || ' reversal journals created.' , null);



  END IF;

  EXCEPTION
        WHEN OTHERS THEN
        pr_error(1, SQLERRM, 0, 'pCreate_rev_journal_batch', 'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted', NULL, NULL, gs_stage, 'PL/SQL');
        RAISE e_internal_processing_error;

END pCreate_rev_journal_batch;



procedure pCreate_reversing_journal_madj(jrnl_id_list varchar2, entity_proc_group VARCHAR2, status CHAR, process_id number)
 is
  vEpgCurrentBussDate date;
begin

  vEpgCurrentBussDate := SLR_UTILITIES_PKG.fEntityGroupCurrBusDate(entity_proc_group);
  IF gp_business_date IS NULL THEN 
   gp_business_date := vEpgCurrentBussDate;
  END IF;

  pg_process_state.log_proc(p_conf_group   => 'SLR',
                            p_stage        => 'slr_post_journals.pCreate_reversing_journal_madj_slr_jrnl_headers_unposted',
                            p_process_id   => process_id,
                            p_epg_id        => entity_proc_group,
							p_rate_set      => slr_post_journals_pkg.gp_rate_set,
							p_business_date => gp_business_date,
                            p_object_name  => 'SLR_JRNL_HEADERS_UNPOSTED',
                            p_start_dt     =>  sysdate,
                            p_status       => 'P');
  pg_process_state.log_proc(p_conf_group   => 'SLR',
                            p_stage        => 'slr_post_journals.pCreate_reversing_journal_madj_slr_jrnl_lines_unposted',
                            p_process_id   => process_id,
                            p_epg_id        => entity_proc_group,
							p_rate_set      => slr_post_journals_pkg.gp_rate_set,
							p_business_date => gp_business_date,
                            p_object_name  => 'SLR_JRNL_LINES_UNPOSTED',
                            p_start_dt     =>  sysdate,
                            p_status       => 'P');


  execute immediate
  'INSERT INTO slr_jrnl_headers_unposted (
            jhu_jrnl_id, jhu_jrnl_type, jhu_jrnl_date, jhu_jrnl_entity, jhu_jrnl_status,
            jhu_jrnl_status_text, jhu_jrnl_process_id, jhu_jrnl_description, jhu_jrnl_source,
            jhu_jrnl_source_jrnl_id, jhu_jrnl_authorised_by, jhu_jrnl_authorised_on,
            jhu_jrnl_validated_by, jhu_jrnl_validated_on, jhu_jrnl_posted_by, jhu_jrnl_posted_on,
            jhu_jrnl_total_hash_debit, jhu_jrnl_total_hash_credit, jhu_jrnl_total_lines,
            jhu_created_by, jhu_created_on, jhu_amended_by, jhu_amended_on, jhu_jrnl_pref_static_src,
            jhu_manual_flag, jhu_epg_id, jhu_jrnl_ref_id, jhu_department_id
        )
  SELECT standard_hash(sjhu.jhu_jrnl_id, ''MD5''),
       sjhu.jhu_jrnl_type,
       sjhu.jhu_jrnl_rev_date,
       sjhu.jhu_jrnl_entity,
       case when sjhu.jhu_jrnl_rev_date <= :curr_bus_date then jhu_jrnl_status else ''W'' end,
       ''Unposted'',
       case when sjhu.jhu_jrnl_rev_date <= :curr_bus_date then :p_process_id else 0 end,
       sjhu.jhu_jrnl_description,
       sjhu.jhu_jrnl_source,
       sjhu.jhu_jrnl_source_jrnl_id,
       sjhu.jhu_jrnl_authorised_by,
       sjhu.jhu_jrnl_authorised_on,
       sjhu.jhu_jrnl_validated_by,
       sjhu.jhu_jrnl_validated_on,
       sjhu.jhu_jrnl_posted_by,
       sjhu.jhu_jrnl_posted_on,
       sjhu.jhu_jrnl_total_hash_credit,
       sjhu.jhu_jrnl_total_hash_debit,
       sjhu.jhu_jrnl_total_lines,
       sjhu.jhu_amended_by,
       SYSDATE,
       sjhu.jhu_amended_by,
       SYSDATE,
       sjhu.jhu_jrnl_pref_static_src,
       ''Y'',
       sjhu.jhu_epg_id,
       sjhu.jhu_jrnl_id,
       sjhu.jhu_department_id
  FROM slr_jrnl_headers_unposted sjhu,
     slr_ext_jrnl_types ejt,
     slr_jrnl_types jt
  WHERE sjhu.jhu_jrnl_id in ('||jrnl_id_list||')
  and sjhu.jhu_jrnl_status = :status
  and sjhu.jhu_jrnl_type = ejt.ejt_type
  AND jt.jt_type = ejt.ejt_jt_type
  and (jt.jt_reverse_flag = ''Y''
       OR jt.jt_reverse_flag = ''C''
     AND sjhu.jhu_jrnl_rev_date is not null)'
  using vEpgCurrentBussDate, vEpgCurrentBussDate,process_id, status;

  execute immediate
  'INSERT INTO slr_jrnl_lines_unposted (
  jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id, jlu_eba_id, jlu_jrnl_status,
  jlu_jrnl_status_text, jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
  jlu_effective_date, jlu_value_date, jlu_entity, jlu_account, jlu_segment_1,
  jlu_segment_2, jlu_segment_3, jlu_segment_4, jlu_segment_5, jlu_segment_6,
  jlu_segment_7, jlu_segment_8, jlu_segment_9, jlu_segment_10, jlu_attribute_1,
  jlu_attribute_2, jlu_attribute_3, jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
  jlu_reference_2, jlu_reference_3, jlu_reference_4, jlu_reference_5, jlu_reference_6,
  jlu_reference_7, jlu_reference_8, jlu_reference_9, jlu_reference_10, jlu_tran_ccy,
  jlu_tran_amount, jlu_base_rate, jlu_base_ccy, jlu_base_amount, jlu_local_rate,
  jlu_local_ccy, jlu_local_amount, jlu_created_by, jlu_created_on, jlu_amended_by,
  jlu_amended_on, jlu_epg_id, jlu_period_month, jlu_period_year, jlu_period_ltd,
  jlu_jrnl_ref_id,jlu_jrnl_rev_date,jlu_jrnl_internal_period_flag,jlu_translation_date,
  jlu_jrnl_type,jlu_jrnl_date,jlu_jrnl_description,jlu_jrnl_source,jlu_jrnl_source_jrnl_id,
  jlu_jrnl_authorised_by,jlu_jrnl_authorised_on,jlu_jrnl_validated_by,jlu_jrnl_validated_on,
  jlu_jrnl_posted_by,jlu_jrnl_posted_on,jlu_jrnl_total_hash_debit,jlu_jrnl_total_hash_credit,
    jlu_jrnl_pref_static_src,jlu_jrnl_ent_rate_set
   )
  SELECT jhu_jrnl_id,
       jlu_jrnl_line_number,
       jlu_fak_id,
       jlu_eba_id,
       jhu_jrnl_status,
       ''Unposted'',
       '||process_id||',
       jlu_description,
       jhu_jrnl_ref_id,
       jhu_jrnl_date,
       jhu_jrnl_date,
       jlu_entity,
       jlu_account,
       jlu_segment_1,
       jlu_segment_2,
       jlu_segment_3,
      jlu_segment_4,
      jlu_segment_5,
      jlu_segment_6,
      jlu_segment_7,
      jlu_segment_8,
      jlu_segment_9,
      jlu_segment_10,
      jlu_attribute_1,
      jlu_attribute_2,
      jlu_attribute_3,
      jlu_attribute_4,
      jlu_attribute_5,
      jlu_reference_1,
      jlu_reference_2,
      jlu_reference_3,
      jlu_reference_4,
      jlu_reference_5,
      jlu_reference_6,
      jlu_reference_7,
      jlu_reference_8,
      jlu_reference_9,
      jlu_reference_10,
      jlu_tran_ccy,
      -jlu_tran_amount,
      jlu_base_rate,
      jlu_base_ccy,
      -jlu_base_amount,
      jlu_local_rate,
      jlu_local_ccy,
      -jlu_local_amount,
      jlu_amended_by,
      SYSDATE,
      jlu_amended_by,
      SYSDATE,
      jlu_epg_id,
      nvl(EP_BUS_PERIOD,0),
      NVL(EP_BUS_YEAR,0),
      CASE WHEN EA_ACCOUNT_TYPE_FLAG = ''P'' THEN NVL(EP_BUS_YEAR,0) ELSE 1 END,
      jhu_jrnl_ref_id,
      null,
      jlu_jrnl_internal_period_flag,
            CASE
        WHEN ext.ejt_translation_date_derived_from=''Reversing'' THEN
           jhu_jrnl_date
        ELSE
           NVL(JLU_TRANSLATION_DATE, JLU_EFFECTIVE_DATE)
       END AS TRANSLATION_DATE,
      jlu_jrnl_type,
      jhu_jrnl_date,
      jlu_jrnl_description,
      jlu_jrnl_source,
      jhu_jrnl_ref_id,
      jlu_jrnl_authorised_by,
      jlu_jrnl_authorised_on,
      jlu_jrnl_validated_by,
      jlu_jrnl_validated_on,
        jlu_jrnl_posted_by,
      jlu_jrnl_posted_on,
      jlu_jrnl_total_hash_debit,
      jlu_jrnl_total_hash_credit,
          jlu_jrnl_pref_static_src,
      jlu_jrnl_ent_rate_set
  FROM slr_jrnl_lines_unposted inner join slr_jrnl_headers_unposted on (jlu_jrnl_hdr_id = jhu_jrnl_ref_id and jlu_jrnl_hdr_id <> jhu_jrnl_id)
   INNER JOIN slr.slr_ext_jrnl_types ext  ON jlu_jrnl_type = ext.ejt_type
  LEFT JOIN SLR_ENTITY_PERIODS
    ON (JHU_JRNL_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
    AND JHU_JRNL_ENTITY = EP_ENTITY
    AND EP_PERIOD_TYPE != 0)
  LEFT JOIN SLR_ENTITIES
    ON (ENT_ENTITY = JHU_JRNL_ENTITY)
  LEFT JOIN SLR_ENTITY_ACCOUNTS
    ON (EA_ENTITY_SET = ENT_ACCOUNTS_SET and JLU_ACCOUNT=EA_ACCOUNT)
  WHERE jlu_jrnl_hdr_id IN ('||jrnl_id_list||')
  AND jlu_jrnl_status = :status
  AND jlu_epg_id = '''||entity_proc_group||''''
   using status;

   execute immediate
   'insert into slr_jrnl_file_attachment (jfa_jh_jrnl_id, jfa_jf_file_id)
   select jhu_jrnl_id, jfa_jf_file_id
   from slr_jrnl_file_attachment,
    slr_jrnl_headers_unposted
   where jfa_jh_jrnl_id = jhu_jrnl_ref_id
   and  jfa_jh_jrnl_id <> jhu_jrnl_id
   and jfa_jh_jrnl_id in ('||jrnl_id_list||')';

   pg_process_state.log_proc_completed(p_conf_group   => 'SLR',
                                       p_stage        => 'slr_post_journals.pCreate_reversing_journal_madj_slr_jrnl_headers_unposted',
                                       p_process_id   => process_id);

   pg_process_state.log_proc_completed(p_conf_group   => 'SLR',
                                       p_stage        => 'slr_post_journals.pCreate_reversing_journal_madj_slr_jrnl_lines_unposted',
                                       p_process_id   => process_id);
exception
  when others then
   Rollback;
	pg_process_state.Set_Process_Failed(p_process_id  => process_id,p_info=> SQLERRM);
    pr_error(1, SQLERRM, 0, 'pCreate_reversing_journal_madj', 'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted', NULL, NULL, gs_stage, 'PL/SQL');
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pCreate_reversing_journal_madj: ' || SQLERRM);

end pCreate_reversing_journal_madj;

PROCEDURE pGenerateFAKLastBalances
(
   p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
   p_day DATE -- last balances will be generated for this day
)
AS
    s_proc_name VARCHAR2(65) := 'SLR_POST_JOURNALS_PKG.pGenerateFAKLastBalances';
   lv_sql_create_lb VARCHAR2(32000);
   lv_table_name VARCHAR2(32);
   lv_last_correct_lb DATE;
   lv_START_TIME  PLS_INTEGER := 0;
   lv_BusDate    DATE;
   lv_sql VARCHAR2(32000);
   lv_inserted BOOLEAN := FALSE;
   lv_cursor    NUMBER;
   lv_countrows NUMBER;
BEGIN

   SELECT MAX(LFI_GENERATED_FOR)
   INTO lv_last_correct_lb
   FROM SLR_FAK_LAST_BALANCES_INDEX
    WHERE LFI_EPG_ID = p_epg_id
        AND LFI_GENERATED_FOR <= p_day;

    lv_BusDate:= SLR_UTILITIES_PKG.fEntityGroupCurrBusDate(p_epg_id);

   lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    IF lv_last_correct_lb IS NULL THEN
        lv_sql:= '
            INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'GENERATE_FAK_LAST_BALANCES') || ' INTO SLR_FAK_LAST_BALANCES
            (
                FLB_FAK_ID,
                FLB_BALANCE_DATE,
                FLB_BALANCE_TYPE,
                FLB_TRAN_DAILY_MOVEMENT,
                FLB_TRAN_MTD_BALANCE,
                FLB_TRAN_QTD_BALANCE,
                FLB_TRAN_YTD_BALANCE,
                FLB_TRAN_LTD_BALANCE,
                FLB_BASE_DAILY_MOVEMENT,
                FLB_BASE_MTD_BALANCE,
                FLB_BASE_QTD_BALANCE,
                FLB_BASE_YTD_BALANCE,
                FLB_BASE_LTD_BALANCE,
                FLB_LOCAL_DAILY_MOVEMENT,
                FLB_LOCAL_MTD_BALANCE,
                FLB_LOCAL_QTD_BALANCE,
                FLB_LOCAL_YTD_BALANCE,
                FLB_LOCAL_LTD_BALANCE,
                FLB_ENTITY,
                FLB_EPG_ID,
                FLB_PERIOD_MONTH,
                FLB_PERIOD_QTR,
                FLB_PERIOD_YEAR,
                FLB_PERIOD_LTD,
                FLB_GENERATED_FOR
            )
            SELECT
                FDB_FAK_ID,
                FDB_BALANCE_DATE,
                FDB_BALANCE_TYPE,
                FDB_TRAN_DAILY_MOVEMENT,
                FDB_TRAN_MTD_BALANCE,
                FDB_TRAN_QTD_BALANCE,
                FDB_TRAN_YTD_BALANCE,
                FDB_TRAN_LTD_BALANCE,
                FDB_BASE_DAILY_MOVEMENT,
                FDB_BASE_MTD_BALANCE,
                FDB_BASE_QTD_BALANCE,
                FDB_BASE_YTD_BALANCE,
                FDB_BASE_LTD_BALANCE,
                FDB_LOCAL_DAILY_MOVEMENT,
                FDB_LOCAL_MTD_BALANCE,
                FDB_LOCAL_QTD_BALANCE,
                FDB_LOCAL_YTD_BALANCE,
                FDB_LOCAL_LTD_BALANCE,
                FDB_ENTITY,
                FDB_EPG_ID,
                FDB_PERIOD_MONTH,
                FDB_PERIOD_QTR,
                FDB_PERIOD_YEAR,
                FDB_PERIOD_LTD,
                :p_day
            FROM
            (
                SELECT
                    FDB_FAK_ID,
                    FDB_BALANCE_DATE,
                    FDB_BALANCE_TYPE,
                    FDB_TRAN_DAILY_MOVEMENT,
                    FDB_TRAN_MTD_BALANCE,
                    FDB_TRAN_QTD_BALANCE,
                    FDB_TRAN_YTD_BALANCE,
                    FDB_TRAN_LTD_BALANCE,
                    FDB_BASE_DAILY_MOVEMENT,
                    FDB_BASE_MTD_BALANCE,
                    FDB_BASE_QTD_BALANCE,
                    FDB_BASE_YTD_BALANCE,
                    FDB_BASE_LTD_BALANCE,
                    FDB_LOCAL_DAILY_MOVEMENT,
                    FDB_LOCAL_MTD_BALANCE,
                    FDB_LOCAL_QTD_BALANCE,
                    FDB_LOCAL_YTD_BALANCE,
                    FDB_LOCAL_LTD_BALANCE,
                    FDB_ENTITY,
                    FDB_EPG_ID,
                    FDB_PERIOD_MONTH,
                    FDB_PERIOD_QTR,
                    FDB_PERIOD_YEAR,
                    FDB_PERIOD_LTD,
                    ROW_NUMBER () OVER (PARTITION BY FDB_FAK_ID, FDB_BALANCE_TYPE ORDER BY FDB_BALANCE_DATE DESC) rn
                FROM SLR_FAK_DAILY_BALANCES
                WHERE FDB_BALANCE_DATE <= :p_day
                    AND FDB_EPG_ID = :p_epg_id
            )
            WHERE rn = 1
        ';
    lv_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':p_day',p_day);
    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );

      --  EXECUTE IMMEDIATE lv_sql USING p_day, p_day;
    IF lv_CountRows> 0 THEN
      lv_inserted := TRUE;
    END IF;
    ELSE
        IF lv_last_correct_lb < p_day THEN
            lv_sql:='
                INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'GENERATE_FAK_LAST_BALANCES') || ' INTO SLR_FAK_LAST_BALANCES
                (
                    FLB_FAK_ID,
                    FLB_BALANCE_DATE,
                    FLB_BALANCE_TYPE,
                    FLB_TRAN_DAILY_MOVEMENT,
                    FLB_TRAN_MTD_BALANCE,
                    FLB_TRAN_QTD_BALANCE,
                    FLB_TRAN_YTD_BALANCE,
                    FLB_TRAN_LTD_BALANCE,
                    FLB_BASE_DAILY_MOVEMENT,
                    FLB_BASE_MTD_BALANCE,
                    FLB_BASE_QTD_BALANCE,
                    FLB_BASE_YTD_BALANCE,
                    FLB_BASE_LTD_BALANCE,
                    FLB_LOCAL_DAILY_MOVEMENT,
                    FLB_LOCAL_MTD_BALANCE,
                    FLB_LOCAL_QTD_BALANCE,
                    FLB_LOCAL_YTD_BALANCE,
                    FLB_LOCAL_LTD_BALANCE,
                    FLB_ENTITY,
                    FLB_EPG_ID,
                    FLB_PERIOD_MONTH,
                    FLB_PERIOD_QTR,
                    FLB_PERIOD_YEAR,
                    FLB_PERIOD_LTD,
                    FLB_GENERATED_FOR
                )
                SELECT
                    FDB_FAK_ID,
                    FDB_BALANCE_DATE,
                    FDB_BALANCE_TYPE,
                    FDB_TRAN_DAILY_MOVEMENT,
                    FDB_TRAN_MTD_BALANCE,
                    FDB_TRAN_QTD_BALANCE,
                    FDB_TRAN_YTD_BALANCE,
                    FDB_TRAN_LTD_BALANCE,
                    FDB_BASE_DAILY_MOVEMENT,
                    FDB_BASE_MTD_BALANCE,
                    FDB_BASE_QTD_BALANCE,
                    FDB_BASE_YTD_BALANCE,
                    FDB_BASE_LTD_BALANCE,
                    FDB_LOCAL_DAILY_MOVEMENT,
                    FDB_LOCAL_MTD_BALANCE,
                    FDB_LOCAL_QTD_BALANCE,
                    FDB_LOCAL_YTD_BALANCE,
                    FDB_LOCAL_LTD_BALANCE,
                    FDB_ENTITY,
                    FDB_EPG_ID,
                    FDB_PERIOD_MONTH,
                    FDB_PERIOD_QTR,
                    FDB_PERIOD_YEAR,
                    FDB_PERIOD_LTD,
                    :p_day
                FROM
                (
                    SELECT
                        FDB_BALANCE_DATE,
                        FDB_FAK_ID,
                        FDB_TRAN_DAILY_MOVEMENT,
                        FDB_TRAN_MTD_BALANCE,
                        FDB_TRAN_QTD_BALANCE,
                        FDB_TRAN_YTD_BALANCE,
                        FDB_TRAN_LTD_BALANCE,
                        FDB_BASE_DAILY_MOVEMENT,
                        FDB_BASE_MTD_BALANCE,
                        FDB_BASE_QTD_BALANCE,
                        FDB_BASE_YTD_BALANCE,
                        FDB_BASE_LTD_BALANCE,
                        FDB_LOCAL_DAILY_MOVEMENT,
                        FDB_LOCAL_MTD_BALANCE,
                        FDB_LOCAL_QTD_BALANCE,
                        FDB_LOCAL_YTD_BALANCE,
                        FDB_LOCAL_LTD_BALANCE,
                        FDB_BALANCE_TYPE,
                        FDB_ENTITY,
                        FDB_EPG_ID,
                        FDB_PERIOD_MONTH,
                        FDB_PERIOD_QTR,
                        FDB_PERIOD_YEAR,
                        FDB_PERIOD_LTD,
                        ROW_NUMBER () OVER (partition by FDB_FAK_ID, FDB_BALANCE_TYPE ORDER BY FDB_BALANCE_DATE DESC) rn
                    FROM
                    (
                        SELECT
                            FLB_BALANCE_DATE AS FDB_BALANCE_DATE,
                            FLB_FAK_ID AS FDB_FAK_ID,
                            FLB_TRAN_DAILY_MOVEMENT AS FDB_TRAN_DAILY_MOVEMENT,
                            FLB_TRAN_MTD_BALANCE AS FDB_TRAN_MTD_BALANCE,
                            FLB_TRAN_QTD_BALANCE AS FDB_TRAN_QTD_BALANCE,
                            FLB_TRAN_YTD_BALANCE AS FDB_TRAN_YTD_BALANCE,
                            FLB_TRAN_LTD_BALANCE AS FDB_TRAN_LTD_BALANCE,
                            FLB_BASE_DAILY_MOVEMENT AS FDB_BASE_DAILY_MOVEMENT,
                            FLB_BASE_MTD_BALANCE AS FDB_BASE_MTD_BALANCE,
                            FLB_BASE_QTD_BALANCE AS FDB_BASE_QTD_BALANCE,
                            FLB_BASE_YTD_BALANCE AS FDB_BASE_YTD_BALANCE,
                            FLB_BASE_LTD_BALANCE AS FDB_BASE_LTD_BALANCE,
                            FLB_LOCAL_DAILY_MOVEMENT AS FDB_LOCAL_DAILY_MOVEMENT,
                            FLB_LOCAL_MTD_BALANCE AS FDB_LOCAL_MTD_BALANCE,
                            FLB_LOCAL_QTD_BALANCE AS FDB_LOCAL_QTD_BALANCE,
                            FLB_LOCAL_YTD_BALANCE AS FDB_LOCAL_YTD_BALANCE,
                            FLB_LOCAL_LTD_BALANCE AS FDB_LOCAL_LTD_BALANCE,
                            FLB_BALANCE_TYPE AS FDB_BALANCE_TYPE,
                            FLB_ENTITY AS FDB_ENTITY,
                            FLB_EPG_ID AS FDB_EPG_ID,
                            FLB_PERIOD_MONTH AS FDB_PERIOD_MONTH,
                            FLB_PERIOD_QTR AS FDB_PERIOD_QTR,
                            FLB_PERIOD_YEAR AS FDB_PERIOD_YEAR,
                            FLB_PERIOD_LTD AS FDB_PERIOD_LTD
                        FROM SLR_FAK_LAST_BALANCES
                        WHERE FLB_GENERATED_FOR = :lv_last_correct_lb
                            AND FLB_EPG_ID = :p_epg_id
                        UNION ALL
                        SELECT
                            FDB_BALANCE_DATE,
                            FDB_FAK_ID,
                            FDB_TRAN_DAILY_MOVEMENT,
                            FDB_TRAN_MTD_BALANCE,
                            FDB_TRAN_QTD_BALANCE,
                            FDB_TRAN_YTD_BALANCE,
                            FDB_TRAN_LTD_BALANCE,
                            FDB_BASE_DAILY_MOVEMENT,
                            FDB_BASE_MTD_BALANCE,
                            FDB_BASE_QTD_BALANCE,
                            FDB_BASE_YTD_BALANCE,
                            FDB_BASE_LTD_BALANCE,
                            FDB_LOCAL_DAILY_MOVEMENT,
                            FDB_LOCAL_MTD_BALANCE,
                            FDB_LOCAL_QTD_BALANCE,
                            FDB_LOCAL_YTD_BALANCE,
                            FDB_LOCAL_LTD_BALANCE,
                            FDB_BALANCE_TYPE,
                            FDB_ENTITY,
                            FDB_EPG_ID,
                            FDB_PERIOD_MONTH,
                            FDB_PERIOD_QTR,
                            FDB_PERIOD_YEAR,
                            FDB_PERIOD_LTD
                        FROM SLR_FAK_DAILY_BALANCES
                        WHERE FDB_BALANCE_DATE > :lv_last_correct_lb
                            AND FDB_BALANCE_DATE <= :p_day
                            AND FDB_EPG_ID = :p_epg_id
                    )
                )
                WHERE rn = 1
            ';
    lv_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse( lv_cursor, lv_sql, dbms_sql.native );
    dbms_sql.bind_variable( lv_cursor, ':p_epg_id',p_epg_id);
    dbms_sql.bind_variable( lv_cursor, ':p_day',p_day);
    dbms_sql.bind_variable( lv_cursor, ':lv_last_correct_lb',lv_last_correct_lb);
    lv_CountRows := dbms_sql.execute( lv_cursor );
    dbms_sql.close_cursor( lv_cursor );


       -- EXECUTE IMMEDIATE lv_sql USING p_day, lv_last_correct_lb, lv_last_correct_lb, p_day;
      IF lv_CountRows> 0 THEN
        lv_inserted := TRUE;
      END IF;
        END IF;
   END IF;

   /* need to insert here, even if lv_inserted := FALSE, as SLR_FAK_LAST_BALANCE_HELPER is used by reporting views as a pointer to SLR_FAK_DAILY_BALANCES */
    MERGE INTO SLR_FAK_LAST_BALANCE_HELPER FLBH1
    USING (
      SELECT p_epg_id as FLBH_EPG_ID FROM dual
    ) FLBH2
    ON
    (
       FLBH1.FLBH_EPG_ID = FLBH2.FLBH_EPG_ID
    )
    WHEN MATCHED THEN UPDATE SET FLBH_GENERATED_FOR = p_day, FLBH_BUSSINESS_DATE=lv_BusDate
    WHEN NOT MATCHED THEN INSERT (FLBH1.FLBH_EPG_ID,FLBH1.FLBH_GENERATED_FOR,FLBH1.FLBH_BUSSINESS_DATE) VALUES (p_epg_id,p_day,lv_BusDate);

  IF lv_inserted = TRUE THEN
    MERGE INTO SLR_FAK_LAST_BALANCES_INDEX LFI1
    USING (
      SELECT p_epg_id as LFI_EPG_ID, p_day as LFI_GENERATED_FOR FROM dual
    ) LFI2
    ON
    (
      LFI1.LFI_EPG_ID = LFI2.LFI_EPG_ID AND LFI1.LFI_GENERATED_FOR = LFI2.LFI_GENERATED_FOR
    )
    WHEN NOT MATCHED THEN INSERT (LFI1.LFI_EPG_ID,LFI1.LFI_GENERATED_FOR) VALUES (p_epg_id,p_day);
  END IF;
  COMMIT;
    SLR_ADMIN_PKG.Debug('FAK Last balances generated.', lv_sql);
   SLR_ADMIN_PKG.PerfInfo( 'LB. FAK Last Balances query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
      pWriteLogError(s_proc_name, 'SLR_FAK_LAST_BALANCES',
         'Error during generating SLR_FAK_LAST_BALANCES table: ' || SQLERRM,
         p_process_id,p_epg_id );
        SLR_ADMIN_PKG.Error('Error during generating SLR_FAK_LAST_BALANCES table: ' || SQLERRM);
        RAISE e_internal_processing_error; -- raised to stop execution

END pGenerateFAKLastBalances;



FUNCTION pValidateEntityProcGroup
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER
) RETURN BOOLEAN

AS

    lv_business_date_count INTEGER;
    lv_post_fak_balances_count INTEGER;
    s_proc_name VARCHAR2(60) := 'SLR_POST_JOURNALS_PKG.pValidateEntityProcGroup';
    lv_success BOOLEAN := TRUE;


BEGIN


    SELECT COUNT(DISTINCT ENT_BUSINESS_DATE), COUNT(DISTINCT ENT_POST_FAK_BALANCES)
    INTO lv_business_date_count, lv_post_fak_balances_count
    FROM SLR_ENTITIES
    WHERE ENT_ENTITY IN
    (
        SELECT EPG_ENTITY
        FROM SLR_ENTITY_PROC_GROUP
        WHERE EPG_ID = p_epg_id
    );



    -- check ENT_ENTITY_DATE
    IF(lv_business_date_count > 1) THEN

        pr_error(1, 'pValidateEntityProcGroup: The business date setup has to be the same for all Entities within the EPG [' || p_epg_id || '] ', 0, s_proc_name, null, p_process_id, 'Process Id', gs_stage, 'PL/SQL');
        lv_success := FALSE;

    END IF;


    -- check ENT_POST_FAK_BALANCES
    IF(lv_post_fak_balances_count > 1) THEN

        pr_error(1, 'pValidateEntityProcGroup: The ENT_POST_FAK_BALANCES flag must be the same for all Entities within the EPG [' || p_epg_id || '] ', 0, s_proc_name, null, p_process_id, 'Process Id', gs_stage, 'PL/SQL');
        lv_success := FALSE;

    END IF;

    RETURN lv_success;


    EXCEPTION
        WHEN OTHERS THEN
            -- FATAL
            gv_msg := 'pValidateEntityProcGroup: Failure during entity proc group validation.';
            pr_error(1, gv_msg || SQLERRM, 0,
                     s_proc_name, null, p_process_id, 'Process Id', gs_stage, 'PL/SQL');
            RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pValidateEntityProcGroup: ' || SQLERRM);

END pValidateEntityProcGroup;


END SLR_POST_JOURNALS_PKG;
/
alter package SLR_POST_JOURNALS_PKG compile;
