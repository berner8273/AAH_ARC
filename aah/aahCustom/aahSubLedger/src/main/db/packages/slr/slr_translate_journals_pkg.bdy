CREATE OR REPLACE PACKAGE BODY SLR.SLR_TRANSLATE_JOURNALS_PKG AS
/******************************************************************************
--
--  Id: $Id: SLR_TRANSLATE_JOURNALS_PKG.sql,v 1.1 2007/11/21 14:35:34 michalg Exp $
--
--  Description: Translate journals
--
-- ----------------------------------------------------------------------------
-- Key Comments
-- 1) Process is not Optimised
-- 2) Process may be WRONG for REVALUATION JOURNALS +++ need specification
-- 3) Individual journal errors are not fatal for the overall processing. In
--    such circumstances, the individual journals are put into error.
-- 4) Unrecognisable errors are fatal.
-- ----------------------------------------------------------------------------
-- Entry to the program is pTransalateJournals. Parameters are self explanatory.
--
-- 1) Translate the Journal Lines to populate a BASE and LOCAL amount
-- 2) Check that the journal is still in balance for BASE and LOCAL
-- ----------------------------------------------------------------------------
-- Procedure History
-- ASH 06-DEC-2004 Code Initially Developed
-- ASH 07-DEC-2004 Enhanced function to only pull journals that do not
-- balance balance by zero.
-- ASH 13-DEC-2004 Added logic so that FX transalate occurs if no BASE or LOCAL
-- value is present.
-- ASH 10-JAN-2004 Added logic to check that an FX Rate exists.
-- ASH 26-JAN-2005 COMPLETE CODE FOR RELEASE 2
******************************************************************************/

  /**************************************************************************
	* Declare private procedures and functions
	**************************************************************************/
	-- Short cuts to error processors
    PROCEDURE pWriteLogError(   p_proc_name     VARCHAR2,
		                            p_table_name    VARCHAR2,
		                            p_msg           VARCHAR2);

    PROCEDURE pWriteLineError(  p_process_id    SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
		                            p_status_text   SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_STATUS_TEXT%TYPE,
		                            p_msg           VARCHAR2,
		                            p_sql           VARCHAR2);

  /**************************************************************************
	* Declare private global attributes
	**************************************************************************/
    -- Declare Working Global Variables
    gProcessId                  NUMBER;
    gProcessIdStr               VARCHAR2(30);
    gJournalEntityList          VARCHAR2(4000);
    gJournalEpgId               SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;
    gStatus                     CHAR(1);

    -- Operational Variables
    gUser   SLR_ENTITIES.ENT_CREATED_BY%TYPE;
    gWhen   SLR_ENTITIES.ENT_CREATED_ON%TYPE;

    -- Error logging attributes
    gv_table_name               VARCHAR2(30);
    gv_msg                      VARCHAR2(1000);
    gs_stage                    CHAR(3) := 'SLR';

    -- Global exceptions
    ge_bad_modify               EXCEPTION;

  /**************************************************************************
	* Processing
	**************************************************************************/

