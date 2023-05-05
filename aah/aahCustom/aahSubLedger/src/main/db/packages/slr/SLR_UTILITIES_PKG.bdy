CREATE OR REPLACE PACKAGE BODY SLR."SLR_UTILITIES_PKG" AS
/*********************************************************************************
*
* Id:           $Id: SLR_UTILITIES_PKG.sql,v 1.1 2007/11/21 17:39:06 michalg Exp $
* Description: Sub-ledger utility processes.
*
* Note:        This package should NOT include the following:
*                 - reconciliation
*                 - FDR / SLR interface processing
*                 - site specific processing
*
* History:
* SC  10-MAY-2005 Amended for TTP88 (SLR error reporting).
*********************************************************************************/

/*********************************************************************************
* Private package variables
*********************************************************************************/
    gv_msg                   VARCHAR2(1000);    -- Generic message field
    gs_stage                 CHAR(3) := 'SLR';

    gv_ddl_lock_timeout INT := 600;

/*********************************************************************************
* Processes
*********************************************************************************/

-- ----------------------------------------------------------------------------
-- Procedure to Run ALL Journals in a status of U
-- ----------------------------------------------------------------------------
-- 10-AUG-2004: ASH : Added error handling
-- ----------------------------------------------------------------------------

    PROCEDURE pRunValidateAndPost
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
		p_rate_set IN slr_entities.ent_rate_set%TYPE,
		pprocess IN Number
    )
    AS
        lv_process_id   NUMBER(38);
        s_proc_name     VARCHAR2(80) := 'SLR_UTILITIES_PKG.pRunValidateAndPost';
        lv_lock_handle  VARCHAR2(100);
        lv_lock_result  INTEGER;
        lv_use_headers 	boolean;


    BEGIN

        ----------------------------------------
        -- Set processId for whole processing
        ----------------------------------------
        IF pprocess IS NULL THEN
			SELECT SEQ_PROCESS_NUMBER.NEXTVAL INTO lv_process_id FROM DUAL;
        ELSE
			lv_process_id := pprocess;
        END IF;


        -- ----------------------------------------------------------------------
        -- 01-JUN-2010    pUpdateJrnlLinesUnposted has to be called to copy data
        --                from SLR_JRNL_HEADERS_UNPOSTED to SLR_JRNL_LINES_UNPOSTED.
        --                Optimised Sub Ledger validation and posting processes ignore SLR_JRNL_HEADERS_UNPOSTED table.
        --                All necessary data should be present in SLR_JRNL_LINES_UNPOSTED table.
        -- ----------------------------------------------------------------------
        SLR_UTILITIES_PKG.pUpdateJrnlLinesUnposted(p_epg_id);
        COMMIT;

        --------------------
        -- Lock request
        --------------------
        -- Lock is needed, because we can't handle more than one processing for the same entity group.

        DBMS_LOCK.ALLOCATE_UNIQUE('MAH_PROCESS_SLR_' || p_epg_id, lv_lock_handle);

        lv_lock_result := DBMS_LOCK.REQUEST(lv_lock_handle, DBMS_LOCK.X_MODE, 5);

        	IF lv_lock_result != 0 THEN
	            gv_msg := 'Can''t acquire lock for pProcessSlr for entity group ' || p_epg_id ||
	                '. Probably another processing for this entity group is running.';
	            pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_SLRFUNC, s_proc_name, null, null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
	        ELSE
            -- Assign existing journals to current batch
            SLR_UTILITIES_PKG.pResetFailedJournals(p_epg_id, lv_process_id,lv_use_headers);
            ----------------------
            -- Main processing
            ----------------------
            BEGIN
                SLR_VALIDATE_JOURNALS_PKG.pValidateJournals(p_epg_id=>p_epg_id, p_process_id => lv_process_id, p_UseHeaders => lv_use_headers, p_rate_set => p_rate_set);
                SLR_POST_JOURNALS_PKG.pPostJournals(p_epg_id=>p_epg_id, p_process_id => lv_process_id, p_UseHeaders => lv_use_headers, p_rate_set => p_rate_set);
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    gv_msg := 'Failure to validate and post for entity group ['||p_epg_id||']';
                    pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_SLRFUNC, s_proc_name, null, null, null, gs_stage, 'PL/SQL');
                    RAISE;
            END;

            --------------------
            -- Lock release
            --------------------
            lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            lv_lock_result := DBMS_LOCK.RELEASE(lv_lock_handle);
            gv_msg := 'Failure to validate and post for entity group ['||p_epg_id||']';
            pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_SLRFUNC, s_proc_name, null, null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
            RAISE_APPLICATION_ERROR(-20002, gv_msg);

    END pRunValidateAndPost;

-- -----------------------------------------------------------------
-- Procedure to run statistics
-- -----------------------------------------------------------------
    PROCEDURE pCalculateStatistics
    AS
        v_sql_statement varchar2(32000);
        s_proc_name     VARCHAR2(80) := 'SLR_UTILITIES_PKG.pCalculateStatistics';

    BEGIN

        v_sql_statement := 'ANALYZE TABLE SLR.SLR_FAK_COMBINATIONS ESTIMATE STATISTICS SAMPLE 25 PERCENT';
        EXECUTE IMMEDIATE v_sql_statement;
        v_sql_statement := 'ANALYZE TABLE SLR.SLR_FAK_DAILY_BALANCES ESTIMATE STATISTICS SAMPLE 25 PERCENT';
        EXECUTE IMMEDIATE v_sql_statement;
        v_sql_statement := 'ANALYZE TABLE SLR.SLR_EBA_COMBINATIONS ESTIMATE STATISTICS SAMPLE 25 PERCENT';
        EXECUTE IMMEDIATE v_sql_statement;
        v_sql_statement := 'ANALYZE TABLE SLR.SLR_EBA_DAILY_BALANCES ESTIMATE STATISTICS SAMPLE 25 PERCENT';
        EXECUTE IMMEDIATE v_sql_statement;
        v_sql_statement := 'ANALYZE TABLE SLR_JRNL_LINES ESTIMATE STATISTICS SAMPLE 25 PERCENT';
        EXECUTE IMMEDIATE v_sql_statement;

    EXCEPTION
        WHEN OTHERS THEN
            gv_msg := 'Failure to calculate statistics';
            pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, null, null, null, gs_stage, 'PL/SQL', SQLCODE);
            RAISE_APPLICATION_ERROR(-20001, gv_msg);
    END;

