--------------------------------------------------------
--  File created - Monday-January-30-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure PR_STAN_RAW_GENERAL_CODES_LD
--------------------------------------------------------

CREATE OR REPLACE PROCEDURE "FDR"."PR_STAN_RAW_GENERAL_CODES_LD" (
    a_lpg_id      IN   fr_global_parameter.lpg_id%TYPE := 1,
    a_code_type   IN   fr_stan_raw_general_codes.srgc_gct_code_type_id%TYPE := null,
    a_processed_count OUT NUMBER,
    a_success_count OUT NUMBER,
    a_failed_count OUT NUMBER
)
AS
--
--PR_STAN_RAW_GEN_CODES_LD  (Procedure)
--
--  Dependencies:
--FR_STAN_RAW_GENERAL_CODES(Table)
--
	v_source_event_id 		NUMBER(12);
	refCursorValue 			SYS_REFCURSOR;
    v_SQL                   varchar2(8000);
    v_active                fr_stan_raw_general_codes.srgc_active%TYPE;
    v_general_code_id       fr_general_codes.gc_general_code_id%TYPE;
    v_general_code_type_id  fr_general_codes.gc_gct_code_type_id%TYPE;
    v_sqlcode               NUMBER (12);
    v_sqlerrm               fr_log.lo_event_text%TYPE;
    v_cur_srgc_id           NUMBER (12);
    v_count					NUMBER (12);
    v_cur_code_type_id      fr_stan_raw_general_codes.srgc_gct_code_type_id%TYPE;
    v_msg                   VARCHAR2 (4000);
    v_event_status          fr_stan_raw_general_codes.event_status%TYPE;
    s_proc_name             VARCHAR2 (30) := 'PR_STAN_RAW_GENERAL_CODES_LD';
    s_target_table          VARCHAR2 (30) := 'FR_STAN_RAW_GENERAL_CODES';
    v_stage 				VARCHAR2(20) := 'FDR_STATIC';
    v_owner                 VARCHAR2(20) := 'FDR';
    v_error_table           VARCHAR2(30);
 BEGIN
    v_error_table := 'ERR$_FR_GENERAL_CODES'||'_'||FLOOR(DBMS_RANDOM.VALUE(100000,999999));

    a_success_count := 0;
    a_failed_count := 0;

    -- create errlog table
    SELECT count(1) INTO v_count FROM user_tables WHERE table_name = v_error_table;
    IF v_count > 0 THEN
        v_SQL := 'drop table '||v_error_table;
        EXECUTE IMMEDIATE v_SQL;
    end if;

    v_SQL := 'begin DBMS_ERRLOG.create_error_log (dml_table_name => ''FR_GENERAL_CODES'', err_log_table_name => '''||v_error_table||'''); end;';
    DBMS_OUTPUT.PUT_LINE(v_SQL);
    EXECUTE IMMEDIATE v_SQL;
    COMMIT;

    v_msg := 'Invalid Insert/Update/Delete Flag';
    INSERT INTO fdr.fr_log (lo_event_datetime,
      lo_event_type_id,
      lo_error_status,
      lo_category_id,
      lo_event_text,
      lo_table_in_error_name,
      lo_row_in_error_key_id,
      lo_field_in_error_name,
      lo_error_technology,
      lo_error_rule_ident,
      lo_error_value,
      lo_error_client_key_no,
      lo_error_client_ver_no,
      lo_todays_bus_date,
      lo_entity,
      lo_book,
      lo_security,
      lo_source_system,
      lo_processing_stage,
      lo_owner,
      lpg_id)
    SELECT sysdate,
      1,
     'E',
      1,
      v_msg,
      s_target_table,
      srgc_general_code_id,
     'srgc_active',
     'PL/SQL',
      s_proc_name,
      srgc_active,
      srgc_general_code_id || '~' || srgc_gct_code_type_id,
      NULL,
      fdr_global_parameters.gp_todays_bus_date,
      NULL,
      NULL,
      NULL,
      NULL,
      v_stage,
      v_owner,
      a_lpg_id
    FROM fr_stan_raw_general_codes
    WHERE lpg_id = a_lpg_id
    AND event_status = 'U'
    AND srgc_gct_code_type_id like nvl(a_code_type||'%', srgc_gct_code_type_id||'%')
    AND nvl(srgc_active, 'X') NOT IN ('A', 'I');

    v_count := SQL%ROWCOUNT;

    IF (v_count > 0 ) THEN
        v_SQL := 'UPDATE FR_STAN_RAW_GENERAL_CODES SET EVENT_STATUS = ''E'' WHERE lpg_id = '''|| a_lpg_id ||''' '|| CASE WHEN a_code_type IS NOT NULL THEN 'AND srgc_gct_code_type_id like ''' || a_code_type ||'%' || '''' END ||' AND nvl(srgc_active, ''X'') NOT IN (''A'', ''I'') AND event_status = ''U''';
        EXECUTE IMMEDIATE v_SQL;
        a_failed_count := v_count;
    END IF;

    v_SQL := 'MERGE INTO fr_general_codes
    USING(SELECT *
        FROM fr_stan_raw_general_codes
        WHERE lpg_id = ''' || a_lpg_id || ''' ' ||
        CASE WHEN a_code_type IS NOT NULL THEN 'AND srgc_gct_code_type_id like ''' || a_code_type ||'%' || '''' END ||'
        AND event_status = ''U'')
        ON (gc_general_code_id = srgc_client_code
		AND gc_gct_code_type_id = srgc_gct_code_type_id)
    WHEN MATCHED THEN UPDATE SET
        gc_client_text1 = case when srgc_active = ''A'' then srgc_client_text1 else gc_client_text1 end,
        gc_client_text2 = case when srgc_active = ''A'' then srgc_client_text2 else gc_client_text2 end,
        gc_client_text3 = case when srgc_active = ''A'' then srgc_client_text3 else gc_client_text3 end,
        gc_client_text4 = case when srgc_active = ''A'' then srgc_client_text4 else gc_client_text4 end,
        gc_client_text5 = case when srgc_active = ''A'' then srgc_client_text5 else gc_client_text5 end,
        gc_client_text6 = case when srgc_active = ''A'' then srgc_client_text6 else gc_client_text6 end,
        gc_client_text7 = case when srgc_active = ''A'' then srgc_client_text7 else gc_client_text7 end,
        gc_client_text8 = case when srgc_active = ''A'' then srgc_client_text8 else gc_client_text8 end,
        gc_client_text9 = case when srgc_active = ''A'' then srgc_client_text9 else gc_client_text9 end,
        gc_client_text10 = case when srgc_active = ''A'' then srgc_client_text10 else gc_client_text10 end,
        gc_description = case when srgc_active = ''A'' then srgc_description else gc_description end,
        gc_active = srgc_active,
        gc_input_by = NVL(srgc_input_by,''Client Static''),
        gc_auth_by = NVL(srgc_auth_by,''Client Static''),
        gc_auth_status = NVL(srgc_auth_status,''A''),
        gc_input_time = SYSDATE,
        gc_valid_from =	NVL (srgc_valid_from, SYSDATE),
        gc_valid_to = case when srgc_active = ''I'' then
            NVL (srgc_valid_to, SYSDATE)
        else
            NVL(srgc_valid_to, TO_DATE(''31-12-2099'',''dd-mm-yyyy''))
        end,
        gc_delete_time = case when srgc_active = ''I'' then
            SYSDATE
        else
            NULL
        end,
        gc_source_event_id = srgc_general_code_id
    WHEN NOT MATCHED THEN INSERT (gc_general_code_id,
        gc_gct_code_type_id,
        gc_client_code,
        gc_client_text1,
        gc_client_text2,
        gc_client_text3,
        gc_client_text4,
        gc_client_text5,
        gc_client_text6,
        gc_client_text7,
        gc_client_text8,
        gc_client_text9,
        gc_client_text10,
        gc_description,
        gc_active,
        gc_input_by,
        gc_auth_by,
        gc_auth_status,
        gc_input_time,
        gc_valid_from,
        gc_valid_to,
        gc_delete_time,
        gc_source_event_id)
    VALUES (srgc_client_code,
        srgc_gct_code_type_id,
        srgc_client_code,
        srgc_client_text1,
        srgc_client_text2,
        srgc_client_text3,
        srgc_client_text4,
        srgc_client_text5,
        srgc_client_text6,
        srgc_client_text7,
        srgc_client_text8,
        srgc_client_text9,
        srgc_client_text10,
        srgc_description,
        srgc_active,
        NVL(srgc_input_by,''Client Static''),
        NVL(srgc_auth_by,''Client Static''),
        NVL(srgc_auth_status,''A''),
        SYSDATE,
        NVL(srgc_valid_from, SYSDATE),
        NVL(srgc_valid_to, TO_DATE(''31-12-2099'',''dd-mm-yyyy'')),
        NULL,
        srgc_general_code_id)
    WHERE srgc_active = ''A''
    LOG ERRORS INTO ' || v_error_table || ' REJECT LIMIT UNLIMITED';

    DBMS_OUTPUT.PUT_LINE(v_SQL);
    EXECUTE IMMEDIATE v_SQL;
--
    v_SQL := 'select count(*) from ' || v_error_table;
    OPEN refCursorValue FOR v_SQL ;
      FETCH refCursorValue INTO v_count;
    CLOSE refCursorValue;

    IF v_count > 0 THEN
      a_failed_count := a_failed_count + v_count;

	 ---LOG ALL ERRORS
      OPEN refCursorValue FOR 'select distinct ORA_ERR_NUMBER$, rtrim(ORA_ERR_MESG$, chr(10)), gc_source_event_id from ' || v_error_table;
			LOOP
				FETCH refCursorValue INTO v_sqlcode, v_sqlerrm, v_source_event_id;
				EXIT WHEN refCursorValue%NOTFOUND;
        PR_ERROR(1, v_sqlerrm, 0, s_proc_name, s_target_table, v_source_event_id, null, v_stage, 'PL/SQL', '-' || v_sqlcode, null, null, null, '', v_source_event_id, null, a_lpg_id, v_owner);
        UPDATE FR_STAN_RAW_GENERAL_CODES SET EVENT_STATUS = 'E' WHERE srgc_general_code_id = v_source_event_id;
      END LOOP;
      CLOSE refCursorValue;
    END IF;

    v_SQL := 'UPDATE FR_STAN_RAW_GENERAL_CODES SET EVENT_STATUS = ''P'' WHERE EVENT_STATUS = ''U'' AND lpg_id = '''|| a_lpg_id ||''' '|| CASE WHEN a_code_type IS NOT NULL THEN 'AND srgc_gct_code_type_id like ''' || a_code_type ||'%' || '''' END ||' AND nvl(srgc_active, ''X'') IN (''A'', ''I'')';
    EXECUTE IMMEDIATE v_SQL;

    a_success_count := SQL%ROWCOUNT;
    a_processed_count := a_success_count + a_failed_count;

    v_SQL := 'drop table '||v_error_table;
    EXECUTE IMMEDIATE v_SQL;

    COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            PR_ERROR(1, SQLERRM, 0, s_proc_name, s_target_table, null, null, v_stage, 'PL/SQL', '-' || SQLCODE, null, null, null, null,'', null, a_lpg_id, v_owner);
            raise_application_error(-20001, 'Unknown error. Please check the FR_LOG for more details. ' || SQLERRM);
END;
/
