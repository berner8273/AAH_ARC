set define off;
--------------------------------------------------------
--  DDL for Package SLR_CLIENT_PROCEDURES_PKG
--------------------------------------------------------
CREATE OR REPLACE PACKAGE  "SLR"."SLR_CLIENT_PROCEDURES_PKG" AS
---------------------------------------------------------------------------------
-- Id:          $Id: SLR_CLIENT_PROCEDURES_PKG.sql,v 1 2007/08/22 11:17:51 jporter Exp $
--
-- Description: Client specific custom procedures - created from
--              SLR_CLIENT_PROCEDURES_PKG template package
--
-- Note:        THIS PACKAGE IS NOT CORE SLR
--              THIS PROCEDURE IS NOT SUPPORTED BY CORE MAINTENANCE.
--
---------------------------------------------------------------------------------
-- History:
-- BJP 22-08-2007 Initial Creation
---------------------------------------------------------------------------------
-- Control/Batch Schedule Wrapper Processes
---------------------------------------------------------------------------------
PROCEDURE pPROCESS_SLR
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.epg_id%TYPE,
	p_rate_set IN slr_entities.ent_rate_set%TYPE
);

PROCEDURE pCHECK_JRNL_ERRORS(p_entity in VARCHAR2);

---------------------------------------------------------------------------------
-- Entity or entity set specifc date routines. See SLR_UTILITIES_PKG for others.
---------------------------------------------------------------------------------
PROCEDURE pROLL_ENTITY_DATE(p_entity IN VARCHAR2, p_business_date in DATE DEFAULT NULL, p_update_end_date in CHAR DEFAULT 'Y');
PROCEDURE pINSERT_SLR_ENTITY_DAYS (p_start_date  in date,
                                   p_end_date    in date,
                                   p_entity_set  in VARCHAR2);

PROCEDURE pINSERT_SLR_ENTITY_PERIODS (p_start_bus_year_month in NUMBER,
                                      p_start_date           in date,
                                      p_end_date             in date,
                                      p_entity               in VARCHAR2);
PROCEDURE pUPDATE_NON_WORKING_DAYS(p_entity in VARCHAR2);

---------------------------------------------------------------------------------
-- Import Procedures
---------------------------------------------------------------------------------
PROCEDURE pIMPORT_SLR_ALL_JRNLS
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.epg_id%TYPE,
    p_process_id IN NUMBER
);
PROCEDURE pIMPORT_SLR_JRNLS
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.epg_id%TYPE,
    p_process_id IN NUMBER
);

---------------------------------------------------------------------------------
-- Static Data Loads
---------------------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_ACCOUNTS(p_entity in VARCHAR2);
PROCEDURE pUPDATE_SLR_CURRENCIES(p_entity in VARCHAR2);
PROCEDURE pUPDATE_SLR_ENTITY_RATES(p_entity in VARCHAR2,
                                   p_business_date in DATE DEFAULT NULL);
PROCEDURE pUPDATE_SLR_SEGMENT_3(p_entity in VARCHAR2);
PROCEDURE pUPDATE_SLR_SEGMENT_4(p_entity in VARCHAR2);
PROCEDURE pUPDATE_SLR_SEGMENT_5(p_entity in VARCHAR2);
PROCEDURE pUPDATE_SLR_SEGMENT_6(p_entity in VARCHAR2);


---------------------------------------------------------------------------------
-- Reconciliations
---------------------------------------------------------------------------------
PROCEDURE pREC_AET_JRNLS (p_epg_id IN VARCHAR2,
                            p_entity IN VARCHAR2 DEFAULT NULL,
                            p_date_from IN DATE DEFAULT NULL,
                            p_date_to IN DATE DEFAULT NULL);

PROCEDURE pSLR_INTERNAL_REC (p_epg_id IN VARCHAR2,
                            p_entity IN VARCHAR2 DEFAULT NULL,
                            p_date_from IN DATE DEFAULT NULL,
                            p_date_to IN DATE DEFAULT NULL);

procedure pCustRunBalanceMovementProcess( pProcess     IN slr_process.p_process%TYPE
                                         ,pEntProcSet  IN slr_bm_entity_processing_set.bmeps_set_id%TYPE
                                         ,pConfig      IN slr_process_config.pc_config%TYPE
                                         ,pSource      IN slr_process_source.sps_source_name%TYPE
                                         ,pBalanceDate IN DATE
                                         ,pRateSet     IN slr_entity_rates.er_entity_set%TYPE
                                        );