-- --------------------------------------------------------------------
-- Procedure to reset failed journals to be re-run
-- sets current p_process_id as well
-- Notes:
--
-- --------------------------------------------------------------------
     PROCEDURE pResetFailedJournals
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_use_Headers OUT boolean
    )
    AS
      v_business_date DATE         := fEntityGroupCurrBusDate(p_epg_id); -- a current date for entities from p_epg_id
      s_proc_name     VARCHAR2(80) := 'SLR_UTILITIES_PKG.pResetFailedJournals';
      v_business_date_char VARCHAR2(10) default to_char(v_business_date, 'yyyy-mm-dd');

      e_invalid_partition EXCEPTION;
      pragma exception_init(e_invalid_partition, -14702);

      PROCEDURE pDropJrnlWaitingPartition (
        p_partition_name IN VARCHAR2
      ) IS
        e_last_partition EXCEPTION;
        pragma exception_init(e_last_partition, -14083);
      BEGIN
        EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_waiting drop partition '||p_partition_name;

      EXCEPTION
        WHEN e_last_partition THEN
          EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_waiting truncate partition '||p_partition_name;
      END pDropJrnlWaitingPartition;

      PROCEDURE pDropJrnlWaitingSubpartition (
        p_partition_name IN VARCHAR2,
        p_subpartition_name IN VARCHAR2
      ) IS
        e_last_subpartition EXCEPTION;
        pragma exception_init(e_last_subpartition, -14629);
      BEGIN
        EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_waiting drop subpartition '||p_subpartition_name;

      EXCEPTION
        WHEN e_last_subpartition THEN
          pDropJrnlWaitingPartition (p_partition_name);
      END pDropJrnlWaitingSubpartition;

      PROCEDURE pAddJrnlWaitingSubpartition (p_lock IN BOOLEAN, p_date IN DATE default v_business_date) IS
        v_partition_date_char VARCHAR2(10) default to_char(p_date, 'yyyy-mm-dd');
      BEGIN
        EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_waiting modify partition for (date '''||v_business_date_char||''') add subpartition values('''||p_epg_id||''')';

        IF p_lock THEN
          EXECUTE IMMEDIATE 'lock table slr_jrnl_lines_waiting subpartition for (date '''||v_business_date_char||''','''||p_epg_id||''') in exclusive mode nowait';
        END IF;
      END pAddJrnlWaitingSubpartition;

      PROCEDURE pLockJrnlWaitingSubpartition IS
        e_missing_subpartition EXCEPTION;
        pragma exception_init(e_missing_subpartition, -14702);
      BEGIN
        EXECUTE IMMEDIATE 'lock table slr_jrnl_lines_waiting subpartition for (date '''||v_business_date_char||''','''||p_epg_id||''') in exclusive mode nowait';

      EXCEPTION
        WHEN e_missing_subpartition THEN
          pAddJrnlWaitingSubpartition(true);
      END pLockJrnlWaitingSubpartition;

      PROCEDURE pRestoreJrnlWaitingSubpart (
        p_earliest_epg_date IN DATE,
        p_earliest_epg_partition IN NUMBER
      ) IS
        e_subpartition_exists exception;
        pragma exception_init(e_subpartition_exists, -14622);
      BEGIN
        IF COALESCE(p_earliest_epg_date, v_business_date + 2) > v_business_date + 1 THEN -- add missing subpartitions if the business date has been moved back
          FOR recPartition IN (
            SELECT p.partition_position, p.partition_name
            FROM user_tab_partitions p
            WHERE p.table_name=UPPER('SLR_JRNL_LINES_WAITING')
            ORDER BY partition_position
          ) LOOP

            BEGIN
              EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_waiting modify partition '||recPartition.partition_name||' add subpartition values('''||p_epg_id||''')';
            EXCEPTION
              WHEN e_subpartition_exists THEN NULL;
            END;

          END LOOP;
        END IF;

      END pRestoreJrnlWaitingSubpart;

      PROCEDURE pMoveJrnlWaitingSubpartition IS
        l_partition_date date;
        l_earliest_epg_date date;
        l_earliest_epg_partition number;
      BEGIN
        <<manageSubpartitions>>
        FOR recSubpartition IN (
          SELECT part_high_value, subpart_high_value, partition_position, partition_name, subpartition_name FROM
            XMLTABLE('/ROWSET/ROW' PASSING -- DBMS_XMLGEN used as a workaround to extract part_high_value which is a long data type
              DBMS_XMLGEN.getXMLType('
                  select p.partition_position, p.high_value as part_high_value, s.high_value as subpart_high_value, p.partition_name, s.subpartition_name
                  from user_tab_partitions p
                    join user_tab_subpartitions s on p.table_name=s.table_name
                      and p.partition_name=s.partition_name
                  where p.table_name=upper(''SLR_JRNL_LINES_WAITING'')
                  order by partition_position
                ')
            COLUMNS
              part_high_value VARCHAR2(2000) PATH 'PART_HIGH_VALUE/text()',
              subpart_high_value VARCHAR2(2000) PATH 'SUBPART_HIGH_VALUE/text()',
              partition_position VARCHAR2(4000) PATH 'PARTITION_POSITION/text()',
              partition_name VARCHAR2(4000) PATH 'PARTITION_NAME/text()',
              subpartition_name VARCHAR2(4000) PATH 'SUBPARTITION_NAME/text()'
            ) x
            WHERE subpart_high_value=''''||p_epg_id||''''
        ) LOOP
          EXECUTE IMMEDIATE 'select '||recSubpartition.part_high_value||' from dual' into l_partition_date;
          l_earliest_epg_date := coalesce(l_earliest_epg_date, l_partition_date - 1);
          l_earliest_epg_partition := coalesce(l_earliest_epg_partition, recSubpartition.partition_position);
          IF l_partition_date - 1 > v_business_date THEN
            EXIT manageSubpartitions;
          END IF;

          pLockJrnlWaitingSubpartition();

          EXECUTE IMMEDIATE 'insert /*+ append */ into slr_jrnl_lines_unposted partition for ('''||p_epg_id||''') jlu
            select '||SLR_UTILITIES_PKG.fHint(p_epg_id, 'RESET_FAILED_JLU')||'
              jlw_jrnl_hdr_id, jlw_jrnl_line_number,
              standard_hash(jlw_entity||jlw_epg_id||jlw_account||jlw_segment_1||jlw_segment_2||jlw_segment_3||jlw_segment_4||jlw_segment_5||jlw_segment_6||jlw_segment_7||jlw_segment_8||jlw_segment_9||jlw_segment_10||jlw_tran_ccy, ''MD5''),
              standard_hash(
                jlw_entity||jlw_epg_id||jlw_account||jlw_segment_1||jlw_segment_2||jlw_segment_3||jlw_segment_4||jlw_segment_5||jlw_segment_6||jlw_segment_7||jlw_segment_8||jlw_segment_9||jlw_segment_10||jlw_tran_ccy||
                jlw_attribute_1||jlw_attribute_2||jlw_attribute_3||jlw_attribute_4||jlw_attribute_5,
              ''MD5''),
              ''U'', jlw_jrnl_status_text,
              '''||p_process_id||''', jlw_description, jlw_source_jrnl_id,
              jlw_effective_date, jlw_value_date, jlw_entity,
              jlw_epg_id, jlw_account, jlw_segment_1,
              jlw_segment_2, jlw_segment_3, jlw_segment_4,
              jlw_segment_5, jlw_segment_6, jlw_segment_7,
              jlw_segment_8, jlw_segment_9, jlw_segment_10,
              jlw_attribute_1, jlw_attribute_2, jlw_attribute_3,
              jlw_attribute_4, jlw_attribute_5, jlw_reference_1,
              jlw_reference_2, jlw_reference_3, jlw_reference_4,
              jlw_reference_5, jlw_reference_6, jlw_reference_7,
              jlw_reference_8, jlw_reference_9, jlw_reference_10,
              jlw_tran_ccy, jlw_tran_amount, jlw_base_rate,
              jlw_base_ccy, jlw_base_amount, jlw_local_rate,
              jlw_local_ccy, jlw_local_amount, jlw_created_by,
              jlw_created_on, jlw_amended_by, jlw_amended_on,
              jlw_jrnl_type, jlw_jrnl_date, jlw_jrnl_description,
              jlw_jrnl_source, jlw_jrnl_source_jrnl_id, jlw_jrnl_authorised_by,
              jlw_jrnl_authorised_on, jlw_jrnl_validated_by, jlw_jrnl_validated_on,
              jlw_jrnl_posted_by, jlw_jrnl_posted_on, jlw_jrnl_total_hash_debit,
              jlw_jrnl_total_hash_credit, jlw_jrnl_pref_static_src, jlw_jrnl_ref_id,
              jlw_jrnl_rev_date, jlw_translation_date, nvl(ep_bus_period, 0),
              nvl(ep_bus_year, 0), case when ea_account_type_flag = ''P'' then ep_bus_year else 1 end, jlw_jrnl_internal_period_flag,
              jlw_jrnl_ent_rate_set, jlw_type
            from slr_jrnl_lines_waiting subpartition('||recSubpartition.subpartition_name||')
              left join slr_entities on jlw_entity = ent_entity
              left join slr_entity_accounts on ea_entity_set = ent_accounts_set and ea_account = jlw_account
              left join slr_entity_periods on jlw_entity = ep_entity and jlw_effective_date >= ep_cal_period_start and jlw_effective_date <= ep_cal_period_end and ep_period_type <> 0';

          $IF DBMS_DB_VERSION.ver_le_11 $THEN
          IF NOT (recSubpartition.partition_position = 1) THEN
            pDropJrnlWaitingSubpartition(recSubpartition.partition_name, recSubpartition.subpartition_name);
          ELSE
            EXECUTE IMMEDIATE  'alter table slr_jrnl_lines_waiting truncate subpartition '||recSubpartition.subpartition_name;
          END IF;
          $ELSE
          IF NOT (DBMS_DB_VERSION.ver_le_12_1 AND recSubpartition.partition_position = 1) THEN -- 12.2 or above supports removal of the first interval partition
            pDropJrnlWaitingSubpartition(recSubpartition.partition_name, recSubpartition.subpartition_name);
          ELSE
            EXECUTE IMMEDIATE  'alter table slr_jrnl_lines_waiting truncate subpartition '||recSubpartition.subpartition_name;
          END IF;
          $END
        END LOOP;

        pRestoreJrnlWaitingSubpart(l_earliest_epg_date, l_earliest_epg_partition);

      END pMoveJrnlWaitingSubpartition;

      PROCEDURE pMoveErroredJournals IS
      BEGIN
        UPDATE  slr_jrnl_headers_unposted
        SET jhu_jrnl_status = 'U', jhu_jrnl_process_id = p_process_id
        WHERE
          jhu_epg_id = p_epg_id
          AND jhu_jrnl_status in ('E')
          AND jhu_jrnl_date <= v_business_date;

        IF SQL%ROWCOUNT > 0 OR p_use_headers THEN
          p_use_headers := TRUE;
        ELSE
          p_use_headers := FALSE;
        END IF;

        EXECUTE IMMEDIATE 'lock table slr_jrnl_lines_unposted subpartition for ('''||p_epg_id||''', ''E'') in exclusive mode nowait';

        EXECUTE IMMEDIATE 'insert /*+ append */ first
          when jlu_effective_date <= :v_business_date then into slr_jrnl_lines_unposted subpartition for ('''||p_epg_id||''', ''U'') values (
            jlu_jrnl_hdr_id, jlu_jrnl_line_number,
            standard_hash(jlu_entity||jlu_epg_id||jlu_account||jlu_segment_1||jlu_segment_2||jlu_segment_3||jlu_segment_4||jlu_segment_5||jlu_segment_6||jlu_segment_7||jlu_segment_8||jlu_segment_9||jlu_segment_10||jlu_tran_ccy, ''MD5''),
            standard_hash(
              jlu_entity||jlu_epg_id||jlu_account||jlu_segment_1||jlu_segment_2||jlu_segment_3||jlu_segment_4||jlu_segment_5||jlu_segment_6||jlu_segment_7||jlu_segment_8||jlu_segment_9||jlu_segment_10||jlu_tran_ccy||
              jlu_attribute_1||jlu_attribute_2||jlu_attribute_3||jlu_attribute_4||jlu_attribute_5,
            ''MD5''),
            jlu_jrnl_status, jlu_jrnl_status_text,
            jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
            jlu_effective_date, jlu_value_date, jlu_entity,
            jlu_epg_id, jlu_account, jlu_segment_1,
            jlu_segment_2, jlu_segment_3, jlu_segment_4,
            jlu_segment_5, jlu_segment_6, jlu_segment_7,
            jlu_segment_8, jlu_segment_9, jlu_segment_10,
            jlu_attribute_1, jlu_attribute_2, jlu_attribute_3,
            jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
            jlu_reference_2, jlu_reference_3, jlu_reference_4,
            jlu_reference_5, jlu_reference_6, jlu_reference_7,
            jlu_reference_8, jlu_reference_9, jlu_reference_10,
            jlu_tran_ccy, jlu_tran_amount, jlu_base_rate,
            jlu_base_ccy, jlu_base_amount, jlu_local_rate,
            jlu_local_ccy, jlu_local_amount, jlu_created_by,
            jlu_created_on, jlu_amended_by, jlu_amended_on,
            jlu_jrnl_type, jlu_jrnl_date, jlu_jrnl_description,
            jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by,
            jlu_jrnl_authorised_on, jlu_jrnl_validated_by, jlu_jrnl_validated_on,
            jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit,
            jlu_jrnl_total_hash_credit, jlu_jrnl_pref_static_src, jlu_jrnl_ref_id,
            jlu_jrnl_rev_date, jlu_translation_date, ep_bus_period,
            ep_bus_year, ep_bus_ltd, jlu_jrnl_internal_period_flag,
            jlu_jrnl_ent_rate_set, jlu_type
          )
          when jlu_effective_date > :v_business_date then into slr_jrnl_lines_waiting
          values (
            jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id,
            jlu_eba_id, ''W'', jlu_jrnl_status_text,
            jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
            jlu_effective_date, jlu_value_date, jlu_entity,
            jlu_epg_id, jlu_account, jlu_segment_1,
            jlu_segment_2, jlu_segment_3, jlu_segment_4,
            jlu_segment_5, jlu_segment_6, jlu_segment_7,
            jlu_segment_8, jlu_segment_9, jlu_segment_10,
            jlu_attribute_1, jlu_attribute_2, jlu_attribute_3,
            jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
            jlu_reference_2, jlu_reference_3, jlu_reference_4,
            jlu_reference_5, jlu_reference_6, jlu_reference_7,
            jlu_reference_8, jlu_reference_9, jlu_reference_10,
            jlu_tran_ccy, jlu_tran_amount, jlu_base_rate,
            jlu_base_ccy, jlu_base_amount, jlu_local_rate,
            jlu_local_ccy, jlu_local_amount, jlu_created_by,
            jlu_created_on, jlu_amended_by, jlu_amended_on,
            jlu_jrnl_type, jlu_jrnl_date, jlu_jrnl_description,
            jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by,
            jlu_jrnl_authorised_on, jlu_jrnl_validated_by, jlu_jrnl_validated_on,
            jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit,
            jlu_jrnl_total_hash_credit, jlu_jrnl_pref_static_src, jlu_jrnl_ref_id,
            jlu_jrnl_rev_date, jlu_translation_date, ep_bus_period,
            ep_bus_year, ep_bus_ltd, jlu_jrnl_internal_period_flag,
            jlu_jrnl_ent_rate_set, jlu_type
          )
          select '||SLR_UTILITIES_PKG.fHint(p_epg_id, 'RESET_FAILED_JLU')||'
            jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id,
            jlu_eba_id, ''U'' as jlu_jrnl_status, jlu_jrnl_status_text,
            '''||p_process_id||''' as jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
            jlu_effective_date, jlu_value_date, jlu_entity,
            jlu_epg_id, jlu_account, jlu_segment_1,
            jlu_segment_2, jlu_segment_3, jlu_segment_4,
            jlu_segment_5, jlu_segment_6, jlu_segment_7,
            jlu_segment_8, jlu_segment_9, jlu_segment_10,
            jlu_attribute_1, jlu_attribute_2, jlu_attribute_3,
            jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
            jlu_reference_2, jlu_reference_3, jlu_reference_4,
            jlu_reference_5, jlu_reference_6, jlu_reference_7,
            jlu_reference_8, jlu_reference_9, jlu_reference_10,
            jlu_tran_ccy, jlu_tran_amount, jlu_base_rate,
            jlu_base_ccy, jlu_base_amount, jlu_local_rate,
            jlu_local_ccy, jlu_local_amount, jlu_created_by,
            jlu_created_on, jlu_amended_by, jlu_amended_on,
            jlu_jrnl_type, jlu_jrnl_date, jlu_jrnl_description,
            jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by,
            jlu_jrnl_authorised_on, jlu_jrnl_validated_by, jlu_jrnl_validated_on,
            jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit,
            jlu_jrnl_total_hash_credit, jlu_jrnl_pref_static_src, jlu_jrnl_ref_id,
            jlu_jrnl_rev_date, jlu_translation_date, nvl(ep_bus_period, 0) as ep_bus_period,
            nvl(ep_bus_year, 0) as ep_bus_year, case when ea_account_type_flag = ''P'' then ep_bus_year else 1 end as ep_bus_ltd, jlu_jrnl_internal_period_flag,
            jlu_jrnl_ent_rate_set, jlu_type
          from slr_jrnl_lines_unposted subpartition for ('''||p_epg_id||''', ''E'')
            left join slr_entities on jlu_entity = ent_entity
            left join slr_entity_accounts on ea_entity_set = ent_accounts_set and ea_account = jlu_account
            left join slr_entity_periods on jlu_entity = ep_entity and jlu_effective_date >= ep_cal_period_start and jlu_effective_date <= ep_cal_period_end and ep_period_type <> 0
          where jlu_epg_id = '''||p_epg_id||'''' using v_business_date, v_business_date;

        EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_unposted truncate subpartition for ('''||p_epg_id||''', ''E'')';
      END pMoveErroredJournals;

      PROCEDURE pMoveWaitingJournals IS
      BEGIN
        EXECUTE IMMEDIATE 'lock table slr_jrnl_lines_unposted subpartition for ('''||p_epg_id||''', ''W'') in exclusive mode nowait';

        EXECUTE IMMEDIATE 'insert /*+ append */ first
          when jlu_effective_date <= :v_business_date then into slr_jrnl_lines_unposted subpartition for ('''||p_epg_id||''', ''U'') values (
            jlu_jrnl_hdr_id, jlu_jrnl_line_number,
            standard_hash(jlu_entity||jlu_epg_id||jlu_account||jlu_segment_1||jlu_segment_2||jlu_segment_3||jlu_segment_4||jlu_segment_5||jlu_segment_6||jlu_segment_7||jlu_segment_8||jlu_segment_9||jlu_segment_10||jlu_tran_ccy, ''MD5''),
            standard_hash(
              jlu_entity||jlu_epg_id||jlu_account||jlu_segment_1||jlu_segment_2||jlu_segment_3||jlu_segment_4||jlu_segment_5||jlu_segment_6||jlu_segment_7||jlu_segment_8||jlu_segment_9||jlu_segment_10||jlu_tran_ccy||
              jlu_attribute_1||jlu_attribute_2||jlu_attribute_3||jlu_attribute_4||jlu_attribute_5,
            ''MD5''),
            ''U'', jlu_jrnl_status_text,
            jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
            jlu_effective_date, jlu_value_date, jlu_entity,
            jlu_epg_id, jlu_account, jlu_segment_1,
            jlu_segment_2, jlu_segment_3, jlu_segment_4,
            jlu_segment_5, jlu_segment_6, jlu_segment_7,
            jlu_segment_8, jlu_segment_9, jlu_segment_10,
            jlu_attribute_1, jlu_attribute_2, jlu_attribute_3,
            jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
            jlu_reference_2, jlu_reference_3, jlu_reference_4,
            jlu_reference_5, jlu_reference_6, jlu_reference_7,
            jlu_reference_8, jlu_reference_9, jlu_reference_10,
            jlu_tran_ccy, jlu_tran_amount, jlu_base_rate,
            jlu_base_ccy, jlu_base_amount, jlu_local_rate,
            jlu_local_ccy, jlu_local_amount, jlu_created_by,
            jlu_created_on, jlu_amended_by, jlu_amended_on,
            jlu_jrnl_type, jlu_jrnl_date, jlu_jrnl_description,
            jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by,
            jlu_jrnl_authorised_on, jlu_jrnl_validated_by, jlu_jrnl_validated_on,
            jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit,
            jlu_jrnl_total_hash_credit, jlu_jrnl_pref_static_src, jlu_jrnl_ref_id,
            jlu_jrnl_rev_date, jlu_translation_date, ep_bus_period,
            ep_bus_year, ep_bus_ltd, jlu_jrnl_internal_period_flag,
            jlu_jrnl_ent_rate_set, jlu_type
          )
          when jlu_effective_date > :v_business_date then into slr_jrnl_lines_waiting
          values (
            jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id,
            jlu_eba_id, jlu_jrnl_status, jlu_jrnl_status_text,
            jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
            jlu_effective_date, jlu_value_date, jlu_entity,
            jlu_epg_id, jlu_account, jlu_segment_1,
            jlu_segment_2, jlu_segment_3, jlu_segment_4,
            jlu_segment_5, jlu_segment_6, jlu_segment_7,
            jlu_segment_8, jlu_segment_9, jlu_segment_10,
            jlu_attribute_1, jlu_attribute_2, jlu_attribute_3,
            jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
            jlu_reference_2, jlu_reference_3, jlu_reference_4,
            jlu_reference_5, jlu_reference_6, jlu_reference_7,
            jlu_reference_8, jlu_reference_9, jlu_reference_10,
            jlu_tran_ccy, jlu_tran_amount, jlu_base_rate,
            jlu_base_ccy, jlu_base_amount, jlu_local_rate,
            jlu_local_ccy, jlu_local_amount, jlu_created_by,
            jlu_created_on, jlu_amended_by, jlu_amended_on,
            jlu_jrnl_type, jlu_jrnl_date, jlu_jrnl_description,
            jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by,
            jlu_jrnl_authorised_on, jlu_jrnl_validated_by, jlu_jrnl_validated_on,
            jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit,
            jlu_jrnl_total_hash_credit, jlu_jrnl_pref_static_src, jlu_jrnl_ref_id,
            jlu_jrnl_rev_date, jlu_translation_date, ep_bus_period,
            ep_bus_year, ep_bus_ltd, jlu_jrnl_internal_period_flag,
            jlu_jrnl_ent_rate_set, jlu_type
          )
          select '||SLR_UTILITIES_PKG.fHint(p_epg_id, 'RESET_FAILED_JLU')||'
            jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id,
            jlu_eba_id, ''W'' as jlu_jrnl_status, jlu_jrnl_status_text,
            '''||p_process_id||''' as jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
            jlu_effective_date, jlu_value_date, jlu_entity,
            jlu_epg_id, jlu_account, jlu_segment_1,
            jlu_segment_2, jlu_segment_3, jlu_segment_4,
            jlu_segment_5, jlu_segment_6, jlu_segment_7,
            jlu_segment_8, jlu_segment_9, jlu_segment_10,
            jlu_attribute_1, jlu_attribute_2, jlu_attribute_3,
            jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
            jlu_reference_2, jlu_reference_3, jlu_reference_4,
            jlu_reference_5, jlu_reference_6, jlu_reference_7,
            jlu_reference_8, jlu_reference_9, jlu_reference_10,
            jlu_tran_ccy, jlu_tran_amount, jlu_base_rate,
            jlu_base_ccy, jlu_base_amount, jlu_local_rate,
            jlu_local_ccy, jlu_local_amount, jlu_created_by,
            jlu_created_on, jlu_amended_by, jlu_amended_on,
            jlu_jrnl_type, jlu_jrnl_date, jlu_jrnl_description,
            jlu_jrnl_source, jlu_jrnl_source_jrnl_id, jlu_jrnl_authorised_by,
            jlu_jrnl_authorised_on, jlu_jrnl_validated_by, jlu_jrnl_validated_on,
            jlu_jrnl_posted_by, jlu_jrnl_posted_on, jlu_jrnl_total_hash_debit,
            jlu_jrnl_total_hash_credit, jlu_jrnl_pref_static_src, jlu_jrnl_ref_id,
            jlu_jrnl_rev_date, jlu_translation_date, nvl(ep_bus_period, 0) as ep_bus_period,
            nvl(ep_bus_year, 0) as ep_bus_year, case when ea_account_type_flag = ''P'' then ep_bus_year else 1 end as ep_bus_ltd, jlu_jrnl_internal_period_flag,
            jlu_jrnl_ent_rate_set, jlu_type
          from slr_jrnl_lines_unposted subpartition for ('''||p_epg_id||''', ''W'')
            left join slr_entities on jlu_entity = ent_entity
            left join slr_entity_accounts on ea_entity_set = ent_accounts_set and ea_account = jlu_account
            left join slr_entity_periods on jlu_entity = ep_entity and jlu_effective_date >= ep_cal_period_start and jlu_effective_date <= ep_cal_period_end and ep_period_type <> 0
          where jlu_epg_id = '''||p_epg_id||'''' using v_business_date, v_business_date;

        EXECUTE IMMEDIATE 'alter table slr_jrnl_lines_unposted truncate subpartition for ('''||p_epg_id||''', ''W'')';

        UPDATE slr_jrnl_headers_unposted
        SET jhu_jrnl_status = 'U', jhu_jrnl_process_id = p_process_id
        WHERE
          jhu_epg_id = p_epg_id
          AND jhu_jrnl_status in ('W')
          AND jhu_jrnl_date <= fEntityGroupCurrBusDate(p_epg_id);

        IF SQL%ROWCOUNT > 0 OR p_use_headers THEN
          p_use_headers := TRUE;
        ELSE
          p_use_headers := FALSE;
        END IF;

      END pMoveWaitingJournals;

    BEGIN

    -- reset failed and reversal journals to be taken by batch processing
    -- set periods fields for those records
    -- reset journal headers if present (created by for instance by MADJ reversal)

    <<moveErroredJournals>>
    DECLARE
      e_subpartition_missing EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_subpartition_missing, -14400);

      e_outside_max_number EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_outside_max_number, -14300);

    BEGIN
      pMoveErroredJournals();
    EXCEPTION
      WHEN e_subpartition_missing THEN
        slr_admin_pkg.error('Failed to move waiting journals for '''||p_epg_id||''', business date: '''||to_char(v_business_date, 'yyyy-mm-dd')||'''. Attempting to add missing subpartitions. ', dbms_utility.format_error_backtrace);
        pRestoreJrnlWaitingSubpart(NULL, NULL);
        pMoveErroredJournals();
      WHEN e_outside_max_number THEN
        slr_admin_pkg.error('Failed to move waiting journals for '''||p_epg_id||''', business date: '''||to_char(v_business_date, 'yyyy-mm-dd')||'''. Attempting to add missing subpartitions. ', dbms_utility.format_error_backtrace);
        pRestoreJrnlWaitingSubpart(NULL, NULL);
        pMoveErroredJournals();
    END moveErroredJournals;

    pMoveJrnlWaitingSubpartition();

    <<moveJournalsToUnposted>>
    DECLARE
      e_subpartition_missing EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_subpartition_missing, -14400);
    BEGIN
      pMoveWaitingJournals();
    EXCEPTION
      WHEN e_subpartition_missing THEN
        slr_admin_pkg.error('Failed to move waiting journals for '''||p_epg_id||''', business date: '''||to_char(v_business_date, 'yyyy-mm-dd')||'''. Attempting to add missing subpartitions. ', dbms_utility.format_error_backtrace);
        pRestoreJrnlWaitingSubpart(NULL, NULL);
        pMoveWaitingJournals();
    END moveJournalsToUnposted;
    COMMIT;

    EXCEPTION
      WHEN e_invalid_partition THEN
          gv_msg := 'Failure to reset failed journals, no partion exists for EPG_ID '||p_epg_id||' in SLR_JRNL_LINES_UNPOSTED. The procedure SLR_ADMIN_PKG.AddEpg needs to by run before proceeding.';
          pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, null, null, null, gs_stage, 'PL/SQL', SQLCODE);
          slr_admin_pkg.error('Failure to reset failed journals from epg_id '''||p_epg_id||''', business date: '''||to_char(v_business_date, 'yyyy-mm-dd')||''' due to error: '||sqlerrm||'. Posting process was not aborted.', dbms_utility.format_error_backtrace);
          ROLLBACK;
      WHEN OTHERS THEN
          gv_msg := 'Failure to reset failed journals';
          pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, null, null, null, gs_stage, 'PL/SQL', SQLCODE);
          slr_admin_pkg.error('Failure to reset failed journals from epg_id '''||p_epg_id||''', business date: '''||to_char(v_business_date, 'yyyy-mm-dd')||''' due to error: '||sqlerrm, dbms_utility.format_error_backtrace);
          ROLLBACK;
          RAISE_APPLICATION_ERROR(-20001, gv_msg);

    END pResetFailedJournals;

-- ----------------------------------------------------------------------------
-- Procedure:   pUPDATE_SLR_ENTITY_DAYS
-- Description: Insert working and non-working days into SLR_ENTITY_DAYS
--              for a specified entity set and, optionally, calendar
--              between specified dates.
-- Note:        Calendar defaults to 1.
--
-- ----------------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_ENTITY_DAYS
(
    p_entity_set  in SLR_ENTITY_DAYS.ED_ENTITY_SET%type,
    p_start_date  in date,
    p_end_date    in date,
    p_status      in SLR_ENTITY_DAYS.ED_STATUS%TYPE,
    p_calendar_name in FR_HOLIDAY_DATE.HD_CA_CALENDAR_NAME%TYPE := 'DEFAULT',
    p_delete_existing_days in CHAR := 'Y',
    user_id       in varchar2 := USER
)
AS
    s_proc_name       VARCHAR2(80) := 'SLR_UTILITIES_PKG.pUPDATE_SLR_ENTITY_DAYS';

BEGIN


	IF( coalesce(p_delete_existing_days,'Y') = 'Y' ) THEN
        DELETE FROM SLR_ENTITY_DAYS
        WHERE ED_ENTITY_SET = p_entity_set;
    end if;

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
					nvl ( CASE RTRIM(UPPER(TO_CHAR(cal_day, 'DAY', 'NLS_DATE_LANGUAGE = ENGLISH')))
								--there is additional checking for extra working/nonworking days from FR_HOLIDAY_DATE - for all weekdays (not only weekend)
								WHEN 'MONDAY'  THEN 
									CASE WHEN CAW_MONDAY = 0 
										 THEN TRIM(NVL(HD_DAY_TYPE,'0')) 
										 ELSE CASE WHEN TRIM(NVL(HD_DAY_TYPE,'1')) = '1'
												   THEN to_char(CAW_MONDAY)
												   ELSE TRIM(NVL(HD_DAY_TYPE,'0'))
											  END
									END
								WHEN 'TUESDAY' THEN
									CASE WHEN CAW_TUESDAY = 0
										 THEN TRIM(NVL(HD_DAY_TYPE,'0'))
										 ELSE CASE WHEN TRIM(NVL(HD_DAY_TYPE,'1')) = '1'
												   THEN to_char(CAW_TUESDAY)
												   ELSE TRIM(NVL(HD_DAY_TYPE,'0'))
											  END
									END
								WHEN 'WEDNESDAY' THEN
									CASE WHEN CAW_WEDNESDAY = 0
										 THEN TRIM(NVL(HD_DAY_TYPE,'0'))
										 ELSE CASE WHEN TRIM(NVL(HD_DAY_TYPE,'1')) = '1'
												   THEN to_char(CAW_WEDNESDAY)
												   ELSE TRIM(NVL(HD_DAY_TYPE,'0'))
											  END
									END
								WHEN 'THURSDAY' THEN
									CASE WHEN CAW_THURSDAY = 0
										 THEN TRIM(NVL(HD_DAY_TYPE,'0'))
										 ELSE CASE WHEN TRIM(NVL(HD_DAY_TYPE,'1')) = '1'
												   THEN to_char(CAW_THURSDAY)
												   ELSE TRIM(NVL(HD_DAY_TYPE,'0'))
											  END
									END
								WHEN 'FRIDAY' THEN
									CASE WHEN CAW_FRIDAY = 0
										 THEN TRIM(NVL(HD_DAY_TYPE,'0'))
										 ELSE CASE WHEN TRIM(NVL(HD_DAY_TYPE,'1')) = '1'
												   THEN to_char(CAW_FRIDAY)
												   ELSE TRIM(NVL(HD_DAY_TYPE,'0'))
											  END
									END
								WHEN 'SATURDAY' THEN
									CASE WHEN CAW_SATURDAY = 0
										 THEN TRIM(NVL(HD_DAY_TYPE,'0'))
										 ELSE CASE WHEN TRIM(NVL(HD_DAY_TYPE,'1')) = '1'
												   THEN to_char(CAW_SATURDAY)
												   ELSE TRIM(NVL(HD_DAY_TYPE,'0'))
											  END
									END
								WHEN 'SUNDAY' THEN
									CASE WHEN CAW_SUNDAY = 0
										 THEN TRIM(NVL(HD_DAY_TYPE,'0'))
										 ELSE CASE WHEN TRIM(NVL(HD_DAY_TYPE,'1')) = '1'
												   THEN to_char(CAW_SUNDAY)
												   ELSE TRIM(NVL(HD_DAY_TYPE,'0')) 
											  END
									END
							  END , '1')   = '0' 
				then 'C'
				else p_status
			end as status,
			user_id, trunc(sysdate),
			user_id, trunc(sysdate)
	FROM days_range
	LEFT JOIN FR_HOLIDAY_DATE ON (TRUNC(HD_HOLIDAY_DATE) = TRUNC(cal_day)  AND HD_ACTIVE = 'A' AND HD_CA_CALENDAR_NAME = p_calendar_name)
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

END pUPDATE_SLR_ENTITY_DAYS;

-- -----------------------------------------------------------------------
-- Procedure:   pUPDATE_SLR_ENTITY_PERIODS
-- Description: Insert data into SLR_ENTITY_PERIODS for a specified entity
--              between specified dates.
-- Calls:       SLR_CALENDAR_PKG
--
-- -----------------------------------------------------------------------
PROCEDURE pUPDATE_SLR_ENTITY_PERIODS
(
    p_entity in SLR_ENTITIES.ENT_ENTITY%TYPE,
    p_start_bus_year_month in NUMBER,
    p_start_date in date,
    p_end_date in date,
    p_status in VARCHAR2,
    p_delete_existing_periods IN CHAR := 'Y'
)
AS

    s_proc_name       VARCHAR2(80) := 'SLR_UTILITIES_PKG.pUPDATE_SLR_ENTITY_PERIODS';

BEGIN

    SLR_CALENDAR_PKG.pSetEntityPeriods(p_entity, p_start_bus_year_month, p_start_date, p_end_date, p_status, p_delete_existing_periods);

EXCEPTION
    WHEN OTHERS THEN
        gv_msg := 'Failed to set SLR entity periods for entity ['||p_entity||'] ';
        pr_error(slr_global_pkg.C_MAJERR, gv_msg, slr_global_pkg.C_TECHNICAL, s_proc_name, 'SLR_ENTITY_PERIODS', null, 'Entity', gs_stage, 'PL/SQL', SQLCODE);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, gv_msg);

END pUPDATE_SLR_ENTITY_PERIODS;

-- -----------------------------------------------------------------------
-- Procedure:   pUpdateJrnlLinesUnposted
-- Description: Copy all information from SLR_JRNL_HEADERS_UNPOSTED
--              to SLR_JRNL_LINES_UNPOSTED as SLR_JRNL_HEADERS_UNPOSTED
--              is not used in ValidateAndPost process.
-- -----------------------------------------------------------------------
PROCEDURE pUpdateJrnlLinesUnposted
(
    p_epg_id        IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE
)
AS
BEGIN

    -------------------------------------------------------------------------
    -- Copy into SLR_JRNL_LINES_UNPOSTED,
    -- conditions against EPG_ID and Status added for partition elimination.
    -------------------------------------------------------------------------
    UPDATE SLR_JRNL_LINES_UNPOSTED
    SET
        (
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
            JLU_JRNL_PREF_STATIC_SRC,
            JLU_JRNL_REF_ID,
            JLU_JRNL_REV_DATE
        )
        =
        (
            SELECT
                JHU_JRNL_TYPE,
                JHU_JRNL_DESCRIPTION,
                JHU_JRNL_SOURCE,
                JHU_JRNL_SOURCE_JRNL_ID,
                JHU_JRNL_AUTHORISED_BY,
                JHU_JRNL_AUTHORISED_ON,
                JHU_JRNL_VALIDATED_BY,
                JHU_JRNL_VALIDATED_ON,
                JHU_JRNL_POSTED_BY,
                JHU_JRNL_POSTED_ON,
                JHU_JRNL_TOTAL_HASH_DEBIT,
                JHU_JRNL_TOTAL_HASH_CREDIT,
                JHU_JRNL_PREF_STATIC_SRC,
                JHU_JRNL_REF_ID,
                JHU_JRNL_REV_DATE
            FROM SLR_JRNL_HEADERS_UNPOSTED
            WHERE JHU_JRNL_ID = JLU_JRNL_HDR_ID
        )
    WHERE EXISTS
    (
        SELECT 1
        FROM SLR_JRNL_HEADERS_UNPOSTED
        WHERE JHU_JRNL_ID = JLU_JRNL_HDR_ID
        AND JHU_EPG_ID = p_epg_id
    )
    AND JLU_EPG_ID = p_epg_id
    AND JLU_JRNL_STATUS IN ('W','E','U')
    ;

    ----------------------------------------------------------------------------------------------------
    -- Delete SLR_JRNL_HEADERS_UNPOSTED that data has been just copied into SLR_JRNL_LINES_UNPOSTED.
    -- Records from GUI are not deleted as they are displayed on screens.
    ----------------------------------------------------------------------------------------------------
    DELETE SLR_JRNL_HEADERS_UNPOSTED
    WHERE EXISTS
    (
        SELECT 1
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JHU_JRNL_ID = JLU_JRNL_HDR_ID
        AND JLU_EPG_ID = p_epg_id
        AND JLU_JRNL_STATUS IN ('W','E','U')
    )
    AND NVL(JHU_MANUAL_FLAG, 'N') = 'N'
    ;

END pUpdateJrnlLinesUnposted;

-- -----------------------------------------------------------------------------
-- Procedure:   pUpdateJrnlLinesUnposted(entity, headerId := null)
-- Description: Copy all information from SLR_JRNL_HEADERS_UNPOSTED
--              to SLR_JRNL_LINES_UNPOSTED per entity and headerId if needed
--				Parameters required for simultaneous MADJ processing
--				SLR_JRNL_HEADERS_UNPOSTED is not used in ValidateAndPost process
-- -----------------------------------------------------------------------------
PROCEDURE pUpdateJrnlLinesUnposted
(
    p_epg_id 		IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    pProcessId		IN NUMBER,
    pStatus			IN CHAR := 'U',
    pJrnlId SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE := NULL
)
AS
BEGIN
   IF pJrnlId IS NULL THEN

	    MERGE INTO SLR_JRNL_LINES_UNPOSTED jlu
   		USING ( SELECT
	                JHU_JRNL_TYPE,
	                JHU_JRNL_DESCRIPTION,
	                JHU_JRNL_SOURCE,
	                JHU_JRNL_SOURCE_JRNL_ID,
	                JHU_JRNL_AUTHORISED_BY,
	                JHU_JRNL_AUTHORISED_ON,
	                JHU_JRNL_VALIDATED_BY,
	                JHU_JRNL_VALIDATED_ON,
	                JHU_JRNL_POSTED_BY,
	                JHU_JRNL_POSTED_ON,
	                JHU_JRNL_TOTAL_HASH_DEBIT,
	                JHU_JRNL_TOTAL_HASH_CREDIT,
	                JHU_JRNL_PREF_STATIC_SRC,
	                JHU_JRNL_REF_ID,
	                JHU_JRNL_REV_DATE,
                    JHU_EPG_ID,
	                NVL(EP_BUS_PERIOD,0)    as EP_BUS_PERIOD,
                    NVL(EP_BUS_YEAR,0)      as EP_BUS_YEAR,
                    JHU_JRNL_DATE,
                    JHU_JRNL_ENTITY,
                    JHU_JRNL_ID,
                    JHU_JRNL_PROCESS_ID,
                    JHU_JRNL_STATUS,
                    EA_ACCOUNT,
                    EA_ACCOUNT_TYPE_FLAG
	            FROM SLR_JRNL_HEADERS_UNPOSTED
	            LEFT JOIN SLR_ENTITY_PERIODS
	            	ON JHU_JRNL_DATE BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
	            	AND JHU_JRNL_ENTITY = EP_ENTITY
	            	AND EP_PERIOD_TYPE != 0
	            LEFT JOIN SLR_ENTITIES
	            	ON ENT_ENTITY = JHU_JRNL_ENTITY
	            LEFT JOIN SLR_ENTITY_ACCOUNTS
            		ON EA_ENTITY_SET = ENT_ACCOUNTS_SET
                WHERE JHU_JRNL_PROCESS_ID = pProcessId
                AND JHU_EPG_ID = p_epg_id
                AND JHU_JRNL_STATUS  = pStatus
	   )hdr
   		ON (jlu.JLU_JRNL_HDR_ID = hdr.JHU_JRNL_ID
	        AND jlu.JLU_ENTITY = hdr.JHU_JRNL_ENTITY
	        AND jlu.JLU_JRNL_STATUS = hdr.JHU_JRNL_STATUS
            AND jlu.JLU_EFFECTIVE_DATE = hdr.JHU_JRNL_DATE
            AND jlu.JLU_JRNL_PROCESS_ID = hdr.JHU_JRNL_PROCESS_ID
            AND jlu.JLU_EPG_ID = hdr.JHU_EPG_ID
            AND jlu.JLU_ACCOUNT	= hdr.EA_ACCOUNT
		)
	   WHEN MATCHED THEN
	   UPDATE SET 	JLU_JRNL_TYPE 				= JHU_JRNL_TYPE,
		            JLU_JRNL_DESCRIPTION 		= JHU_JRNL_DESCRIPTION,
		            JLU_JRNL_SOURCE 			= JHU_JRNL_SOURCE,
		            JLU_JRNL_SOURCE_JRNL_ID 	= JHU_JRNL_SOURCE_JRNL_ID,
		            JLU_JRNL_AUTHORISED_BY 		= JHU_JRNL_AUTHORISED_BY,
		            JLU_JRNL_AUTHORISED_ON 		= JHU_JRNL_AUTHORISED_ON,
		            JLU_JRNL_VALIDATED_BY 		= JHU_JRNL_VALIDATED_BY,
		            JLU_JRNL_VALIDATED_ON 		= JHU_JRNL_VALIDATED_ON,
		            JLU_JRNL_POSTED_BY 			= JHU_JRNL_POSTED_BY,
		            JLU_JRNL_POSTED_ON 			= JHU_JRNL_POSTED_ON,
		            JLU_JRNL_TOTAL_HASH_DEBIT 	= JHU_JRNL_TOTAL_HASH_DEBIT,
		            JLU_JRNL_TOTAL_HASH_CREDIT 	= JHU_JRNL_TOTAL_HASH_CREDIT,
		            JLU_JRNL_PREF_STATIC_SRC 	= JHU_JRNL_PREF_STATIC_SRC,
		            JLU_JRNL_REF_ID 			= JHU_JRNL_REF_ID,
		            JLU_JRNL_REV_DATE 			= JHU_JRNL_REV_DATE,
		            JLU_PERIOD_MONTH			= EP_BUS_PERIOD,
	    			JLU_PERIOD_YEAR				= EP_BUS_YEAR,
					JLU_PERIOD_LTD				= CASE WHEN EA_ACCOUNT_TYPE_FLAG = 'P' THEN NVL(EP_BUS_YEAR,0) ELSE 1 END
		;

	    DELETE SLR_JRNL_HEADERS_UNPOSTED
	    WHERE EXISTS
	    (
	        SELECT 1
	        FROM SLR_JRNL_LINES_UNPOSTED
	        WHERE JHU_JRNL_ID = JLU_JRNL_HDR_ID
	        AND JHU_JRNL_ENTITY = JLU_ENTITY
	        AND JLU_EPG_ID = p_epg_id
	    )
	    AND NVL(JHU_MANUAL_FLAG, 'N') = 'N'
	    ;

	    ELSE

		    UPDATE SLR_JRNL_LINES_UNPOSTED
		    SET
		        (
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
		            JLU_JRNL_PREF_STATIC_SRC,
		            JLU_JRNL_REF_ID,
		            JLU_JRNL_REV_DATE
		        )
		        =
		        (
		            SELECT
		                JHU_JRNL_TYPE,
		                JHU_JRNL_DESCRIPTION,
		                JHU_JRNL_SOURCE,
		                JHU_JRNL_SOURCE_JRNL_ID,
		                JHU_JRNL_AUTHORISED_BY,
		                JHU_JRNL_AUTHORISED_ON,
		                JHU_JRNL_VALIDATED_BY,
		                JHU_JRNL_VALIDATED_ON,
		                JHU_JRNL_POSTED_BY,
		                JHU_JRNL_POSTED_ON,
		                JHU_JRNL_TOTAL_HASH_DEBIT,
		                JHU_JRNL_TOTAL_HASH_CREDIT,
		                JHU_JRNL_PREF_STATIC_SRC,
		                JHU_JRNL_REF_ID,
		                JHU_JRNL_REV_DATE
		            FROM SLR_JRNL_HEADERS_UNPOSTED
		            WHERE JHU_JRNL_ID = JLU_JRNL_HDR_ID
		            AND JHU_JRNL_ID = pJrnlId

		        )
		    WHERE EXISTS
		    (
		        SELECT 1
		        FROM SLR_JRNL_HEADERS_UNPOSTED
		        WHERE JHU_JRNL_ID = JLU_JRNL_HDR_ID
		     	AND JHU_JRNL_ID = pJrnlId
		    );

		    DELETE SLR_JRNL_HEADERS_UNPOSTED
		    WHERE EXISTS
		    (
		        SELECT 1
		        FROM SLR_JRNL_LINES_UNPOSTED
		        WHERE JHU_JRNL_ID = JLU_JRNL_HDR_ID
		        AND JLU_JRNL_HDR_ID = pJrnlId
		    )
		    AND NVL(JHU_MANUAL_FLAG, 'N') = 'N'
		    AND JHU_JRNL_ID = pJrnlId
		    ;
	END IF;

END pUpdateJrnlLinesUnposted;

-- returns subpartition name P[YYYYMMDD]_S[ENT_GROUP]
FUNCTION fSubpartitionName
(
	p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
	p_date IN DATE
) RETURN VARCHAR2
AS
BEGIN
	RETURN 'P' || TO_CHAR(p_date, 'YYYYMMDD') || '_S' || p_epg_id;
END fSubpartitionName;

FUNCTION fSubpartitionExists
(
    p_table_name VARCHAR,
    p_subpartition_name VARCHAR
) RETURN BOOLEAN
AS
    lv_number NUMBER(1);
BEGIN
    SELECT COUNT(*) INTO lv_number
    FROM USER_TAB_SUBPARTITIONS
    WHERE TABLE_NAME = UPPER(p_table_name)
        AND SUBPARTITION_NAME = UPPER(p_subpartition_name);

    IF lv_number = 1 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END fSubpartitionExists;

FUNCTION fUserSubpartitionExists
(
    p_user VARCHAR,
    p_table_name VARCHAR,
    p_subpartition_name VARCHAR
) RETURN BOOLEAN
AS
    lv_number NUMBER(1);
BEGIN
    SELECT COUNT(*) INTO lv_number
    FROM ALL_TAB_SUBPARTITIONS
    WHERE TABLE_NAME = UPPER(p_table_name)
        AND TABLE_OWNER = UPPER(p_user)
        AND SUBPARTITION_NAME = UPPER(p_subpartition_name);

    IF lv_number = 1 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END fUserSubpartitionExists;

FUNCTION fHint
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_statement IN SLR_HINTS_SETS.HS_STATEMENT%TYPE
) RETURN SLR_HINTS_SETS.HS_HINT%TYPE
AS
    lv_hint SLR_HINTS_SETS.HS_HINT%TYPE;
BEGIN
    SELECT HS_HINT
    INTO lv_hint
    FROM SLR_HINTS
    JOIN SLR_HINTS_SETS
        ON H_SET = HS_SET
    WHERE H_EPG_ID = p_epg_id
        AND HS_STATEMENT = p_statement;

    RETURN lv_hint;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        SLR_ADMIN_PKG.Error('Hint not found for statement key ' || p_statement || ' and EPG_ID ' || p_epg_id || '. No hint was used, but processing is in progress.');
        RETURN '';
END fHint;

--------------------------------------------------------------------------------

PROCEDURE pDropTableIfExists
(
    p_table_name IN VARCHAR2
)
AS
BEGIN
	EXECUTE IMMEDIATE 'DROP TABLE ' || p_table_name;
EXCEPTION
	WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END pDropTableIfExists;

--------------------------------------------------------------------------------
PROCEDURE pAssignNewProcessIdAndStatus
(
    p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_header_id_list IN VARCHAR2,
    p_status_from IN CHAR,
    p_status_to	IN CHAR,
    p_process_id OUT NUMBER
)
IS
s_proc_name VARCHAR2(80) := 'SLR_UTILITIES_PKG.pAssignNewProcessIdAndStatus';
e_internal_processing_error      EXCEPTION;

BEGIN

	SELECT SEQ_PROCESS_NUMBER.NEXTVAL INTO p_process_id  FROM DUAL;

	EXECUTE IMMEDIATE
    'UPDATE SLR_JRNL_LINES_UNPOSTED
    SET
        JLU_JRNL_PROCESS_ID = ' || to_char(p_process_id) || ',
		JLU_JRNL_STATUS  = ''' || p_status_to  || '''
    WHERE JLU_JRNL_HDR_ID IN (' || p_header_id_list ||')
	AND JLU_EPG_ID = ''' || p_epg_id || '''
	AND JLU_JRNL_STATUS = ''' || p_status_from  || '''';

    EXECUTE IMMEDIATE
    'UPDATE SLR_JRNL_HEADERS_UNPOSTED
    SET
        JHU_JRNL_PROCESS_ID = ' || to_char(p_process_id) || ',
		JHU_JRNL_STATUS  = ''' || p_status_to  || '''
    WHERE JHU_JRNL_ID IN (' || p_header_id_list ||')
	AND JHU_EPG_ID = ''' || p_epg_id || '''
	AND JHU_JRNL_STATUS = ''' || p_status_from  || '''';

    EXCEPTION
	WHEN OTHERS THEN
       ROLLBACK;
       SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'SLR_JRNL_LINES/HEADERS_UNPOSTED',
			'Error during assigning new process id and status to SLR_JRNL_LINES/HEADERS_UNPOSTED',
			p_process_id,p_epg_id,p_status_from);
        RAISE e_internal_processing_error; -- raised to stop processing

END pAssignNewProcessIdAndStatus;
----------------------------------------------------------------------------------------

PROCEDURE pSetDdlLockTimeout(p_timeout INT)
AS
BEGIN
    IF p_timeout < 0 OR p_timeout > 1000000 THEN
        RAISE VALUE_ERROR;
    END IF;
    gv_ddl_lock_timeout := p_timeout;
END pSetDdlLockTimeout;

FUNCTION fGetDdlLockTimeout RETURN INT
AS
BEGIN
    RETURN gv_ddl_lock_timeout;
END;

-- ---------------------------------------------------------------------------
-- Function to retrieve Entity Processing Group for given pJrnlHdrID
-- Notes:
--      based on SLR_JRNL_LINES_UNPOSTED table
-- ---------------------------------------------------------------------------
FUNCTION fGetEntityProcGroup
    (
        pJrnlHdrID          in SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_ID%TYPE
    ) RETURN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE
AS
    s_proc_name             VARCHAR2(80) := 'SLR_UTILITIES_PKG.fGetEntityProcGroup';
    s_table_name            VARCHAR2(32);
    vEPG_DIMENSION_column_name    SLR_ENTITY_PROC_GROUP_CONFIG.EPGC_JLU_COLUMN_NAME%TYPE;
    v_entity_proc_group     SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;    -- returned
    v_sql varchar(1000);

BEGIN

    ----------------------------------------------------------------------------
    -- Get column name which defines Entity Group mapping.
    -- vEPG_DIMENSION_column_name is a column name of SLR_JRNL_LINES_UNPOSTED table
    -- Assume there is exactly one row, but don't validate it.
    ----------------------------------------------------------------------------
    s_table_name := 'SLR_ENTITY_PROC_GROUP_CONFIG';

    BEGIN
        SELECT max(EPGC_JLU_COLUMN_NAME)
        INTO vEPG_DIMENSION_column_name
        FROM SLR_ENTITY_PROC_GROUP_CONFIG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- It is not an error when SLR_ENTITY_PROC_GROUP_CONFIG is empty
            NULL;
    END;

    --------------------------------------------------------------------------------------------------
    -- Use vEPG_DIMENSION_column_name to retrieve Entity Processing Group from SLR_JRNL_LINES_UNPOSTED.
    -- If vEPG_DIMENSION_column_name is null then skip condition against EPG_DIMENSION.
    --------------------------------------------------------------------------------------------------
    s_table_name := 'SLR_ENTITY_PROC_GROUP';

    v_sql :=
      ' SELECT  DISTINCT EPG_ID
        FROM    SLR_JRNL_LINES_UNPOSTED, SLR_ENTITY_PROC_GROUP
        WHERE
            JLU_JRNL_HDR_ID = :pJrnlHdrID
        AND JLU_ENTITY = EPG_ENTITY';
    if vEPG_DIMENSION_column_name is not null then
        v_sql := v_sql || ' AND (EPG_DIMENSION IS NULL OR EPG_DIMENSION = '||vEPG_DIMENSION_column_name||') ';
    end if;

    EXECUTE IMMEDIATE v_sql
    INTO v_entity_proc_group
    USING pJrnlHdrID;

    RETURN v_entity_proc_group;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Log message
        pr_error(0, 'Errors during retrieving Entity Processing Group for Jrnl Header: '|| pJrnlHdrID,
            0, s_proc_name, s_table_name, null, 'Entity', 'SLR', 'PL/SQL', SQLCODE);
        RAISE;

    WHEN TOO_MANY_ROWS THEN
        -- Log message
        pr_error(0, 'Errors during retrieving Entity Processing Group for Jrnl Header: '|| pJrnlHdrID,
            0, s_proc_name, s_table_name, null, 'Entity', 'SLR', 'PL/SQL', SQLCODE);
        RAISE;

    WHEN OTHERS THEN
        -- Log message
        pr_error(0, 'Errors during retrieving Entity Processing Group for Jrnl Header: '|| pJrnlHdrID,
            0, s_proc_name, s_table_name, null, 'Entity', 'SLR', 'PL/SQL', SQLCODE);
        RAISE;

END fGetEntityProcGroup;
----------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------
-- Function to retrieve Business Date for Entity Processing Group
-- Notes:
--      Get minimum ENT_BUSINESS_DATE of ENT_BUSINESS_DATE from SLR_ENTITIES
-- -------------------------------------------------------------------------------
FUNCTION fEntityGroupCurrBusDate
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE
    ) RETURN SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE
AS
    s_proc_name             VARCHAR2(80) := 'SLR_UTILITIES_PKG.fEntityGroupCurrBusDate';
    s_table_name            VARCHAR2(32);
    v_business_date    SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE;      -- returned

BEGIN

    s_table_name := 'SLR_ENTITIES';

    SELECT MIN(ENT_BUSINESS_DATE)
    INTO v_business_date
    FROM SLR_ENTITIES, SLR_ENTITY_PROC_GROUP
    WHERE
        ENT_ENTITY = EPG_ENTITY
    AND EPG_ID = p_epg_id
    ;

    RETURN v_business_date;

EXCEPTION
    WHEN OTHERS THEN
        -- Log message
        pr_error(0, 'Errors during retrieving Business Date for Entity Processing Group: '|| p_epg_id,
            0, s_proc_name, s_table_name, null, 'Entity', 'SLR', 'PL/SQL', SQLCODE);
        RAISE;

END fEntityGroupCurrBusDate;
----------------------------------------------------------------------------------------

    -- ------------------------------------------------------------------------------------------------
    -- Procedure to Set Entity Groups in SLR_JRNL_LINES_UNPOSTED, SLR_JRNL_HEADERES_UNPOSTED tables
    -- Notes:
    --      For given Journal Id
    -- ------------------------------------------------------------------------------------------------
  PROCEDURE MAT_EPG_ID_BD_All_EBA_TABLE
    (
        p_epg_id VARCHAR2,
        p_epg_id_alias VARCHAR2
    )
    AS
        lv_sql VARCHAR(32000);
        lv_table_name VARCHAR2 (32);
    BEGIN
        lv_table_name:= 'SLR_'|| p_epg_id_alias ||'_BD_ALL_EBA_BAL';
        EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || lv_table_name;
        lv_sql:= 'INSERT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'INS_EPG_ID_BD_All_EBA') || ' INTO '|| lv_table_name || '
        (
                EAB_FAK_ID,
                EAB_EBA_ID,
                EAB_BALANCE_DATE,
                EAB_BALANCE_TYPE,
                EAB_TRAN_DAILY_MOVEMENT,
                EAB_TRAN_MTD_BALANCE,
                EAB_TRAN_YTD_BALANCE,
                EAB_TRAN_LTD_BALANCE,
                EAB_BASE_DAILY_MOVEMENT,
                EAB_BASE_MTD_BALANCE,
                EAB_BASE_YTD_BALANCE,
                EAB_BASE_LTD_BALANCE,
                EAB_LOCAL_DAILY_MOVEMENT,
                EAB_LOCAL_MTD_BALANCE,
                EAB_LOCAL_YTD_BALANCE,
                EAB_LOCAL_LTD_BALANCE,
                EAB_ENTITY,
                EAB_EPG_ID,
                EAB_PERIOD_MONTH,
                EAB_PERIOD_YEAR,
                EAB_PERIOD_LTD,
                EAB_BUSINESS_DATE
        )
         SELECT
                EAB_FAK_ID,
                EAB_EBA_ID,
                EAB_BALANCE_DATE,
                EAB_BALANCE_TYPE,
                EAB_TRAN_DAILY_MOVEMENT,
                EAB_TRAN_MTD_BALANCE,
                EAB_TRAN_YTD_BALANCE,
                EAB_TRAN_LTD_BALANCE,
                EAB_BASE_DAILY_MOVEMENT,
                EAB_BASE_MTD_BALANCE,
                EAB_BASE_YTD_BALANCE,
                EAB_BASE_LTD_BALANCE,
                EAB_LOCAL_DAILY_MOVEMENT,
                EAB_LOCAL_MTD_BALANCE,
                EAB_LOCAL_YTD_BALANCE,
                EAB_LOCAL_LTD_BALANCE,
                EAB_ENTITY,
                EAB_EPG_ID,
                EAB_PERIOD_MONTH,
                EAB_PERIOD_YEAR,
                EAB_PERIOD_LTD,
                EAB_BUSINESS_DATE
         FROM V_SLR_'|| p_epg_id_alias ||'_BD_ALL_EBA_BAL ';

        EXECUTE IMMEDIATE  lv_sql;
        COMMIT;
        EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
    END;



PROCEDURE pUpdateFakEbaCombinations_Jlu
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_status IN CHAR DEFAULT 'U'
)
AS
BEGIN
    ---------------------------------------------------------------
    -- Insert new FAK and EBA Combinations
    ---------------------------------------------------------------
    pInsertFakEbaCombinations_Jlu(p_entity_proc_group, p_process_id, p_status);

    ---------------------------------------------------------------
    -- Populate SLR_JRNL_LINES_UNPOSTED with proper FAK_ID.
    -- Add NVL on JLU_BASE_AMOUNT, JLU_LOCAL_AMOUNT
    ---------------------------------------------------------------
    UPDATE SLR_JRNL_LINES_UNPOSTED
    SET
        (
            JLU_FAK_ID
            ,JLU_BASE_AMOUNT
            ,JLU_LOCAL_AMOUNT
        )
        =
        (
            SELECT
                FC_FAK_ID
                ,CASE
                    WHEN ENT_APPLY_FX_TRANSLATION = 'Y' OR JLU_BASE_AMOUNT IS NOT NULL THEN
                        JLU_BASE_AMOUNT
                    ELSE 0
                END AS JLU_BASE_AMOUNT
                ,CASE
                    WHEN ENT_APPLY_FX_TRANSLATION = 'Y' OR JLU_LOCAL_AMOUNT IS NOT NULL THEN
                        JLU_LOCAL_AMOUNT
                    ELSE 0
                END AS JLU_LOCAL_AMOUNT
            FROM SLR_FAK_COMBINATIONS, SLR_ENTITIES
            WHERE
                JLU_ACCOUNT = FC_ACCOUNT
                AND JLU_TRAN_CCY = FC_CCY
                AND JLU_EPG_ID = FC_EPG_ID
                AND JLU_ENTITY = FC_ENTITY
                AND JLU_SEGMENT_1 = FC_SEGMENT_1
                AND JLU_SEGMENT_2 = FC_SEGMENT_2
                AND JLU_SEGMENT_3 = FC_SEGMENT_3
                AND JLU_SEGMENT_4 = FC_SEGMENT_4
                AND JLU_SEGMENT_5 = FC_SEGMENT_5
                AND JLU_SEGMENT_6 = FC_SEGMENT_6
                AND JLU_SEGMENT_7 = FC_SEGMENT_7
                AND JLU_SEGMENT_8 = FC_SEGMENT_8
                AND JLU_SEGMENT_9 = FC_SEGMENT_9
                AND JLU_SEGMENT_10 = FC_SEGMENT_10
                AND JLU_ENTITY = ENT_ENTITY
        )
    WHERE
        Nvl(JLU_FAK_ID, 0) = 0
    AND JLU_EPG_ID = p_entity_proc_group
    AND JLU_JRNL_PROCESS_ID = p_process_id
    AND JLU_JRNL_STATUS = p_status
    ;

    ---------------------------------------------------------------
    -- Populate SLR_JRNL_LINES_UNPOSTED with proper EBA_ID
    -- Add NVL on JLU_BASE_AMOUNT, JLU_LOCAL_AMOUNT
    ---------------------------------------------------------------
    UPDATE SLR_JRNL_LINES_UNPOSTED
    SET
        (
            JLU_EBA_ID
            ,JLU_BASE_AMOUNT
            ,JLU_LOCAL_AMOUNT
        )
        =
        (
            SELECT
                EC_EBA_ID
                ,CASE
                    WHEN ENT_APPLY_FX_TRANSLATION = 'Y' OR JLU_BASE_AMOUNT IS NOT NULL THEN
                        JLU_BASE_AMOUNT
                    ELSE 0
                END AS JLU_BASE_AMOUNT
                ,CASE
                    WHEN ENT_APPLY_FX_TRANSLATION = 'Y' OR JLU_LOCAL_AMOUNT IS NOT NULL THEN
                        JLU_LOCAL_AMOUNT
                    ELSE 0
                END AS JLU_LOCAL_AMOUNT
            FROM SLR_EBA_COMBINATIONS, SLR_ENTITIES
            WHERE
                JLU_FAK_ID = EC_FAK_ID
                AND JLU_ATTRIBUTE_1 = EC_ATTRIBUTE_1
                AND JLU_ATTRIBUTE_2 = EC_ATTRIBUTE_2
                AND JLU_ATTRIBUTE_3 = EC_ATTRIBUTE_3
                AND JLU_ATTRIBUTE_4 = EC_ATTRIBUTE_4
                AND JLU_ATTRIBUTE_5 = EC_ATTRIBUTE_5
                AND JLU_EPG_ID = EC_EPG_ID
                AND JLU_ENTITY = ENT_ENTITY
        )
    WHERE
        Nvl(JLU_EBA_ID, 0) = 0
    AND JLU_EPG_ID = p_entity_proc_group
    AND JLU_JRNL_PROCESS_ID = p_process_id
    AND JLU_JRNL_STATUS = p_status;

END pUpdateFakEbaCombinations_Jlu;


-----------------------------------------------------------------------------------
-- Used by GUI (MADJ) procedures to asign FAK/EBA combination base on journal lines
-------------------------------------------------------------------------------------
PROCEDURE pInsertFakEbaCombinations_Jlu
(
    p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
    p_process_id IN NUMBER,
    p_status IN CHAR DEFAULT 'U'
)
IS
    s_proc_name VARCHAR2(80) := 'SLR_UTILITIES_PKG.pInsertFakEbaCombinations_Jlu';

    e_internal_processing_error      EXCEPTION;

BEGIN

    ---------------------------------------------------------------
    -- Insert new FAK Combinations
    ---------------------------------------------------------------
    MERGE INTO SLR_FAK_COMBINATIONS
    USING
    (
        SELECT DISTINCT
            JLU_EPG_ID, JLU_ENTITY, JLU_TRAN_CCY, JLU_ACCOUNT,
            JLU_SEGMENT_1, JLU_SEGMENT_2, JLU_SEGMENT_3,
            JLU_SEGMENT_4, JLU_SEGMENT_5, JLU_SEGMENT_6,
            JLU_SEGMENT_7, JLU_SEGMENT_8, JLU_SEGMENT_9, JLU_SEGMENT_10
        FROM SLR_JRNL_LINES_UNPOSTED
        WHERE JLU_EPG_ID =  p_entity_proc_group
        AND JLU_JRNL_PROCESS_ID =  p_process_id
        AND JLU_JRNL_STATUS = p_status
    )
    ON
    (
        JLU_ACCOUNT = FC_ACCOUNT
        AND JLU_TRAN_CCY = FC_CCY
        AND JLU_EPG_ID = FC_EPG_ID
        AND JLU_ENTITY = FC_ENTITY
        AND JLU_SEGMENT_1 = FC_SEGMENT_1
        AND JLU_SEGMENT_2 = FC_SEGMENT_2
        AND JLU_SEGMENT_3 = FC_SEGMENT_3
        AND JLU_SEGMENT_4 = FC_SEGMENT_4
        AND JLU_SEGMENT_5 = FC_SEGMENT_5
        AND JLU_SEGMENT_6 = FC_SEGMENT_6
        AND JLU_SEGMENT_7 = FC_SEGMENT_7
        AND JLU_SEGMENT_8 = FC_SEGMENT_8
        AND JLU_SEGMENT_9 = FC_SEGMENT_9
        AND JLU_SEGMENT_10 = FC_SEGMENT_10
    )
    WHEN NOT MATCHED THEN
        INSERT
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
        VALUES
        (
            JLU_EPG_ID ,
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
            fSLR_SEQ_FAK_COMBO_ID
        );

    ---------------------------------------------------------------
    -- Insert new EBA Combinations
    ---------------------------------------------------------------
    MERGE  INTO SLR_EBA_COMBINATIONS
    USING
    (
        SELECT DISTINCT
            JLU_EPG_ID
            ,FC_FAK_ID
            ,JLU_ATTRIBUTE_1
            ,JLU_ATTRIBUTE_2
            ,JLU_ATTRIBUTE_3
            ,JLU_ATTRIBUTE_4
            ,JLU_ATTRIBUTE_5
        FROM SLR_JRNL_LINES_UNPOSTED, SLR_FAK_COMBINATIONS
        WHERE
           JLU_EPG_ID = p_entity_proc_group
            AND JLU_ACCOUNT = FC_ACCOUNT
            AND JLU_TRAN_CCY = FC_CCY
            AND JLU_EPG_ID = FC_EPG_ID
            AND JLU_JRNL_PROCESS_ID =  p_process_id
            AND JLU_ENTITY = FC_ENTITY
            AND JLU_SEGMENT_1 = FC_SEGMENT_1
            AND JLU_SEGMENT_2 = FC_SEGMENT_2
            AND JLU_SEGMENT_3 = FC_SEGMENT_3
            AND JLU_SEGMENT_4 = FC_SEGMENT_4
            AND JLU_SEGMENT_5 = FC_SEGMENT_5
            AND JLU_SEGMENT_6 = FC_SEGMENT_6
            AND JLU_SEGMENT_7 = FC_SEGMENT_7
            AND JLU_SEGMENT_8 = FC_SEGMENT_8
            AND JLU_SEGMENT_9 = FC_SEGMENT_9
            AND JLU_SEGMENT_10 = FC_SEGMENT_10
    )
    ON
    (
        EC_FAK_ID = FC_FAK_ID
        AND JLU_ATTRIBUTE_1 = EC_ATTRIBUTE_1
        AND JLU_ATTRIBUTE_2 = EC_ATTRIBUTE_2
        AND JLU_ATTRIBUTE_3 = EC_ATTRIBUTE_3
        AND JLU_ATTRIBUTE_4 = EC_ATTRIBUTE_4
        AND JLU_ATTRIBUTE_5 = EC_ATTRIBUTE_5
        AND JLU_EPG_ID = EC_EPG_ID
    )
    WHEN NOT MATCHED THEN
        INSERT
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
        VALUES
        (
            JLU_EPG_ID,
            FC_FAK_ID,
            fSLR_SEQ_EBA_COMBO_ID,
            JLU_ATTRIBUTE_1,
            JLU_ATTRIBUTE_2,
            JLU_ATTRIBUTE_3,
            JLU_ATTRIBUTE_4,
            JLU_ATTRIBUTE_5
        );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        SLR_VALIDATE_JOURNALS_PKG.pWriteLogError(s_proc_name, 'SLR_FAK/EBA_COMBINATIONS',
            'Error during inserting new combinations to SLR_FAK/EBA_COMBINATIONS',
            p_process_id,p_entity_proc_group);
        SLR_ADMIN_PKG.Error('Error during inserting new combinations to SLR_FAK/EBA_COMBINATIONS');
        RAISE e_internal_processing_error; -- raised to stop processing

END pInsertFakEbaCombinations_Jlu;


  PROCEDURE MAT_EPG_ID_BD_All_FAK_TABLE
    (
        p_epg_id VARCHAR2,
        p_epg_id_alias VARCHAR2
    )
    AS
        lv_sql VARCHAR(32000);
        lv_table_name VARCHAR2 (32);
    BEGIN
        lv_table_name:= 'SLR_'|| p_epg_id_alias ||'_BD_ALL_FAK_BAL';
        EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || lv_table_name;
        lv_sql:= 'INSERT '|| SLR_UTILITIES_PKG.fHint(p_epg_id, 'INS_EPG_ID_BD_All_FAK') || ' INTO '|| lv_table_name || '
        (
                EAB_FAK_ID,
                EAB_BALANCE_DATE,
                EAB_BALANCE_TYPE,
                EAB_TRAN_DAILY_MOVEMENT,
                EAB_TRAN_MTD_BALANCE,
                EAB_TRAN_YTD_BALANCE,
                EAB_TRAN_LTD_BALANCE,
                EAB_BASE_DAILY_MOVEMENT,
                EAB_BASE_MTD_BALANCE,
                EAB_BASE_YTD_BALANCE,
                EAB_BASE_LTD_BALANCE,
                EAB_LOCAL_DAILY_MOVEMENT,
                EAB_LOCAL_MTD_BALANCE,
                EAB_LOCAL_YTD_BALANCE,
                EAB_LOCAL_LTD_BALANCE,
                EAB_ENTITY,
                EAB_EPG_ID,
                EAB_PERIOD_MONTH,
                EAB_PERIOD_YEAR,
                EAB_PERIOD_LTD,
                EAB_BUSINESS_DATE
        )
         SELECT
                EAB_FAK_ID,
                EAB_BALANCE_DATE,
                EAB_BALANCE_TYPE,
                EAB_TRAN_DAILY_MOVEMENT,
                EAB_TRAN_MTD_BALANCE,
                EAB_TRAN_YTD_BALANCE,
                EAB_TRAN_LTD_BALANCE,
                EAB_BASE_DAILY_MOVEMENT,
                EAB_BASE_MTD_BALANCE,
                EAB_BASE_YTD_BALANCE,
                EAB_BASE_LTD_BALANCE,
                EAB_LOCAL_DAILY_MOVEMENT,
                EAB_LOCAL_MTD_BALANCE,
                EAB_LOCAL_YTD_BALANCE,
                EAB_LOCAL_LTD_BALANCE,
                EAB_ENTITY,
                EAB_EPG_ID,
                EAB_PERIOD_MONTH,
                EAB_PERIOD_YEAR,
                EAB_PERIOD_LTD,
                EAB_BUSINESS_DATE
         FROM V_SLR_'|| p_epg_id_alias ||'_BD_ALL_FAK_BAL ';

        EXECUTE IMMEDIATE  lv_sql;
        COMMIT;
        EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
    END;

    ---------------------------------------------------------------------------------------------------
    -- Function fSLR_SEQ_EBA_COMBO_ID
    --  Returns nextval from sequence SLR.SEQ_EBA_COMBO_ID.
    ---------------------------------------------------------------------------------------------------

    FUNCTION fSLR_SEQ_EBA_COMBO_ID
    RETURN NUMBER
    IS
      seq_number number;
     BEGIN

        SELECT SLR.SEQ_EBA_COMBO_ID.nextval INTO seq_number FROM dual;

        RETURN seq_number;
    END;

    ---------------------------------------------------------------------------------------------------
    -- Function fSLR_SEQ_FAK_COMBO_ID
    --  Returns nextval from sequence SLR.SEQ_SLR_FAK_COMBO_ID.
    ---------------------------------------------------------------------------------------------------

    FUNCTION fSLR_SEQ_FAK_COMBO_ID
    RETURN NUMBER
    IS
      seq_number number;
     BEGIN

        SELECT SLR.SEQ_SLR_FAK_COMBO_ID.nextval INTO seq_number FROM dual;

        RETURN seq_number;
    END;

    FUNCTION fSLR_SEQ_PROCESS_ID
    RETURN NUMBER
    IS
    BEGIN
      RETURN SLR.SEQ_PROCESS_NUMBER.nextval;
    END fSLR_SEQ_PROCESS_ID;

END SLR_UTILITIES_PKG;

/