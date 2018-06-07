CREATE OR REPLACE PACKAGE BODY slr.slr_pkg AS


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- Private procedures
---------------------------------------------------------------------------------
    PROCEDURE pEntityBusinessDate
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_business_date OUT DATE
    );

    PROCEDURE pRollbackImportExchange
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_subpartition_name IN VARCHAR2,
        p_pm_table_name IN VARCHAR2
    );

---------------------------------------------------------------------------------
-- Private package attributes
---------------------------------------------------------------------------------
    gv_msg        VARCHAR2(1000);   -- General messsage field
    gs_stage      CHAR(3) := 'SLR';

    -- For new way of posting
    e_internal_processing_error EXCEPTION;
    e_lock_acquire_error EXCEPTION;
    e_fak_daily_balances_error EXCEPTION;
    e_invalid_dates EXCEPTION;

    c_lock_request_timeout CONSTANT NUMBER := 300; -- seconds

-- -----------------------------------------------------------------------------------------------
-- Procedure:   pPROCESS_SLR (entity)
-- Description: Run the sub-ledger for a specified entity.
-- Notes:
-- -----------------------------------------------------------------------------------------------
PROCEDURE pUpdateJLU AS

v_epg_id SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;

BEGIN

  FOR i IN (SELECT DISTINCT ENT_PG.EPG_ID FROM SLR_ENTITY_PROC_GROUP ENT_PG)
  LOOP
    v_epg_id := i.epg_id;

    DBMS_OUTPUT.PUT_LINE('Running pUpdateJLU for EPG_ID = ' || v_epg_id);
    SLR_UTILITIES_PKG.pUpdateJrnlLinesUnposted(v_epg_id);
  END LOOP;

END pUpdateJLU;

PROCEDURE pPROCESS_SLR AS

    s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pPROCESS_SLR';
    lv_process_id NUMBER(30) := 0;
    lv_lock_handle VARCHAR2(100);
    lv_lock_result INTEGER;
    lvCount NUMBER;
    lv_use_headers     boolean;
    lv_START_TIME     PLS_INTEGER := 0;

    v_epg_id SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;
    v_ent_rate_set slr_entities.ent_rate_set%TYPE;

BEGIN

  FOR i IN
      (
        SELECT DISTINCT
             ENT.ENT_RATE_SET,
             ENT_PG.EPG_ID
        FROM SLR_ENTITIES ENT,
             SLR_ENTITY_PROC_GROUP ENT_PG
        WHERE ENT.ENT_ENTITY = ENT_PG.EPG_ENTITY
      )
  LOOP
    v_ent_rate_set := i.ent_rate_set;
    v_epg_id       := i.epg_id;
    DBMS_OUTPUT.PUT_LINE
      ('ENT_RATE_SET_Val = ' || v_ent_rate_set || ', EPG_ID = ' || v_epg_id);

    ----------------------------------------
    -- Set processId for whole processing
    ----------------------------------------
    SELECT SEQ_PROCESS_NUMBER.NEXTVAL INTO lv_process_id  FROM DUAL;

    --------------------
    -- Lock request
    --------------------
    -- Lock is needed, because we can't handle more than one processing for the same entity group.

    DBMS_LOCK.ALLOCATE_UNIQUE('MAH_PROCESS_SLR_' || v_epg_id, lv_lock_handle);

    lv_lock_result := DBMS_LOCK.REQUEST(lv_lock_handle, DBMS_LOCK.X_MODE, 5);
    IF lv_lock_result != 0 THEN
         gv_msg := 'Can''t acquire lock for pProcessSlr for entity group ' || v_epg_id ||
                    '. Probably another processing for this entity group is running.';

        pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_SLRFUNC, s_proc_name, null, null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        SLR_ADMIN_PKG.Error('ERROR in ' || s_proc_name || ': ' || gv_msg);
        RAISE e_lock_acquire_error;
    ELSE
        ----------------------
        -- Main processing
        ----------------------
        lv_START_TIME:=DBMS_UTILITY.GET_TIME();
        pIMPORT_SLR_JRNLS(v_epg_id, lv_process_id);
        SLR_ADMIN_PKG.PerfInfo( 'Import JL function. Import journal function execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

        ----------------------------------------------------------------------
        -- Assign existing journals to current batch
        -- Mark Jrnl Lines from previous runs as Unposted
        ----------------------------------------------------------------------
        lv_START_TIME:=DBMS_UTILITY.GET_TIME();
        SLR_UTILITIES_PKG.pResetFailedJournals(v_epg_id, lv_process_id, lv_use_headers);
        SLR_ADMIN_PKG.PerfInfo( 'Reset Failed JL function. Reset Failed JL function execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

        BEGIN
        lv_START_TIME:=DBMS_UTILITY.GET_TIME();
        DBMS_STATS.GATHER_TABLE_STATS(ownname=>'SLR',tabname=>'SLR_JRNL_LINES_UNPOSTED',estimate_percent=>dbms_stats.auto_sample_size,degree=>8, granularity => 'ALL');

        SLR_ADMIN_PKG.PerfInfo( 'Gather table statistics. Execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
        END;

       ----------------------------------------------------------------------------------------
        -- Check that there are actually some records in the unposted table before calling
        --  the core validate and post procedure. If there is no data then the core
        --  procedure will raise some messages saying that there is no data.
        ----------------------------------------------------------------------------------------
        SELECT COUNT(1) INTO lvCount FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_JRNL_STATUS = 'U'
        AND JLU_EPG_ID = v_epg_id
        AND ROWNUM <= 1;

        IF lvCount >= 1 THEN
            ----------------------
            -- Validate and Post
            ----------------------
            lv_START_TIME:=DBMS_UTILITY.GET_TIME();
            SLR_VALIDATE_JOURNALS_PKG.pValidateJournals(p_epg_id => v_epg_id, p_process_id => lv_process_id, p_UseHeaders => lv_use_headers, p_rate_set => v_ent_rate_set);
            SLR_ADMIN_PKG.PerfInfo( 'Validate function. Validate function execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
            lv_START_TIME:=DBMS_UTILITY.GET_TIME();
            SLR_POST_JOURNALS_PKG.pPostJournals(p_epg_id => v_epg_id, p_process_id => lv_process_id, p_UseHeaders => lv_use_headers, p_rate_set => v_ent_rate_set);
            SLR_ADMIN_PKG.PerfInfo( 'Post Journals. Post Journals function execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

        ELSE
            -- Log a message - 0 indicates it is an informational message
            pr_error(0, 'Sub-Ledger posting not performed for Entity Processing Group ' || v_epg_id || '.  No journals to post.',
                                0, s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', null, 'Entity', 'SLR', 'PL/SQL', SQLCODE);
        END IF;

        --------------------
        -- Lock release
        --------------------
        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
    END IF;

END LOOP;

pGENERATE_FAK_BOP_VALUES();
pGENERATE_EBA_BOP_VALUES();

EXCEPTION
WHEN e_lock_acquire_error THEN
        -- error was logged before
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pPROCESS_SLR');
    WHEN OTHERS THEN
        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, '', 'Error in pPROCESS_SLR for entity group ' || v_epg_id, lv_process_id, v_epg_id);
        SLR_ADMIN_PKG.Error('Error in pPROCESS_SLR for entity group ' || v_epg_id);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pPROCESS_SLR: ' || SQLERRM);



END pPROCESS_SLR;

-- -----------------------------------------------------------------------
-- Procedure: pIMPORT_SLR_ALL_JRNLS
-- -----------------------------------------------------------------------
-- Procedure to import journal lines from the AET to the SLR Unposted
-- tables
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pIMPORT_SLR_ALL_JRNLS
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER
)
AS

    p_process NUMBER;
    s_proc_name       VARCHAR2(50) := 'SLR_CLIENT_PROCEDURES_PKG.pIMPORT_SLR_ALL_JRNLS';

BEGIN
        If p_process_id IS NULL THEN
            SELECT   SEQ_PROCESS_NUMBER.NEXTVAL INTO p_process FROM  DUAL;
        ELSE
            p_process := p_process_id;
        end if;

        pIMPORT_SLR_JRNLS(p_entity_proc_group, p_process);

EXCEPTION
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, '(1) Failure to import journals: '
                 ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'FR_ACCOUNTING_EVENT', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pIMPORT_SLR_ALL_JRNLS: ' || SQLERRM);

END pIMPORT_SLR_ALL_JRNLS;

-- -----------------------------------------------------------------------
-- Procedure: pIMPORT_SLR_JRNLS
-- -----------------------------------------------------------------------
-- Procedure to generate Journal Lines and to insert journal
-- headers. These are generated from the FR_ACCOUNTING_EVENT table
-- which is subsequently updated to show the records have been moved
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- Procedure References:
--      FR_ACCOUNTING_EVENT
--      SLR_JOURNAL_LINES
--      SLR_JOURNAL_HEADERS
--
-- -----------------------------------------------------------------------
-- Procedure Steps
-- 1) Select the system date
-- 2) Open up cursor over FR_ACCOUNTING_EVENT
-- 3) Insert journal headers
-- 4) Insert journal lines
-- 5) Update accounting event to show records have been extracted
-- 6) Commit the records
--
-- -----------------------------------------------------------------------
-- History
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pIMPORT_SLR_JRNLS
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER
)
AS
    s_proc_name CONSTANT VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pIMPORT_SLR_JRNLS';
    lv_business_date SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE;
    lv_user VARCHAR2(30);
    lv_gp_todays_bus_date FR_GLOBAL_PARAMETER.GP_TODAYS_BUS_DATE%TYPE;
    lv_subpartition_name VARCHAR2(30);
    lv_lock_handle VARCHAR2(100);
    lv_lock_result INTEGER;
    lv_part_move_table_name VARCHAR2(100);
    lv_rollback_exchange BOOLEAN := FALSE;
    lv_rows_on_subpartition NUMBER(12);
    lv_date_condition VARCHAR(250);
    lv_sql VARCHAR2(32000);
    lv_START_TIME PLS_INTEGER := 0;
    lvAuthOn            DATE;
    TYPE cur_type IS REF CURSOR;
    cValidateRows cur_type;
    v_posting_date FR_ACCOUNTING_EVENT.AE_POSTING_DATE%TYPE;