END SLR_CLIENT_PROCEDURES_PKG;

/

--------------------------------------------------------
--  DDL for Package Body SLR_CLIENT_PROCEDURES_PKG
--------------------------------------------------------

  create or replace PACKAGE BODY       "SLR_CLIENT_PROCEDURES_PKG" AS
---------------------------------------------------------------------------------
-- Id:          $Id: SLR_CLIENT_PROCEDURES_PKG.sql,v 1 2007/08/22 11:17:51 jporter Exp $
--
-- Description: Client specific custom procedures - created from
--              SLR_CLIENT_PROCEDURES_PKG template package
--
-- Note:        THIS PACKAGE IS NOT CORE SLR
--              THIS PROCEDURE IS NOT SUPPORTED BY CORE MAINTENANCE.
--
---------------------------------------------------------------------------------
-- History:
-- BJP 22-08-2007 Initial Creation
---------------------------------------------------------------------------------

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
PROCEDURE pPROCESS_SLR
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
	p_rate_set IN slr_entities.ent_rate_set%TYPE
)
AS

    s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pPROCESS_SLR';
    lv_process_id NUMBER(30) := 0;
    lv_lock_handle VARCHAR2(100);
    lv_lock_result INTEGER;
    lvCount NUMBER;
    lv_use_headers 	boolean;
    
	lv_START_TIME 	PLS_INTEGER := 0;