-- ----------------------------------------------------------------------------
-- Procedure to Tranlsate Journals
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
    PROCEDURE pTranslateJournals(   pProcessId         in NUMBER,
                                    pJournalEntityList in VARCHAR2,
	                                  pCurrencySet       in SLR_ENTITIES.ENT_CURRENCY_SET%TYPE,
                                    pRateSet           in SLR_ENTITIES.ENT_RATE_SET%TYPE,
                                    pBaseCcy           in SLR_ENTITIES.ENT_BASE_CCY%TYPE,
                                    pLocalCcy          in SLR_ENTITIES.ENT_LOCAL_CCY%TYPE,
                                    p_epg_id           in SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
                                    p_status           in CHAR := 'U'
                                ) AS

	    v_status       BOOLEAN := TRUE;
      s_proc_name    VARCHAR2(80) := 'SLR_TRANSLATE_JOURNALS_PKG.pTranslateJournals';
		  e_bad_journals EXCEPTION;

    BEGIN
	    --dbms_output.enable(1000000);
      --dbms_output.put_line('SLR_TRANSLATE_JOURNALS_PKG starting ...');

      gProcessId := pProcessId;
		  gProcessIdStr := to_char(gProcessId);
      gJournalEntityList := pJournalEntityList;
      gJournalEpgId := p_epg_id;
      gStatus := p_status;

      -- Set Global variables for the User and the Time of the Action
      -- ------------------------------------------------------------------------
		  SELECT USER INTO gUser FROM DUAL;
		  SELECT SYSDATE INTO gWhen FROM DUAL;

      --1) Translate the Journal Lines to populate a BASE and LOCAL amount
      -- ----------------------------------------------------------------------
      $IF $$debug_mode $THEN
        insert into slr_log(step,proc,stage,entity,curr_date,comments) values(8,'pPROCESS_SLR Post','start',pJournalEntity,null,'pTranslateJournals # fApplyTranslation '||pProcessId);
      $END

      IF fApplyTranslation(pCurrencySet, pRateSet, pBaseCcy, pLocalCcy) = FALSE THEN
        v_status := FALSE;
        pWriteLogError(s_proc_name, null, 'fApplyTranslation: Failed to apply translation for some or all journals. ');
		  END IF;
      $IF $$debug_mode $THEN
        insert into slr_log(step,proc,stage,entity,curr_date,comments) values(8,'pPROCESS_SLR Post','end',pJournalEntity,null,'pTranslateJournals # fApplyTranslation '||pProcessId);
      $END

		  --dbms_output.put_line('After fApplyTranslation');

      --2) Check that the journal is still in balance for BASE and LOCAL
      -- ----------------------------------------------------------------------
      $IF $$debug_mode $THEN
        insert into slr_log(step,proc,stage,entity,curr_date,comments) values(8,'pPROCESS_SLR Post','start',pJournalEntity,null,'pTranslateJournals # fValidateTranslation '||pProcessId);
      $END

      IF fValidateTranslation = FALSE THEN
		    v_status := FALSE;
        pWriteLogError(s_proc_name, null, 'fValidateTranslation: Failed to validate translation for some or all journals. ');
		  END IF;
      $IF $$debug_mode $THEN
        insert into slr_log(step,proc,stage,entity,curr_date,comments) values(8,'pPROCESS_SLR Post','end',pJournalEntity,null,'pTranslateJournals # fValidateTranslation '||pProcessId);
      $END

      -- 3) Write top level error messages
      -- ----------------------------------------------------------------------
		  IF v_status = FALSE THEN
		    RAISE e_bad_journals;
		  END IF;

		  --dbms_output.put_line('SLR_TRANSLATE_JOURNALS_PKG completed: successfully');

    EXCEPTION
      WHEN e_bad_journals THEN
		    gv_msg := '(2) Failure of some or all journals during translate journals';
		    pWriteLogError(s_proc_name, null, gv_msg);
        RAISE ge_bad_translate;  -- This exception should be caught by the calling process

      WHEN OTHERS THEN
		    gv_msg := '(3) Unspecified failure during translate journals. ';
		    pWriteLogError(s_proc_name, null, gv_msg);
        RAISE_APPLICATION_ERROR(-20003, gv_msg);

    END pTranslateJournals;
    
    PROCEDURE pTranslateJournals (
      pEpgId IN slr_entity_proc_group.epg_id%TYPE,
      pProcessId IN NUMBER DEFAULT NULL,
      pRateSet IN slr_entities.ent_rate_set%TYPE DEFAULT NULL,
      pStatus IN CHAR DEFAULT 'U',
      pJournalEntity IN VARCHAR2 DEFAULT NULL
    ) IS
      lSql VARCHAR2(32767);
      sProcName CONSTANT VARCHAR2(80) := 'SLR_TRANSLATE_JOURNALS_PKG.pTranslateJournals';
      lStartTime PLS_INTEGER DEFAULT 0;
      lRateSet slr_entities.ent_rate_set%TYPE; 
    BEGIN
    
      IF pRateSet IS NOT NULL THEN
        lRateSet:=''''||pRateSet||'''';
      END IF;

      gProcessId := pProcessId;
      gProcessIdStr := TO_CHAR(gProcessId);
      gJournalEntityList := pJournalEntity;
      gJournalEpgId := pEpgId;
      gStatus := pStatus;
      
      EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_fx truncate partition for ('''||pEpgId||''')';          

      lSql:='
        insert /*+ append */ into slr_jrnl_lines_fx partition for ('''||pEpgId||''')
        with src as (
        select '||SLR_UTILITIES_PKG.fHint(gJournalEpgId, 'FX_APPLY_TRANS_INSERT_SUBQUERY')||'     
          jlu_jrnl_hdr_id,
          jlu_jrnl_line_number,
          jlu_tran_amount,
          jlu_jrnl_ref_id,
          jlu_tran_ccy,
          coalesce(jlu_base_ccy, ent_base_ccy) as jlu_base_ccy,
          nvl2(jlu_base_amount, jlu_base_rate, r_base.er_rate) as jlu_base_rate,  
          coalesce(jlu_local_ccy, ent_local_ccy) as jlu_local_ccy,
          nvl2(jlu_local_amount, jlu_local_rate, r_local.er_rate) as jlu_local_rate,
          c_base.ec_digits_after_point as base_digits_after_point,
          c_local.ec_digits_after_point as local_digits_after_point, 
          coalesce(jlu_base_amount, round(jlu_tran_amount * r_base.er_rate, c_base.ec_digits_after_point)) as jlu_base_amount,
          coalesce(jlu_local_amount, round(jlu_tran_amount * r_local.er_rate, c_local.ec_digits_after_point)) as jlu_local_amount
        from slr_jrnl_lines_unposted 
          join slr_entities on jlu_entity = ent_entity and ent_apply_fx_translation = ''Y''
          join slr_entity_rates r_base
            on r_base.er_date = nvl(jlu_translation_date, jlu_effective_date) 
            and r_base.er_entity_set = coalesce('||COALESCE(lRateSet, 'null')||', jlu_jrnl_ent_rate_set, ent_rate_set)
            and r_base.er_ccy_from = jlu_tran_ccy
            and r_base.er_ccy_to = coalesce(jlu_base_ccy, ent_base_ccy)
            and r_base.er_rate_type = ''SPOT''
          join slr_entity_rates r_local
            on r_local.er_date = nvl(jlu_translation_date, jlu_effective_date) 
            and r_local.er_entity_set = coalesce('||COALESCE(lRateSet, 'null')||', jlu_jrnl_ent_rate_set, ent_rate_set)
            and r_local.er_ccy_from = jlu_tran_ccy
            and r_local.er_ccy_to = coalesce(jlu_local_ccy, ent_local_ccy)
            and r_local.er_rate_type = ''SPOT''
          join slr_entity_currencies c_base on c_base.ec_entity_set = ent_currency_set and c_base.ec_ccy = coalesce(jlu_base_ccy, ent_base_ccy) and c_base.ec_status = ''A''
          join slr_entity_currencies c_local on c_local.ec_entity_set = ent_currency_set and c_local.ec_ccy = coalesce(jlu_local_ccy, ent_local_ccy) and c_local.ec_status = ''A''
        where jlu_epg_id = '''||pEpgId||'''
          and jlu_jrnl_status = '''||pStatus||''' '||CASE WHEN pJournalEntity IS NOT NULL THEN 'jlu_entity = '''||pJournalEntity||'''' END ||'        
        ), lines as ( 
          select
            jlu_jrnl_hdr_id,
            jlu_jrnl_line_number,
            jlu_base_ccy,
            jlu_base_rate,  
            jlu_local_ccy,
            jlu_local_rate,
            count(jlu_jrnl_hdr_id) over (partition by jlu_jrnl_hdr_id, jlu_tran_ccy order by (case when jlu_jrnl_ref_id is null then jlu_tran_amount else -1 *  jlu_tran_amount end) desc, jlu_jrnl_line_number asc) as line_no,
            coalesce(jlu_base_amount, round(jlu_tran_amount * jlu_base_rate, base_digits_after_point)) as jlu_base_amount,
            sum(coalesce(jlu_base_amount, round(jlu_tran_amount * jlu_base_rate, base_digits_after_point))) over (partition by jlu_jrnl_hdr_id, jlu_tran_ccy) as base_sum,
            coalesce(jlu_local_amount, round(jlu_tran_amount * jlu_local_rate, local_digits_after_point)) as jlu_local_amount,
            sum(coalesce(jlu_local_amount, round(jlu_tran_amount * jlu_local_rate, local_digits_after_point))) over (partition by jlu_jrnl_hdr_id, jlu_tran_ccy) as local_sum
          from src 
        ) select 
          '''||pEpgId||''',  
          jlu_jrnl_hdr_id,
          jlu_jrnl_line_number,   
          jlu_base_rate,  
          jlu_base_ccy,
          case when (line_no = 1 and base_sum != 0) then jlu_base_amount - base_sum else jlu_base_amount end as jlu_base_amount,
          jlu_local_rate,  
          jlu_local_ccy,
          case when (line_no = 1 and local_sum != 0) then jlu_local_amount - local_sum else jlu_local_amount end as jlu_local_amount
        from lines';

      SLR_ADMIN_PKG.Debug('FX Translate - translate journals', lSql);
      lStartTime:=DBMS_UTILITY.get_time();
      EXECUTE IMMEDIATE lSql;      

      COMMIT;
      slr_admin_pkg.PerfInfo( 'FXT. FX Translate query execution time: ' || (DBMS_UTILITY.get_time() - lStartTime)/100.0 || ' s.');

    EXCEPTION WHEN OTHERS THEN
      dbms_output.put_line(sqlerrm||': '||dbms_utility.format_error_backtrace);
      pWriteLogError(sProcName, 'SLR_JRNL_LINES_UNPOSTED', '(1) Unspecified failure in apply translation. ');
      raise_application_error (-20010, 'Fatal error in FX Transalte');
    END pTranslateJournals;