BEGIN
    SLR_ADMIN_PKG.InitLog(p_entity_proc_group, p_process_id);
    SLR_ADMIN_PKG.Debug('pIMPORT_SLR_JRNLS - begin');

    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
    EXECUTE IMMEDIATE 'ALTER SESSION SET DDL_LOCK_TIMEOUT = ' || SLR_UTILITIES_PKG.fGetDdlLockTimeout();

    pEntityBusinessDate(p_entity_proc_group, p_process_id, lv_business_date);

    SELECT USER INTO lv_user FROM DUAL;

    SELECT TRUNC(SYSDATE) INTO lv_gp_todays_bus_date FROM DUAL;
    SELECT SYSDATE INTO lvAuthOn FROM DUAL;

    pInsertFakEbaCombinations(p_entity_proc_group, p_process_id, lv_business_date);

    lv_sql := '
        INSERT ' || SLR_UTILITIES_PKG.fHint(p_entity_proc_group, 'IMPORT_INSERT_UNPOSTED') || ' INTO SLR_JRNL_LINES_UNPOSTED
        (
            JLU_JRNL_HDR_ID,
            JLU_JRNL_LINE_NUMBER,
            JLU_FAK_ID,
            JLU_EBA_ID,
            JLU_JRNL_STATUS,
            JLU_JRNL_STATUS_TEXT,
            JLU_JRNL_PROCESS_ID,
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
            JLU_AMENDED_BY,
            JLU_AMENDED_ON,
            JLU_JRNL_TYPE,
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
            JLU_JRNL_REF_ID,
            JLU_JRNL_REV_DATE,
            JLU_TRANSLATION_DATE

        )
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_entity_proc_group, 'IMPORT_INSERT_UNPOSTED_SUBSELECT') || '
            MAX(FNSLR_GETHEADERID()) OVER
            (
                PARTITION BY AE_AET_ACC_EVENT_TYPE_ID, AE_GL_ENTITY, AE_POSTING_DATE,  AE_ACC_EVENT_ID,  AE_SOURCE_SYSTEM, AE_JOURNAL_TYPE, AE_REVERSE_DATE
            )
            AS JLU_JRNL_HDR_ID,
            NVL
            (
                AE_TRANSACTION_NO, ROW_NUMBER() OVER
                (
                    PARTITION BY AE_AET_ACC_EVENT_TYPE_ID, AE_GL_ENTITY, AE_POSTING_DATE,  AE_ACC_EVENT_ID,  AE_SOURCE_SYSTEM, AE_JOURNAL_TYPE, AE_REVERSE_DATE
                    ORDER BY NULL
                )
            ) AS JLU_JRNL_LINE_NUMBER,
            FC_FAK_ID AS JLU_FAK_ID,
            EC_EBA_ID AS JLU_EBA_ID,
            ''U'' AS JLU_JRNL_STATUS,
            NULL AS JLU_JRNL_STATUS_TEXT,
            :process_id___1 AS JLU_JRNL_PROCESS_ID,
            AE_GL_NARRATIVE AS JLU_DESCRIPTION,
            AE_ACC_EVENT_ID AS JLU_SOURCE_JRNL_ID,
            COALESCE(AE_CLIENT_DATE1, AE_VALUE_DATE, AE_POSTING_DATE) AS JLU_EFFECTIVE_DATE,  /*Updated per user story 25193*/
            NVL(AE_VALUE_DATE, AE_POSTING_DATE) AS JLU_VALUE_DATE,
            AE_GL_ENTITY AS JLU_ENTITY,
            AE_EPG_ID AS JLU_EPG_ID,
            AE_GL_ACCOUNT AS JLU_ACCOUNT,
            AE_POSTING_SCHEMA AS JLU_SEGMENT_1,
            AE_GAAP AS JLU_SEGMENT_2,
            nvl(AE_DIMENSION_2,''NVS'') AS JLU_SEGMENT_3,
            nvl(AE_DIMENSION_4,''NVS'') AS JLU_SEGMENT_4,
            nvl(AE_DIMENSION_1,''NVS'') AS JLU_SEGMENT_5,
            AE_DIMENSION_11 AS JLU_SEGMENT_6,
            AE_DIMENSION_12 AS JLU_SEGMENT_7,
            AE_DIMENSION_7 AS JLU_SEGMENT_8,
            ''NVS'' AS JLU_SEGMENT_9,
            ''NVS'' AS JLU_SEGMENT_10,
            AE_DIMENSION_8 AS JLU_ATTRIBUTE_1,
            AE_DIMENSION_9 AS JLU_ATTRIBUTE_2,
            AE_DIMENSION_14 AS JLU_ATTRIBUTE_3,
            AE_CLIENT_SPARE_ID4 AS JLU_ATTRIBUTE_4,
            ''NVS'' AS JLU_ATTRIBUTE_5,
            AE_DIMENSION_15 AS JLU_REFERENCE_1,
            AE_CLIENT_SPARE_ID3 AS JLU_REFERENCE_2,
            AE_DIMENSION_6 AS JLU_REFERENCE_3,
            AE_DIMENSION_13 AS JLU_REFERENCE_4,
            AE_CLIENT_SPARE_ID11 AS JLU_REFERENCE_5,
            nvl(AE_DIMENSION_5,''NVS'') AS JLU_REFERENCE_6,
            AE_DIMENSION_3 AS JLU_REFERENCE_7,
            ''NVS'' AS JLU_REFERENCE_8,
            ''NVS'' AS JLU_REFERENCE_9,
            ''NVS'' AS JLU_REFERENCE_10,
            AE_ISO_CURRENCY_CODE AS JLU_TRAN_CCY,
            AE_AMOUNT AS JLU_TRAN_AMOUNT,
            AE_BASE_RATE AS JLU_BASE_RATE,
            AE_CLIENT_SPARE_ID7 AS JLU_BASE_CCY,
            AE_CLIENT_SPARE_ID8 AS JLU_BASE_AMOUNT,
            AE_LOCAL_RATE AS JLU_LOCAL_RATE,
            AE_CLIENT_SPARE_ID5 AS JLU_LOCAL_CCY,
            AE_CLIENT_SPARE_ID6 JLU_LOCAL_AMOUNT,
            :user___3 AS JLU_CREATED_BY,
            :gp_todays_bus_date___4 AS JLU_CREATED_ON,
            :user___5 AS JLU_AMENDED_BY,
            :gp_todays_bus_date___6 AS JLU_AMENDED_ON,
            AE_JOURNAL_TYPE AS JLU_JRNL_TYPE,
            NULL AS JLU_JRNL_DESCRIPTION,
            AE_SOURCE_SYSTEM AS JLU_JRNL_SOURCE,
            AE_ACC_EVENT_ID AS JLU_JRNL_SOURCE_JRNL_ID,
            ''SLR'' AS JLU_JRNL_AUTHORISED_BY,
            SYSDATE AS JLU_JRNL_AUTHORISED_ON,
            NULL AS JLU_JRNL_VALIDATED_BY,
            NULL AS JLU_JRNL_VALIDATED_ON,
            NULL AS JLU_JRNL_POSTED_BY,
            NULL AS JLU_JRNL_POSTED_ON,
            SUM(CASE WHEN ROUND(AE_AMOUNT,2) > 0.00 THEN AE_AMOUNT ELSE 0 END) OVER
                (PARTITION BY AE_AET_ACC_EVENT_TYPE_ID, AE_GL_ENTITY, AE_POSTING_DATE,  AE_ACC_EVENT_ID,  AE_SOURCE_SYSTEM, AE_JOURNAL_TYPE, AE_REVERSE_DATE
                 ORDER BY NULL)
                AS JLU_JRNL_TOTAL_HASH_DEBIT,
            SUM(CASE WHEN ROUND(AE_AMOUNT,2) < 0.00 THEN AE_AMOUNT ELSE 0 END) OVER
                (PARTITION BY AE_AET_ACC_EVENT_TYPE_ID, AE_GL_ENTITY, AE_POSTING_DATE,  AE_ACC_EVENT_ID,  AE_SOURCE_SYSTEM, AE_JOURNAL_TYPE, AE_REVERSE_DATE
                 ORDER BY NULL)
                AS JLU_JRNL_TOTAL_HASH_CREDIT,
            NULL AS JLU_JRNL_REF_ID,
            AE_REVERSE_DATE AS JLU_JRNL_REV_DATE,
            NVL(AE_TRANSLATION_DATE, AE_POSTING_DATE) AS JLU_TRANSLATION_DATE
        FROM FR_ACCOUNTING_EVENT
        JOIN SLR_ENTITIES
            ON ENT_ENTITY = AE_GL_ENTITY
        JOIN SLR_FAK_COMBINATIONS
            ON NVL(AE_DIMENSION_11,''NVS'') = FC_SEGMENT_6
            AND AE_GL_ACCOUNT = FC_ACCOUNT
            AND AE_ISO_CURRENCY_CODE = FC_CCY
            AND AE_EPG_ID = FC_EPG_ID
            AND AE_GL_ENTITY = FC_ENTITY
            AND AE_POSTING_SCHEMA = FC_SEGMENT_1
            AND AE_GAAP = FC_SEGMENT_2
            AND NVL(AE_DIMENSION_2,''NVS'') = FC_SEGMENT_3
            AND NVL(AE_DIMENSION_4,''NVS'') = FC_SEGMENT_4
            AND NVL(AE_DIMENSION_1,''NVS'') = FC_SEGMENT_5
            AND NVL(AE_DIMENSION_12,''NVS'') = FC_SEGMENT_7
            AND NVL(AE_DIMENSION_7,''NVS'') = FC_SEGMENT_8
            AND ''NVS'' = FC_SEGMENT_9
            AND ''NVS'' = FC_SEGMENT_10
        JOIN SLR_EBA_COMBINATIONS
            ON NVL(AE_DIMENSION_8,''NVS'') = EC_ATTRIBUTE_1
            AND EC_FAK_ID = FC_FAK_ID
            AND NVL(AE_DIMENSION_9,''NVS'') = EC_ATTRIBUTE_2
            AND NVL(AE_DIMENSION_14,''NVS'') = EC_ATTRIBUTE_3
            AND NVL(AE_CLIENT_SPARE_ID4,''NVS'') = EC_ATTRIBUTE_4
            AND ''NVS'' = EC_ATTRIBUTE_5
            AND AE_EPG_ID = EC_EPG_ID
        WHERE AE_EPG_ID = ''' || p_entity_proc_group || '''
            AND AE_POSTING_DATE <= :business_date___7
    ';
    SLR_ADMIN_PKG.Debug('Importing AE', lv_sql);
    lv_START_TIME:=DBMS_UTILITY.GET_TIME();

    SLR_ADMIN_PKG.Debug('PARAM VALUES FOR p_process_id, lv_business_date, lv_user, lv_gp_todays_bus_date, lv_user, lv_gp_todays_bus_date, lv_business_date', p_process_id||'~'||lv_business_date||'~'||lv_user||'~'||lv_gp_todays_bus_date||'~'||lv_user||'~'||lv_gp_todays_bus_date||'~'||lv_business_date);

    EXECUTE IMMEDIATE lv_sql USING p_process_id, lv_user, lv_gp_todays_bus_date, lv_user, lv_gp_todays_bus_date, lv_business_date;

    IF SQL%ROWCOUNT = 0 THEN
        COMMIT;
        SLR_ADMIN_PKG.Info('No records in FR_ACCOUNTING_EVENT to import into SLR_JRNL_LINES_UNPOSTED');
        pr_error(0, 'No records in FR_ACCOUNTING_EVENT to import into SLR_JRNL_LINES_UNPOSTED', 1, s_proc_name, 'FR_ACCOUNTING_EVENT', p_process_id, 'Process Id', 'SLR', 'PL/SQL');
        RETURN; -- no recors were imported
    ELSE
        COMMIT;
        SLR_ADMIN_PKG.Info('ACCOUNTING EVENTS imported to SLR_JRNL_LINES_UNPOSTED');
        SLR_ADMIN_PKG.PerfInfo( 'Import. Import query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
    END IF;

    lv_subpartition_name := SLR_UTILITIES_PKG.fSubpartitionName(p_entity_proc_group, lv_business_date);
    IF SLR_UTILITIES_PKG.fUserSubpartitionExists('FDR','FR_ACCOUNTING_EVENT_IMP', lv_subpartition_name) = FALSE THEN
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'FR_ACCOUNTING_EVENT_IMP',
            'Lack of subpartition in FR_ACCOUNTING_EVENT_IMP for EPG ' || p_entity_proc_group
            || ' and business date ' || lv_business_date, p_process_id,p_entity_proc_group);
        SLR_ADMIN_PKG.Error('ERROR in ' || s_proc_name || ': lack of subpartition in FR_ACCOUNTING_EVENT_IMP for EPG '
            || p_entity_proc_group || ' and business date ' || lv_business_date);
        RAISE e_internal_processing_error;
    END IF;

    EXECUTE IMMEDIATE '
        SELECT /*+ noparallel */ COUNT(*) FROM FR_ACCOUNTING_EVENT_IMP
        SUBPARTITION (' || lv_subpartition_name || ') WHERE ROWNUM < 2'
    INTO lv_rows_on_subpartition;



    IF lv_rows_on_subpartition > 0 THEN
        SLR_ADMIN_PKG.Debug('Processing without exchanging partition');
        lv_date_condition := 'AE_POSTING_DATE <= ''' || lv_business_date || '''';
    ELSE
        SLR_ADMIN_PKG.Debug('Processing with exchanging partition');

        lv_date_condition := 'AE_POSTING_DATE < ''' || lv_business_date || '''';
        lv_part_move_table_name := 'FDR.FR_IMP_PM_' || p_entity_proc_group;

        PR_TRUNCATE_PART_MOVE_TABLE(p_entity_proc_group);

        DBMS_LOCK.ALLOCATE_UNIQUE('MAH_SLR_IMPORT', lv_lock_handle);
        lv_lock_result := DBMS_LOCK.REQUEST(lv_lock_handle, DBMS_LOCK.X_MODE, c_lock_request_timeout);
        IF lv_lock_result != 0 THEN
            SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'FR_ACCOUNTING_EVENT',
                'Error during import from FR_ACCOUNTING_EVENT to SLR_JRNL_LINES_UNPOSTED: can''t acquire lock to exchange partitions',
                p_process_id,p_entity_proc_group);
            SLR_ADMIN_PKG.Error('ERROR in ' || s_proc_name || ': Error during import from FR_ACCOUNTING_EVENT
                to SLR_JRNL_LINES_UNPOSTED: can''t acquire lock to exchange partitions');
            RAISE e_lock_acquire_error;
        END IF;

        lv_rollback_exchange := TRUE;
        EXECUTE IMMEDIATE 'ALTER TABLE FDR.FR_ACCOUNTING_EVENT EXCHANGE SUBPARTITION '
            || lv_subpartition_name || ' WITH TABLE ' || lv_part_move_table_name || ' WITHOUT VALIDATION';


        EXECUTE IMMEDIATE 'ALTER TABLE FDR.FR_ACCOUNTING_EVENT_IMP EXCHANGE SUBPARTITION '
            || lv_subpartition_name || ' WITH TABLE ' || lv_part_move_table_name || ' WITHOUT VALIDATION';

        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
    END IF;

    lv_sql := '
        INSERT ' || SLR_UTILITIES_PKG.fHint(p_entity_proc_group, 'IMPORT_INSERT_ARCH') || ' INTO FR_ACCOUNTING_EVENT_IMP
        (
            AE_ACCEVENT_DATE,
            AE_ACCEVENT_ID,
            AE_ACC_EVENT_ID,
            AE_AET_ACC_EVENT_TYPE_ID,
            AE_AMOUNT,
            AE_BASE_AMOUNT,
            AE_BASE_CURRENCY_CODE,
            AE_BASE_RATE,
            AE_CALC_PERIOD,
            AE_CLIENT_DATE1,
            AE_CLIENT_SPARE_ID1,
            AE_CLIENT_SPARE_ID10,
            AE_CLIENT_SPARE_ID11,
            AE_CLIENT_SPARE_ID12,
            AE_CLIENT_SPARE_ID2,
            AE_CLIENT_SPARE_ID3,
            AE_CLIENT_SPARE_ID4,
            AE_CLIENT_SPARE_ID5,
            AE_CLIENT_SPARE_ID6,
            AE_CLIENT_SPARE_ID7,
            AE_CLIENT_SPARE_ID8,
            AE_CLIENT_SPARE_ID9,
            AE_DIMENSION_1,
            AE_DIMENSION_10,
            AE_DIMENSION_11,
            AE_DIMENSION_12,
            AE_DIMENSION_13,
            AE_DIMENSION_14,
            AE_DIMENSION_15,
            AE_DIMENSION_2,
            AE_DIMENSION_3,
            AE_DIMENSION_4,
            AE_DIMENSION_5,
            AE_DIMENSION_6,
            AE_DIMENSION_7,
            AE_DIMENSION_8,
            AE_DIMENSION_9,
            AE_DR_CR,
            AE_EPG_ID,
            AE_FDR_TRAN_NO,
            AE_GAAP,
            AE_GL_ACCOUNT,
            AE_GL_ACCOUNT_ALIAS,
            AE_GL_BOOK,
            AE_GL_CASH_FLOW_TYPE,
            AE_GL_CLIENT1_ORG_UNIT_ID,
            AE_GL_CLIENT2_ORG_UNIT_ID,
            AE_GL_CLIENT3_ORG_UNIT_ID,
            AE_GL_CONTRACT_ID,
            AE_GL_COST_CENTRE,
            AE_GL_ENTITY,
            AE_GL_INSTRUMENT_ID,
            AE_GL_INSTR_SUPER_CLASS,
            AE_GL_LEDGER_ID,
            AE_GL_NARRATIVE,
            AE_GL_PARTY_BUSINESS_ID,
            AE_GL_PERSON_ID,
            AE_GL_PLANT_ID,
            AE_GL_PRODUCT_PART_ID,
            AE_GL_PROFIT_CENTRE,
            AE_GL_RIGHTS_CATEG_ID,
            AE_GL_RIGHTS_SUBCATEG_ID,
            AE_GL_SHIP_TO_COUNTRY_ID,
            AE_GL_TAX_CODE_ID,
            AE_GL_TRANSACTION_ID,
            AE_IL_INSTR_LEG_ID,
            AE_INPUT_TIME,
            AE_IN_REPOSITORY_IND,
            AE_ISO_CURRENCY_CODE,
            AE_I_INSTRUMENT_ID,
            AE_JOURNAL_TYPE,
            AE_LEDGER_PERIOD,
            AE_LEDGER_REC_STATUS,
            AE_LEDGER_REC_STATUS2,
            AE_LOCAL_AMOUNT,
            AE_LOCAL_CURRENCY_CODE,
            AE_LOCAL_RATE,
            AE_NUMBER_OF_PERIODS,
            AE_POSTING_CODE,
            AE_POSTING_DATE,
            AE_POSTING_SCHEMA,
            AE_RATE_DATE,
            AE_REP_SCHEMA_UPD,
            AE_RET_AGV_OR_ARREARS,
            AE_RET_AMORT_FLAG,
            AE_RET_CA_CALENDAR_NAME,
            AE_RET_POST_PERIOD,
            AE_RET_RECOG_TYPE_ID,
            AE_REVERSE_DATE,
            AE_RULES_AMOUNT_REF_ID,
            AE_RULE_ID,
            AE_SOURCE_JRNL_ID,
            AE_SOURCE_SYSTEM,
            AE_SOURCE_TRAN_NO,
            AE_SUB_EVENT_ID,
            AE_SUB_LEDGER_UPD,
            AE_TRANSACTION_NO,
            AE_TRANSLATION_DATE,
            AE_VALUE_DATE,
            LPG_ID,
            AE_CLIENT_SPARE_ID13,
            AE_CLIENT_SPARE_ID14,
            AE_CLIENT_SPARE_ID15,
            AE_CLIENT_SPARE_ID16,
            AE_CLIENT_SPARE_ID17,
            AE_CLIENT_SPARE_ID18,
            AE_CLIENT_SPARE_ID19,
            AE_CLIENT_SPARE_ID20,
            AE_CLIENT_DATE2,
            AE_CLIENT_DATE3,
            AE_CLIENT_DATE4,
            AE_CLIENT_DATE5
        )
        SELECT ' || SLR_UTILITIES_PKG.fHint(p_entity_proc_group, 'IMPORT_INSERT_ARCH_SUBSELECT') || '
            AE_ACCEVENT_DATE,
            AE_ACCEVENT_ID,
            AE_ACC_EVENT_ID,
            AE_AET_ACC_EVENT_TYPE_ID,
            AE_AMOUNT,
            AE_BASE_AMOUNT,
            AE_BASE_CURRENCY_CODE,
            AE_BASE_RATE,
            AE_CALC_PERIOD,
            AE_CLIENT_DATE1,
            AE_CLIENT_SPARE_ID1,
            AE_CLIENT_SPARE_ID10,
            AE_CLIENT_SPARE_ID11,
            AE_CLIENT_SPARE_ID12,
            AE_CLIENT_SPARE_ID2,
            AE_CLIENT_SPARE_ID3,
            AE_CLIENT_SPARE_ID4,
            AE_CLIENT_SPARE_ID5,
            AE_CLIENT_SPARE_ID6,
            AE_CLIENT_SPARE_ID7,
            AE_CLIENT_SPARE_ID8,
            AE_CLIENT_SPARE_ID9,
            AE_DIMENSION_1,
            AE_DIMENSION_10,
            AE_DIMENSION_11,
            AE_DIMENSION_12,
            AE_DIMENSION_13,
            AE_DIMENSION_14,
            AE_DIMENSION_15,
            AE_DIMENSION_2,
            AE_DIMENSION_3,
            AE_DIMENSION_4,
            AE_DIMENSION_5,
            AE_DIMENSION_6,
            AE_DIMENSION_7,
            AE_DIMENSION_8,
            AE_DIMENSION_9,
            AE_DR_CR,
            AE_EPG_ID,
            AE_FDR_TRAN_NO,
            AE_GAAP,
            AE_GL_ACCOUNT,
            AE_GL_ACCOUNT_ALIAS,
            AE_GL_BOOK,
            AE_GL_CASH_FLOW_TYPE,
            AE_GL_CLIENT1_ORG_UNIT_ID,
            AE_GL_CLIENT2_ORG_UNIT_ID,
            AE_GL_CLIENT3_ORG_UNIT_ID,
            AE_GL_CONTRACT_ID,
            AE_GL_COST_CENTRE,
            AE_GL_ENTITY,
            AE_GL_INSTRUMENT_ID,
            AE_GL_INSTR_SUPER_CLASS,
            AE_GL_LEDGER_ID,
            AE_GL_NARRATIVE,
            AE_GL_PARTY_BUSINESS_ID,
            AE_GL_PERSON_ID,
            AE_GL_PLANT_ID,
            AE_GL_PRODUCT_PART_ID,
            AE_GL_PROFIT_CENTRE,
            AE_GL_RIGHTS_CATEG_ID,
            AE_GL_RIGHTS_SUBCATEG_ID,
            AE_GL_SHIP_TO_COUNTRY_ID,
            AE_GL_TAX_CODE_ID,
            AE_GL_TRANSACTION_ID,
            AE_IL_INSTR_LEG_ID,
            AE_INPUT_TIME,
            AE_IN_REPOSITORY_IND,
            AE_ISO_CURRENCY_CODE,
            AE_I_INSTRUMENT_ID,
            AE_JOURNAL_TYPE,
            AE_LEDGER_PERIOD,
            AE_LEDGER_REC_STATUS,
            AE_LEDGER_REC_STATUS2,
            AE_LOCAL_AMOUNT,
            AE_LOCAL_CURRENCY_CODE,
            AE_LOCAL_RATE,
            AE_NUMBER_OF_PERIODS,
            AE_POSTING_CODE,
            AE_POSTING_DATE,
            AE_POSTING_SCHEMA,
            AE_RATE_DATE,
            AE_REP_SCHEMA_UPD,
            AE_RET_AGV_OR_ARREARS,
            AE_RET_AMORT_FLAG,
            AE_RET_CA_CALENDAR_NAME,
            AE_RET_POST_PERIOD,
            AE_RET_RECOG_TYPE_ID,
            AE_REVERSE_DATE,
            AE_RULES_AMOUNT_REF_ID,
            AE_RULE_ID,
            AE_SOURCE_JRNL_ID,
            AE_SOURCE_SYSTEM,
            AE_SOURCE_TRAN_NO,
            AE_SUB_EVENT_ID,
            AE_SUB_LEDGER_UPD,
            AE_TRANSACTION_NO,
            AE_TRANSLATION_DATE,
            AE_VALUE_DATE,
            LPG_ID,
            AE_CLIENT_SPARE_ID13,
            AE_CLIENT_SPARE_ID14,
            AE_CLIENT_SPARE_ID15,
            AE_CLIENT_SPARE_ID16,
            AE_CLIENT_SPARE_ID17,
            AE_CLIENT_SPARE_ID18,
            AE_CLIENT_SPARE_ID19,
            AE_CLIENT_SPARE_ID20,
            AE_CLIENT_DATE2,
            AE_CLIENT_DATE3,
            AE_CLIENT_DATE4,
            AE_CLIENT_DATE5
        FROM FR_ACCOUNTING_EVENT
        WHERE AE_EPG_ID = ''' || p_entity_proc_group || '''
        AND ' || lv_date_condition
    ;
    SLR_ADMIN_PKG.Debug('Inserting rows into FR_ACCOUNTING_EVENT_IMP', lv_sql);
    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    EXECUTE IMMEDIATE lv_sql;
    COMMIT;
    SLR_ADMIN_PKG.PerfInfo( 'Import Copy AE. Import Copy AE query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

    SLR_ADMIN_PKG.Info('Rows copied to FR_ACCOUNTING_EVENT_IMP');


    BEGIN
        lv_sql :=  'SELECT ' || SLR_UTILITIES_PKG.fHint(p_entity_proc_group, 'SELECT_ACC_EVENT') || ' DISTINCT AE_POSTING_DATE FROM FR_ACCOUNTING_EVENT
            WHERE AE_POSTING_DATE <= to_date(''' || lv_business_date || ''') AND AE_EPG_ID = ''' || p_entity_proc_group || ''' ';

        OPEN cValidateRows FOR lv_sql;
        LOOP
            FETCH cValidateRows INTO v_posting_date;
            EXIT WHEN cValidateRows%NOTFOUND;
        TRUNC_AE_SUBPART( SLR_UTILITIES_PKG.fSubpartitionName(p_entity_proc_group, v_posting_date) );
        END LOOP;
        CLOSE cValidateRows;

    EXCEPTION
        WHEN OTHERS THEN
            SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'FR_ACCOUNTING_EVENT',
                'Import finished but records from FR_ACCOUNTING_EVENT were not removed due to error.',
                p_process_id,p_entity_proc_group);
            SLR_ADMIN_PKG.Error('Import finished but records from FR_ACCOUNTING_EVENT were not removed due to error.');
    END;
    SLR_ADMIN_PKG.Info('Imported rows removed from FR_ACCOUNTING_EVENT');

    EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';

    SLR_ADMIN_PKG.Debug('pIMPORT_SLR_JRNLS - end');

EXCEPTION
    WHEN e_lock_acquire_error THEN
        -- error was logged before
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during import');

    WHEN e_internal_processing_error THEN
        -- e_internal_processing_error exception was logged in procedure which raised it
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during import');

    WHEN OTHERS THEN
        ROLLBACK;
        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'FR_ACCOUNTING_EVENT',
            'Error during import from FR_ACCOUNTING_EVENT to SLR_JRNL_LINES_UNPOSTED.',
            p_process_id,p_entity_proc_group);
        SLR_ADMIN_PKG.Error('ERROR in ' || s_proc_name || ': ' || SQLERRM);
        IF lv_rollback_exchange = TRUE THEN
            pRollbackImportExchange(p_entity_proc_group, lv_subpartition_name, lv_part_move_table_name);
        END IF;

        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pIMPORT_SLR_JRNLS: ' || SQLERRM);

END pIMPORT_SLR_JRNLS;

----------------------------------------------------------------------------------------
-- Used during batch processing to assign FAK/EBA combinations base on accounting events
-- NOTE: Mappings in following merge queries should be updated
-- to be coherent with segments and atrributes settings from import
-- (insert query in pIMPORT_SLR_JRNLS procedure)
-----------------------------------------------------------------------------------------

PROCEDURE pInsertFakEbaCombinations
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_business_date SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE
)
IS
    s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pInsertFakEbaCombinations';
    lv_START_TIME     PLS_INTEGER := 0;
    lv_sql VARCHAR2(32000);
BEGIN

    lv_sql := '
        INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'MERGE_FAK') || ' INTO SLR_FAK_COMBINATIONS
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
            FC_FAK_ID
        )
        WITH ROWS_TO_INSERT AS
        (
            SELECT DISTINCT
                AE_EPG_ID,
                AE_GL_ENTITY,
                AE_GL_ACCOUNT,
                AE_ISO_CURRENCY_CODE,
                AE_POSTING_SCHEMA,
                AE_GAAP,
                NVL(AE_DIMENSION_2,''NVS'')    AE_DIMENSION_2,
                NVL(AE_DIMENSION_4,''NVS'')    AE_DIMENSION_4,
                NVL(AE_DIMENSION_1,''NVS'')    AE_DIMENSION_1,
                NVL(AE_DIMENSION_11,''NVS'')   AE_DIMENSION_11,
                NVL(AE_DIMENSION_12,''NVS'')   AE_DIMENSION_12,
                NVL(AE_DIMENSION_7,''NVS'')    AE_DIMENSION_7
            FROM FR_ACCOUNTING_EVENT
            WHERE AE_EPG_ID = ''' || p_epg_id || '''
                AND AE_POSTING_DATE <= :business_date___1
            MINUS
                SELECT
                    FC_EPG_ID, FC_ENTITY, FC_ACCOUNT, FC_CCY,
                    FC_SEGMENT_1, FC_SEGMENT_2, FC_SEGMENT_3, FC_SEGMENT_4,
                    FC_SEGMENT_5, FC_SEGMENT_6, FC_SEGMENT_7, FC_SEGMENT_8
                FROM SLR_FAK_COMBINATIONS
                WHERE FC_EPG_ID = ''' || p_epg_id || '''
        )
        SELECT
            AE_EPG_ID,
            AE_GL_ENTITY,
            AE_GL_ACCOUNT,
            AE_ISO_CURRENCY_CODE,
            AE_POSTING_SCHEMA,
            AE_GAAP,
            NVL(AE_DIMENSION_2,''NVS''),
            NVL(AE_DIMENSION_4,''NVS''),
            NVL(AE_DIMENSION_1,''NVS''),
            NVL(AE_DIMENSION_11,''NVS''),
            NVL(AE_DIMENSION_12,''NVS''),
            NVL(AE_DIMENSION_7,''NVS''),
            ''NVS'',
            ''NVS'',
            SEQ_SLR_FAK_COMBO_ID.NEXTVAL
        FROM ROWS_TO_INSERT
    ';
    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    EXECUTE IMMEDIATE lv_sql USING p_business_date;
    COMMIT;
    SLR_ADMIN_PKG.PerfInfo( 'FAKC. FAK combination query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
    SLR_ADMIN_PKG.Info('New FAK combinations inserted');

    lv_sql := '
        INSERT ' || SLR_UTILITIES_PKG.fHint(p_epg_id, 'MERGE_EBA') || ' INTO SLR_EBA_COMBINATIONS
        (
            EC_EPG_ID,
            EC_FAK_ID,
            EC_EBA_ID,
            EC_ATTRIBUTE_1,
            EC_ATTRIBUTE_2,
            EC_ATTRIBUTE_3,
            EC_ATTRIBUTE_4,
            EC_ATTRIBUTE_5
        )
        WITH ROWS_TO_INSERT AS
        (
            SELECT DISTINCT
                AE_EPG_ID,
                FC_FAK_ID,
                AE_DIMENSION_8,
                NVL(AE_DIMENSION_9,''NVS'') AE_DIMENSION_9,
                AE_DIMENSION_14,
                AE_CLIENT_SPARE_ID4
            FROM FR_ACCOUNTING_EVENT
            JOIN SLR_FAK_COMBINATIONS
              ON AE_GL_ACCOUNT = FC_ACCOUNT
                AND AE_ISO_CURRENCY_CODE = FC_CCY
                AND AE_EPG_ID = FC_EPG_ID
                AND AE_GL_ENTITY = FC_ENTITY
                AND AE_POSTING_SCHEMA = FC_SEGMENT_1
                AND AE_GAAP = FC_SEGMENT_2
                AND NVL(AE_DIMENSION_2,''NVS'') = FC_SEGMENT_3
                AND NVL(AE_DIMENSION_4,''NVS'') = FC_SEGMENT_4
                AND NVL(AE_DIMENSION_1,''NVS'') = FC_SEGMENT_5
                AND NVL(AE_DIMENSION_11,''NVS'') = FC_SEGMENT_6
                AND NVL(AE_DIMENSION_12,''NVS'') = FC_SEGMENT_7
                AND NVL(AE_DIMENSION_7,''NVS'') = FC_SEGMENT_8
                AND ''NVS'' = FC_SEGMENT_9
                AND ''NVS'' = FC_SEGMENT_10
            WHERE AE_EPG_ID = ''' || p_epg_id || '''
                AND AE_POSTING_DATE <= :business_date___1
            MINUS
                SELECT
                    EC_EPG_ID,
                    EC_FAK_ID,
                    EC_ATTRIBUTE_1,
                    EC_ATTRIBUTE_2,
                    EC_ATTRIBUTE_3,
                    EC_ATTRIBUTE_4
                FROM SLR_EBA_COMBINATIONS
                WHERE EC_EPG_ID = ''' || p_epg_id || '''
        )
        SELECT
            AE_EPG_ID,
            FC_FAK_ID,
            SEQ_EBA_COMBO_ID.NEXTVAL,
            NVL(AE_DIMENSION_8,''NVS''),
            NVL(AE_DIMENSION_9,''NVS''),
            NVL(AE_DIMENSION_14,''NVS''),
            NVL(AE_CLIENT_SPARE_ID4,''NVS''),
            ''NVS''
        FROM ROWS_TO_INSERT
    ';

    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    EXECUTE IMMEDIATE lv_sql USING p_business_date;
    COMMIT;
    SLR_ADMIN_PKG.PerfInfo( 'EBAC. EBA combination query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
    SLR_ADMIN_PKG.Info('New EBA combinations inserted');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'SLR_FAK/EBA_COMBINATIONS',
            'Error during inserting new combinations to SLR_FAK/EBA_COMBINATIONS',
            p_process_id, p_epg_id);
        SLR_ADMIN_PKG.Error('Error during inserting new combinations to SLR_FAK/EBA_COMBINATIONS');
        RAISE e_internal_processing_error; -- raised to stop processing

END pInsertFakEbaCombinations;

------------------------------------------------------------------


PROCEDURE pUPDATE_SLR_SEGMENT_3(pLPG_ID IN NUMBER, p_no_processed_records OUT NUMBER, p_no_failed_records OUT NUMBER) AS

s_proc_name         VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_3';
v_records_processed NUMBER(18);

BEGIN

    DELETE FROM  slr_fak_segment_3 seg3
          WHERE  seg3.fs3_entity_set IN (SELECT  DISTINCT ent.ent_segment_3_set
                                           FROM  slr.slr_entities ent
                                                 INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                                       AND frlpg.lc_lpg_id = pLPG_ID);

    INSERT INTO slr_fak_segment_3 (
            fs3_entity_set,
            fs3_segment_value,
            fs3_segment_description,
            fs3_status,
            fs3_created_by,
            fs3_created_on,
            fs3_amended_by,
            fs3_amended_on)
   SELECT  seg3.ent_segment_3_set,
            frbk.bo_book_clicode,
            frbk.bo_book_name,
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  fdr.fr_book frbk
            CROSS JOIN (
                    SELECT DISTINCT ent.ent_segment_3_set
                    FROM  slr.slr_entities ent
                    INNER JOIN fdr.fr_lpg_config frlpg
                            ON frlpg.lc_grp_code = ent.ent_entity
                           AND frlpg.lc_lpg_id = pLPG_ID
                        ) seg3;

    SELECT  COUNT(*)
      INTO  v_records_processed
      FROM  slr_fak_segment_3;

    p_no_processed_records := v_records_processed;
    p_no_failed_records := 0;

END pUPDATE_SLR_SEGMENT_3;


PROCEDURE pUPDATE_SLR_SEGMENT_4(pLPG_ID IN NUMBER, p_no_processed_records OUT NUMBER, p_no_failed_records OUT NUMBER) AS

s_proc_name         VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_4';
v_records_processed NUMBER(18);

BEGIN



    DELETE FROM  slr_fak_segment_4 seg4
          WHERE  seg4.fs4_entity_set IN (SELECT  DISTINCT ent.ent_segment_4_set
                                           FROM  slr.slr_entities ent
                                                 INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                                       AND frlpg.lc_lpg_id = pLPG_ID);

    INSERT INTO slr_fak_segment_4 (
            fs4_entity_set,
            fs4_segment_value,
            fs4_segment_description,
            fs4_status,
            fs4_created_by,
            fs4_created_on,
            fs4_amended_by,
            fs4_amended_on)
    SELECT  seg4.ent_segment_4_set,
            pl.pl_party_legal_id,
            pl.pl_int_ext_flag,
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  fdr.fr_party_legal pl
            CROSS JOIN (SELECT  DISTINCT ent.ent_segment_4_set
                          FROM  slr.slr_entities ent
                                INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                  AND frlpg.lc_lpg_id = pLPG_ID) seg4
            WHERE pl.pl_int_ext_flag in ('I','E')
            AND PL.PL_PARTY_LEGAL_ID <> 'NVS'
     ;

    SELECT  COUNT(*)
      INTO  v_records_processed
      FROM  slr_fak_segment_4;

    p_no_processed_records := v_records_processed;
    p_no_failed_records := 0;

END pUPDATE_SLR_SEGMENT_4;


PROCEDURE pUPDATE_SLR_SEGMENT_5(pLPG_ID IN NUMBER, p_no_processed_records OUT NUMBER, p_no_failed_records OUT NUMBER) AS

s_proc_name         VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_5';
v_records_processed NUMBER(18);

BEGIN

       DELETE FROM  slr_fak_segment_5 seg5
          WHERE  seg5.fs5_entity_set IN (SELECT  DISTINCT ent.ent_segment_5_set
                                           FROM  slr.slr_entities ent
                                                 INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                                       AND frlpg.lc_lpg_id = pLPG_ID);

    INSERT INTO slr_fak_segment_5 (
            fs5_entity_set,
            fs5_segment_value,
            fs5_segment_description,
            fs5_status,
            fs5_created_by,
            fs5_created_on,
            fs5_amended_by,
            fs5_amended_on)
    SELECT  seg5.ent_segment_5_set,
            frgc.gc_client_code,
            frgc.gc_client_text2,
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  fdr.fr_general_codes frgc
            CROSS JOIN (SELECT  DISTINCT ent.ent_segment_5_set
                          FROM  slr.slr_entities ent
                                INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                  AND frlpg.lc_lpg_id = pLPG_ID) seg5
            WHERE frgc.gc_gct_code_type_id = 'GL_CHARTFIELD'
     ;

    SELECT  COUNT(*)
      INTO  v_records_processed
      FROM  slr_fak_segment_5;

    p_no_processed_records := v_records_processed;
    p_no_failed_records := 0;

END pUPDATE_SLR_SEGMENT_5;

PROCEDURE pUPDATE_SLR_SEGMENT_6(pLPG_ID IN NUMBER, p_no_processed_records OUT NUMBER, p_no_failed_records OUT NUMBER) AS

s_proc_name         VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_7';
v_records_processed NUMBER(18);

BEGIN

    DELETE FROM  slr_fak_segment_6 seg6
          WHERE  seg6.fs6_entity_set IN (SELECT  DISTINCT ent.ent_segment_6_set
                                           FROM  slr.slr_entities ent
                                                 INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                                       AND frlpg.lc_lpg_id = pLPG_ID);

    INSERT INTO slr_fak_segment_6 (
            fs6_entity_set,
            fs6_segment_value,
            fs6_segment_description,
            fs6_status,
            fs6_created_by,
            fs6_created_on,
            fs6_amended_by,
            fs6_amended_on)
    SELECT DISTINCT
            seg6.ent_segment_6_set,
            et.execution_typ,
            et.execution_typ,
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  stn.execution_type et
            CROSS JOIN (SELECT  DISTINCT ent.ent_segment_6_set
                          FROM  slr.slr_entities ent
                                INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                  AND frlpg.lc_lpg_id = pLPG_ID) seg6;

    SELECT  COUNT(*)
      INTO  v_records_processed
      FROM  slr_fak_segment_6;

    p_no_processed_records := v_records_processed;
    p_no_failed_records := 0;

END pUPDATE_SLR_SEGMENT_6;

PROCEDURE pUPDATE_SLR_SEGMENT_7(pLPG_ID IN NUMBER, p_no_processed_records OUT NUMBER, p_no_failed_records OUT NUMBER) AS

s_proc_name         VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_7';
v_records_processed NUMBER(18);

BEGIN

    DELETE FROM  slr_fak_segment_7 seg7
          WHERE  seg7.fs7_entity_set IN (SELECT  DISTINCT ent.ent_segment_7_set
                                           FROM  slr.slr_entities ent
                                                 INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                                       AND frlpg.lc_lpg_id = pLPG_ID);

    INSERT INTO slr_fak_segment_7 (
            fs7_entity_set,
            fs7_segment_value,
            fs7_segment_description,
            fs7_status,
            fs7_created_by,
            fs7_created_on,
            fs7_amended_by,
            fs7_amended_on)
    SELECT  seg7.ent_segment_7_set,
            bt.business_typ,
            bt.business_typ,
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  stn.business_type bt
            CROSS JOIN (SELECT  DISTINCT ent.ent_segment_7_set
                          FROM  slr.slr_entities ent
                                INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                  AND frlpg.lc_lpg_id = pLPG_ID) seg7 ;

    SELECT  COUNT(*)
      INTO  v_records_processed
      FROM  slr_fak_segment_7;

    p_no_processed_records := v_records_processed;
    p_no_failed_records := 0;

END pUPDATE_SLR_SEGMENT_7;


PROCEDURE pUPDATE_SLR_SEGMENT_8(pLPG_ID IN NUMBER, p_no_processed_records OUT NUMBER, p_no_failed_records OUT NUMBER) AS

s_proc_name         VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_8';
v_records_processed NUMBER(18);

BEGIN

    DELETE FROM  slr_fak_segment_8 seg8
          WHERE  seg8.fs8_entity_set IN (SELECT  DISTINCT ent.ent_segment_8_set
                                           FROM  slr.slr_entities ent
                                                 INNER JOIN fdr.fr_lpg_config frlpg ON frlpg.lc_grp_code = ent.ent_entity
                                                       AND frlpg.lc_lpg_id = pLPG_ID);

    INSERT INTO slr_fak_segment_8 (
            fs8_entity_set,
            fs8_segment_value,
            fs8_segment_description,
            fs8_status,
            fs8_created_by,
            fs8_created_on,
            fs8_amended_by,
            fs8_amended_on)
    SELECT  distinct seg8.ent_segment_8_set,
            ext.iie_cover_signing_party,
            substrb(ext.IIE_COVER_NOTE_DESCRIPTION,0,100) as IIE_COVER_NOTE_DESCRIPTION,
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  fdr.fr_instrument frinstr
            CROSS JOIN (SELECT  DISTINCT ent.ent_segment_8_set
                        FROM  slr.slr_entities ent
                        INNER JOIN fdr.fr_lpg_config frlpg
                          ON frlpg.lc_grp_code = ent.ent_entity
                          AND frlpg.lc_lpg_id = pLPG_ID
                        ) seg8
            INNER JOIN fdr.fr_trade ft
                  ON frinstr.i_instrument_id = ft.t_i_instrument_id
            INNER JOIN fdr.fr_instr_insure_extend ext
                  ON FRINSTR.I_INSTRUMENT_ID = ext.IIE_INSTRUMENT_ID
            WHERE frinstr.i_it_instr_type_id = 'INSURANCE_POLICY';

    SELECT  COUNT(*)
      INTO  v_records_processed
      FROM  slr_fak_segment_8;

    p_no_processed_records := v_records_processed;
    p_no_failed_records := 0;

END pUPDATE_SLR_SEGMENT_8;

-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_CURRENCIES
-- Function:       Insert data into SLR_ENTITY_CURRENCIES
-- Note:           All entities will probably share the same currency but
--                 this can be run per entity in each batch per entity to
--                 ensure it is always up to date
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------

PROCEDURE pUPDATE_SLR_CURRENCIES(pLPG_ID IN NUMBER, o_records_processed OUT NUMBER, o_records_failed OUT NUMBER) AS

s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_CURRENCIES';
lvEntitySet SLR_ENTITIES.ENT_CURRENCY_SET%TYPE;
v_records_processed NUMBER(18);

BEGIN

    SELECT  DISTINCT ent.ent_currency_set
      INTO  lvEntitySet
      FROM  fdr.fr_lpg_config frlpg
            INNER JOIN  slr_entities ent ON frlpg.lc_grp_code = ent.ent_entity
     WHERE  frlpg.lc_lpg_id = pLPG_ID;

    SLR_FDR_PROCEDURES_PKG.PUPDATE_SLR_CURRENCIES(lvEntitySet);

    SELECT  COUNT(*)
      INTO  v_records_processed
      FROM  slr_entity_currencies;

    o_records_processed := v_records_processed;
    o_records_failed := 0;

END pUPDATE_SLR_CURRENCIES;


PROCEDURE pr_fx_rate
        (
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        s_proc_name varchar2(50) := $$plsql_unit || '.' || $$plsql_function ;
    begin
        merge
         into
              slr.slr_entity_rates er
        using (
                  select
                         rs.ent_rate_set              er_entity_set
                       , fx.fr_fxrate_date            er_date
                       , fx.fr_cu_currency_numer_id   er_ccy_from
                       , fx.fr_cu_currency_denom_id   er_ccy_to
                       , fx.fr_fx_rate                er_rate
                       , fx.fr_rty_rate_type_id       er_rate_type
                    from
                                    fdr.fr_fx_rate fx
                         cross join (
                                        select
                                               distinct
                                                        ent_rate_set
                                          from
                                               slr.slr_entities
                                    )
                                    rs
                   where
                         fx.fr_fx_rate is not null
              )
              input
           on (
                      er.er_entity_set = input.er_entity_set
                  and er.er_date       = input.er_date
                  and er.er_ccy_from   = input.er_ccy_from
                  and er.er_ccy_to     = input.er_ccy_to
                  and er.er_rate_type  = input.er_rate_type
              )
        when
              matched then update
                              set
                                  er.er_rate = input.er_rate
        when not
              matched then insert
                           (
                               er_entity_set
                           ,   er_date
                           ,   er_ccy_from
                           ,   er_ccy_to
                           ,   er_rate
                           ,   er_rate_type
                           ,   er_created_by
                           ,   er_created_on
                           ,   er_amended_by
                           ,   er_amended_on
                           )
                           values
                           (
                               input.er_entity_set
                           ,   input.er_date
                           ,   input.er_ccy_from
                           ,   input.er_ccy_to
                           ,   input.er_rate
                           ,   input.er_rate_type
                           ,   user
                           ,   sysdate
                           ,   user
                           ,   sysdate
                           );
        p_no_processed_records := SQL%ROWCOUNT;
        p_no_failed_records := 0;

/*      FX RULE 0 FX RATES      */

        MERGE INTO SLR.SLR_ENTITY_RATES SER
        USING 
        (
        SELECT 
        'FX_RULE0' AS ER_ENTITY_SET,
        B.ER_DATE AS ER_DATE,
        A.ER_CCY_FROM,
        A.ER_CCY_TO,
        A.ER_RATE AS ER_RATE,
        A.ER_CREATED_BY,
        A.ER_CREATED_ON,
        A.ER_AMENDED_BY,
        A.ER_AMENDED_ON,
        'FX_RULE0' AS ER_RATE_TYPE
        FROM SLR.SLR_ENTITY_RATES A
        LEFT JOIN
          SLR.SLR_ENTITY_RATES B
            ON  A.ER_ENTITY_SET = B.ER_ENTITY_SET
            AND LAST_DAY(ADD_MONTHS(A.ER_DATE,-1)) = B.ER_DATE
            AND A.ER_CCY_FROM = B.ER_CCY_FROM
            AND A.ER_CCY_TO = B.ER_CCY_TO
            AND A.ER_RATE_TYPE = B.ER_RATE_TYPE 
        WHERE A.ER_RATE_TYPE = 'SPOT'
        AND   A.ER_DATE = LAST_DAY(A.ER_DATE)
        AND   B.ER_DATE IS NOT NULL
        )QRY
        ON 
        (
            QRY.ER_ENTITY_SET = SER.ER_ENTITY_SET
        AND QRY.ER_DATE = SER.ER_DATE
        AND QRY.ER_CCY_FROM = SER.ER_CCY_FROM
        AND QRY.ER_CCY_TO = SER.ER_CCY_TO
        AND QRY.ER_RATE_TYPE = SER.ER_RATE_TYPE
        )
        WHEN MATCHED THEN UPDATE SET 
        SER.ER_RATE = QRY.ER_RATE,
        SER.ER_AMENDED_BY = 'SLR',
        SER.ER_AMENDED_ON = SYSDATE
        WHEN NOT MATCHED THEN INSERT 
        (
        SER.ER_ENTITY_SET,
        SER.ER_DATE,
        SER.ER_CCY_FROM,
        SER.ER_CCY_TO,
        SER.ER_RATE,
        SER.ER_CREATED_BY,
        SER.ER_CREATED_ON,
        SER.ER_AMENDED_BY,
        SER.ER_AMENDED_ON,
        SER.ER_RATE_TYPE
        )
        VALUES 
        (
        QRY.ER_ENTITY_SET,
        QRY.ER_DATE,
        QRY.ER_CCY_FROM,
        QRY.ER_CCY_TO,
        QRY.ER_RATE,
        QRY.ER_CREATED_BY,
        QRY.ER_CREATED_ON,
        'SLR',
        SYSDATE,
        QRY.ER_RATE_TYPE
        )
        ;

/*      FX RULE 1 FX RATES      */

        MERGE INTO SLR.SLR_ENTITY_RATES SER
        USING 
        (
        SELECT 
        'FX_RULE1' AS ER_ENTITY_SET,
        ER_DATE,
        ER_CCY_FROM,
        ER_CCY_TO,
        ER_RATE,
        ER_CREATED_BY,
        ER_CREATED_ON,
        ER_AMENDED_BY,
        ER_AMENDED_ON,
        'FX_RULE1' AS ER_RATE_TYPE
        FROM SLR_ENTITY_RATES 
        WHERE ER_RATE_TYPE = 'MAVG'
        AND ER_ENTITY_SET = 'ENT_RATE_SET'
        AND ER_DATE = LAST_DAY(ER_DATE)
        )QRY
        ON 
        (
            QRY.ER_ENTITY_SET = SER.ER_ENTITY_SET
        AND QRY.ER_DATE = SER.ER_DATE
        AND QRY.ER_CCY_FROM = SER.ER_CCY_FROM
        AND QRY.ER_CCY_TO = SER.ER_CCY_TO
        AND QRY.ER_RATE_TYPE = SER.ER_RATE_TYPE
        )
        WHEN MATCHED THEN UPDATE SET 
        SER.ER_RATE = QRY.ER_RATE,
        SER.ER_AMENDED_BY = 'SLR',
        SER.ER_AMENDED_ON = SYSDATE
        WHEN NOT MATCHED THEN INSERT 
        (
        SER.ER_ENTITY_SET,
        SER.ER_DATE,
        SER.ER_CCY_FROM,
        SER.ER_CCY_TO,
        SER.ER_RATE,
        SER.ER_CREATED_BY,
        SER.ER_CREATED_ON,
        SER.ER_AMENDED_BY,
        SER.ER_AMENDED_ON,
        SER.ER_RATE_TYPE
        )
        VALUES 
        (
        QRY.ER_ENTITY_SET,
        QRY.ER_DATE,
        QRY.ER_CCY_FROM,
        QRY.ER_CCY_TO,
        QRY.ER_RATE,
        QRY.ER_CREATED_BY,
        QRY.ER_CREATED_ON,
        'SLR',
        SYSDATE,
        QRY.ER_RATE_TYPE
        )
        ;

/*      FX RULE 2 FX RATES      */

        MERGE INTO SLR.SLR_ENTITY_RATES SER
        USING 
        (
        SELECT 
        'FX_RULE2' AS ER_ENTITY_SET,
        ER_DATE,
        ER_CCY_FROM,
        ER_CCY_TO,
        ER_RATE,
        ER_CREATED_BY,
        ER_CREATED_ON,
        ER_AMENDED_BY,
        ER_AMENDED_ON,
        'FX_RULE2' AS ER_RATE_TYPE
        FROM SLR_ENTITY_RATES 
        WHERE ER_RATE_TYPE = 'SPOT'
        AND ER_ENTITY_SET = 'ENT_RATE_SET'
        AND ER_DATE = LAST_DAY(ER_DATE)
        )QRY
        ON 
        (
            QRY.ER_ENTITY_SET = SER.ER_ENTITY_SET
        AND QRY.ER_DATE = SER.ER_DATE
        AND QRY.ER_CCY_FROM = SER.ER_CCY_FROM
        AND QRY.ER_CCY_TO = SER.ER_CCY_TO
        AND QRY.ER_RATE_TYPE = SER.ER_RATE_TYPE
        )
        WHEN MATCHED THEN UPDATE SET 
        SER.ER_RATE = QRY.ER_RATE,
        SER.ER_AMENDED_BY = 'SLR',
        SER.ER_AMENDED_ON = SYSDATE
        WHEN NOT MATCHED THEN INSERT 
        (
        SER.ER_ENTITY_SET,
        SER.ER_DATE,
        SER.ER_CCY_FROM,
        SER.ER_CCY_TO,
        SER.ER_RATE,
        SER.ER_CREATED_BY,
        SER.ER_CREATED_ON,
        SER.ER_AMENDED_BY,
        SER.ER_AMENDED_ON,
        SER.ER_RATE_TYPE
        )
        VALUES 
        (
        QRY.ER_ENTITY_SET,
        QRY.ER_DATE,
        QRY.ER_CCY_FROM,
        QRY.ER_CCY_TO,
        QRY.ER_RATE,
        QRY.ER_CREATED_BY,
        QRY.ER_CREATED_ON,
        'SLR',
        SYSDATE,
        QRY.ER_RATE_TYPE
        );
        
    end pr_fx_rate;

PROCEDURE pr_account
        (
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        s_proc_name varchar2(50) := $$plsql_unit || '.' || $$plsql_function ;
    begin
        merge
         into
              slr.slr_entity_accounts ea
        using (
                  select
                         eas.ent_accounts_set            ea_entity_set
                       , ga.ga_account_code              ea_account
                       , nvl(ga.ga_account_type, 'X')    ea_account_type
                       , ga.ga_account_type_flag         ea_account_type_flag
                       , ga.ga_position_flag             ea_position_flag
                       , ga.ga_revaluation_ind           ea_revaluation_flag
                       , nvl(ga.ga_account_name, 'NVS')  ea_description
                       , ga.ga_active                    ea_status
                       , ga.ga_valid_from                ea_eff_from
                       , ga.ga_valid_to                  ea_eff_to
                    from
                                    fdr.fr_gl_account ga
                         cross join (
                                        select
                                               distinct
                                                        ent_accounts_set
                                          from
                                               slr.slr_entities
                                    )
                                    eas
                   where ga.ga_account_code <> NVL(ga.ga_client_text4,0)     /* only include sub-accounts */
              )
              input
           on (
                      ea.ea_entity_set   = input.ea_entity_set
                  and ea.ea_account      = input.ea_account
              )
        when
              matched then update
                              set
                                  ea.ea_account_type      = input.ea_account_type
                              ,   ea.ea_account_type_flag = input.ea_account_type_flag
                              ,   ea.ea_position_flag     = input.ea_position_flag
                              ,   ea.ea_revaluation_flag  = input.ea_revaluation_flag
                              ,   ea.ea_description       = input.ea_description
                              ,   ea.ea_status            = input.ea_status
                              ,   ea.ea_eff_from          = input.ea_eff_from
                              ,   ea.ea_eff_to            = input.ea_eff_to
        when not
              matched then insert
                           (
                               ea_entity_set
                           ,   ea_account
                           ,   ea_account_type
                           ,   ea_account_type_flag
                           ,   ea_position_flag
                           ,   ea_revaluation_flag
                           ,   ea_description
                           ,   ea_status
                           ,   ea_eff_from
                           ,   ea_eff_to
                           ,   ea_created_by
                           ,   ea_created_on
                           ,   ea_amended_by
                           ,   ea_amended_on
                           )
                           values
                           (
                               input.ea_entity_set
                           ,   input.ea_account
                           ,   input.ea_account_type
                           ,   input.ea_account_type_flag
                           ,   input.ea_position_flag
                           ,   input.ea_revaluation_flag
                           ,   input.ea_description
                           ,   input.ea_status
                           ,   input.ea_eff_from
                           ,   input.ea_eff_to
                           ,   user
                           ,   sysdate
                           ,   user
                           ,   sysdate
                           );
        p_no_processed_records := SQL%ROWCOUNT;
        p_no_failed_records := 0;
    end pr_account;
-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_ENTITY_RATES
-- Function:       Insert data into SLR_ENTITY_ENTITY_RATES
-- Note:           This defaults the required rate type to CLOSING
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_ENTITY_RATES(p_entity IN VARCHAR2,
                                   p_business_date in DATE DEFAULT NULL) AS

s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_ENTITY_RATES';
lvBusinessDate DATE;

BEGIN

    SELECT ENT_BUSINESS_DATE
    INTO   lvBusinessDate
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    lvBusinessDate := NVL(p_business_date, lvBusinessDate);

    SLR_FDR_PROCEDURES_PKG.PUPDATE_SLR_ENTITY_RATES(p_entity, lvBusinessDate, 'SPOT');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert entity rates, invalid entity supplied: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
  WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert entity rates: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_RATES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_SLR_ENTITY_RATES: ' || SQLERRM);

END pUPDATE_SLR_ENTITY_RATES;

-- -----------------------------------------------------------------------
-- Procedure:       pREC_AET_JRNLS
-- Function:        Reconciliation of journals between FDR and SLR.
-- Note:
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pREC_AET_JRNLS (p_epg_id IN VARCHAR2,
                            p_entity IN VARCHAR2 DEFAULT NULL,
                            p_date_from IN DATE DEFAULT NULL,
                            p_date_to IN DATE DEFAULT NULL) AS

    s_proc_name       VARCHAR2(50) := 'SLR_CLIENT_PROCEDURES_PKG.pREC_AET_JRNLS';
    e_epg_id_is_null      EXCEPTION;
    e_epg_not_exists      EXCEPTION;
    e_entity_not_in_epg   EXCEPTION;
    e_wrong_dates            EXCEPTION;
    v_count               NUMBER(1);

BEGIN

    IF p_epg_id IS NULL THEN
        raise e_epg_id_is_null;
    END IF;

    IF p_epg_id IS NOT NULL AND p_entity IS NULL THEN

        SELECT count(*) into v_count
        FROM SLR_ENTITY_PROC_GROUP
        WHERE EPG_ID=p_epg_id;

        IF v_count = 0 THEN
            raise e_epg_not_exists;
        END IF;

    ELSIF p_epg_id IS NOT NULL AND p_entity IS NOT NULL THEN

        SELECT count(*) into v_count
        FROM SLR_ENTITY_PROC_GROUP
        WHERE EPG_ID=p_epg_id
        AND EPG_ENTITY=p_entity;

        IF v_count = 0 THEN
            raise e_entity_not_in_epg;
        END IF;

    END IF;

    DELETE FROM SLR_AET_JOURNAL_REC WHERE SAJR_GL_ENTITY = p_entity;

    INSERT INTO SLR_AET_JOURNAL_REC (
        SAJR_JOURNAL_ID,
        SAJR_GL_ENTITY,
        SAJR_GL_ACCOUNT,
        SAJR_SEGMENT_1,
        SAJR_SEGMENT_2,
        SAJR_SEGMENT_3,
        SAJR_SEGMENT_4,
        SAJR_SEGMENT_5,
        SAJR_SEGMENT_6,
        SAJR_ATTRIBUTE_1,
        SAJR_ATTRIBUTE_2,
        SAJR_ATTRIBUTE_3,
        SAJR_ATTRIBUTE_4,
        SAJR_ISO_CURRENCY_CODE,
        SAJR_AE_AMOUNT)
     SELECT
        SEQ_SLR_SAJR_JOURNAL_ID.NEXTVAL,
        A.*
     FROM
        (SELECT
            AE_GL_ENTITY                       AE_GL_ENTITY,
            AE_GL_ACCOUNT                      AE_GL_ACCOUNT,
            AE_POSTING_SCHEMA                  AE_POSTING_SCHEMA,
            AE_GAAP                            AE_GAAP,
            AE_GL_BOOK                         AE_GL_BOOK,
            Nvl(AE_GL_INSTR_SUPER_CLASS,'NVS') AE_GL_INSTR_SUPER_CLASS,
            Nvl(AE_GL_INSTRUMENT_ID,'NVS')     AE_GL_INSTRUMENT_ID,
            Nvl(AE_GL_PARTY_BUSINESS_ID,'NVS') AE_GL_PARTY_BUSINESS_ID,
            Nvl(AE_FDR_TRAN_NO,'NVS')          AE_FDR_TRAN_NO,
            AE_SOURCE_SYSTEM                   AE_SOURCE_SYSTEM,
            Nvl(AE_GL_PERSON_ID,'NVS')         AE_GL_PERSON_ID,
            'NVS'                              STRATEGY,
            AE_ISO_CURRENCY_CODE               AE_ISO_CURRENCY_CODE,
            sum(ROUND(AE_AMOUNT,3))            AE_AMOUNT
        FROM
            FR_ACCOUNTING_EVENT_IMP
        WHERE
            AE_EPG_ID = p_epg_id
            AND AE_SUB_LEDGER_UPD = 'Y'
            AND AE_GL_ENTITY = NVL(p_entity, ae_gl_entity)
            AND AE_POSTING_DATE BETWEEN NVL(p_date_from, AE_POSTING_DATE) AND NVL(p_date_to, AE_POSTING_DATE)
        GROUP BY
            AE_GL_ENTITY,
            AE_POSTING_SCHEMA,
            AE_GAAP,
            AE_GL_ACCOUNT,
            AE_GL_BOOK,
            Nvl(AE_GL_INSTR_SUPER_CLASS,'NVS'),
            Nvl(AE_GL_INSTRUMENT_ID,'NVS'),
            Nvl(AE_GL_PARTY_BUSINESS_ID,'NVS'),
            Nvl(AE_FDR_TRAN_NO,'NVS'),
            AE_SOURCE_SYSTEM,
            Nvl(AE_GL_PERSON_ID,'NVS'),
            'NVS',
            AE_ISO_CURRENCY_CODE) A;

    MERGE INTO SLR_AET_JOURNAL_REC
    USING (SELECT
               JL_ENTITY,
               JL_ACCOUNT,
               JL_SEGMENT_1,
               JL_SEGMENT_2,
               JL_SEGMENT_3,
               JL_SEGMENT_4,
               JL_SEGMENT_5,
               JL_SEGMENT_6,
               JL_ATTRIBUTE_1,
               JL_ATTRIBUTE_2,
               JL_ATTRIBUTE_3,
               JL_ATTRIBUTE_4,
               JL_TRAN_CCY,
               SUM(ROUND(JL_TRAN_AMOUNT,3)) as SUM_JL_TRAN_AMOUNT
           FROM (SELECT
                     JLU_ENTITY      as JL_ENTITY,
                     JLU_ACCOUNT     as JL_ACCOUNT,
                     JLU_SEGMENT_1   as JL_SEGMENT_1,
                     JLU_SEGMENT_2   as JL_SEGMENT_2,
                     JLU_SEGMENT_3   as JL_SEGMENT_3,
                     JLU_SEGMENT_4   as JL_SEGMENT_4,
                     JLU_SEGMENT_5   as JL_SEGMENT_5,
                     JLU_SEGMENT_6   as JL_SEGMENT_6,
                     JLU_ATTRIBUTE_1 as JL_ATTRIBUTE_1,
                     JLU_ATTRIBUTE_2 as JL_ATTRIBUTE_2,
                     JLU_ATTRIBUTE_3 as JL_ATTRIBUTE_3,
                     JLU_ATTRIBUTE_4 as JL_ATTRIBUTE_4,
                     JLU_TRAN_CCY    as JL_TRAN_CCY,
                     JLU_TRAN_AMOUNT as JL_TRAN_AMOUNT
                 FROM
                     SLR_JRNL_LINES_UNPOSTED
                 WHERE
                    JLU_EPG_ID = p_epg_id
                    AND JLU_ATTRIBUTE_2 NOT LIKE 'MADJ%'  --exclude MADJ
                    AND JLU_ENTITY = NVL(p_entity, JLU_ENTITY)
                    AND JLU_EFFECTIVE_DATE BETWEEN NVL(p_date_from, JLU_EFFECTIVE_DATE) AND NVL(p_date_to, JLU_EFFECTIVE_DATE)
         UNION ALL
         SELECT
                     JL_ENTITY,
                     JL_ACCOUNT,
                     JL_SEGMENT_1,
                     JL_SEGMENT_2,
                     JL_SEGMENT_3,
                     JL_SEGMENT_4,
                     JL_SEGMENT_5,
                     JL_SEGMENT_6,
                     JL_ATTRIBUTE_1,
                     JL_ATTRIBUTE_2,
                     JL_ATTRIBUTE_3,
                     JL_ATTRIBUTE_4,
                     JL_TRAN_CCY,
                     JL_TRAN_AMOUNT
                 FROM
                     SLR_JRNL_LINES
                 WHERE
                     JL_EPG_ID = p_epg_id
                     AND JL_ATTRIBUTE_2 NOT LIKE 'MADJ%'
                     AND JL_ENTITY = NVL(p_entity, JL_ENTITY)
                     AND JL_EFFECTIVE_DATE BETWEEN NVL(p_date_from, JL_EFFECTIVE_DATE) AND NVL(p_date_to, JL_EFFECTIVE_DATE))  --exclude MADJ
                 GROUP BY
                     JL_ENTITY,
                     JL_ACCOUNT,
                     JL_SEGMENT_1,
                     JL_SEGMENT_2,
                     JL_SEGMENT_3,
                     JL_SEGMENT_4,
                     JL_SEGMENT_5,
                     JL_SEGMENT_6,
                     JL_ATTRIBUTE_1,
                     JL_ATTRIBUTE_2,
                     JL_ATTRIBUTE_3,
                     JL_ATTRIBUTE_4,
                     JL_TRAN_CCY) JRNLS
          ON (SAJR_GL_ENTITY            = JRNLS.JL_ENTITY
          AND SAJR_GL_ACCOUNT           = JRNLS.JL_ACCOUNT
          AND SAJR_SEGMENT_1            = JRNLS.JL_SEGMENT_1
          AND SAJR_SEGMENT_2            = JRNLS.JL_SEGMENT_2
          AND SAJR_SEGMENT_3            = JRNLS.JL_SEGMENT_3
          AND SAJR_SEGMENT_4            = JRNLS.JL_SEGMENT_4
          AND SAJR_SEGMENT_5            = JRNLS.JL_SEGMENT_5
          AND SAJR_SEGMENT_6            = JRNLS.JL_SEGMENT_6
          AND SAJR_ATTRIBUTE_1          = JRNLS.JL_ATTRIBUTE_1
          AND SAJR_ATTRIBUTE_2          = JRNLS.JL_ATTRIBUTE_2
          AND SAJR_ATTRIBUTE_3          = JRNLS.JL_ATTRIBUTE_3
          AND SAJR_ATTRIBUTE_4          = JRNLS.JL_ATTRIBUTE_4
          AND SAJR_ISO_CURRENCY_CODE    = JRNLS.JL_TRAN_CCY)
    WHEN MATCHED THEN
    UPDATE SET
        SAJR_JRNL_AMOUNT = SUM_JL_TRAN_AMOUNT,
        SAJR_RECONCILED  = decode(SAJR_AE_AMOUNT, SUM_JL_TRAN_AMOUNT, 'Y','N')
    WHEN NOT MATCHED THEN
    INSERT (
        SAJR_JOURNAL_ID,
        SAJR_GL_ENTITY,
        SAJR_GL_ACCOUNT,
        SAJR_SEGMENT_1,
        SAJR_SEGMENT_2,
        SAJR_SEGMENT_3,
        SAJR_SEGMENT_4,
        SAJR_SEGMENT_5,
        SAJR_SEGMENT_6,
        SAJR_ATTRIBUTE_1,
        SAJR_ATTRIBUTE_2,
        SAJR_ATTRIBUTE_3,
        SAJR_ATTRIBUTE_4,
        SAJR_ISO_CURRENCY_CODE,
        SAJR_JRNL_AMOUNT,
        SAJR_RECONCILED)
    VALUES (
        SEQ_SLR_SAJR_JOURNAL_ID.NEXTVAL,
        JL_ENTITY,
        JL_ACCOUNT,
        JL_SEGMENT_1,
        JL_SEGMENT_2,
        JL_SEGMENT_3,
        JL_SEGMENT_4,
        JL_SEGMENT_5,
        JL_SEGMENT_6,
        JL_ATTRIBUTE_1,
        JL_ATTRIBUTE_2,
        JL_ATTRIBUTE_3,
        JL_ATTRIBUTE_4,
        JL_TRAN_CCY,
        SUM_JL_TRAN_AMOUNT,
        'N');

  COMMIT;

EXCEPTION
    WHEN e_epg_id_is_null THEN
        gv_msg := 'EPG_ID must be given.';
        pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, 'FR_ACCOUNTING_EVENT', null, 'p_epg_id', gs_stage, 'PL/SQL', SQLCODE);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, gv_msg);

    WHEN e_epg_not_exists THEN
        gv_msg := 'Entity Processing Group '||p_epg_id||' doesn''t exist.';
        pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, 'FR_ACCOUNTING_EVENT', null, 'p_epg_id', gs_stage, 'PL/SQL', SQLCODE);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, gv_msg);

    WHEN e_entity_not_in_epg THEN
        gv_msg := 'Entity '||p_entity||' is not in given Entity Processing Group: '||p_epg_id||' ';
        pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, 'FR_ACCOUNTING_EVENT', null, 'p_entity', gs_stage, 'PL/SQL', SQLCODE);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, gv_msg);

    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to reconcile journals: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'FR_ACCOUNTING_EVENT', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pREC_AET_JRNLS: ' || SQLERRM);

END pREC_AET_JRNLS;

-- -----------------------------------------------------------------------
-- Procedure:       pSLR_INTERNAL_REC
-- Function:        Calls internal SLR recs for the supplied entity
-- Note:
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pSLR_INTERNAL_REC (p_epg_id IN VARCHAR2,
                            p_entity IN VARCHAR2 DEFAULT NULL,
                            p_date_from IN DATE DEFAULT NULL,
                            p_date_to IN DATE DEFAULT NULL) AS

    s_proc_name         VARCHAR2(50) := 'SLR_CLIENT_PROCEDURES_PKG.pSLR_INTERNAL_REC';
    lvBusinessDate      DATE;
    lvPriorBusinessDate DATE;
    lv_entity SLR_ENTITIES.ENT_ENTITY%TYPE;
BEGIN

    IF p_date_from IS NULL AND p_date_to IS NULL THEN
        SELECT EPG_ENTITY INTO lv_entity
        FROM SLR_ENTITY_PROC_GROUP
        WHERE EPG_ID = p_epg_id
            AND ROWNUM = 1;

        SELECT GP_TODAYS_BUS_DATE, GP_YESTERDAY_BUS_DATE
        INTO lvBusinessDate, lvPriorBusinessDate
        FROM FR_GLOBAL_PARAMETER
        LEFT OUTER JOIN FR_LPG_CONFIG
            ON NVL(LC_LPG_ID, 1) = LPG_ID
        WHERE NVL(LC_GRP_CODE, lv_entity) = lv_entity
            AND LC_LPG_ID = LPG_ID;
    ELSIF p_date_from IS NOT NULL AND p_date_to IS NOT NULL THEN
        lvPriorBusinessDate := p_date_from;
        lvBusinessDate := p_date_to;
    END IF;

    pREC_AET_JRNLS(p_epg_id, p_entity, p_date_from, p_date_to);

    SLR_RECONCILIATION_PKG.pReconcileAccountsMovement(p_epg_id, p_entity, lvPriorBusinessDate, lvBusinessDate);



EXCEPTION
    WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to run reconciliation, invalid EPG_ID supplied: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_PROC_GROUP', null, 'EPG_ID', gs_stage, 'PL/SQL', SQLCODE);
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to run reconciliation: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITIES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pSLR_INTERNAL_REC: ' || SQLERRM);

END pSLR_INTERNAL_REC;

-- -----------------------------------------------------------------------
-- Procedure:       pROLL_ENTITY_DATE
-- Function:        Rolls dates as specified for the specified entity
-- Note:
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pROLL_ENTITY_DATE(p_entity in VARCHAR2, p_business_date in DATE DEFAULT NULL, p_update_end_date in CHAR DEFAULT 'Y') AS

    s_proc_name      VARCHAR2(50) := 'SLR_CLIENT_PROCEDURES_PKG.pROLL_ENTITY_DATE ';
    lvBusinessDate   DATE;

    lvCurrYearFirstBusDate    DATE;
    lvCleardownYearEndDate    DATE;
    lvBusinessYear            NUMBER(4,0);
    e_raise_exception         EXCEPTION;

BEGIN

    BEGIN
        IF p_business_date IS NULL THEN
            SELECT GP_TODAYS_BUS_DATE
            INTO   lvBusinessDate
            FROM   FR_GLOBAL_PARAMETER,
                   FR_LPG_CONFIG
            WHERE  LC_GRP_CODE = p_entity
            AND    LC_LPG_ID   = LPG_ID;
        ELSE
            lvBusinessDate := p_business_date;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            pr_error(slr_global_pkg.C_MAJERR, 'Failure to roll entity dates, unable to get business date: '
                     ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITIES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
            RAISE e_raise_exception;
    END;

    SLR_CALENDAR_PKG.pSetEntityBusinessDate(p_entity, lvBusinessDate);

    begin
    /* open closed periods */
    update
           slr.slr_entity_periods ep
       set
           ep.ep_status = 'O'
     where
           ep.ep_entity    = p_entity
       and ep.ep_bus_year >= 2017
       and ep.ep_status    = 'C'
       and exists ( select
                           null
                      from 
                           fdr.fr_general_lookup fgl
                     where
                           fgl.lk_lkt_lookup_type_code  = 'EVENT_CLASS_PERIOD'
                       and to_number(fgl.lk_match_key2) = ep.ep_bus_year
                       and to_number(fgl.lk_match_key3) = ep.ep_bus_period
                       and ( case
                                  when fgl.lk_lookup_value1 <> 'C'
                                  then 1
                                  else 0
                              end ) > 0
                  group by 
                           fgl.lk_match_key2
                         , fgl.lk_match_key3 ) ;
    /* close open periods */
    update
           slr.slr_entity_periods ep
       set
           ep.ep_status = 'C'
     where
           ep.ep_entity    = p_entity
       and ep.ep_bus_year >= 2017
       and ep.ep_status    = 'O'
       and not exists ( select
                           null
                      from 
                           fdr.fr_general_lookup fgl
                     where
                           fgl.lk_lkt_lookup_type_code  = 'EVENT_CLASS_PERIOD'
                       and to_number(fgl.lk_match_key2) = ep.ep_bus_year
                       and to_number(fgl.lk_match_key3) = ep.ep_bus_period
                       and ( case
                                  when fgl.lk_lookup_value1 <> 'C'
                                  then 1
                                  else 0
                              end ) > 0
                  group by 
                           fgl.lk_match_key2
                         , fgl.lk_match_key3 ) ;
    end;
    --find business year
    BEGIN
       SELECT EP_BUS_YEAR
            INTO lvBusinessYear
            FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = p_entity
            AND lvBusinessDate BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
            AND EP_PERIOD_TYPE != 0;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            pr_error(slr_global_pkg.C_MAJERR, 'Failure to roll entity dates, business year not defined: '
                     ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITIES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
            RAISE e_raise_exception;
    END;

    BEGIN
        --find final period end for a given business year (CleardownYearEndDate)
        SELECT EP_BUS_PERIOD_END
            INTO lvCleardownYearEndDate
            FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = p_entity
            AND EP_BUS_YEAR = lvBusinessYear
            AND EP_PERIOD_TYPE = 2;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            pr_error(slr_global_pkg.C_MAJERR, 'Failure to roll entity dates, no final period defined for a business year: '
                     ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITIES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
            RAISE e_raise_exception;
    END;

    BEGIN
        --find the begininig of a given business year (CurrYearFirstBusDate)
        SELECT min(EP_CAL_PERIOD_START)
            INTO lvCurrYearFirstBusDate
            FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = p_entity
            AND EP_BUS_YEAR = lvBusinessYear;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            pr_error(slr_global_pkg.C_MAJERR, 'Failure to roll entity dates, unable to get business date or no final period defined for a business year.'
                     ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITIES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
            RAISE e_raise_exception;
    END;
    /*IF TO_CHAR(lvBusinessDate,'MM') in ('11','12') THEN
        lvCurrYearFirstBusDate := TO_DATE('01-NOV-' || TO_CHAR(lvBusinessDate,'YYYY'),'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH');
        lvCleardownYearEndDate := TO_DATE('31-OCT-' || TO_CHAR(TO_NUMBER(TO_CHAR(lvBusinessDate,'YYYY'))+1),'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH');
    ELSE
        lvCurrYearFirstBusDate := TO_DATE('01-NOV-' || TO_CHAR(TO_NUMBER(TO_CHAR(lvBusinessDate,'YYYY'))-1),'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH');
        lvCleardownYearEndDate := TO_DATE('31-OCT-' || TO_CHAR(lvBusinessDate,'YYYY'),'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH');
    END IF;*/

    --also set these two fields as they are not set by core package as they depend on configuration
    IF UPPER(p_update_end_date) =  'Y' THEN
    SLR_CALENDAR_PKG.pSetCleardownYearEndDate(p_entity, lvCleardownYearEndDate);
    END IF;
   --SLR_CALENDAR_PKG.pSetCurrYearFirstBusDate(p_entity, lvCurrYearFirstBusDate);

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to roll entity dates, more than one final period declared for business year: '
                 ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_PERIODS', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
    WHEN e_raise_exception THEN
        null;
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to roll entity dates: '
                 ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITIES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pROLL_ENTITY_DATE: ' || SQLERRM);

END pROLL_ENTITY_DATE;

-- -----------------------------------------------------------------------
-- Procedure:       pCHECK_JRNL_ERRORS
-- Function:        Checks for unposted journals
-- Note:
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pCHECK_JRNL_ERRORS(p_entity in VARCHAR2) IS
  v_count        NUMBER := 0;
  s_proc_name    VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pCHECK_JRNL_ERRORS';

  e_jrnl_errors  EXCEPTION;

BEGIN

    SELECT COUNT(1)
    INTO   v_count
    FROM   slr_jrnl_headers_unposted hdr, slr_entities ent
    WHERE  hdr.JHU_JRNL_ENTITY = ent.ENT_ENTITY
    AND    hdr.JHU_JRNL_STATUS in ('E','V','U')
    AND    hdr.JHU_JRNL_TYPE   not like 'MADJ%'
    AND    hdr.JHU_JRNL_DATE   >= ent.ENT_BUSINESS_DATE
    AND    ent.ENT_ENTITY      = p_entity;

  -- If entries exist, then raise unhandled exception.
  IF v_count > 0 THEN
    -- Log to log table
    pr_error(slr_global_pkg.C_MAJERR, 'Error: There are ' || v_count || ' unposted journal headers',
                            slr_global_pkg.C_SLRFUNC, s_proc_name, 'SLR_JRNL_HEADERS_UNPOSTED', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);

    RAISE e_jrnl_errors;

  END IF;

END pCHECK_JRNL_ERRORS;

-- -----------------------------------------------------------------------
-- Procedure:       pUPDATE_NON_WORKING_DAYS
-- Function:        Update SLR Entity Days and SLR Entity Periods so that
--                  any changes to working days in the FDR are taken into account
-- Note:            If a working day was set to be a bank holiday after it
--                  already has journals posted to it then this would still close
--                  the day so no journals would be allowed on it
--
-- BJP 22-AUG-2007  Initial version
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_NON_WORKING_DAYS
(
    p_entity in VARCHAR2
)
AS

    s_proc_name       VARCHAR2(50) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_NON_WORKING_DAYS';
    lvTableName       VARCHAR2(30);
    lvEntitySet       SLR_ENTITIES.ENT_PERIODS_AND_DAYS_SET%TYPE;

BEGIN

    lvTableName := 'SLR_ENTITIES';

    SELECT ENT_PERIODS_AND_DAYS_SET
    INTO   lvEntitySet
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    lvTableName := 'SLR_ENTITY_DAYS';

    --Close days marked as Open that have a bank holiday defined in the FDR
    UPDATE
        slr_entity_days ed1
    SET
        ed_status = 'C'
    WHERE EXISTS (
        SELECT 1
        FROM
            slr_entity_days ed2 inner join fr_party_legal
            ON  ed_entity_set     = lvEntitySet
            AND pl_party_legal_id = p_entity
            AND ed_status         = 'O'
                INNER JOIN fr_country
                ON pl_co_country_resid_id = co_country_id
                    INNER JOIN fr_calendar
                    ON co_ca_calendar_name = ca_calendar_name
                        INNER JOIN fr_holiday_date
                        ON  hd_ca_calendar_name = ca_calendar_name
                        AND ed_date             = hd_holiday_date
                        AND HD_ACTIVE = 'A'
        WHERE
            ed1.ed_entity_set = ed2.ed_entity_set
        AND ed1.ed_date    = ed2.ed_date);

    --Re-open days marked as Closed that do not have a bank holiday defined in the FDR
    UPDATE
        slr_entity_days ed1
    SET
        ed_status = 'O'
    WHERE EXISTS (
        SELECT 1
        FROM
            slr_entity_days ed2 inner join fr_party_legal
            ON  ed_entity_set          = lvEntitySet
            AND ed_status              = 'C'
           -- AND to_char(ed_date,'DY')  NOT IN ('SAT','SUN')
            AND pl_party_legal_id      = p_entity
                INNER JOIN fr_country
                ON pl_co_country_resid_id = co_country_id
                  INNER JOIN fr_calendar
                   ON co_ca_calendar_name = ca_calendar_name
                  AND CASE
                   WHEN UPPER(to_char(ed_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')) =  'MON' THEN
                        ( SELECT MAX(CAW_MONDAY) FROM FDR.FR_CALENDAR_WEEK WHERE CAW_CA_CALENDAR_NAME = co_ca_calendar_name)
                   WHEN UPPER(to_char(ed_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')) =  'TUE' THEN
                        ( SELECT MAX(CAW_TUESDAY) FROM FDR.FR_CALENDAR_WEEK WHERE CAW_CA_CALENDAR_NAME = co_ca_calendar_name)
                   WHEN UPPER(to_char(ed_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')) =  'WED' THEN
                        ( SELECT MAX(CAW_WEDNESDAY) FROM FDR.FR_CALENDAR_WEEK WHERE CAW_CA_CALENDAR_NAME = co_ca_calendar_name)
                   WHEN UPPER(to_char(ed_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')) =  'THU' THEN
                        ( SELECT MAX(CAW_THURSDAY) FROM FDR.FR_CALENDAR_WEEK WHERE CAW_CA_CALENDAR_NAME = co_ca_calendar_name)
                   WHEN UPPER(to_char(ed_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')) =  'FRI' THEN
                        ( SELECT MAX(CAW_FRIDAY) FROM FDR.FR_CALENDAR_WEEK WHERE CAW_CA_CALENDAR_NAME = co_ca_calendar_name)
                   WHEN UPPER(to_char(ed_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')) =  'SAT' THEN
                        ( SELECT MAX(CAW_SATURDAY)FROM FDR.FR_CALENDAR_WEEK WHERE CAW_CA_CALENDAR_NAME = co_ca_calendar_name)
                   WHEN UPPER(to_char(ed_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')) =  'SUN' THEN
                        ( SELECT MAX(CAW_SUNDAY) FROM FDR.FR_CALENDAR_WEEK WHERE CAW_CA_CALENDAR_NAME = co_ca_calendar_name)
                  END = 1
                       LEFT OUTER JOIN fr_holiday_date
                       ON  ca_calendar_name = hd_ca_calendar_name
                       AND ed_date          = hd_holiday_date
                       AND HD_ACTIVE = 'A'
        WHERE
            hd_ca_calendar_name IS NULL
        AND ed1.ed_entity_set = ed2.ed_entity_set
        AND ed1.ed_date    = ed2.ed_date);

    lvTableName := 'SLR_ENTITY_PERIODS';

    --Update first and last business date on all open periods
    UPDATE
        slr_entity_periods
    SET
        (EP_BUS_PERIOD_START, EP_BUS_PERIOD_END) = (
            SELECT
                MIN(ED_DATE),
                MAX(ED_DATE)
            FROM
                slr_entity_days
            WHERE
                ED_ENTITY_SET           = lvEntitySet
            AND ED_STATUS               = 'O'
            AND ED_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END)
    WHERE
        EP_ENTITY       = p_entity
    AND EP_STATUS       = 'O'
    AND EP_PERIOD_TYPE != 0
    AND (EP_BUS_PERIOD_START != (SELECT MIN(ED_DATE)
                                 FROM   SLR_ENTITY_DAYS
                                 WHERE  ED_ENTITY_SET           = lvEntitySet
                                 AND    ED_STATUS               = 'O'
                                 AND ED_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END)
         OR
         EP_BUS_PERIOD_END   != (SELECT MAX(ED_DATE)
                                 FROM   SLR_ENTITY_DAYS
                                 WHERE  ED_ENTITY_SET           = lvEntitySet
                                 AND    ED_STATUS               = 'O'
                                 AND ED_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END));

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failed to update SLR Non Working Days for entity: '
                            ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, lvTableName, null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failed to update SLR Non Working Days for entity: '
                            ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, lvTableName, null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_NON_WORKING_DAYS: ' || SQLERRM);

END pUPDATE_NON_WORKING_DAYS;

---------------------------------------------------------------------------------------------------
-- Procedure pEntityBusinessDate
--  Returns Entity Business Date for given Entity Processing Group.
--  An error is raised when Entities from given EPG don't have the same Business Date.
---------------------------------------------------------------------------------------------------
PROCEDURE pEntityBusinessDate
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_business_date OUT DATE
)
AS
    s_proc_name VARCHAR2(65) := 'SLR_CLIENT_PROCEDURES_PKG.pEntityBusinessDate';
BEGIN

    FOR r IN
    (
        SELECT EPG_ID, COUNT(DISTINCT ENT_BUSINESS_DATE)
        FROM SLR_ENTITY_PROC_GROUP
        JOIN SLR_ENTITIES
            ON EPG_ENTITY = ENT_ENTITY
        WHERE EPG_ID = p_epg_id
        GROUP BY EPG_ID
        HAVING COUNT(DISTINCT ENT_BUSINESS_DATE) > 1
    )
    LOOP
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'SLR_ENTITIES',
            'Entities from EPG ''' || r.EPG_ID || ''' have different business date',
            p_process_id,p_epg_id);
        RAISE e_internal_processing_error; -- raised to stop processing
    END LOOP;

    BEGIN
        SELECT ENT_BUSINESS_DATE
        INTO p_business_date
        FROM SLR_ENTITIES
        WHERE ENT_ENTITY =
        (
            SELECT EPG_ENTITY
            FROM SLR_ENTITY_PROC_GROUP
            WHERE EPG_ID = p_epg_id
                AND ROWNUM = 1
        );
    EXCEPTION
        WHEN OTHERS THEN
            SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'SLR_ENTITIES',
                'Can''t find business date for EPG ' || p_epg_id, p_process_id,p_epg_id);
            SLR_ADMIN_PKG.Error('ERROR: Can''t find business date. ' || SQLERRM);
            RAISE e_internal_processing_error; -- raised to stop processing
    END;

END pEntityBusinessDate;

PROCEDURE pRollbackImportExchange
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_subpartition_name IN VARCHAR2,
    p_pm_table_name IN VARCHAR2
)
AS
    lv_sql VARCHAR2(32000);
BEGIN
    SLR_ADMIN_PKG.Info('Rollbacking EXCHANGE PARTITION between FR_ACCOUNTING_EVENT and FR_ACCOUNTING_EVENT_IMP');

    lv_sql := '
        INSERT INTO FDR.FR_ACCOUNTING_EVENT

        SELECT * FROM
        (
            SELECT * FROM FR_ACCOUNTING_EVENT_IMP
            SUBPARTITION (' || p_subpartition_name || ')
        )
        UNION ALL
        (
            SELECT * FROM ' || p_pm_table_name || '
        )
    ';
    SLR_ADMIN_PKG.Debug('Running SQL for rollback', lv_sql);
    EXECUTE IMMEDIATE lv_sql;
    COMMIT;

    lv_sql := 'DELETE FROM FDR.FR_ACCOUNTING_EVENT_IMP SUBPARTITION(' || p_subpartition_name || ')';
    SLR_ADMIN_PKG.Debug('Running SQL for rollback', lv_sql);
    EXECUTE IMMEDIATE lv_sql;
    COMMIT;

    SLR_ADMIN_PKG.Info('Rollback successfully done');
END;


procedure pCustRunBalanceMovementProcess( pProcess     IN slr_process.p_process%TYPE
                                         ,pEntProcSet  IN slr_bm_entity_processing_set.bmeps_set_id%TYPE
                                         ,pConfig      IN slr_process_config.pc_config%TYPE
                                         ,pSource      IN slr_process_source.sps_source_name%TYPE
                                         ,pBalanceDate IN DATE
                                         ,pRateSet     IN slr_entity_rates.er_entity_set%TYPE
                                        )
AS
  v_min_date DATE;
  v_max_date DATE;
  v_min_period_end DATE;
  v_max_period_end DATE;
  v_min_status CHAR(1);
  v_max_status CHAR(1);
  pprocessId NUMBER;

  CURSOR cEntityProcGroups(pEntProcSet IN slr_bm_entity_processing_set.bmeps_set_id%TYPE,pConfig IN slr_process_config.pc_config%TYPE,pProcess IN slr_process.p_process%TYPE) IS
        SELECT DISTINCT JLU_EPG_ID
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE jlu_jrnl_status = 'U'
        AND JLU_ENTITY IN (SELECT BMEPS_ENTITY FROM SLR_BM_ENTITY_PROCESSING_SET WHERE BMEPS_SET_ID = pEntProcSet)
        OR JLU_ENTITY IN (SELECT PCD_ENTITY FROM SLR_PROCESS_CONFIG_DETAIL WHERE pcd_pc_config = pConfig AND pcd_pc_P_process = pProcess AND NVL(PCD_ENTITY,'**SOURCE**') <> '**SOURCE**')
        ;


begin

    --logic for previous year balances <begin> --
    --we need to run processes for the end of the previous year as long as it's not closed, --
    --in case that there were any backdated transactions that would not be otherwise taken as source for balance movement processes --
    --and therefore render the end year reports invalid --

    --check if balance date is the same for all entities within processing set--
    SELECT min(ENT_BUSINESS_DATE), max(ENT_BUSINESS_DATE) into v_min_date, v_max_date FROM
    slr_entities where ent_entity in (select BMEPS_ENTITY from SLR_BM_ENTITY_PROCESSING_SET where BMEPS_SET_ID = pEntProcSet);

    IF v_min_date <> v_max_date THEN
        RAISE_APPLICATION_ERROR(-20001,'Entity business date not consistent within entity processing set: '|| NVL(pEntProcSet, ''));
    end if;

    --last working day of the previous year and period status must be the same for all entities within entity processing set
    SELECT MIN( b.ep_bus_period_end), MAX( b.ep_bus_period_end), MIN(b.EP_STATUS), MAX(b.EP_STATUS)
    into v_min_period_end, v_max_period_end, v_min_status, v_max_status FROM
    SLR_BM_ENTITY_PROCESSING_SET LEFT JOIN slr_entity_periods a ON (a.EP_ENTITY = BMEPS_ENTITY)
    LEFT JOIN slr_entity_periods b ON (a.EP_ENTITY = b.EP_ENTITY AND a.EP_BUS_YEAR-1 = b.EP_BUS_YEAR )
    WHERE BMEPS_SET_ID = pEntProcSet
    AND v_min_date BETWEEN a.ep_cal_period_start AND a.ep_cal_period_end
    AND b.ep_period_type = 2;

    IF v_min_status <> v_max_status THEN
        RAISE_APPLICATION_ERROR(-20001,'The status of the last working day of the previous year is not consistent within entity processing set: '|| NVL(pEntProcSet, ''));
    END IF;

  --if previous business year is still open run process for the end of previous year and post created journals
    if v_min_status = 'O' then
        --providing that last working day of the previous year is the same for all entities
        IF v_min_period_end <> v_max_period_end THEN
            RAISE_APPLICATION_ERROR(-20001,'Last working day of the previous year is not consistent within entity processing set: '|| NVL(pEntProcSet, ''));
        end if;

        SLR_BALANCE_MOVEMENT_PKG.pBMRunBalanceMovementProcess(pProcess,pEntProcSet,pConfig,pSource,v_min_period_end,pRateSet,pprocessId);

        FOR cEntityProcGroup IN cEntityProcGroups(pEntProcSet,pConfig,pProcess)
        LOOP
           SLR_UTILITIES_PKG.pRunValidateAndPost(cEntityProcGroup.JLU_EPG_ID,NULL, pprocessId);
        END LOOP;


    END IF;
    --logic for previous year balances <end> --

  SLR_BALANCE_MOVEMENT_PKG.pBMRunBalanceMovementProcess(pProcess,pEntProcSet,pConfig,pSource,pBalanceDate,pRateSet,pprocessId);

        FOR cEntityProcGroup IN cEntityProcGroups(pEntProcSet,pConfig,pProcess)
        LOOP
            SLR_UTILITIES_PKG.pRunValidateAndPost(cEntityProcGroup.JLU_EPG_ID,NULL, pprocessId);
        END LOOP;

   COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, null, slr_global_pkg.C_TECHNICAL, 'SLR_CLIENT_PROCEDURES_PKG.pCustRunBalanceMovementProcess', NULL, NULL, NULL, 'SLR', 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pCustRunBalanceMovementProcess: ' || SQLERRM);

END pCustRunBalanceMovementProcess;

-- ----------------------------------------------------------------------------
-- Procedure:   pSLR_DAYS_PERIODS
-- Description: calls SLR_ENTITY_DAYS procedure from SLR_UTILITIES package
--              for every entity set using a loop
-- Note:        Created by Konrad Bafia
--
-- ----------------------------------------------------------------------------
PROCEDURE pSLR_DAYS_PERIODS
AS
    s_proc_name       VARCHAR2(80) := 'SLR_PKG.pSLR_DAYS_PERIODS';
    v_start_date date := trunc(sysdate-1500);
    v_end_date date := trunc(sysdate+1500);
    v_entity_set SLR_ENTITY_DAYS.ED_ENTITY_SET%type;


   CURSOR entity_set_cur
   IS
      SELECT ES_ENTITY_SET
      FROM SLR.SLR_ENTITY_SETS
      ORDER BY ES_ENTITY_SET ASC
  ;


BEGIN

/* BEGIN SLR DAY LOAD */

     OPEN entity_set_cur;

     LOOP
        FETCH entity_set_cur INTO v_entity_set;
        EXIT WHEN entity_set_cur%NOTFOUND;

        SLR.SLR_PKG.pSLR_ENTITY_DAYS(V_ENTITY_SET,V_START_DATE,V_END_DATE,'O','AAH');

     END LOOP;

     CLOSE entity_set_cur;

/* BEGIN SLR DAY LOAD */

        SLR.SLR_PKG.pSLR_ENTITY_PERIODS();
        SLR.SLR_PKG.pEVENT_CLASS_PERIODS();

END pSLR_DAYS_PERIODS;

PROCEDURE pSLR_ENTITY_DAYS
(
    p_entity_set  in SLR_ENTITY_DAYS.ED_ENTITY_SET%type,
    p_start_date  in date,
    p_end_date    in date,
    p_status      in SLR_ENTITY_DAYS.ED_STATUS%TYPE,
    p_calendar_name in FR_HOLIDAY_DATE.HD_CA_CALENDAR_NAME%TYPE := 'DEFAULT'
)
AS
    s_proc_name       VARCHAR2(80) := 'SLR_UTILITIES_PKG.pUPDATE_SLR_ENTITY_DAYS';

BEGIN


	INSERT INTO SLR_ENTITY_DAYS(
								   ED_ENTITY_SET,
                                   ED_DATE,
                                   ED_STATUS,
                                   ED_CREATED_BY,
                                   ED_CREATED_ON,
                                   ED_AMENDED_BY,
                                   ED_AMENDED_ON
                )
	WITH days_range (cal_day)
	AS (
		SELECT p_end_date as cal_day FROM DUAL
		UNION ALL
		SELECT cal_day -1 FROM days_range
		WHERE  cal_day > p_start_date
	)
	SELECT  p_entity_set,
			cal_day,
			case
				when
					nvl((SELECT HD_ACTIVE FROM FR_HOLIDAY_DATE WHERE HD_HOLIDAY_DATE = cal_day  AND HD_ACTIVE = 'A' AND HD_CA_CALENDAR_NAME = p_calendar_name) ,'N') = 'A' OR
					nvl ( CASE RTRIM(UPPER(TO_CHAR(cal_day, 'DAY', 'NLS_DATE_LANGUAGE = ENGLISH')))
								WHEN 'MONDAY'  THEN CAW_MONDAY
								WHEN 'TUESDAY' THEN  CAW_TUESDAY
								WHEN 'WEDNESDAY' THEN CAW_WEDNESDAY
								WHEN 'THURSDAY' THEN CAW_THURSDAY
								WHEN 'FRIDAY' THEN CAW_FRIDAY
								WHEN 'SATURDAY' THEN CAW_SATURDAY
								WHEN 'SUNDAY' THEN CAW_SUNDAY
							  END , 1) = 0
				then 'C'
				else p_status
			end as status,
			user, trunc(sysdate),
			user, trunc(sysdate)
	FROM days_range
	LEFT JOIN FR_CALENDAR_WEEK ON (CAW_CA_CALENDAR_NAME = p_calendar_name)
	WHERE
	NOT EXISTS (
			SELECT 1 FROM slr_entity_days
			WHERE ed_entity_set = p_entity_set
			AND ed_date = cal_day);

EXCEPTION
    WHEN OTHERS THEN
        gv_msg := 'Failed to set SLR entity days for entity set ['||p_entity_set||'] ';
        pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_DAYS', null, 'Entity Set', gs_stage, 'PL/SQL', SQLCODE);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, gv_msg);

END pSLR_ENTITY_DAYS;

PROCEDURE pSLR_ENTITY_PERIODS AS

BEGIN

INSERT INTO SLR_ENTITY_PERIODS (
          EP_ENTITY,
          EP_BUS_YEAR,
          EP_BUS_PERIOD,
          EP_PERIOD_TYPE,
          EP_STATUS,
          EP_BUS_PERIOD_START,
          EP_BUS_PERIOD_END,
          EP_BUS_PERIOD_END_ID,
          EP_CAL_PERIOD_START,
          EP_CAL_PERIOD_END,
          EP_CREATED_BY,
          EP_CREATED_ON,
          EP_AMENDED_BY,
          EP_AMENDED_ON
          )
with
     minmax_days
as (
      select
          MIN(ED_DATE) as min_date
        , MAX(ED_DATE) as max_date
      from SLR_ENTITY_DAYS d
    )

  ,  base_years
  as (
             select
                    ((extract ( year from y.max_date )+1) - level) the_year
               from
                    minmax_days y
         connect by
                    level <= ((extract ( year from y.max_date )+1) - extract( year from y.min_date ))
     )
   , base_months
  as (
             select
                    level the_month
               from
                    dual m
         connect by
                    level <= 12
     )
  , results as (
select
       s.ent_entity AS EP_ENTITY
     , y.the_year AS EP_BUS_YEAR
     , m.the_month AS EP_BUS_PERIOD
     , CASE WHEN m.the_month = 12 THEN 2 ELSE 1 END AS EP_PERIOD_TYPE
     , 'O' AS EP_STATUS
     , to_date(lpad(m.the_month,2,0)||y.the_year,'mmyyyy') as EP_BUS_PERIOD_START
     , (add_months(to_date(lpad(m.the_month,2,0)||y.the_year,'mmyyyy'),1)-1) as EP_BUS_PERIOD_END
     , to_char((add_months(to_date(lpad(m.the_month,2,0)||y.the_year,'mmyyyy'),1)-1),'YYYYMMDD')||50 AS EP_BUS_PERIOD_END_ID
     , to_date(lpad(m.the_month,2,0)||y.the_year,'mmyyyy') as EP_CAL_PERIOD_START
     , (add_months(to_date(lpad(m.the_month,2,0)||y.the_year,'mmyyyy'),1)-1) as EP_CAL_PERIOD_END
     , USER AS EP_CREATED_BY
     , SYSDATE AS EP_CREATED_ON
     , USER AS EP_AMENDED_BY
     , SYSDATE AS EP_AMENDED_ON
  from
                  base_years  y
       cross join base_months m
       cross join slr.slr_entities s
    )

, results2 as
(

select
          EP_ENTITY,
          EP_BUS_YEAR,
          EP_BUS_PERIOD,
          EP_PERIOD_TYPE,
          EP_STATUS,
          EP_BUS_PERIOD_START,
          EP_BUS_PERIOD_END,
          EP_BUS_PERIOD_END_ID,
          EP_CAL_PERIOD_START,
          EP_CAL_PERIOD_END,
          EP_CREATED_BY,
          EP_CREATED_ON,
          EP_AMENDED_BY,
          EP_AMENDED_ON
from results r
  ,  minmax_days m
where R.EP_BUS_PERIOD_END between m.min_date and m.max_date
)

SELECT *
from results2
WHERE (EP_ENTITY||EP_BUS_PERIOD_END_ID) NOT IN (SELECT DISTINCT (EP_ENTITY||EP_BUS_PERIOD_END_ID) FROM SLR.SLR_ENTITY_PERIODS)
order by 1,2,3
;


END pSLR_ENTITY_PERIODS;

PROCEDURE pEVENT_CLASS_PERIODS AS

BEGIN
merge
 into
      fdr.fr_general_lookup gl
using (
          select distinct
                 'EVENT_CLASS_PERIOD'                                       LK_LKT_LOOKUP_TYPE_CODE
               , eg.event_group                                             LK_MATCH_KEY1
               , to_char(ep.ep_bus_year)                                    LK_MATCH_KEY2
               , lpad(ep.ep_bus_period,2,'0')                               LK_MATCH_KEY3
               , to_char(ep.ep_bus_year)||'-'||lpad(ep.ep_bus_period,2,'0') LK_MATCH_KEY4
               , 'O'                                                        LK_LOOKUP_VALUE1
               , to_char(ep.ep_bus_period_start,'DD-MON-YYYY')              LK_LOOKUP_VALUE2
               , to_char(ep.ep_bus_period_end,'DD-MON-YYYY')                LK_LOOKUP_VALUE3
               , 'N'                                                        LK_LOOKUP_VALUE5
               , to_date('01/01/2000','mm/dd/yyyy')                         LK_EFFECTIVE_FROM
               , to_date('01/01/2099','mm/dd/yyyy')                         LK_EFFECTIVE_TO
            from
                 slr_entity_periods ep
      cross join ( select distinct
                          lk_match_key1    event_group
                        , lk_lookup_value2 frequency_ind
                     from
                          fdr.fr_general_lookup
                    where
                          lk_lkt_lookup_type_code = 'EVENT_CLASS'
                      and sysdate between LK_EFFECTIVE_FROM and LK_EFFECTIVE_TO
                 ) eg
         where (   eg.frequency_ind = 'M'
                   or eg.frequency_ind is null
                   or (     eg.frequency_ind = 'Q'
                        and ep.ep_bus_period in ( 3 , 6 , 9 , 12 )
                      )
                  )
              and ep.ep_bus_period_start >= to_date('01-JAN-2017','DD-MON-YYYY')
      )
      input
   on (
              gl.LK_MATCH_KEY1           = input.LK_MATCH_KEY1
          and gl.LK_LOOKUP_VALUE2        = input.LK_LOOKUP_VALUE2
          and gl.LK_LOOKUP_VALUE3        = input.LK_LOOKUP_VALUE3
          and GL.LK_LKT_LOOKUP_TYPE_CODE = 'EVENT_CLASS_PERIOD'
      )
when
      matched then update set
                     gl.LK_MATCH_KEY2 = input.LK_MATCH_KEY2
                   , gl.LK_MATCH_KEY3 = input.LK_MATCH_KEY3
                   , gl.LK_MATCH_KEY4 = input.LK_MATCH_KEY4
when not
      matched then insert
                   (
                      gl.LK_LKT_LOOKUP_TYPE_CODE
                    , gl.LK_MATCH_KEY1
                    , gl.LK_MATCH_KEY2
                    , gl.LK_MATCH_KEY3
                    , gl.LK_MATCH_KEY4
                    , gl.LK_LOOKUP_VALUE1
                    , gl.LK_LOOKUP_VALUE2
                    , gl.LK_LOOKUP_VALUE3
                    , gl.LK_LOOKUP_VALUE5
                    , gl.LK_EFFECTIVE_FROM
                    , gl.LK_EFFECTIVE_TO
                   )
                   values
                   (
                       input.LK_LKT_LOOKUP_TYPE_CODE
                   ,   input.LK_MATCH_KEY1
                   ,   input.LK_MATCH_KEY2
                   ,   input.LK_MATCH_KEY3
                   ,   input.LK_MATCH_KEY4
                   ,   input.LK_LOOKUP_VALUE1
                   ,   input.LK_LOOKUP_VALUE2
                   ,   input.LK_LOOKUP_VALUE3
                   ,   input.LK_LOOKUP_VALUE5
                   ,   input.LK_EFFECTIVE_FROM
                   ,   input.LK_EFFECTIVE_TO
                   )
                   ;
END pEVENT_CLASS_PERIODS;

PROCEDURE pGENERATE_EBA_BOP_VALUES AS
  BEGIN
  
    EXECUTE IMMEDIATE 'TRUNCATE TABLE SLR.SLR_EBA_BOP_AMOUNTS_TMP';
    INSERT INTO SLR.SLR_EBA_BOP_AMOUNTS_TMP
     (     EDB_FAK_ID
         , EDB_EBA_ID
         , EDB_BALANCE_DATE
         , EDB_BALANCE_TYPE
         , EDB_TRAN_BOP_MTD_BALANCE
         , EDB_TRAN_BOP_QTD_BALANCE
         , EDB_TRAN_BOP_YTD_BALANCE
         , EDB_BASE_BOP_MTD_BALANCE
         , EDB_BASE_BOP_QTD_BALANCE
         , EDB_BASE_BOP_YTD_BALANCE
         , EDB_LOCAL_BOP_MTD_BALANCE
         , EDB_LOCAL_BOP_QTD_BALANCE
         , EDB_LOCAL_BOP_YTD_BALANCE
         , EDB_PERIOD_MONTH
         , EDB_PERIOD_QTR
         , EDB_PERIOD_YEAR
         , EDB_PERIOD_LTD
         , EDB_AMENDED_ON
      )
      with all_data as
      (
        SELECT
                 EDB.EDB_FAK_ID
               , EDB.EDB_EBA_ID
               , EDB.EDB_BALANCE_DATE
               , EDB.EDB_BALANCE_TYPE
               , EDB.EDB_TRAN_DAILY_MOVEMENT
               , EDB.EDB_TRAN_MTD_BALANCE
               , EDB.EDB_TRAN_YTD_BALANCE
               , EDB.EDB_TRAN_LTD_BALANCE
               , EDB.EDB_BASE_DAILY_MOVEMENT
               , EDB.EDB_BASE_MTD_BALANCE
               , EDB.EDB_BASE_YTD_BALANCE
               , EDB.EDB_BASE_LTD_BALANCE
               , EDB.EDB_LOCAL_DAILY_MOVEMENT
               , EDB.EDB_LOCAL_MTD_BALANCE
               , EDB.EDB_LOCAL_YTD_BALANCE
               , EDB.EDB_LOCAL_LTD_BALANCE
               , EDB.EDB_ENTITY
               , EDB.EDB_EPG_ID
               , EDB.EDB_PERIOD_MONTH
               , TO_NUMBER(TO_CHAR(EDB_BALANCE_DATE, 'Q')) AS EDB_PERIOD_QTR
               , EDB.EDB_PERIOD_YEAR
               , EDB.EDB_PERIOD_LTD
               , EDB.EDB_PROCESS_ID
               , EDB.EDB_AMENDED_ON
               , EDB_FAK_ID||'\\'||EDB_EBA_ID||'\\'||EDB_BALANCE_TYPE||'\\'||EDB_ENTITY||'\\'||EDB_EPG_ID AS EDB_ID
               , TO_CHAR(EDB_BALANCE_DATE, 'YYYYMM') AS YEAR_MTH
               , TO_CHAR(EDB_BALANCE_DATE, 'YYYYQ') AS YEAR_QTR
               , TO_CHAR(EDB_BALANCE_DATE, 'YYYY') AS YEAR

        FROM
               SLR.SLR_EBA_DAILY_BALANCES EDB

        ORDER BY 1,2,3

      ),

      MAX_MTH_DATES AS
      (
        SELECT AD.EDB_ID
             , AD.YEAR_MTH
             , MAX(EDB_BALANCE_DATE) AS MAX_MTH_DATE
        FROM   ALL_DATA AD
        GROUP BY
               AD.EDB_ID
             , AD.YEAR_MTH
      ),

      MAX_MTH_DATE_AMTS AS
      (
        SELECT MMD.EDB_ID
             , MMD.YEAR_MTH
             , MMD.MAX_MTH_DATE
             , RANK() OVER (PARTITION BY MMD.EDB_ID ORDER BY MMD.YEAR_MTH ASC) AS RANK_NBR
             , AD.EDB_TRAN_LTD_BALANCE
             , AD.EDB_BASE_LTD_BALANCE
             , AD.EDB_LOCAL_LTD_BALANCE
        FROM   MMD.MAX_MTH_DATES MMD
        LEFT JOIN
               ALL_DATA AD
         ON   AD.EDB_ID = MMD.EDB_ID
         AND  AD.EDB_BALANCE_DATE = MMD.MAX_MTH_DATE
        ORDER BY
              1,2 DESC
      ),


      MTD_BALANCES AS
      (
        SELECT   A.EDB_ID
               , A.YEAR_MTH
               , B.YEAR_MTH AS YEAR_MTH_LM
               , B.MAX_MTH_DATE AS MAX_MTH_DATE_LM
               , B.EDB_TRAN_LTD_BALANCE AS EDB_TRAN_BOP_MTD_BALANCE
               , B.EDB_BASE_LTD_BALANCE AS EDB_BASE_BOP_MTD_BALANCE
               , B.EDB_LOCAL_LTD_BALANCE AS EDB_LOCAL_BOP_MTD_BALANCE
        FROM      MAX_MTH_DATE_AMTS A
        LEFT JOIN MAX_MTH_DATE_AMTS B
          ON     A.EDB_ID = B.EDB_ID
          AND    A.RANK_NBR = (B.RANK_NBR+1)
        ORDER BY 1,2
      ),

      MAX_QTR_DATES AS
      (
        SELECT
               AD.EDB_ID
             , AD.YEAR_QTR
             , MAX(EDB_BALANCE_DATE) AS MAX_QTR_DATE
        FROM   ALL_DATA AD
        GROUP BY
               AD.EDB_ID
             , AD.YEAR_QTR
      ),

      MAX_QTR_DATE_AMTS AS
      (
        SELECT MQD.EDB_ID
             , MQD.YEAR_QTR
             , MQD.MAX_QTR_DATE
             , RANK() OVER (PARTITION BY MQD.EDB_ID ORDER BY MQD.YEAR_QTR ASC) AS RANK_NBR
             , AD.EDB_TRAN_LTD_BALANCE
             , AD.EDB_BASE_LTD_BALANCE
             , AD.EDB_LOCAL_LTD_BALANCE
        FROM   MQD.MAX_QTR_DATES MQD
        LEFT JOIN
               ALL_DATA AD
         ON   AD.EDB_ID = MQD.EDB_ID
         AND  AD.EDB_BALANCE_DATE = MQD.MAX_QTR_DATE
        ORDER BY
              1,2 DESC
      ),

      QTD_BALANCES AS
      (
        SELECT   A.EDB_ID
               , A.YEAR_QTR
               , B.YEAR_QTR AS YEAR_QTR_LQ
               , B.MAX_QTR_DATE AS MAX_QTR_DATE_LQ
               , B.EDB_TRAN_LTD_BALANCE AS EDB_TRAN_BOP_QTD_BALANCE
               , B.EDB_BASE_LTD_BALANCE AS EDB_BASE_BOP_QTD_BALANCE
               , B.EDB_LOCAL_LTD_BALANCE AS EDB_LOCAL_BOP_QTD_BALANCE
        FROM      MAX_QTR_DATE_AMTS A
        LEFT JOIN MAX_QTR_DATE_AMTS B
          ON     A.EDB_ID = B.EDB_ID
          AND    A.RANK_NBR = (B.RANK_NBR+1)
        ORDER BY 1,2
      ),

      MAX_YR_DATES AS
      (
        SELECT
               AD.EDB_ID
             , AD.YEAR
             , MAX(EDB_BALANCE_DATE) AS MAX_YR_DATE
        FROM   ALL_DATA AD
        GROUP BY
               AD.EDB_ID
             , AD.YEAR
      ),

      MAX_YR_DATE_AMTS AS
      (
        SELECT MYD.EDB_ID
             , MYD.YEAR
             , MYD.MAX_YR_DATE
             , RANK() OVER (PARTITION BY MYD.EDB_ID ORDER BY MYD.YEAR ASC) AS RANK_NBR
             , AD.EDB_TRAN_LTD_BALANCE
             , AD.EDB_BASE_LTD_BALANCE
             , AD.EDB_LOCAL_LTD_BALANCE
        FROM   MYD.MAX_YR_DATES MYD
        LEFT JOIN
               ALL_DATA AD
         ON   AD.EDB_ID = MYD.EDB_ID
         AND  AD.EDB_BALANCE_DATE = MYD.MAX_YR_DATE
        ORDER BY
              1,2 DESC
      ),

      YTD_BALANCES AS
      (
        SELECT   A.EDB_ID
               , A.YEAR
               , B.YEAR AS YEAR_LY
               , B.MAX_YR_DATE AS MAX_QTR_DATE_LY
               , B.EDB_TRAN_LTD_BALANCE AS EDB_TRAN_BOP_YTD_BALANCE
               , B.EDB_BASE_LTD_BALANCE AS EDB_BASE_BOP_YTD_BALANCE
               , B.EDB_LOCAL_LTD_BALANCE AS EDB_LOCAL_BOP_YTD_BALANCE
        FROM      MAX_YR_DATE_AMTS A
        LEFT JOIN MAX_YR_DATE_AMTS B
          ON     A.EDB_ID = B.EDB_ID
          AND    A.RANK_NBR = (B.RANK_NBR+1)
        ORDER BY 1,2
      )

      SELECT  /*+ PARALLEL +*/
                 AD.EDB_FAK_ID
               , AD.EDB_EBA_ID
               , AD.EDB_BALANCE_DATE
               , AD.EDB_BALANCE_TYPE
               , MB.EDB_TRAN_BOP_MTD_BALANCE
               , QB.EDB_TRAN_BOP_QTD_BALANCE
               , YB.EDB_TRAN_BOP_YTD_BALANCE
               , MB.EDB_BASE_BOP_MTD_BALANCE
               , QB.EDB_BASE_BOP_QTD_BALANCE
               , YB.EDB_BASE_BOP_YTD_BALANCE
               , MB.EDB_LOCAL_BOP_MTD_BALANCE
               , QB.EDB_LOCAL_BOP_QTD_BALANCE
               , YB.EDB_LOCAL_BOP_YTD_BALANCE
               , AD.EDB_PERIOD_MONTH
               , AD.EDB_PERIOD_QTR
               , AD.EDB_PERIOD_YEAR
               , AD.EDB_PERIOD_LTD
               , AD.EDB_AMENDED_ON
        FROM      ALL_DATA AD

        LEFT JOIN MTD_BALANCES MB
          ON     AD.EDB_ID = MB.EDB_ID
          AND    AD.YEAR_MTH = MB.YEAR_MTH

        LEFT JOIN QTD_BALANCES QB
          ON     AD.EDB_ID = QB.EDB_ID
          AND    AD.YEAR_QTR = QB.YEAR_QTR

        LEFT JOIN YTD_BALANCES YB
          ON     AD.EDB_ID = YB.EDB_ID
          AND    AD.YEAR_QTR = YB.YEAR

      ORDER BY 1,2;

   COMMIT;

   MERGE INTO SLR.SLR_EBA_BOP_AMOUNTS BOP
     USING (
            SELECT
                 EDB_FAK_ID
               , EDB_EBA_ID
               , EDB_BALANCE_DATE
               , EDB_BALANCE_TYPE
               , EDB_TRAN_BOP_MTD_BALANCE
               , EDB_TRAN_BOP_QTD_BALANCE
               , EDB_TRAN_BOP_YTD_BALANCE
               , EDB_BASE_BOP_MTD_BALANCE
               , EDB_BASE_BOP_QTD_BALANCE
               , EDB_BASE_BOP_YTD_BALANCE
               , EDB_LOCAL_BOP_MTD_BALANCE
               , EDB_LOCAL_BOP_QTD_BALANCE
               , EDB_LOCAL_BOP_YTD_BALANCE
               , EDB_PERIOD_MONTH
               , EDB_PERIOD_QTR
               , EDB_PERIOD_YEAR
               , EDB_PERIOD_LTD
               , EDB_AMENDED_ON
            FROM
                SLR_EBA_BOP_AMOUNTS_TMP TMP
            ) TMP
      ON (
                TMP.EDB_FAK_ID = BOP.EDB_FAK_ID
            AND TMP.EDB_EBA_ID = BOP.EDB_EBA_ID
            AND TMP.EDB_BALANCE_DATE = BOP.EDB_BALANCE_DATE
            AND TMP.EDB_BALANCE_TYPE = BOP.EDB_BALANCE_TYPE
          )
    WHEN MATCHED
    THEN
       UPDATE SET BOP.EDB_TRAN_BOP_MTD_BALANCE  = TMP.EDB_TRAN_BOP_MTD_BALANCE
                , BOP.EDB_TRAN_BOP_QTD_BALANCE  = TMP.EDB_TRAN_BOP_QTD_BALANCE
                , BOP.EDB_TRAN_BOP_YTD_BALANCE  = TMP.EDB_TRAN_BOP_YTD_BALANCE
                , BOP.EDB_BASE_BOP_MTD_BALANCE  = TMP.EDB_BASE_BOP_MTD_BALANCE
                , BOP.EDB_BASE_BOP_QTD_BALANCE  = TMP.EDB_BASE_BOP_QTD_BALANCE
                , BOP.EDB_BASE_BOP_YTD_BALANCE  = TMP.EDB_BASE_BOP_YTD_BALANCE
                , BOP.EDB_LOCAL_BOP_MTD_BALANCE = TMP.EDB_LOCAL_BOP_MTD_BALANCE
                , BOP.EDB_LOCAL_BOP_QTD_BALANCE = TMP.EDB_LOCAL_BOP_QTD_BALANCE
                , BOP.EDB_LOCAL_BOP_YTD_BALANCE = TMP.EDB_LOCAL_BOP_YTD_BALANCE
                , BOP.EDB_PERIOD_MONTH = TMP.EDB_PERIOD_MONTH
                , BOP.EDB_PERIOD_QTR = TMP.EDB_PERIOD_QTR
                , BOP.EDB_PERIOD_YEAR = TMP.EDB_PERIOD_YEAR
                , BOP.EDB_PERIOD_LTD = TMP.EDB_PERIOD_LTD
                , BOP.EDB_AMENDED_ON = SYSDATE

    WHEN NOT MATCHED
    THEN
       INSERT
        (
          EDB_FAK_ID
        , EDB_EBA_ID
        , EDB_BALANCE_DATE
        , EDB_BALANCE_TYPE
        , EDB_TRAN_BOP_MTD_BALANCE
        , EDB_TRAN_BOP_QTD_BALANCE
        , EDB_TRAN_BOP_YTD_BALANCE
        , EDB_BASE_BOP_MTD_BALANCE
        , EDB_BASE_BOP_QTD_BALANCE
        , EDB_BASE_BOP_YTD_BALANCE
        , EDB_LOCAL_BOP_MTD_BALANCE
        , EDB_LOCAL_BOP_QTD_BALANCE
        , EDB_LOCAL_BOP_YTD_BALANCE
        , EDB_PERIOD_MONTH
        , EDB_PERIOD_QTR
        , EDB_PERIOD_YEAR
        , EDB_PERIOD_LTD
        , EDB_AMENDED_ON
        )
        VALUES
        (
          TMP.EDB_FAK_ID
        , TMP.EDB_EBA_ID
        , TMP.EDB_BALANCE_DATE
        , TMP.EDB_BALANCE_TYPE
        , TMP.EDB_TRAN_BOP_MTD_BALANCE
        , TMP.EDB_TRAN_BOP_QTD_BALANCE
        , TMP.EDB_TRAN_BOP_YTD_BALANCE
        , TMP.EDB_BASE_BOP_MTD_BALANCE
        , TMP.EDB_BASE_BOP_QTD_BALANCE
        , TMP.EDB_BASE_BOP_YTD_BALANCE
        , TMP.EDB_LOCAL_BOP_MTD_BALANCE
        , TMP.EDB_LOCAL_BOP_QTD_BALANCE
        , TMP.EDB_LOCAL_BOP_YTD_BALANCE
        , TMP.EDB_PERIOD_MONTH
        , TMP.EDB_PERIOD_QTR
        , TMP.EDB_PERIOD_YEAR
        , TMP.EDB_PERIOD_LTD
        , SYSDATE
        );

      EXECUTE IMMEDIATE 'TRUNCATE TABLE SLR.SLR_EBA_BOP_AMOUNTS_TMP';
END pGENERATE_EBA_BOP_VALUES;

PROCEDURE pGENERATE_FAK_BOP_VALUES AS
  BEGIN

    EXECUTE IMMEDIATE 'TRUNCATE TABLE SLR.SLR_FAK_BOP_AMOUNTS_TMP';
    INSERT INTO SLR.SLR_FAK_BOP_AMOUNTS_TMP
     (     FDB_FAK_ID
         , FDB_BALANCE_DATE
         , FDB_BALANCE_TYPE
         , FDB_TRAN_BOP_MTD_BALANCE
         , FDB_TRAN_BOP_QTD_BALANCE
         , FDB_TRAN_BOP_YTD_BALANCE
         , FDB_BASE_BOP_MTD_BALANCE
         , FDB_BASE_BOP_QTD_BALANCE
         , FDB_BASE_BOP_YTD_BALANCE
         , FDB_LOCAL_BOP_MTD_BALANCE
         , FDB_LOCAL_BOP_QTD_BALANCE
         , FDB_LOCAL_BOP_YTD_BALANCE
         , FDB_PERIOD_MONTH
         , FDB_PERIOD_QTR
         , FDB_PERIOD_YEAR
         , FDB_PERIOD_LTD
         , FDB_AMENDED_ON
      )
      with all_data as
      (
        SELECT
                 FDB.FDB_FAK_ID
               , FDB.FDB_BALANCE_DATE
               , FDB.FDB_BALANCE_TYPE
               , FDB.FDB_TRAN_DAILY_MOVEMENT
               , FDB.FDB_TRAN_MTD_BALANCE
               , FDB.FDB_TRAN_YTD_BALANCE
               , FDB.FDB_TRAN_LTD_BALANCE
               , FDB.FDB_BASE_DAILY_MOVEMENT
               , FDB.FDB_BASE_MTD_BALANCE
               , FDB.FDB_BASE_YTD_BALANCE
               , FDB.FDB_BASE_LTD_BALANCE
               , FDB.FDB_LOCAL_DAILY_MOVEMENT
               , FDB.FDB_LOCAL_MTD_BALANCE
               , FDB.FDB_LOCAL_YTD_BALANCE
               , FDB.FDB_LOCAL_LTD_BALANCE
               , FDB.FDB_ENTITY
               , FDB.FDB_EPG_ID
               , FDB.FDB_PERIOD_MONTH
               , TO_NUMBER(TO_CHAR(FDB_BALANCE_DATE, 'Q')) AS FDB_PERIOD_QTR
               , FDB.FDB_PERIOD_YEAR
               , FDB.FDB_PERIOD_LTD
               , FDB.FDB_PROCESS_ID
               , FDB.FDB_AMENDED_ON
               , FDB_FAK_ID||'\\'||FDB_BALANCE_TYPE||'\\'||FDB_ENTITY||'\\'||FDB_EPG_ID AS FDB_ID
               , TO_CHAR(FDB_BALANCE_DATE, 'YYYYMM') AS YEAR_MTH
               , TO_CHAR(FDB_BALANCE_DATE, 'YYYYQ') AS YEAR_QTR
               , TO_CHAR(FDB_BALANCE_DATE, 'YYYY') AS YEAR

        FROM
               SLR.SLR_FAK_DAILY_BALANCES FDB

        ORDER BY 1,2,3

      ),

      MAX_MTH_DATES AS
      (
        SELECT AD.FDB_ID
             , AD.YEAR_MTH
             , MAX(FDB_BALANCE_DATE) AS MAX_MTH_DATE
        FROM   ALL_DATA AD
        GROUP BY
               AD.FDB_ID
             , AD.YEAR_MTH
      ),

      MAX_MTH_DATE_AMTS AS
      (
        SELECT MMD.FDB_ID
             , MMD.YEAR_MTH
             , MMD.MAX_MTH_DATE
             , RANK() OVER (PARTITION BY MMD.FDB_ID ORDER BY MMD.YEAR_MTH ASC) AS RANK_NBR
             , AD.FDB_TRAN_LTD_BALANCE
             , AD.FDB_BASE_LTD_BALANCE
             , AD.FDB_LOCAL_LTD_BALANCE
        FROM   MMD.MAX_MTH_DATES MMD
        LEFT JOIN
               ALL_DATA AD
         ON   AD.FDB_ID = MMD.FDB_ID
         AND  AD.FDB_BALANCE_DATE = MMD.MAX_MTH_DATE
        ORDER BY
              1,2 DESC
      ),


      MTD_BALANCES AS
      (
        SELECT   A.FDB_ID
               , A.YEAR_MTH
               , B.YEAR_MTH AS YEAR_MTH_LM
               , B.MAX_MTH_DATE AS MAX_MTH_DATE_LM
               , B.FDB_TRAN_LTD_BALANCE AS FDB_TRAN_BOP_MTD_BALANCE
               , B.FDB_BASE_LTD_BALANCE AS FDB_BASE_BOP_MTD_BALANCE
               , B.FDB_LOCAL_LTD_BALANCE AS FDB_LOCAL_BOP_MTD_BALANCE
        FROM      MAX_MTH_DATE_AMTS A
        LEFT JOIN MAX_MTH_DATE_AMTS B
          ON     A.FDB_ID = B.FDB_ID
          AND    A.RANK_NBR = (B.RANK_NBR+1)
        ORDER BY 1,2
      ),

      MAX_QTR_DATES AS
      (
        SELECT
               AD.FDB_ID
             , AD.YEAR_QTR
             , MAX(FDB_BALANCE_DATE) AS MAX_QTR_DATE
        FROM   ALL_DATA AD
        GROUP BY
               AD.FDB_ID
             , AD.YEAR_QTR
      ),

      MAX_QTR_DATE_AMTS AS
      (
        SELECT MQD.FDB_ID
             , MQD.YEAR_QTR
             , MQD.MAX_QTR_DATE
             , RANK() OVER (PARTITION BY MQD.FDB_ID ORDER BY MQD.YEAR_QTR ASC) AS RANK_NBR
             , AD.FDB_TRAN_LTD_BALANCE
             , AD.FDB_BASE_LTD_BALANCE
             , AD.FDB_LOCAL_LTD_BALANCE
        FROM   MQD.MAX_QTR_DATES MQD
        LEFT JOIN
               ALL_DATA AD
         ON   AD.FDB_ID = MQD.FDB_ID
         AND  AD.FDB_BALANCE_DATE = MQD.MAX_QTR_DATE
        ORDER BY
              1,2 DESC
      ),

      QTD_BALANCES AS
      (
        SELECT   A.FDB_ID
               , A.YEAR_QTR
               , B.YEAR_QTR AS YEAR_QTR_LQ
               , B.MAX_QTR_DATE AS MAX_QTR_DATE_LQ
               , B.FDB_TRAN_LTD_BALANCE AS FDB_TRAN_BOP_QTD_BALANCE
               , B.FDB_BASE_LTD_BALANCE AS FDB_BASE_BOP_QTD_BALANCE
               , B.FDB_LOCAL_LTD_BALANCE AS FDB_LOCAL_BOP_QTD_BALANCE
        FROM      MAX_QTR_DATE_AMTS A
        LEFT JOIN MAX_QTR_DATE_AMTS B
          ON     A.FDB_ID = B.FDB_ID
          AND    A.RANK_NBR = (B.RANK_NBR+1)
        ORDER BY 1,2
      ),

      MAX_YR_DATES AS
      (
        SELECT
               AD.FDB_ID
             , AD.YEAR
             , MAX(FDB_BALANCE_DATE) AS MAX_YR_DATE
        FROM   ALL_DATA AD
        GROUP BY
               AD.FDB_ID
             , AD.YEAR
      ),

      MAX_YR_DATE_AMTS AS
      (
        SELECT MYD.FDB_ID
             , MYD.YEAR
             , MYD.MAX_YR_DATE
             , RANK() OVER (PARTITION BY MYD.FDB_ID ORDER BY MYD.YEAR ASC) AS RANK_NBR
             , AD.FDB_TRAN_LTD_BALANCE
             , AD.FDB_BASE_LTD_BALANCE
             , AD.FDB_LOCAL_LTD_BALANCE
        FROM   MYD.MAX_YR_DATES MYD
        LEFT JOIN
               ALL_DATA AD
         ON   AD.FDB_ID = MYD.FDB_ID
         AND  AD.FDB_BALANCE_DATE = MYD.MAX_YR_DATE
        ORDER BY
              1,2 DESC
      ),

      YTD_BALANCES AS
      (
        SELECT   A.FDB_ID
               , A.YEAR
               , B.YEAR AS YEAR_LY
               , B.MAX_YR_DATE AS MAX_QTR_DATE_LY
               , B.FDB_TRAN_LTD_BALANCE AS FDB_TRAN_BOP_YTD_BALANCE
               , B.FDB_BASE_LTD_BALANCE AS FDB_BASE_BOP_YTD_BALANCE
               , B.FDB_LOCAL_LTD_BALANCE AS FDB_LOCAL_BOP_YTD_BALANCE
        FROM      MAX_YR_DATE_AMTS A
        LEFT JOIN MAX_YR_DATE_AMTS B
          ON     A.FDB_ID = B.FDB_ID
          AND    A.RANK_NBR = (B.RANK_NBR+1)
        ORDER BY 1,2
      )

      SELECT  /*+ PARALLEL +*/
                 AD.FDB_FAK_ID
               , AD.FDB_BALANCE_DATE
               , AD.FDB_BALANCE_TYPE
               , MB.FDB_TRAN_BOP_MTD_BALANCE
               , QB.FDB_TRAN_BOP_QTD_BALANCE
               , YB.FDB_TRAN_BOP_YTD_BALANCE
               , MB.FDB_BASE_BOP_MTD_BALANCE
               , QB.FDB_BASE_BOP_QTD_BALANCE
               , YB.FDB_BASE_BOP_YTD_BALANCE
               , MB.FDB_LOCAL_BOP_MTD_BALANCE
               , QB.FDB_LOCAL_BOP_QTD_BALANCE
               , YB.FDB_LOCAL_BOP_YTD_BALANCE
               , AD.FDB_PERIOD_MONTH
               , AD.FDB_PERIOD_QTR
               , AD.FDB_PERIOD_YEAR
               , AD.FDB_PERIOD_LTD
               , AD.FDB_AMENDED_ON
        FROM      ALL_DATA AD

        LEFT JOIN MTD_BALANCES MB
          ON     AD.FDB_ID = MB.FDB_ID
          AND    AD.YEAR_MTH = MB.YEAR_MTH

        LEFT JOIN QTD_BALANCES QB
          ON     AD.FDB_ID = QB.FDB_ID
          AND    AD.YEAR_QTR = QB.YEAR_QTR

        LEFT JOIN YTD_BALANCES YB
          ON     AD.FDB_ID = YB.FDB_ID
          AND    AD.YEAR_QTR = YB.YEAR

      ORDER BY 1,2;

   COMMIT;

   MERGE INTO SLR.SLR_FAK_BOP_AMOUNTS BOP
     USING (
            SELECT
                 FDB_FAK_ID
               , FDB_BALANCE_DATE
               , FDB_BALANCE_TYPE
               , FDB_TRAN_BOP_MTD_BALANCE
               , FDB_TRAN_BOP_QTD_BALANCE
               , FDB_TRAN_BOP_YTD_BALANCE
               , FDB_BASE_BOP_MTD_BALANCE
               , FDB_BASE_BOP_QTD_BALANCE
               , FDB_BASE_BOP_YTD_BALANCE
               , FDB_LOCAL_BOP_MTD_BALANCE
               , FDB_LOCAL_BOP_QTD_BALANCE
               , FDB_LOCAL_BOP_YTD_BALANCE
               , FDB_PERIOD_MONTH
               , FDB_PERIOD_QTR
               , FDB_PERIOD_YEAR
               , FDB_PERIOD_LTD
               , FDB_AMENDED_ON
            FROM
                SLR.SLR_FAK_BOP_AMOUNTS_TMP TMP
            ) TMP
      ON (
                TMP.FDB_FAK_ID = BOP.FDB_FAK_ID
            AND TMP.FDB_BALANCE_DATE = BOP.FDB_BALANCE_DATE
            AND TMP.FDB_BALANCE_TYPE = BOP.FDB_BALANCE_TYPE
          )
    WHEN MATCHED
    THEN
       UPDATE SET BOP.FDB_TRAN_BOP_MTD_BALANCE  = TMP.FDB_TRAN_BOP_MTD_BALANCE
                , BOP.FDB_TRAN_BOP_QTD_BALANCE  = TMP.FDB_TRAN_BOP_QTD_BALANCE
                , BOP.FDB_TRAN_BOP_YTD_BALANCE  = TMP.FDB_TRAN_BOP_YTD_BALANCE
                , BOP.FDB_BASE_BOP_MTD_BALANCE  = TMP.FDB_BASE_BOP_MTD_BALANCE
                , BOP.FDB_BASE_BOP_QTD_BALANCE  = TMP.FDB_BASE_BOP_QTD_BALANCE
                , BOP.FDB_BASE_BOP_YTD_BALANCE  = TMP.FDB_BASE_BOP_YTD_BALANCE
                , BOP.FDB_LOCAL_BOP_MTD_BALANCE = TMP.FDB_LOCAL_BOP_MTD_BALANCE
                , BOP.FDB_LOCAL_BOP_QTD_BALANCE = TMP.FDB_LOCAL_BOP_QTD_BALANCE
                , BOP.FDB_LOCAL_BOP_YTD_BALANCE = TMP.FDB_LOCAL_BOP_YTD_BALANCE
                , BOP.FDB_PERIOD_MONTH = TMP.FDB_PERIOD_MONTH
                , BOP.FDB_PERIOD_QTR = TMP.FDB_PERIOD_QTR
                , BOP.FDB_PERIOD_YEAR = TMP.FDB_PERIOD_YEAR
                , BOP.FDB_PERIOD_LTD = TMP.FDB_PERIOD_LTD
                , BOP.FDB_AMENDED_ON = SYSDATE

    WHEN NOT MATCHED
    THEN
       INSERT
        (
          FDB_FAK_ID
        , FDB_BALANCE_DATE
        , FDB_BALANCE_TYPE
        , FDB_TRAN_BOP_MTD_BALANCE
        , FDB_TRAN_BOP_QTD_BALANCE
        , FDB_TRAN_BOP_YTD_BALANCE
        , FDB_BASE_BOP_MTD_BALANCE
        , FDB_BASE_BOP_QTD_BALANCE
        , FDB_BASE_BOP_YTD_BALANCE
        , FDB_LOCAL_BOP_MTD_BALANCE
        , FDB_LOCAL_BOP_QTD_BALANCE
        , FDB_LOCAL_BOP_YTD_BALANCE
        , FDB_PERIOD_MONTH
        , FDB_PERIOD_QTR
        , FDB_PERIOD_YEAR
        , FDB_PERIOD_LTD
        , FDB_AMENDED_ON
        )
        VALUES
        (
          TMP.FDB_FAK_ID
        , TMP.FDB_BALANCE_DATE
        , TMP.FDB_BALANCE_TYPE
        , TMP.FDB_TRAN_BOP_MTD_BALANCE
        , TMP.FDB_TRAN_BOP_QTD_BALANCE
        , TMP.FDB_TRAN_BOP_YTD_BALANCE
        , TMP.FDB_BASE_BOP_MTD_BALANCE
        , TMP.FDB_BASE_BOP_QTD_BALANCE
        , TMP.FDB_BASE_BOP_YTD_BALANCE
        , TMP.FDB_LOCAL_BOP_MTD_BALANCE
        , TMP.FDB_LOCAL_BOP_QTD_BALANCE
        , TMP.FDB_LOCAL_BOP_YTD_BALANCE
        , TMP.FDB_PERIOD_MONTH
        , TMP.FDB_PERIOD_QTR
        , TMP.FDB_PERIOD_YEAR
        , TMP.FDB_PERIOD_LTD
        , SYSDATE
        );
   EXECUTE IMMEDIATE 'TRUNCATE TABLE SLR.SLR_FAK_BOP_AMOUNTS_TMP';

END pGENERATE_FAK_BOP_VALUES;

PROCEDURE pFX_REVAL(p_month IN NUMBER, p_year IN NUMBER, p_event_class IN VARCHAR2, p_acc_basis IN VARCHAR2) AS

  PPROCESS VARCHAR2(40);
  PENTPROCSET VARCHAR2(20);
  PCONFIG VARCHAR2(40);
  PSOURCE VARCHAR2(40);
  PBALANCEDATE DATE;
  PRATESET VARCHAR2(20);
  GPROCID NUMBER;
 
  V_FX_DT     DATE;
  V_FX_DT_LM  DATE;
  
BEGIN

/* DEFINE AND SET MONTH-END DATES FOR FX RUN */
  V_FX_DT    := LAST_DAY(TO_DATE(TO_CHAR(LPAD(p_month||p_year,6,0)),'MMYYYY'));
  V_FX_DT_LM := ADD_MONTHS(V_FX_DT,-1);
  
/* SET ALL ENTITY ACCOUNTS THAT SHOULD BE REVALUED */

  UPDATE slr_entity_accounts
  SET EA_REVALUATION_FLAG = 'Y'
  WHERE EA_ACCOUNT IN
  (
    SELECT DISTINCT LK_MATCH_KEY2
    FROM FDR.FR_GENERAL_LOOKUP
    WHERE LK_LKT_LOOKUP_TYPE_CODE = 'FXREVAL_REBAL_ACCTS'
  );
  COMMIT;

/* UPDATE FX RUN VARIABLES */
    update fdr.fr_general_lookup
    set lk_match_key1 = p_month -- month nbr
      , lk_match_key2 = p_year -- year nbr
      , lk_match_key3 = p_event_class -- event class
      , lk_match_key4 = p_acc_basis -- accounting basis
    where lk_lkt_lookup_type_code = 'FXREVAL_RUN_VALUES'
    ;

/**********************************************************************************************************
**************************          BEGIN MONTH-END             *******************************************
**************************           FX REVALUATION             *******************************************
**************************             (FXRULE0)                *******************************************
***********************************************************************************************************/
  
  IF p_acc_basis = 'US_STAT' 
    THEN SLR.SLR_PKG.pFX_REVAL_RULE0_USSTAT(V_FX_DT_LM);
  ELSIF p_acc_basis = 'US_GAAP' 
    THEN SLR.SLR_PKG.pFX_REVAL_RULE0_USGAAP(V_FX_DT_LM) ;
  END IF;

/**********************************************************************************************************
**************************        BEGIN MONTHLY TRAFFIC         *******************************************
**************************           FX REVALUATION             *******************************************
**************************             (FXRULE2)                *******************************************
***********************************************************************************************************/

  IF p_acc_basis = 'US_STAT' 
    THEN SLR.SLR_PKG.pFX_REVAL_RULE2_USSTAT(V_FX_DT);
  ELSIF p_acc_basis = 'US_GAAP' 
    THEN SLR.SLR_PKG.pFX_REVAL_RULE2_USGAAP(V_FX_DT);
  END IF;

/**********************************************************************************************************
**************************         POST NEWLY CREATED           *******************************************
**************************           FX REVALUATION             *******************************************
**************************           JOURNAL LINES              *******************************************
***********************************************************************************************************/
  
  SLR_UTILITIES_PKG.pRunValidateAndPost ('AG', 'ENT_RATE_SET', GPROCID) ;  

/**********************************************************************************************************
**************************        BEGIN MONTHLY TRAFFIC         *******************************************
**************************           FX REVALUATION             *******************************************
**************************        SPOT VS MAVG (FXRULE1)        *******************************************
***********************************************************************************************************/
  
  IF p_acc_basis = 'US_STAT' 
    THEN SLR.SLR_PKG.pFX_REVAL_RULE1_USSTAT(V_FX_DT); -- RUN FX PROCESS
         SLR_UTILITIES_PKG.pRunValidateAndPost ('AG', 'ENT_RATE_SET', GPROCID) ; -- POST NEW LINES FROM FXRULE1 RUN   
  END IF;
  
END pFX_REVAL;

PROCEDURE pFX_REVAL_RULE0_USSTAT(v_date IN DATE) AS

  PPROCESS VARCHAR2(40);
  PENTPROCSET VARCHAR2(20);
  PCONFIG VARCHAR2(40);
  PSOURCE VARCHAR2(40);
  PBALANCEDATE DATE;
  PRATESET VARCHAR2(20);
  GPROCID NUMBER;

BEGIN
/* BEGIN FXRULE0 RUN */
/* SET ALL VARIABLE VALUES FOR FXRULE0 RUN */

  PPROCESS := 'FXREVALUE';
  PENTPROCSET := 'AG';
  PCONFIG := 'FX_AG_RULE0_USSTAT';
  PSOURCE := 'BMFXREVAL_EBA_AG_R0_USSTAT';
  PBALANCEDATE := v_date;
  PRATESET := 'FX_RULE0';
  GPROCID := NULL;


/* EXECUTE FXRULE0 RUN */
  SLR_BALANCE_MOVEMENT_PKG.pBMRunBalanceMovementProcess
  (  
        PPROCESS => PPROCESS,
        PENTPROCSET => PENTPROCSET,
        PCONFIG => PCONFIG,
        PSOURCE => PSOURCE,
        PBALANCEDATE => PBALANCEDATE,
        PRATESET => PRATESET,
        GPROCID => GPROCID
  ) ; 
  
  update SLR_JRNL_LINES_UNPOSTED
  set JLU_EFFECTIVE_DATE = add_months(JLU_EFFECTIVE_DATE,1)
   ,  JLU_VALUE_DATE = add_months(JLU_VALUE_DATE,1)
   ,  JLU_JRNL_DATE = add_months(JLU_JRNL_DATE,1)
   ,  JLU_FAK_ID = 0
   ,  JLU_EBA_ID = 0
  where jlu_jrnl_process_id = GPROCID
  ;
  commit;

/* FXRULE0 ==> UPDATE UNPOSTED FXRULE0 JOURNAL LINES WITH CORRECT ACCOUNT NUMBERS AND ACCOUNTING EVENT TYPES */

  execute immediate 'truncate table slr.slr_fx_reval_temp';
  
  insert into slr.slr_fx_reval_temp 
  (
     select 
      fgl.lk_match_key10   as adjust_offset
    , fgl.lk_lookup_value1 as fx_acccounting_event
    , fgl.lk_lookup_value2 as fx_gl_account
    , jlu.ROWID as jlu_ROWID
    from fdr.fr_general_lookup fgl
    join slr.slr_jrnl_lines_unposted jlu
    on  fgl.lk_match_key1  = jlu.jlu_segment_2 --join on accounting basis
    and fgl.lk_match_key2  = jlu.jlu_account -- join on sub-account
    and fgl.lk_match_key3  = jlu.jlu_segment_6 -- join on execution type (MTM/NON_MTM)
    and fgl.lk_match_key4  = jlu.jlu_attribute_3 -- join on premium type (U/I/M)
    and fgl.lk_match_key5  = jlu.jlu_segment_7 -- join on business type (A/AA/C/CA/D)
    and fgl.lk_match_key10 = jlu.jlu_type -- join on adjust/offset record type
    where lk_lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS'
    and jlu.jlu_jrnl_ent_rate_set = 'FX_RULE0'
  );
  
  commit;
  
  MERGE INTO 
    slr.slr_jrnl_lines_unposted jlu
  USING
    (select * from slr.slr_fx_reval_temp) tmp
  ON 
    (tmp.jlu_rowid = jlu.ROWID)
  WHEN MATCHED THEN UPDATE SET
    jlu.jlu_account     = tmp.fx_gl_account,         -- updating account number
    jlu.jlu_attribute_4 = tmp.fx_accounting_event,   -- updating accounting event
    jlu.jlu_amended_by  = 'FXPROCESS',               -- updating amended by to FX to identify all records that were updated by process
    jlu.jlu_amended_on  = sysdate                    -- updating amended time to when the process ran
  ;
  
  execute immediate 'truncate table slr.slr_fx_reval_temp';

/* FXRULE0 ==> GENERATE APPROPRIATE FAK/EBA IDs */
  
  SLR.SLR_UTILITIES_PKG.pUpdateFakEbaCombinations_Jlu (PENTPROCSET,GPROCID, 'U');  
  
  commit;

/**********************************************************************************************************
************************************* END FXRULE0 RUN *****************************************************
***********************************************************************************************************/


END pFX_REVAL_RULE0_USSTAT;

PROCEDURE pFX_REVAL_RULE1_USSTAT(v_date IN DATE) AS
   PPROCESS VARCHAR2(40);
  PENTPROCSET VARCHAR2(20);
  PCONFIG VARCHAR2(40);
  PSOURCE VARCHAR2(40);
  PBALANCEDATE DATE;
  PRATESET VARCHAR2(20);
  GPROCID NUMBER;

BEGIN
/* BEGIN FXRULE2 RUN */
/* SET ALL VARIABLE VALUES FOR FXRULE2 RUN */

  PPROCESS := 'FXREVALUE';
  PENTPROCSET := 'AG';
  PCONFIG := 'FX_AG_RULE1_USSTAT';
  PSOURCE := 'BMFXREVAL_EBA_AG_R1_USSTAT';
  PBALANCEDATE := v_date;
  PRATESET := 'FX_RULE1';
  GPROCID := NULL;


/* EXECUTE FXRULE2 RUN */
  SLR_BALANCE_MOVEMENT_PKG.pBMRunBalanceMovementProcess
  (  
        PPROCESS => PPROCESS,
        PENTPROCSET => PENTPROCSET,
        PCONFIG => PCONFIG,
        PSOURCE => PSOURCE,
        PBALANCEDATE => PBALANCEDATE,
        PRATESET => PRATESET,
        GPROCID => GPROCID
  ) ; 
  
  update SLR_JRNL_LINES_UNPOSTED
  set JLU_FAK_ID = 0
   ,  JLU_EBA_ID = 0
  where jlu_jrnl_process_id = GPROCID
  ;
  commit;

/* FXRULE2 ==> UPDATE UNPOSTED FXRULE0 JOURNAL LINES WITH CORRECT ACCOUNT NUMBERS AND ACCOUNTING EVENT TYPES */

  execute immediate 'truncate table slr.slr_fx_reval_temp';
  
  insert into slr.slr_fx_reval_temp 
  (
     select 
      fgl.lk_match_key10   as adjust_offset
    , fgl.lk_lookup_value1 as fx_acccounting_event
    , fgl.lk_lookup_value2 as fx_gl_account
    , jlu.ROWID as jlu_ROWID
    from fdr.fr_general_lookup fgl
    join slr.slr_jrnl_lines_unposted jlu
    on  fgl.lk_match_key1  = jlu.jlu_segment_2 --join on accounting basis
    and fgl.lk_match_key2  = jlu.jlu_attribute_4 -- join on accounting event
    and fgl.lk_match_key3  = jlu.jlu_segment_6 -- join on execution type (MTM/NON_MTM)
    and fgl.lk_match_key4  = jlu.jlu_attribute_3 -- join on premium type (U/I/M)
    and fgl.lk_match_key5  = jlu.jlu_segment_7 -- join on business type (A/AA/C/CA/D)
    and fgl.lk_match_key10 = jlu.jlu_type -- join on adjust/offset record type
    where lk_lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS'
    and jlu.jlu_jrnl_ent_rate_set = 'FX_RULE1'
  );
  
  commit;
  
  MERGE INTO 
    slr.slr_jrnl_lines_unposted jlu
  USING
    (select * from slr.slr_fx_reval_temp) tmp
  ON 
    (tmp.jlu_rowid = jlu.ROWID)
  WHEN MATCHED THEN UPDATE SET
    jlu.jlu_account     = tmp.fx_gl_account,         -- updating account number
    jlu.jlu_attribute_4 = tmp.fx_accounting_event,   -- updating accounting event
    jlu.jlu_amended_by  = 'FXPROCESS',               -- updating amended by to FX to identify all records that were updated by process
    jlu.jlu_amended_on  = sysdate                    -- updating amended time to when the process ran
  ;
  
  execute immediate 'truncate table slr.slr_fx_reval_temp';

/* FXRULE0 ==> GENERATE APPROPRIATE FAK/EBA IDs */
  
  SLR.SLR_UTILITIES_PKG.pUpdateFakEbaCombinations_Jlu (PENTPROCSET,GPROCID, 'U');  
  
  commit;

END pFX_REVAL_RULE1_USSTAT;


PROCEDURE pFX_REVAL_RULE2_USSTAT(v_date IN DATE) AS
   PPROCESS VARCHAR2(40);
  PENTPROCSET VARCHAR2(20);
  PCONFIG VARCHAR2(40);
  PSOURCE VARCHAR2(40);
  PBALANCEDATE DATE;
  PRATESET VARCHAR2(20);
  GPROCID NUMBER;

BEGIN
/* BEGIN FXRULE2 RUN */
/* SET ALL VARIABLE VALUES FOR FXRULE2 RUN */

  PPROCESS := 'FXREVALUE';
  PENTPROCSET := 'AG';
  PCONFIG := 'FX_AG_RULE2_USSTAT';
  PSOURCE := 'BMFXREVAL_EBA_AG_R2_USSTAT';
  PBALANCEDATE := v_date;
  PRATESET := 'FX_RULE2';
  GPROCID := NULL;


/* EXECUTE FXRULE2 RUN */
  SLR_BALANCE_MOVEMENT_PKG.pBMRunBalanceMovementProcess
  (  
        PPROCESS => PPROCESS,
        PENTPROCSET => PENTPROCSET,
        PCONFIG => PCONFIG,
        PSOURCE => PSOURCE,
        PBALANCEDATE => PBALANCEDATE,
        PRATESET => PRATESET,
        GPROCID => GPROCID
  ) ; 
  
  update SLR_JRNL_LINES_UNPOSTED
  set JLU_FAK_ID = 0
   ,  JLU_EBA_ID = 0
  where jlu_jrnl_process_id = GPROCID
  ;
  commit;

/* FXRULE2 ==> UPDATE UNPOSTED FXRULE0 JOURNAL LINES WITH CORRECT ACCOUNT NUMBERS AND ACCOUNTING EVENT TYPES */

  execute immediate 'truncate table slr.slr_fx_reval_temp';
  
  insert into slr.slr_fx_reval_temp 
  (
     select 
      fgl.lk_match_key10   as adjust_offset
    , fgl.lk_lookup_value1 as fx_acccounting_event
    , fgl.lk_lookup_value2 as fx_gl_account
    , jlu.ROWID as jlu_ROWID
    from fdr.fr_general_lookup fgl
    join slr.slr_jrnl_lines_unposted jlu
    on  fgl.lk_match_key1  = jlu.jlu_segment_2 --join on accounting basis
    and fgl.lk_match_key2  = jlu.jlu_attribute_4 -- join on accounting event
    and fgl.lk_match_key3  = jlu.jlu_segment_6 -- join on execution type (MTM/NON_MTM)
    and fgl.lk_match_key4  = jlu.jlu_attribute_3 -- join on premium type (U/I/M)
    and fgl.lk_match_key5  = jlu.jlu_segment_7 -- join on business type (A/AA/C/CA/D)
    and fgl.lk_match_key10 = jlu.jlu_type -- join on adjust/offset record type
    where lk_lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS'
    and jlu.jlu_jrnl_ent_rate_set = 'FX_RULE2'
  );
  
  commit;
  
  MERGE INTO 
    slr.slr_jrnl_lines_unposted jlu
  USING
    (select * from slr.slr_fx_reval_temp) tmp
  ON 
    (tmp.jlu_rowid = jlu.ROWID)
  WHEN MATCHED THEN UPDATE SET
    jlu.jlu_account     = tmp.fx_gl_account,         -- updating account number
    jlu.jlu_attribute_4 = tmp.fx_accounting_event,   -- updating accounting event
    jlu.jlu_amended_by  = 'FXPROCESS',               -- updating amended by to FX to identify all records that were updated by process
    jlu.jlu_amended_on  = sysdate                    -- updating amended time to when the process ran
  ;
  
  execute immediate 'truncate table slr.slr_fx_reval_temp';

/* FXRULE0 ==> GENERATE APPROPRIATE FAK/EBA IDs */
  
  SLR.SLR_UTILITIES_PKG.pUpdateFakEbaCombinations_Jlu (PENTPROCSET,GPROCID, 'U');  
  
  commit;

END pFX_REVAL_RULE2_USSTAT;

PROCEDURE pFX_REVAL_RULE0_USGAAP(v_date IN DATE) AS

  PPROCESS VARCHAR2(40);
  PENTPROCSET VARCHAR2(20);
  PCONFIG VARCHAR2(40);
  PSOURCE VARCHAR2(40);
  PBALANCEDATE DATE;
  PRATESET VARCHAR2(20);
  GPROCID NUMBER;

BEGIN
/* BEGIN FXRULE0 RUN */
/* SET ALL VARIABLE VALUES FOR FXRULE0 RUN */

  PPROCESS := 'FXREVALUE';
  PENTPROCSET := 'AG';
  PCONFIG := 'FX_AG_RULE0_USGAAP';
  PSOURCE := 'BMFXREVAL_EBA_AG_R0_USGAAP';
  PBALANCEDATE := v_date;
  PRATESET := 'FX_RULE0';
  GPROCID := NULL;


/* EXECUTE FXRULE0 RUN */
  SLR_BALANCE_MOVEMENT_PKG.pBMRunBalanceMovementProcess
  (  
        PPROCESS => PPROCESS,
        PENTPROCSET => PENTPROCSET,
        PCONFIG => PCONFIG,
        PSOURCE => PSOURCE,
        PBALANCEDATE => PBALANCEDATE,
        PRATESET => PRATESET,
        GPROCID => GPROCID
  ) ; 
  
  update SLR_JRNL_LINES_UNPOSTED
  set JLU_EFFECTIVE_DATE = add_months(JLU_EFFECTIVE_DATE,1)
   ,  JLU_VALUE_DATE = add_months(JLU_VALUE_DATE,1)
   ,  JLU_JRNL_DATE = add_months(JLU_JRNL_DATE,1)
   ,  JLU_FAK_ID = 0
   ,  JLU_EBA_ID = 0
  where jlu_jrnl_process_id = GPROCID
  ;
  commit;

/* FXRULE0 ==> UPDATE UNPOSTED FXRULE0 JOURNAL LINES WITH CORRECT ACCOUNT NUMBERS AND ACCOUNTING EVENT TYPES */

  execute immediate 'truncate table slr.slr_fx_reval_temp';
  
  insert into slr.slr_fx_reval_temp 
  (
     select 
      fgl.lk_match_key10   as adjust_offset
    , fgl.lk_lookup_value1 as fx_acccounting_event
    , fgl.lk_lookup_value2 as fx_gl_account
    , jlu.ROWID as jlu_ROWID
    from fdr.fr_general_lookup fgl
    join slr.slr_jrnl_lines_unposted jlu
    on  fgl.lk_match_key1  = jlu.jlu_segment_2 --join on accounting basis
    and fgl.lk_match_key2  = jlu.jlu_account -- join on sub-account
    and fgl.lk_match_key3  = jlu.jlu_segment_6 -- join on execution type (MTM/NON_MTM)
    and fgl.lk_match_key4  = jlu.jlu_attribute_3 -- join on premium type (U/I/M)
    and fgl.lk_match_key5  = jlu.jlu_segment_7 -- join on business type (A/AA/C/CA/D)
    and fgl.lk_match_key10 = jlu.jlu_type -- join on adjust/offset record type
    where lk_lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS'
    and jlu.jlu_jrnl_ent_rate_set = 'FX_RULE0'
  );
  
  commit;
  
  MERGE INTO 
    slr.slr_jrnl_lines_unposted jlu
  USING
    (select * from slr.slr_fx_reval_temp) tmp
  ON 
    (tmp.jlu_rowid = jlu.ROWID)
  WHEN MATCHED THEN UPDATE SET
    jlu.jlu_account     = tmp.fx_gl_account,         -- updating account number
    jlu.jlu_attribute_4 = tmp.fx_accounting_event,   -- updating accounting event
    jlu.jlu_amended_by  = 'FXPROCESS',               -- updating amended by to FX to identify all records that were updated by process
    jlu.jlu_amended_on  = sysdate                    -- updating amended time to when the process ran
  ;
  
  execute immediate 'truncate table slr.slr_fx_reval_temp';

/* FXRULE0 ==> GENERATE APPROPRIATE FAK/EBA IDs */
  
  SLR.SLR_UTILITIES_PKG.pUpdateFakEbaCombinations_Jlu (PENTPROCSET,GPROCID, 'U');  
  
  commit;

/**********************************************************************************************************
************************************* END FXRULE0 RUN *****************************************************
***********************************************************************************************************/


END pFX_REVAL_RULE0_USGAAP;

PROCEDURE pFX_REVAL_RULE2_USGAAP(v_date IN DATE) AS
   PPROCESS VARCHAR2(40);
  PENTPROCSET VARCHAR2(20);
  PCONFIG VARCHAR2(40);
  PSOURCE VARCHAR2(40);
  PBALANCEDATE DATE;
  PRATESET VARCHAR2(20);
  GPROCID NUMBER;

BEGIN
/* BEGIN FXRULE2 RUN */
/* SET ALL VARIABLE VALUES FOR FXRULE2 RUN */

  PPROCESS := 'FXREVALUE';
  PENTPROCSET := 'AG';
  PCONFIG := 'FX_AG_RULE2_USGAAP';
  PSOURCE := 'BMFXREVAL_EBA_AG_R2_USGAAP';
  PBALANCEDATE := v_date;
  PRATESET := 'FX_RULE2';
  GPROCID := NULL;


/* EXECUTE FXRULE2 RUN */
  SLR_BALANCE_MOVEMENT_PKG.pBMRunBalanceMovementProcess
  (  
        PPROCESS => PPROCESS,
        PENTPROCSET => PENTPROCSET,
        PCONFIG => PCONFIG,
        PSOURCE => PSOURCE,
        PBALANCEDATE => PBALANCEDATE,
        PRATESET => PRATESET,
        GPROCID => GPROCID
  ) ; 
  
  update SLR_JRNL_LINES_UNPOSTED
  set JLU_FAK_ID = 0
   ,  JLU_EBA_ID = 0
  where jlu_jrnl_process_id = GPROCID
  ;
  commit;

/* FXRULE2 ==> UPDATE UNPOSTED FXRULE0 JOURNAL LINES WITH CORRECT ACCOUNT NUMBERS AND ACCOUNTING EVENT TYPES */

  execute immediate 'truncate table slr.slr_fx_reval_temp';
  
  insert into slr.slr_fx_reval_temp 
  (
     select 
      fgl.lk_match_key10   as adjust_offset
    , fgl.lk_lookup_value1 as fx_acccounting_event
    , fgl.lk_lookup_value2 as fx_gl_account
    , jlu.ROWID as jlu_ROWID
    from fdr.fr_general_lookup fgl
    join slr.slr_jrnl_lines_unposted jlu
    on  fgl.lk_match_key1  = jlu.jlu_segment_2 --join on accounting basis
    and fgl.lk_match_key2  = jlu.jlu_attribute_4 -- join on accounting event
    and fgl.lk_match_key3  = jlu.jlu_segment_6 -- join on execution type (MTM/NON_MTM)
    and fgl.lk_match_key4  = jlu.jlu_attribute_3 -- join on premium type (U/I/M)
    and fgl.lk_match_key5  = jlu.jlu_segment_7 -- join on business type (A/AA/C/CA/D)
    and fgl.lk_match_key10 = jlu.jlu_type -- join on adjust/offset record type
    where lk_lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS'
    and jlu.jlu_jrnl_ent_rate_set = 'FX_RULE2'
  );
  
  commit;
  
  MERGE INTO 
    slr.slr_jrnl_lines_unposted jlu
  USING
    (select * from slr.slr_fx_reval_temp) tmp
  ON 
    (tmp.jlu_rowid = jlu.ROWID)
  WHEN MATCHED THEN UPDATE SET
    jlu.jlu_account     = tmp.fx_gl_account,         -- updating account number
    jlu.jlu_attribute_4 = tmp.fx_accounting_event,   -- updating accounting event
    jlu.jlu_amended_by  = 'FXPROCESS',               -- updating amended by to FX to identify all records that were updated by process
    jlu.jlu_amended_on  = sysdate                    -- updating amended time to when the process ran
  ;
  
  execute immediate 'truncate table slr.slr_fx_reval_temp';

/* FXRULE0 ==> GENERATE APPROPRIATE FAK/EBA IDs */
  
  SLR.SLR_UTILITIES_PKG.pUpdateFakEbaCombinations_Jlu (PENTPROCSET,GPROCID, 'U');  
  
  commit;

END pFX_REVAL_RULE2_USGAAP;

PROCEDURE pYECleardown(pConfig      IN slr_process_config.pc_config%TYPE
                                      ,pSource      IN slr_process_source.sps_source_name%TYPE
                                      ,pBalanceDate IN DATE )                                                                                  
                                       
as

    s_proc_name varchar2(50) := $$plsql_unit || '.' || $$plsql_function ;     
    pProcess   slr_process.p_process%TYPE := 'PLRETEARNINGS';
    pEntProcSet slr_bm_entity_processing_set.bmeps_set_id%TYPE :='AG';
    pRateSet  slr_entity_rates.er_entity_set%TYPE := NULL;
    gProcId  number;

  begin
  
  slr.slr_balance_movement_pkg.pBMRunBalanceMovementProcess (pProcess,pEntProcSet,pConfig,pSource,pBalanceDate,pRateSet,gProcId);
  
end pYECleardown;                                        



END SLR_PKG;
/