BEGIN
    ----------------------------------------
    -- Set processId for whole processing
    ----------------------------------------
    SELECT SEQ_PROCESS_NUMBER.NEXTVAL INTO lv_process_id  FROM DUAL;

    -- ----------------------------------------------------------------------
    -- 01-JUN-2010    pUpdateJrnlLinesUnposted has to be called to copy data
    --                from SLR_JRNL_HEADERS_UNPOSTED to SLR_JRNL_LINES_UNPOSTED.
    --                Optimised Sub Ledger validation and posting processes ignore SLR_JRNL_HEADERS_UNPOSTED table.
    --                All necessary data should be present in SLR_JRNL_LINES_UNPOSTED table.
    -- ----------------------------------------------------------------------
    SLR_UTILITIES_PKG.pUpdateJrnlLinesUnposted(p_entity_proc_group);
    COMMIT;

    --------------------
    -- Lock request
    --------------------
    -- Lock is needed, because we can't handle more than one processing for the same entity group.

    DBMS_LOCK.ALLOCATE_UNIQUE('MAH_PROCESS_SLR_' || p_entity_proc_group, lv_lock_handle);

    lv_lock_result := DBMS_LOCK.REQUEST(lv_lock_handle, DBMS_LOCK.X_MODE, 5);
    IF lv_lock_result != 0 THEN
		 gv_msg := 'Can''t acquire lock for pProcessSlr for entity group ' || p_entity_proc_group ||
	                '. Probably another processing for this entity group is running.';
        
	    pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_SLRFUNC, s_proc_name, null, null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        SLR_ADMIN_PKG.Error('ERROR in ' || s_proc_name || ': ' || gv_msg);
        RAISE e_lock_acquire_error;
    ELSE
        ----------------------
        -- Main processing
        ----------------------
		lv_START_TIME:=DBMS_UTILITY.GET_TIME();
        pIMPORT_SLR_JRNLS(p_entity_proc_group, lv_process_id);
		SLR_ADMIN_PKG.PerfInfo( 'Import JL function. Import journal function execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

		----------------------------------------------------------------------
        -- Assign existing journals to current batch
		-- Mark Jrnl Lines from previous runs as Unposted
		----------------------------------------------------------------------
		lv_START_TIME:=DBMS_UTILITY.GET_TIME();
        SLR_UTILITIES_PKG.pResetFailedJournals(p_entity_proc_group, lv_process_id, lv_use_headers);
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
        AND JLU_EPG_ID = p_entity_proc_group
        AND ROWNUM <= 1;

        IF lvCount >= 1 THEN
            ----------------------
            -- Validate and Post
            ----------------------
			lv_START_TIME:=DBMS_UTILITY.GET_TIME();
            SLR_VALIDATE_JOURNALS_PKG.pValidateJournals(p_epg_id => p_entity_proc_group, p_process_id => lv_process_id, p_UseHeaders => lv_use_headers, p_rate_set => p_rate_set);
			SLR_ADMIN_PKG.PerfInfo( 'Validate function. Validate function execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');
			lv_START_TIME:=DBMS_UTILITY.GET_TIME();
            SLR_POST_JOURNALS_PKG.pPostJournals(p_epg_id => p_entity_proc_group, p_process_id => lv_process_id, p_UseHeaders => lv_use_headers, p_rate_set => p_rate_set);
			SLR_ADMIN_PKG.PerfInfo( 'Post Journals. Post Journals function execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

        ELSE
            -- Log a message - 0 indicates it is an informational message
            pr_error(0, 'Sub-Ledger posting not performed for Entity Processing Group ' || p_entity_proc_group || '.  No journals to post.',
                                0, s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', null, 'Entity', 'SLR', 'PL/SQL', SQLCODE);
        END IF;

        --------------------
        -- Lock release
        --------------------
        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
    END IF;

EXCEPTION
WHEN e_lock_acquire_error THEN
        -- error was logged before
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pPROCESS_SLR');
    WHEN OTHERS THEN
        lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, '', 'Error in pPROCESS_SLR for entity group ' || p_entity_proc_group, lv_process_id, p_entity_proc_group);
        SLR_ADMIN_PKG.Error('Error in pPROCESS_SLR for entity group ' || p_entity_proc_group);
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
    cJOURNAL_HEADER_EXPRESSION CONSTANT VARCHAR2(500) := 'ae_aet_acc_event_type_id||ae_posting_date||ae_gl_entity||ae_acc_event_id||ae_posting_schema||ae_gaap||ae_source_system||to_char(ae_reverse_date, ''YYYYMMDD'')||ae_journal_type';
    
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

    lv_sql := '
      insert /*+ append */ first 
       when jlu_effective_date <= :v_business_date then into slr_jrnl_lines_unposted subpartition for ('''||p_entity_proc_group||''', ''U'') (
        jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id, jlu_eba_id, jlu_jrnl_status, jlu_jrnl_status_text, jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id, jlu_effective_date, jlu_value_date, 
        jlu_entity, jlu_epg_id, jlu_account, jlu_segment_1, jlu_segment_2, jlu_segment_3, jlu_segment_4, jlu_segment_5, jlu_segment_6, jlu_segment_7, jlu_segment_8, jlu_segment_9, jlu_segment_10, 
        jlu_attribute_1, jlu_attribute_2, jlu_attribute_3, jlu_attribute_4, jlu_attribute_5, jlu_reference_1, jlu_reference_2, jlu_reference_3, jlu_reference_4, jlu_reference_5, jlu_reference_6, 
        jlu_reference_7, jlu_reference_8, jlu_reference_9, jlu_reference_10, jlu_tran_ccy, jlu_tran_amount, jlu_base_rate, jlu_base_ccy, jlu_base_amount, jlu_local_rate, jlu_local_ccy, jlu_local_amount, 
        jlu_created_by, jlu_created_on, jlu_amended_by, jlu_amended_on, jlu_jrnl_type, jlu_jrnl_description, jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by, jlu_jrnl_authorised_on, 
        jlu_jrnl_validated_by, jlu_jrnl_validated_on, jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit, jlu_jrnl_total_hash_credit, jlu_jrnl_ref_id, jlu_jrnl_rev_date, jlu_translation_date,
        jlu_period_month,  jlu_period_year, jlu_period_ltd
      ) values (
        jlu_jrnl_hdr_id, jlu_jrnl_line_number, 
        standard_hash(jlu_entity||jlu_epg_id||jlu_account||jlu_segment_1||jlu_segment_2||jlu_segment_3||jlu_segment_4||jlu_segment_5||jlu_segment_6||jlu_segment_7||jlu_segment_8||jlu_segment_9||jlu_segment_10||jlu_tran_ccy, ''MD5''),
        standard_hash(
          jlu_entity||jlu_epg_id||jlu_account||jlu_segment_1||jlu_segment_2||jlu_segment_3||jlu_segment_4||jlu_segment_5||jlu_segment_6||jlu_segment_7||jlu_segment_8||jlu_segment_9||jlu_segment_10||jlu_tran_ccy||
          jlu_attribute_1||jlu_attribute_2||jlu_attribute_3||jlu_attribute_4||jlu_attribute_5,
        ''MD5''), 
        jlu_jrnl_status, jlu_jrnl_status_text, jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id, jlu_effective_date, jlu_value_date, 
        jlu_entity, jlu_epg_id, jlu_account, jlu_segment_1, jlu_segment_2, jlu_segment_3, jlu_segment_4, jlu_segment_5, jlu_segment_6, jlu_segment_7, jlu_segment_8, jlu_segment_9, jlu_segment_10, 
        jlu_attribute_1, jlu_attribute_2, jlu_attribute_3, jlu_attribute_4, jlu_attribute_5, jlu_reference_1, jlu_reference_2, jlu_reference_3, jlu_reference_4, jlu_reference_5, jlu_reference_6, 
        jlu_reference_7, jlu_reference_8, jlu_reference_9, jlu_reference_10, jlu_tran_ccy, jlu_tran_amount, jlu_base_rate, jlu_base_ccy, jlu_base_amount, jlu_local_rate, jlu_local_ccy, jlu_local_amount, 
        jlu_created_by, jlu_created_on, jlu_amended_by, jlu_amended_on, jlu_jrnl_type, jlu_jrnl_description, jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by, jlu_jrnl_authorised_on, 
        jlu_jrnl_validated_by, jlu_jrnl_validated_on, jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit, jlu_jrnl_total_hash_credit, jlu_jrnl_ref_id, jlu_jrnl_rev_date, jlu_translation_date,
        jlu_period_month,  jlu_period_year, jlu_period_ltd        
      ) when jlu_effective_date > :v_business_date then into slr_jrnl_lines_unposted subpartition for ('''||p_entity_proc_group||''', ''W'') ( 
        jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id, jlu_eba_id, 
        jlu_jrnl_status, jlu_jrnl_status_text, jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id, jlu_effective_date, jlu_value_date, 
        jlu_entity, jlu_epg_id, jlu_account, jlu_segment_1, jlu_segment_2, jlu_segment_3, jlu_segment_4, jlu_segment_5, jlu_segment_6, jlu_segment_7, jlu_segment_8, jlu_segment_9, jlu_segment_10, 
        jlu_attribute_1, jlu_attribute_2, jlu_attribute_3, jlu_attribute_4, jlu_attribute_5, jlu_reference_1, jlu_reference_2, jlu_reference_3, jlu_reference_4, jlu_reference_5, jlu_reference_6, 
        jlu_reference_7, jlu_reference_8, jlu_reference_9, jlu_reference_10, jlu_tran_ccy, jlu_tran_amount, jlu_base_rate, jlu_base_ccy, jlu_base_amount, jlu_local_rate, jlu_local_ccy, jlu_local_amount, 
        jlu_created_by, jlu_created_on, jlu_amended_by, jlu_amended_on, jlu_jrnl_type, jlu_jrnl_description, jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by, jlu_jrnl_authorised_on, 
        jlu_jrnl_validated_by, jlu_jrnl_validated_on, jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit, jlu_jrnl_total_hash_credit, jlu_jrnl_ref_id, jlu_jrnl_rev_date, jlu_translation_date,
        jlu_period_month,  jlu_period_year, jlu_period_ltd
      ) values (
        jlu_jrnl_hdr_id, jlu_jrnl_line_number, null, null, jlu_jrnl_status, jlu_jrnl_status_text, jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id, jlu_effective_date, jlu_value_date, 
        jlu_entity, jlu_epg_id, jlu_account, jlu_segment_1, jlu_segment_2, jlu_segment_3, jlu_segment_4, jlu_segment_5, jlu_segment_6, jlu_segment_7, jlu_segment_8, jlu_segment_9, jlu_segment_10, 
        jlu_attribute_1, jlu_attribute_2, jlu_attribute_3, jlu_attribute_4, jlu_attribute_5, jlu_reference_1, jlu_reference_2, jlu_reference_3, jlu_reference_4, jlu_reference_5, jlu_reference_6, 
        jlu_reference_7, jlu_reference_8, jlu_reference_9, jlu_reference_10, jlu_tran_ccy, jlu_tran_amount, jlu_base_rate, jlu_base_ccy, jlu_base_amount, jlu_local_rate, jlu_local_ccy, jlu_local_amount, 
        jlu_created_by, jlu_created_on, jlu_amended_by, jlu_amended_on, jlu_jrnl_type, jlu_jrnl_description, jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by, jlu_jrnl_authorised_on, 
        jlu_jrnl_validated_by, jlu_jrnl_validated_on, jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit, jlu_jrnl_total_hash_credit, jlu_jrnl_ref_id, jlu_jrnl_rev_date, jlu_translation_date,
        jlu_period_month,  jlu_period_year, jlu_period_ltd        
      ) 
      select ' || SLR_UTILITIES_PKG.fHint(p_entity_proc_group, 'IMPORT_INSERT_UNPOSTED') || '
        standard_hash('|| cJOURNAL_HEADER_EXPRESSION ||'||to_char(:process_id___1), ''MD5'') as jlu_jrnl_hdr_id,
        rn as jlu_jrnl_line_number,
        ''U'' as jlu_jrnl_status,
        null as jlu_jrnl_status_text,
        :process_id___1 as jlu_jrnl_process_id,
        ae_gl_narrative as jlu_description,
        ae_acc_event_id as jlu_source_jrnl_id,
        ae_posting_date as jlu_effective_date,
        nvl(ae_value_date, ae_posting_date) as jlu_value_date,
        ae_gl_entity as jlu_entity,
        ae_epg_id as jlu_epg_id,
        ae_gl_account as jlu_account,
        ae_posting_schema as jlu_segment_1,
        ae_gaap as jlu_segment_2,
        ae_gl_book as jlu_segment_3,
        ae_gl_instr_super_class as jlu_segment_4,
        ae_gl_instrument_id as jlu_segment_5,
        ae_gl_party_business_id as jlu_segment_6,
        ''NVS'' as jlu_segment_7,
        ''NVS'' as jlu_segment_8,
        ''NVS'' as jlu_segment_9,
        ''NVS'' as jlu_segment_10,
        ae_fdr_tran_no as jlu_attribute_1,
        ae_source_system as jlu_attribute_2,
        ae_gl_person_id as jlu_attribute_3,
        ''NVS'' as jlu_attribute_4,
        ''NVS'' as jlu_attribute_5,
        ae_client_spare_id1 as jlu_reference_1,
        ae_client_spare_id2 as jlu_reference_2,
        ae_client_spare_id3 as jlu_reference_3,
        ae_client_spare_id4 as jlu_reference_4,
        ae_client_spare_id5 as jlu_reference_5,
        ae_client_spare_id6 as jlu_reference_6,
        :business_date___2 as jlu_reference_7,
        ae_accevent_id as jlu_reference_8,
        ae_aet_acc_event_type_id as jlu_reference_9,
        to_char(ae_accevent_date,''DDMMYYYY'') as jlu_reference_10,
        ae_iso_currency_code as jlu_tran_ccy,
        ae_amount as jlu_tran_amount,
        ae_base_rate as jlu_base_rate,
        ent_base_ccy as jlu_base_ccy,
        case when ent_apply_fx_translation = ''Y'' or ae_base_amount is not null then ae_base_amount else 0 end as jlu_base_amount,
        ae_local_rate as jlu_local_rate,
        ent_local_ccy as jlu_local_ccy,
        case when ent_apply_fx_translation = ''Y'' or ae_local_amount is not null then ae_local_amount else 0 end as jlu_local_amount,
        :user___3 as jlu_created_by,
        :gp_todays_bus_date___4 as jlu_created_on,
        :user___5 as jlu_amended_by,
        :gp_todays_bus_date___6 as jlu_amended_on,
        ae_journal_type as jlu_jrnl_type,
        null as jlu_jrnl_description,
        ae_source_system as jlu_jrnl_source,
        ae_acc_event_id as jlu_jrnl_source_jrnl_id,
        ''SLR'' as jlu_jrnl_authorised_by,
        ''' || lvAuthOn || ''' as jlu_jrnl_authorised_on,
        null as jlu_jrnl_validated_by,
        null as jlu_jrnl_validated_on,
        null as jlu_jrnl_posted_by,
        null as jlu_jrnl_posted_on,
        0 as jlu_jrnl_total_hash_debit,
        0 as jlu_jrnl_total_hash_credit,
        null as jlu_jrnl_ref_id,
        ae_reverse_date as jlu_jrnl_rev_date,
        nvl(ae_translation_date, ae_posting_date) as jlu_translation_date,
        ep_bus_period as jlu_period_month, ep_bus_year as jlu_period_year, case when ea_account_type_flag = ''P'' then ep_bus_year else 1 end as jlu_period_ltd
      from (select ae.*, rownum as rn from fr_accounting_event ae where ae_epg_id = '''||p_entity_proc_group||''' and ae_posting_date <= :business_date___7) ae
        left join slr_entities on ent_entity = ae_gl_entity
        left join slr_entity_accounts on ea_account = ae_gl_account and ea_entity_set = ent_accounts_set 
        left join slr_entity_periods on ae_posting_date between ep_cal_period_start and ep_cal_period_end and ep_entity = ae_gl_entity and ep_period_type != 0
    ';
      
    SLR_ADMIN_PKG.Debug('Importing AE', lv_sql);
    lv_START_TIME:=DBMS_UTILITY.GET_TIME();
    EXECUTE IMMEDIATE lv_sql USING lv_business_date, lv_business_date, p_process_id, p_process_id, lv_business_date, lv_user, lv_gp_todays_bus_date, lv_user, lv_gp_todays_bus_date, lv_business_date;

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

--------------------------------------------------------------------------

-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_SEGMENT_3
-- Function:       Insert data into SLR_FAK_SEGMENT_3
-- Note:           For Segment 3 relates to Book
--                 Link Book to Party Legal via BO_PL_LEDGER_ENTITY_CODE
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_SEGMENT_3(p_entity IN VARCHAR2) AS

lvUser       VARCHAR2(50);
lvWhen       DATE;
s_proc_name  VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_3';
lvEntitySet SLR_ENTITIES.ENT_SEGMENT_3_SET%TYPE;

BEGIN

    -- Initialize local variables
    lvWhen := trunc(sysdate);

    SELECT USER INTO lvUser FROM DUAL;

    SELECT ENT_SEGMENT_3_SET
    INTO   lvEntitySet
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    DELETE FROM SLR_FAK_SEGMENT_3 WHERE FS3_ENTITY_SET = lvEntitySet;

    INSERT INTO SLR_FAK_SEGMENT_3 (
        FS3_ENTITY_SET,
        FS3_SEGMENT_VALUE,
        FS3_SEGMENT_DESCRIPTION,
        FS3_STATUS,
        FS3_CREATED_BY,
        FS3_CREATED_ON,
        FS3_AMENDED_BY,
        FS3_AMENDED_ON)
    SELECT
        lvEntitySet,
        BO_BOOK_ID,
        BO_BOOK_NAME,
        'A',
        lvUser,
        lvWhen,
        lvUser,
        lvWhen
    FROM
        FR_BOOK frbk,
        FR_PARTY_LEGAL frpl
    WHERE
        frbk.BO_PL_LEDGER_ENTITY_CODE = frpl.PL_PARTY_LEGAL_ID
    AND p_entity                      = frpl.PL_PARTY_LEGAL_ID;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 3, invalid entity supplied: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_3', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);

    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 3: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_3', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_SLR_SEGMENT_3: ' || SQLERRM);


END pUPDATE_SLR_SEGMENT_3;

-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_SEGMENT_4
-- Function:       Insert data into SLR_FAK_SEGMENT_4
-- Note:           This is Instrument Type (Product) here
--                 There is no link from Instrument Type to Party Legal
--                 so will load all Instrument Types for the specified
--                 entity set.
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_SEGMENT_4(p_entity IN VARCHAR2) AS

lvUser      VARCHAR2(50);
lvWhen      DATE;
s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_4';
lvEntitySet SLR_ENTITIES.ENT_SEGMENT_4_SET%TYPE;

BEGIN

    -- Initialize local variables
    lvWhen := trunc(sysdate);

    SELECT USER INTO lvUser FROM DUAL;

    SELECT ENT_SEGMENT_4_SET
    INTO   lvEntitySet
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    DELETE FROM SLR_FAK_SEGMENT_4 WHERE FS4_ENTITY_SET = lvEntitySet;

    INSERT INTO SLR_FAK_SEGMENT_4 (
        FS4_ENTITY_SET,
        FS4_SEGMENT_VALUE,
        FS4_SEGMENT_DESCRIPTION,
        FS4_STATUS,
        FS4_CREATED_BY,
        FS4_CREATED_ON,
        FS4_AMENDED_BY,
        FS4_AMENDED_ON)
    SELECT
        lvEntitySet,
        IT_INSTR_TYPE_ID,
        IT_INSTR_TYPE_NAME,
        'A',
        lvUser,
        lvWhen,
        lvUser,
        lvWhen
    FROM
        FR_INSTRUMENT_TYPE
    WHERE
        IT_INSTR_TYPE_ID != '1';

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 4, invalid entity  supplied: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_4', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 4: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_4', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_SLR_SEGMENT_4: ' || SQLERRM);

END pUPDATE_SLR_SEGMENT_4;

-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_SEGMENT_5
-- Function:       Insert data into SLR_FAK_SEGMENT_5
-- Note:           This is Instrument here
--                 There is no link from Instrument to Party Legal so will
--                 load all Instrument for the specified entity set.
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_SEGMENT_5(p_entity in VARCHAR2) AS

lvUser VARCHAR2(50);
lvWhen DATE;
s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_5';
lvEntitySet SLR_ENTITIES.ENT_SEGMENT_5_SET%TYPE;

BEGIN

    -- Initialize local variables
    lvWhen := trunc(sysdate);

    SELECT USER INTO lvUser FROM DUAL;

    SELECT ENT_SEGMENT_5_SET
    INTO   lvEntitySet
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    DELETE FROM SLR_FAK_SEGMENT_5 WHERE FS5_ENTITY_SET = lvEntitySet;

    INSERT INTO SLR_FAK_SEGMENT_5 (
        FS5_ENTITY_SET,
        FS5_SEGMENT_VALUE,
        FS5_SEGMENT_DESCRIPTION,
        FS5_STATUS,
        FS5_CREATED_BY,
        FS5_CREATED_ON,
        FS5_AMENDED_BY,
        FS5_AMENDED_ON)
    SELECT
        lvEntitySet,
        I_INSTRUMENT_ID,
        I_INSTR_DESC_LINE1,
        'A',
        lvUser,
        lvWhen,
        lvUser,
        lvWhen
    FROM
        FR_INSTRUMENT
    WHERE
        I_INSTRUMENT_ID != '1'
    AND I_SHARED_FLAG    = '1';

    COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 5, invalid entity supplied: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_5', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
  WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 5: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_5', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_SLR_SEGMENT_5: ' || SQLERRM);