-- -----------------------------------------------------------------------------
-- Function to Apply Translation Process
-- -----------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------
    FUNCTION fApplyTranslation( pCurrencySet     in SLR_ENTITIES.ENT_CURRENCY_SET%TYPE,
	                              pRateSet         in SLR_ENTITIES.ENT_RATE_SET%TYPE,
                                pBaseCcy         in SLR_ENTITIES.ENT_BASE_CCY%TYPE,
                                pLocalCcy        in SLR_ENTITIES.ENT_LOCAL_CCY%TYPE)  RETURN BOOLEAN
    AS
		lvEffectiveDate    DATE;
		lv_START_TIME 	PLS_INTEGER := 0;
		lvTranCcy          SLR_ENTITIES.ENT_LOCAL_CCY%TYPE;
		lvBaseRate         SLR_ENTITY_RATES.ER_RATE%TYPE;
		lvLocalRate        SLR_ENTITY_RATES.ER_RATE%TYPE;
		lvBaseCcyNumOfDPs  SLR_ENTITY_CURRENCIES.EC_DIGITS_AFTER_POINT%TYPE;
		lvLocalCcyNumOfDPs SLR_ENTITY_CURRENCIES.EC_DIGITS_AFTER_POINT%TYPE;
		lv_ent_rate_set SLR_ENTITIES.ENT_RATE_SET%TYPE;

		v_status           BOOLEAN := TRUE;
    s_proc_name        VARCHAR2(80) := 'SLR_TRANSLATE_JOURNALS_PKG.fApplyTranslation';
		e_bad_update       EXCEPTION;

    lv_sql VARCHAR(32000);
		lv_where VARCHAR2(1024);

    BEGIN
	  -- Get The decimal places for the currencies
	  -- -----------------------------------------
      BEGIN
		    SELECT EC_DIGITS_AFTER_POINT
			INTO lvBaseCcyNumOfDPs
			FROM SLR_ENTITY_CURRENCIES
		    WHERE EC_ENTITY_SET = pCurrencySet
			AND EC_CCY = pBaseCcy
			AND EC_STATUS = 'A';

      EXCEPTION
			WHEN NO_DATA_FOUND THEN
				lvBaseCcyNumOfDPs := 2;
			WHEN OTHERS THEN
				lvBaseCcyNumOfDPs := 2;
        END;

	    BEGIN
            SELECT EC_DIGITS_AFTER_POINT
            INTO lvLocalCcyNumOfDPs
			FROM SLR_ENTITY_CURRENCIES
			WHERE EC_ENTITY_SET = pCurrencySet
			AND EC_CCY = pLocalCcy
			AND EC_STATUS = 'A';

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				lvLocalCcyNumOfDPs := 2;
			WHEN OTHERS THEN
				lvLocalCcyNumOfDPs := 2;
        END;
     
     /* 
		 SELECT ENT_RATE_SET INTO lv_ent_rate_set FROM SLR_ENTITIES
         WHERE ENT_ENTITY = gJournalEntity;*/

    lv_where := '(r.er_entity_set = jlu_jrnl_ent_rate_set or (r.er_entity_set = '''||pRateSet||''' and jlu_jrnl_ent_rate_set is null))';

    /*
		IF(pRateSet is null) THEN
			lv_where := '(r.er_entity_set = jlu_jrnl_ent_rate_set or (r.er_entity_set = '''||lv_ent_rate_set||''' and jlu_jrnl_ent_rate_set is null))';
		ELSE
			lv_where := 'r.ER_ENTITY_SET = ''' || pRateSet || ''' ';
		END IF;*/

        BEGIN
            lv_sql := q'[
                        update ]'|| SLR_UTILITIES_PKG.fHint(gJournalEpgId, 'FX_APPLY_TRANS_MERGE') ||
                        q'[(SELECT
                             CASE
                                 WHEN jlu_base_amount IS NOT NULL THEN jlu_base_rate
                                 ELSE r1_er_rate
                             END AS using_base_rate,
                             CASE
                                 WHEN jlu_base_ccy IS NOT NULL THEN jlu_base_ccy
                                 ELSE :baseccy___1
                             END AS using_base_ccy,
                             CASE
                                 WHEN jlu_base_amount IS NULL THEN round(jlu_tran_amount * r1_er_rate, :baseccynumofdps___2
                                 )
                                 ELSE jlu_base_amount
                             END AS using_base_amount,
                             CASE
                                 WHEN jlu_local_amount IS NOT NULL THEN jlu_local_rate
                                 ELSE r2_er_rate
                             END AS using_local_rate,
                             CASE
                                 WHEN jlu_local_ccy IS NOT NULL THEN jlu_local_ccy
                                 ELSE :localccy___3
                             END AS using_local_ccy,
                             CASE
                                 WHEN jlu_local_amount IS NULL THEN round(jlu_tran_amount * r2_er_rate, :localccynumofdps___4
                                 )
                                 ELSE jlu_local_amount
                             END AS using_local_amount,
                             jlu_base_ccy,
                             jlu_base_rate,
                             jlu_base_amount,
                             jlu_local_ccy,
                             jlu_local_rate,
                             jlu_local_amount,
                             jlu_tran_amount
                        from (
                         select jlu_jrnl_line_number   using_lines_number,
                         jlu_jrnl_hdr_id        using_hdr_id,
                         jlu_base_ccy,
                         jlu_base_rate,
                         jlu_base_amount,
                         jlu_local_ccy,
                         jlu_local_rate,
                         jlu_local_amount,
                         jlu_tran_amount,
                         (select er_rate
                            from slr_entity_rates r
                            where ]'||lv_where||
                            q'[and r.er_date = nvl(jlu_translation_date, jlu_effective_date)
                            and r.er_ccy_from = jlu_tran_ccy
                            AND r.er_ccy_to = :baseccy___7
                            and er_rate_type = 'SPOT'
                            ) as r1_er_rate,
                         (select er_rate
                            from slr_entity_rates r
                            where ]'||lv_where||
                            q'[ and r.er_date = nvl(jlu_translation_date, jlu_effective_date)
                            and r.er_ccy_from = jlu_tran_ccy
                            AND r.er_ccy_to = :localccy___8
                            and er_rate_type = 'SPOT'
                            ) as r2_er_rate
                        FROM
                         slr_jrnl_lines_unposted
                        WHERE
                            JLU_EPG_ID = ']' || gJournalEpgId || q'['
                        AND JLU_ENTITY IN (]' || gJournalEntityList || q'[)
                        AND JLU_JRNL_STATUS = ']' || gStatus || q'['
                        )
                        )
                        set jlu_base_ccy = using_base_ccy,
                        jlu_base_rate = using_base_rate,
                        jlu_base_amount = using_base_amount,
                        jlu_local_ccy = using_local_ccy,
                        jlu_local_rate = using_local_rate,
                        jlu_local_amount = using_local_amount
            ]';

      SLR_ADMIN_PKG.Debug('FX Translate - apply translation', lv_sql);
			SLR_ADMIN_PKG.Debug('FX Translate - apply translation', 'pBaseCcy: ' || pBaseCcy || ', pLocalCcy: ' || pLocalCcy);
			lv_START_TIME:=DBMS_UTILITY.GET_TIME();
			EXECUTE IMMEDIATE lv_sql USING pBaseCcy, lvBaseCcyNumOfDPs, pLocalCcy, lvLocalCcyNumOfDPs, pBaseCcy, pLocalCcy;
			COMMIT;
			SLR_ADMIN_PKG.PerfInfo( 'FXT. FX Translate query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');

			EXCEPTION
				WHEN OTHERS THEN
					-- FATAL so stop processing
					SLR_ADMIN_PKG.Error('Error in fApplyTranslation: ' || SQLERRM);
					SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', 'Error in fApplyTranslation: ', NULL,NULL);
					RAISE e_bad_update;

      END;
      RETURN v_status;

    EXCEPTION
	    WHEN e_bad_update THEN
			  pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', '(2) Failure to update lines in apply translation. ');
			  RETURN FALSE;

      WHEN OTHERS THEN
			  pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', '(1) Unspecified failure in apply translation. ');
			  RETURN FALSE;

    END fApplyTranslation;  -- END OF FUNCTION

    -- --------------------------------------------------------------------------
    -- Function to Validate Translation Process
    -- --------------------------------------------------------------------------
    FUNCTION fValidateTranslation RETURN BOOLEAN
    AS
      s_proc_name VARCHAR2(80) := 'SLR_TRANSLATE_JOURNALS_PKG.fValidateTranslation';
      lv_sql VARCHAR(32000);
      lv_START_TIME 	PLS_INTEGER := 0;
    BEGIN

			 lv_sql := '
			 MERGE ' || SLR_UTILITIES_PKG.fHint(gJournalEpgId, 'FX_VALID_TRANS_MERGE') || ' INTO SLR_JRNL_LINES_UNPOSTED USING
        (
        SELECT
           SUM((CASE WHEN rr = 1 then JLU_JRNL_LINE_NUMBER ELSE 0 END)) LINE_NUM,
           JLU_JRNL_HDR_ID HEAD_ID,
           JLU_TRAN_CCY trans,
           sum(JLU_BASE_AMOUNT) base_amount_sum,
           sum(JLU_LOCAL_AMOUNT) local_amount_sum
        FROM (
        select
           JLU_JRNL_HDR_ID,
           JLU_JRNL_LINE_NUMBER,
           JLU_TRAN_CCY,
           CASE WHEN JLU_JRNL_REF_ID is null THEN
            (ROW_NUMBER() OVER (PARTITION BY JLU_JRNL_HDR_ID,JLU_TRAN_CCY ORDER BY JLU_TRAN_AMOUNT DESC, JLU_JRNL_LINE_NUMBER ASC ))
           ELSE
            (ROW_NUMBER() OVER (PARTITION BY JLU_JRNL_HDR_ID,JLU_TRAN_CCY ORDER BY JLU_TRAN_AMOUNT ASC, JLU_JRNL_LINE_NUMBER ASC ))
           END rr,
           NVL((JLU_BASE_AMOUNT), 0) JLU_BASE_AMOUNT,
           NVL((JLU_LOCAL_AMOUNT), 0) JLU_LOCAL_AMOUNT,
           JLU_EPG_ID,
           JLU_JRNL_STATUS
        from
        SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_EPG_ID = ''' || gJournalEpgId || '''
           AND JLU_ENTITY IN (' || gJournalEntityList || ')
           AND JLU_JRNL_STATUS= ''' || gStatus || ''' )
        GROUP BY
        JLU_JRNL_HDR_ID,
        JLU_TRAN_CCY
        HAVING
        SUM(JLU_BASE_AMOUNT) != 0
        OR SUM(JLU_LOCAL_AMOUNT)!= 0
        )
        ON
              (   JLU_EPG_ID = ''' || gJournalEpgId || ''' AND
                JLU_JRNL_LINE_NUMBER = LINE_NUM AND
                JLU_JRNL_HDR_ID = HEAD_ID AND
                JLU_TRAN_CCY = trans
              )
              WHEN MATCHED THEN
                UPDATE SET
                  JLU_BASE_AMOUNT = JLU_BASE_AMOUNT - base_amount_sum,
                  JLU_LOCAL_AMOUNT = JLU_LOCAL_AMOUNT - local_amount_sum';

        SLR_ADMIN_PKG.Debug('FX Translate - validate translation', lv_sql);

      lv_START_TIME:=DBMS_UTILITY.GET_TIME();
      EXECUTE IMMEDIATE lv_sql;
      COMMIT;
      SLR_ADMIN_PKG.PerfInfo( 'FXTV. FX Translate - validate translation query execution time: ' || (DBMS_UTILITY.GET_TIME() - lv_START_TIME)/100.0 || ' s.');		        
      RETURN TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN TRUE;

        WHEN OTHERS THEN
          pWriteLogError(s_proc_name, 'SLR_JRNL_LINES_UNPOSTED', 'Failure to validate translation. ');
          RETURN FALSE;

    END fValidateTranslation;

    -- ---------------------------------------------------------------------------
	-- Function:     fSelectCurrencyRate
	-- Description:  Get currency rate from database.
    -- ---------------------------------------------------------------------------
    FUNCTION fSelectCurrencyRate(
                                    pRateSet         in SLR_ENTITIES.ENT_RATE_SET%TYPE,
                                    pRateDate        in DATE,
                                    pFromCcy         in SLR_ENTITY_RATES.ER_CCY_FROM%TYPE,
                                    pToCcy           in SLR_ENTITY_RATES.ER_CCY_TO%TYPE
                                )
                                RETURN  SLR_ENTITY_RATES.ER_RATE%TYPE
    AS

        lvRate SLR_ENTITY_RATES.ER_RATE%TYPE;
		s_proc_name    VARCHAR2(80) := 'SLR_TRANSLATE_JOURNALS_PKG.fSelectCurrencyRate';

    BEGIN

            SELECT      ER_RATE
            INTO        lvRate
            FROM        SLR_ENTITY_RATES
            WHERE       ER_ENTITY_SET           = pRateSet
            AND         ER_DATE                 = pRateDate
            AND         ER_CCY_FROM             = pFromCcy
            AND         ER_CCY_TO               = pToCcy;

            RETURN lvRate;

	EXCEPTION
        WHEN NO_DATA_FOUND THEN
		    pWriteLogError(s_proc_name, 'SLR_ENTITY_RATES', 'No data for entity set ['||pRateSet
			               ||'], date ['||to_char(pRateDate, 'DD-MON-YYYY')||'] ');
            RETURN 0;

        WHEN OTHERS THEN
		    pWriteLogError(s_proc_name, 'SLR_ENTITY_RATES', 'Unspecified error for entity set ['||pRateSet
			               ||'], date ['||to_char(pRateDate, 'DD-MON-YYYY')||'] ');
            RETURN 0;

    END fSelectCurrencyRate;

    -- ---------------------------------------------------------------------------
	-- Procedure:    pWriteLogError
    -- Description:  Wrap writing to the error log to set up common params.
	-- Note:         pr_error is an autonomous transaction to permit error logging
	--               while rolling back other updates.
	-- Author:      Tony Watton
    -- ---------------------------------------------------------------------------
    PROCEDURE pWriteLogError
    (
	    p_proc_name     VARCHAR2,
		p_table_name    VARCHAR2,
		p_msg           VARCHAR2
	)
	IS

	BEGIN
	    SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(p_proc_name, p_table_name, p_msg, gProcessId, gJournalEpgId, gStatus, gJournalEntityList);

    END pWriteLogError;

    -- ---------------------------------------------------------------------------
	-- Procedure:    pWriteLineError
    -- Description:  Short cut to standard write journal errors routine.
	-- Note:         pWriteLineError is an autonomous transaction to permit error
	--               logging while rolling back other updates. Take care not to
	--               have an uncommitted journal line or header update as this
	--               will cause a deadlock when writing the error.
	-- Author:      Tony Watton
    -- ---------------------------------------------------------------------------
    PROCEDURE pWriteLineError
	(
	    p_process_id    SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
		p_status_text   SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_STATUS_TEXT%TYPE,
		p_msg           VARCHAR2,
		p_sql           VARCHAR2
	)
	IS
    BEGIN
        SLR_VALIDATE_JOURNALS_PKG.pWriteLineError(gJournalEntityList, p_process_id, p_status_text, p_msg, p_sql,gJournalEpgId);

	END pWriteLineError;

END SLR_TRANSLATE_JOURNALS_PKG;
/