END pUPDATE_SLR_SEGMENT_5;

-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_SEGMENT_6
-- Function:       Insert data into SLR_FAK_SEGMENT_6
-- Note:           This is Counterparty here
--                 There is no link from Party Business to the internal
--                 Party Legal at present so this loads all Counterparties
--                 to the specified entity set.  If required this
--                 relationship could be loaded from Global Client
--                 Could add a filter on party type if required.
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_SEGMENT_6(p_entity IN VARCHAR2) AS

lvUser      VARCHAR2(50);
lvWhen      DATE;
s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_SEGMENT_6';
lvEntitySet SLR_ENTITIES.ENT_SEGMENT_6_SET%TYPE;

BEGIN

    -- Initialize local variables
    lvWhen := trunc(sysdate);

    SELECT USER INTO lvUser FROM DUAL;

    SELECT ENT_SEGMENT_6_SET
    INTO   lvEntitySet
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    DELETE FROM SLR_FAK_SEGMENT_6 WHERE FS6_ENTITY_SET = lvEntitySet;

    INSERT INTO SLR_FAK_SEGMENT_6 (
        FS6_ENTITY_SET,
        FS6_SEGMENT_VALUE,
        FS6_SEGMENT_DESCRIPTION,
        FS6_STATUS,
        FS6_CREATED_BY,
        FS6_CREATED_ON,
        FS6_AMENDED_BY,
        FS6_AMENDED_ON)
    SELECT
        lvEntitySet,
        PBU_PARTY_BUSINESS_ID,
        PBU_NAME,
        'A',
        lvUser,
        lvWhen,
        lvUser,
        lvWhen
    FROM
        FR_PARTY_BUSINESS
    WHERE
        PBU_PARTY_BUSINESS_ID != '1';

    COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 6, invalid entity supplied: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_6', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
  WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert segment 6: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_FAK_SEGMENT_6', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_SLR_SEGMENT_6: ' || SQLERRM);

END pUPDATE_SLR_SEGMENT_6;

-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_CURRENCIES
-- Function:       Insert data into SLR_ENTITY_CURRENCIES
-- Note:           All entities will probably share the same currency but
--                 this can be run per entity in each batch per entity to
--                 ensure it is always up to date
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_CURRENCIES(p_entity IN VARCHAR2) AS

s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_CURRENCIES';
lvEntitySet SLR_ENTITIES.ENT_CURRENCY_SET%TYPE;

BEGIN

    SELECT ENT_CURRENCY_SET
    INTO   lvEntitySet
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    SLR_FDR_PROCEDURES_PKG.PUPDATE_SLR_CURRENCIES(lvEntitySet);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert currencies, unable to obtain entity set: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
  WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert currencies: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_CURRENCIES', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_SLR_CURRENCIES: ' || SQLERRM);

END pUPDATE_SLR_CURRENCIES;

-- -----------------------------------------------------------------------
-- Procedure:      pUPDATE_SLR_ACCOUNTS
-- Function:       Insert data into SLR_ENTITY_ACCOUNTS
-- Note:           All entities will probably share the same accounts but
--                 this can be run per entity in each batch per entity to
--                 ensure it is always up to date
--
-- BJP 22-AUG-2007 Initial Creation
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_ACCOUNTS(p_entity IN VARCHAR2) AS

s_proc_name VARCHAR2(80) := 'SLR_CLIENT_PROCEDURES_PKG.pUPDATE_SLR_ACCOUNTS';
lvEntitySet SLR_ENTITIES.ENT_ACCOUNTS_SET%TYPE;

BEGIN

    SELECT ENT_ACCOUNTS_SET
    INTO   lvEntitySet
    FROM   SLR_ENTITIES
    WHERE  ENT_ENTITY = p_entity;

    SLR_FDR_PROCEDURES_PKG.PUPDATE_SLR_ACCOUNTS(lvEntitySet);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert accounts, unable to obtain entity set: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
  WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failure to insert accounts: '
                                ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_ACCOUNTS', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pUPDATE_SLR_ACCOUNTS: ' || SQLERRM);

END pUPDATE_SLR_ACCOUNTS;

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
    e_wrong_dates      	  EXCEPTION;
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
-- Procedure:       pINSERT_SLR_ENTITY_DAYS
-- Description:     Insert data into SLR_ENTITY_DAYS for the
--                  Calendar entity set.
-- Note:
--
-- BJP 22-AUG-2007  Initial version
-- -----------------------------------------------------------------------
PROCEDURE pINSERT_SLR_ENTITY_DAYS
(
    p_start_date  in date,
    p_end_date    in date,
    p_entity_set  in VARCHAR2
)
AS

    s_proc_name   VARCHAR2(50) := 'SLR_CLIENT_PROCEDURES_PKG.pINSERT_SLR_ENTITY_DAYS';

BEGIN

    SLR_UTILITIES_PKG.pUPDATE_SLR_ENTITY_DAYS(p_entity_set, p_start_date, p_end_date, 'O');

EXCEPTION
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failed to set SLR entity dates for entity set ['||p_entity_set||']: '
                            ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_DAYS', null, 'Entity Set', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pINSERT_SLR_ENTITY_DAYS: ' || SQLERRM);

END pINSERT_SLR_ENTITY_DAYS;

-- -----------------------------------------------------------------------
-- Procedure:       pINSERT_SLR_ENTITY_PERIODS
-- Function:        Insert data into SLR_ENTITY_PERIODS
-- Note:
--
-- BJP 22-AUG-2007  Initial version
-- -----------------------------------------------------------------------
PROCEDURE pINSERT_SLR_ENTITY_PERIODS
(
    p_start_bus_year_month in NUMBER,
    p_start_date           in date,
    p_end_date             in date,
    p_entity               in VARCHAR2
)
AS

    s_proc_name       VARCHAR2(60) := 'SLR_CLIENT_PROCEDURES_PKG.pINSERT_SLR_ENTITY_PERIODS';

BEGIN

    SLR_CALENDAR_PKG.pSetEntityPeriods(p_entity, p_start_bus_year_month, p_start_date, p_end_date, 'O');

EXCEPTION
    WHEN OTHERS THEN
        pr_error(slr_global_pkg.C_MAJERR, 'Failed to set SLR entity periods for entity ['||p_entity||']: '
                            ||sqlerrm, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_PERIODS', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        RAISE_APPLICATION_ERROR(-20001, 'Fatal error during call of pINSERT_SLR_ENTITY_PERIODS: ' || SQLERRM);

END pINSERT_SLR_ENTITY_PERIODS;

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

END SLR_CLIENT_PROCEDURES_PKG;
/

set define on;

