create or replace procedure rdr.pcombinationcheck_glint (
  pinControlID in rr_interface_control.rgic_id%TYPE)
As
/* Place this procedure within the PGC_GLINT package and use as a custom procedure when calling the GL Interface (Either directly by using the PG_GLINT.pProcess - pinCustomProcess parameter or indirectly by creating a custom wrapper procedure). */
/* Procedure assumes RR_GLINT_TEMP_JOURNAL has been populated with the relevant journals. */
/* Amend the optimizer hints according to data profile. */
/* No COMMIT. */

/* Constants. */
lcUnitName        Constant all_procedures.procedure_name%TYPE := 'pCombinationCheck_GLINT';
lcViewName        Constant all_views.view_name%TYPE := 'RCV_COMBINATION_CHECK_GLINT';
lcDesc_Suspense   Constant slr.slr_jrnl_headers.jh_jrnl_description%TYPE := 'Suspense';

/* Variables. */
myErrorCount Pls_Integer;
myInsertInit Varchar2(5000);
myInsert     Varchar2(5000);
mySelectInit Varchar2(5000);
mySelect     Varchar2(5000);
myFromInit   Varchar2(5000);
myFrom       Varchar2(5000);
mySQL        Varchar2(32000);
myProcessID  slr.slr_jrnl_lines_unposted.jlu_jrnl_process_id%TYPE;

Begin
  dbms_application_info.set_module(
    module_name => lcUnitName,
    action_name => 'Start');
  fdr.PG_COMMON.pLogDebug(pinMessage => 'Start Combo Check - GL Interface');

  /* Configure the optimizer hints for Combination Checking. */
  fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboInput := '';
  fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboError := '';
  fdr.PG_COMBINATION_CHECK.gSQLHint_InsertInput      := '/*+ no_parallel */';
  fdr.PG_COMBINATION_CHECK.gSQLHint_SelectInput      := '/*+ parallel */';
  fdr.PG_COMBINATION_CHECK.gSQLHint_InsertComboError := '/*+ no_parallel */';
  fdr.PG_COMBINATION_CHECK.gSQLHint_SelectComboError := '/*+ parallel */';

  /* Call the Combination Check for those journals that are to be processed by the GL Interface. */
  fdr.PG_COMBINATION_CHECK.pCombinationCheck(
    pinObjectName   =>  lcViewName,
    pinFilter       =>  NULL,
    pinBusinessDate =>  NULL,
    poutErrorCount  =>  myErrorCount);

  If myErrorCount > 0 Then
    /* Create Error for each combination check failure. */
    dbms_application_info.set_action('Create Error Log');
    Insert /*+ parallel */ into fdr.fr_log (
      lo_event_datetime,
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
      lo_client_spare01,
      lo_client_spare02,
      lo_client_spare03,
      lo_client_spare04)
    Select /*+ parallel */
           sysdate as lo_event_datetime,
           fdr.PG_COMMON.gcErrorEventType_Error as lo_event_type_id,
           fdr.PG_COMMON.gcStatusFlag_Error as lo_error_status,
           fdr.PG_COMMON.gcErrorCategory_Tech as lo_category_id,
           'Combination Check Failure : Rule Set= ' || ce_ruleset || ' : Rule=' || ce_rule as lo_event_text,
           lcViewName as lo_table_in_error_name,
           to_number(substr(ce_input_id,1,instr(ce_input_id,'_')-1)) as lo_row_in_error_key_id,
           ce_attribute_name as lo_field_in_error_name,
           fdr.PG_COMMON.gcErrorTechnology_PLSQL as lo_error_technology,
           lcUnitName as lo_error_rule_ident,
           case ce_attribute_name When fdr.PG_COMBINATION_CHECK.gcAttribute_1 Then ce_attribute_1
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_2 Then ce_attribute_2
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_3 Then ce_attribute_3
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_4 Then ce_attribute_4
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_5 Then ce_attribute_5
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_6 Then ce_attribute_6
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_7 Then ce_attribute_7
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_8 Then ce_attribute_8
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_9 Then ce_attribute_9
                                  When fdr.PG_COMBINATION_CHECK.gcAttribute_10 Then ce_attribute_10
           end as lo_error_value,
           ce_input_id as lo_error_client_key_no,
           NULL as lo_error_client_ver_no,
           NULL as lo_todays_bus_date,
           NULL as lo_entity,
           NULL as lo_book,
           NULL as lo_security,
           NULL as lo_source_system,
           user as lo_processing_stage,
           user as lo_owner,
           NULL as lo_client_spare01,
           NULL as lo_client_spare02,
           NULL as lo_client_spare03,
           NULL as lo_client_spare04
      from fdr.fr_combination_check_error;

    /* Create Suspense Line for the Failed Sub-Ledger Journal Line - this will be used by the GL Interface instead of the source journal line. */
    dbms_application_info.set_action('Create Suspense Line');
    myInsertInit := 'Insert /*+ no_parallel */ into rr_glint_suspense_line('
                 || '  jl_jrnl_hdr_id,'
                 || '  jl_jrnl_line_number,'
                 || '  jl_epg_id,'
                 || '  jl_effective_date,'
                 || '  jl_suspense_id';
    mySelectInit := ') Select /*+ parallel */'
                 || '       jl_jrnl_hdr_id,'
                 || '       jl_jrnl_line_number,'
                 || '       jl_epg_id,'
                 || '       jl_effective_date,';
    myFromInit := ' from slr.slr_jrnl_lines jl'
               || ' join slr.slr_jrnl_headers jh on jl.jl_jrnl_hdr_id = jh.jh_jrnl_id'
               || '                             and jl.jl_epg_id = jh.jh_jrnl_epg_id'
               || '                             and jl.jl_effective_date = jh.jh_jrnl_date'
               || ' join (Select substr(ce_input_id,1,instr(ce_input_id,''_'')-1) as jhe_jrnl_id, '
               || '              substr(ce_input_id,instr(ce_input_id,''_'')+1) as jle_jrnl_line_number'
               || '         from fdr.fr_combination_check_error'
               || '        where ce_suspense_id = ';

    /* Create a process identifier to use for the suspense journals. */
    Select slr.seq_process_number.nextval into myProcessID from dual;
    fdr.PG_COMMON.pLogDebug(pinMessage => 'Process ID=' || myProcessID);

    /* Get each suspense set from the errors. */
    For c1Rec in (Select lk_lookup_key_id, lk_lookup_value1, ejt_madj_flag
                    from fdr.fr_combination_check_error
                    join fdr.fr_general_lookup on ce_suspense_id = lk_lookup_key_id
                    join slr.slr_ext_jrnl_types on ejt_type = lk_lookup_value2
                   group by lk_lookup_key_id, lk_lookup_value1, lk_lookup_value2, ejt_madj_flag) Loop
      mySelect := mySelect || c1Rec.lk_lookup_key_id;
      /* For each suspense set, get the suspense values. */
      For c2Rec in (Select attribute, suspense_value
                      from fdr.fcv_combination_check_suspense
                     where data_set = c1Rec.lk_lookup_value1) Loop
        myInsert := myInsert
                 || ',' || c2Rec.attribute;
        mySelect := mySelect
                 || ',' || sys.dbms_assert.enquote_literal(c2Rec.suspense_value) || ' as ' || c2Rec.attribute;
      End Loop;
      myFrom := c1Rec.lk_lookup_key_id || ' group by ce_input_id) ce on jh_jrnl_id = ce.jhe_jrnl_id and jl_jrnl_line_number = ce.jle_jrnl_line_number';

      /* Generate the suspense lines for each suspense set.
         These will be used to replace the values on the Journal Line that is sent to the GL. */
      mySQL := myInsertInit || myInsert || mySelectInit || mySelect || myFromInit || myFrom;
      fdr.PG_COMMON.pExecuteSQL(pinSQL => mySQL);
      
      /* Create a Suspense Journal for each line in error (containing 2 lines).
      /* Determine whether the journal is to be posted within Sub-Ledger Batch or manually. */
      If c1Rec.ejt_madj_flag = fdr.PG_COMMON.gcYesOrNo_Yes Then
        /* Reverse the failed Journal Lines - GUI. */
        Insert into gui.gui_jrnl_lines_unposted (
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
          jlu_period_ltd)
        Select slr.fnslr_getheaderid as jlu_jrnl_hdr_id,
               1 as jlu_jrnl_line_number,
               0 as jlu_fak_id,
               0 as jlu_eba_id,
               fdr.PG_COMMON.gcStatusFlag_Manual as jlu_jrnl_status,
               fdr.PG_COMMON.gcStatusFlag_Manual as jlu_jrnl_status_text,
               myProcessID as jlu_jrnl_process_id,
               lcDesc_Suspense as jlu_description,
               jl.jl_jrnl_hdr_id as jlu_source_jrnl_id,
               jl.jl_effective_date as jlu_effective_date,
               jl.jl_value_date as jlu_value_date,
               jl.jl_entity as jlu_entity,
               jl.jl_epg_id as jlu_epg_id,
               jl.jl_account as jlu_account,
               jl.jl_segment_1 as jlu_segment_1,
               jl.jl_segment_2 as jlu_segment_2,
               jl.jl_segment_3 as jlu_segment_3,
               jl.jl_segment_4 as jlu_segment_4,
               jl.jl_segment_5 as jlu_segment_5,
               jl.jl_segment_6 as jlu_segment_6,
               jl.jl_segment_7 as jlu_segment_7,
               jl.jl_segment_8 as jlu_segment_8,
               jl.jl_segment_9 as jlu_segment_9,
               jl.jl_segment_10 as jlu_segment_10,
               jl.jl_attribute_1 as jlu_attribute_1,
               jl.jl_attribute_2 as jlu_attribute_2,
               jl.jl_attribute_3 as jlu_attribute_3,
               jl.jl_attribute_4 as jlu_attribute_4,
               jl.jl_attribute_5 as jlu_attribute_5,
               jl.jl_reference_1 as jlu_reference_1,
               jl.jl_reference_2 as jlu_reference_2,
               jl.jl_reference_3 as jlu_reference_3,
               jl.jl_reference_4 as jlu_reference_4,
               jl.jl_reference_5 as jlu_reference_5,
               jl.jl_reference_6 as jlu_reference_6,
               jl.jl_reference_7 as jlu_reference_7,
               jl.jl_reference_8 as jlu_reference_8,
               jl.jl_reference_9 as jlu_reference_9,
               jl.jl_reference_10 as jlu_reference_10,
               jl.jl_tran_ccy as jlu_tran_ccy,
               jl.jl_tran_amount * -1 as jlu_tran_amount,
               jl.jl_base_rate as jlu_base_rate,
               jl.jl_base_ccy as jlu_base_ccy,
               jl.jl_base_amount * -1 as jlu_base_amount,
               jl.jl_local_rate as jlu_local_rate,
               jl.jl_local_ccy as jlu_local_ccy,
               jl.jl_local_amount * -1 as jlu_local_amount,
               user as jlu_created_by,
               sysdate as jlu_created_on,
               user as jlu_amended_by,
               sysdate as jlu_amended_on,
               c1Rec.lk_lookup_value1 as jlu_jrnl_type,
               jl.jl_effective_date as jlu_jrnl_date,
               lcDesc_Suspense as jlu_jrnl_description,
               jl.jl_jrnl_line_number as jlu_jrnl_source,
               jl.jl_jrnl_hdr_id as jlu_jrnl_source_jrnl_id,
               NULL as jlu_jrnl_authorised_by,
               NULL as jlu_jrnl_authorised_on,
               NULL as jlu_jrnl_validated_by,
               NULL as jlu_jrnl_validated_on,
               NULL as jlu_jrnl_posted_by,
               NULL as jlu_jrnl_posted_on,
               abs(jl.jl_tran_amount) as jlu_jrnl_total_hash_debit,
               abs(jl.jl_tran_amount) as jlu_jrnl_total_hash_credit,
               jh.jh_jrnl_pref_static_src as jlu_jrnl_pref_static_src,
               NULL as jlu_jrnl_ref_id,
               NULL as jlu_jrnl_rev_date,
               jl.jl_translation_date as jlu_translation_date,
               jl.jl_period_month as jlu_period_month,
               jl.jl_period_year as jlu_period_year,
               jl.jl_period_ltd as jlu_period_ltd
          from rr_glint_suspense_line jle
          join slr.slr_jrnl_lines jl on jle.jl_jrnl_hdr_id = jl.jl_jrnl_hdr_id
                                    and jle.jl_jrnl_line_number = jl.jl_jrnl_line_number
                                    and jle.jl_effective_date = jl.jl_effective_date
                                    and jle.jl_epg_id = jl.jl_epg_id
          join slr.slr_jrnl_headers jh on jl.jl_jrnl_hdr_id = jh.jh_jrnl_id
                                      and jl.jl_effective_date = jh.jh_jrnl_date
                                      and jl.jl_epg_id = jh.jh_jrnl_epg_id          
          join rr_glint_temp_journal tj on jh.jh_jrnl_id = tj.jh_jrnl_id
                                       and jh.jh_jrnl_date = tj.jh_jrnl_date
                                       and jh.jh_jrnl_epg_id = tj.jh_jrnl_epg_id
         where tj.previous_flag = fdr.PG_COMMON.gcYesOrNo_No  --Ensure suspense journals are created for the first attempt at sending to GL
           and jle.jl_suspense_id = c1Rec.lk_lookup_key_id;

        /* Create the offset lines (i.e. mirror what is being sent to the GL). */
        Insert into gui.gui_jrnl_lines_unposted (
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
          jlu_period_ltd)
        Select jlu.jlu_jrnl_hdr_id as jlu_jrnl_hdr_id,
               2 as jlu_jrnl_line_number,
               jlu.jlu_fak_id as jlu_fak_id,
               jlu.jlu_eba_id as jlu_eba_id,
               jlu.jlu_jrnl_status as jlu_jrnl_status,
               jlu.jlu_jrnl_status_text as jlu_jrnl_status_text,
               jlu.jlu_jrnl_process_id as jlu_jrnl_process_id,
               jlu.jlu_description as jlu_description,
               jlu.jlu_source_jrnl_id as jlu_source_jrnl_id,
               jlu.jlu_effective_date as jlu_effective_date,
               jlu.jlu_value_date as jlu_value_date,
               jlu.jlu_entity as jlu_entity,
               jlu.jlu_epg_id as jlu_epg_id,
               jl.jl_account as jlu_account,
               jl.jl_segment_1 as jlu_segment_1,
               jl.jl_segment_2 as jlu_segment_2,
               jl.jl_segment_3 as jlu_segment_3,
               jl.jl_segment_4 as jlu_segment_4,
               jl.jl_segment_5 as jlu_segment_5,
               jl.jl_segment_6 as jlu_segment_6,
               jl.jl_segment_7 as jlu_segment_7,
               jl.jl_segment_8 as jlu_segment_8,
               jl.jl_segment_9 as jlu_segment_9,
               jl.jl_segment_10 as jlu_segment_10,
               jl.jl_attribute_1 as jlu_attribute_1,
               jl.jl_attribute_2 as jlu_attribute_2,
               jl.jl_attribute_3 as jlu_attribute_3,
               jl.jl_attribute_4 as jlu_attribute_4,
               jl.jl_attribute_5 as jlu_attribute_5,
               jl.jl_reference_1 as jlu_reference_1,
               jl.jl_reference_2 as jlu_reference_2,
               jl.jl_reference_3 as jlu_reference_3,
               jl.jl_reference_4 as jlu_reference_4,
               jl.jl_reference_5 as jlu_reference_5,
               jl.jl_reference_6 as jlu_reference_6,
               jl.jl_reference_7 as jlu_reference_7,
               jl.jl_reference_8 as jlu_reference_8,
               jl.jl_reference_9 as jlu_reference_9,
               jl.jl_reference_10 as jlu_reference_10,
               jl.jl_tran_ccy as jlu_tran_ccy,
               jl.jl_tran_amount as jlu_tran_amount,
               jl.jl_base_rate as jlu_base_rate,
               jl.jl_base_ccy as jlu_base_ccy,
               jl.jl_base_amount as jlu_base_amount,
               jl.jl_local_rate as jlu_local_rate,
               jl.jl_local_ccy as jlu_local_ccy,
               jl.jl_local_amount as jlu_local_amount,
               jlu.jlu_created_by as jlu_created_by,
               jlu.jlu_created_on as jlu_created_on,
               jlu.jlu_amended_by as jlu_amended_by,
               jlu.jlu_amended_on as jlu_amended_on,
               jlu.jlu_jrnl_type as jlu_jrnl_type,
               jlu.jlu_jrnl_date as jlu_jrnl_date,
               jlu.jlu_jrnl_description as jlu_jrnl_description,
               jlu.jlu_jrnl_source as jlu_jrnl_source,
               jlu.jlu_jrnl_source_jrnl_id as jlu_jrnl_source_jrnl_id,
               NULL as jlu_jrnl_authorised_by,
               NULL as jlu_jrnl_authorised_on,
               NULL as jlu_jrnl_validated_by,
               NULL as jlu_jrnl_validated_on,
               NULL as jlu_jrnl_posted_by,
               NULL as jlu_jrnl_posted_on,
               jlu.jlu_jrnl_total_hash_debit as jlu_jrnl_total_hash_debit,
               jlu.jlu_jrnl_total_hash_credit as jlu_jrnl_total_hash_credit,
               jlu.jlu_jrnl_pref_static_src as jlu_jrnl_pref_static_src,
               NULL as jlu_jrnl_ref_id,
               NULL as jlu_jrnl_rev_date,
               jlu.jlu_translation_date as jlu_translation_date,
               jlu.jlu_period_month as jlu_period_month,
               jlu.jlu_period_year as jlu_period_year,
               jlu.jlu_period_ltd as jlu_period_ltd
          from gui.gui_jrnl_lines_unposted jlu         
          join rcv_glint_journal_line jl on jlu.jlu_jrnl_source_jrnl_id = jl.jl_jrnl_hdr_id
                                        and jlu.jlu_jrnl_source = jl.jl_jrnl_line_number
                                        and jlu.jlu_effective_date = jl.jl_effective_date
                                        and jlu.jlu_epg_id = jl.jl_epg_id
                                        and jlu.jlu_jrnl_process_id = myProcessID
         where jl.jl_suspense_id = c1Rec.lk_lookup_key_id;
          
        /* Create the headers. */
        Insert into gui.gui_jrnl_headers_unposted (
          jhu_jrnl_id,
          jhu_jrnl_type,
          jhu_jrnl_date,
          jhu_jrnl_entity,
          jhu_epg_id,
          jhu_jrnl_status,
          jhu_jrnl_status_text,
          jhu_jrnl_process_id,
          jhu_jrnl_description,
          jhu_jrnl_source,
          jhu_jrnl_source_jrnl_id,
          jhu_jrnl_authorised_by,
          jhu_jrnl_authorised_on,
          jhu_jrnl_validated_by,
          jhu_jrnl_validated_on,
          jhu_jrnl_posted_by,
          jhu_jrnl_posted_on,
          jhu_jrnl_total_hash_debit,
          jhu_jrnl_total_hash_credit,
          jhu_jrnl_total_lines,
          jhu_created_by,
          jhu_created_on,
          jhu_amended_by,
          jhu_amended_on,
          jhu_jrnl_pref_static_src,
          jhu_jrnl_ref_id,
          jhu_jrnl_rev_date,
          jhu_manual_flag,
          jhu_version)
        Select jlu_jrnl_hdr_id as jhu_jrnl_id,
               max(jlu_jrnl_type) as jhu_jrnl_type,
               max(jlu_effective_date) as jhu_jrnl_date,
               max(jlu_entity) as jhu_jrnl_entity,
               max(jlu_epg_id) as jhu_epg_id,
               fdr.PG_COMMON.gcStatusFlag_Manual as jhu_jrnl_status,
               fdr.PG_COMMON.gcStatusFlag_Manual as jhu_jrnl_status_text,
               myProcessID as jhu_jrnl_process_id,
               max(jlu_description) as jhu_jrnl_description,
               max(jlu_jrnl_source) as jhu_jrnl_source,
               max(jlu_jrnl_source_jrnl_id) as jhu_jrnl_source_jrnl_id,
               NULL as jhu_jrnl_authorised_by,
               NULL as jhu_jrnl_authorised_on,
               NULL as jhu_jrnl_validated_by,
               NULL as jhu_jrnl_validated_on,
               NULL as jhu_jrnl_posted_by,
               NULL as jhu_jrnl_posted_on,
               max(jlu_jrnl_total_hash_debit) as jhu_jrnl_total_hash_debit,
               max(jlu_jrnl_total_hash_credit) as jhu_jrnl_total_hash_credit,
               count(*) as jhu_jrnl_total_lines,
               user as jhu_created_by,
               sysdate as jhu_created_on,
               user as jhu_amended_by,
               sysdate as jhu_amended_on,
               max(jlu_jrnl_pref_static_src) as jhu_jrnl_pref_static_src,
               NULL as jhu_jrnl_ref_id,
               NULL as jhu_jrnl_rev_date,
               fdr.PG_COMMON.gcYesOrNo_Yes as jhu_manual_flag,
               1 as jhu_version
          from gui.gui_jrnl_lines_unposted
         where jlu_jrnl_process_id = myProcessID
         group by jlu_jrnl_hdr_id;         

      Else
        /* Create Suspense for Batch. */
        /* Reverse Failed Journal Lines - SLR. */
        Insert into slr.slr_jrnl_lines_unposted (
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
          jlu_type)
        Select slr.fnslr_getheaderid as jlu_jrnl_hdr_id,
               1 as jlu_jrnl_line_number,
               0 as jlu_fak_id,
               0 as jlu_eba_id,
               fdr.PG_COMMON.gcStatusFlag_Unprocessed as jlu_jrnl_status,
               fdr.PG_COMMON.gcStatusFlag_Unprocessed as jlu_jrnl_status_text,
               myProcessID as jlu_jrnl_process_id,
               lcDesc_Suspense as jlu_description,
               jl.jl_jrnl_hdr_id as jlu_source_jrnl_id,
               jl.jl_effective_date as jlu_effective_date,
               jl.jl_value_date as jlu_value_date,
               jl.jl_entity as jlu_entity,
               jl.jl_epg_id as jlu_epg_id,
               jl.jl_account as jlu_account,
               jl.jl_segment_1 as jlu_segment_1,
               jl.jl_segment_2 as jlu_segment_2,
               jl.jl_segment_3 as jlu_segment_3,
               jl.jl_segment_4 as jlu_segment_4,
               jl.jl_segment_5 as jlu_segment_5,
               jl.jl_segment_6 as jlu_segment_6,
               jl.jl_segment_7 as jlu_segment_7,
               jl.jl_segment_8 as jlu_segment_8,
               jl.jl_segment_9 as jlu_segment_9,
               jl.jl_segment_10 as jlu_segment_10,
               jl.jl_attribute_1 as jlu_attribute_1,
               jl.jl_attribute_2 as jlu_attribute_2,
               jl.jl_attribute_3 as jlu_attribute_3,
               jl.jl_attribute_4 as jlu_attribute_4,
               jl.jl_attribute_5 as jlu_attribute_5,
               jl.jl_reference_1 as jlu_reference_1,
               jl.jl_reference_2 as jlu_reference_2,
               jl.jl_reference_3 as jlu_reference_3,
               jl.jl_reference_4 as jlu_reference_4,
               jl.jl_reference_5 as jlu_reference_5,
               jl.jl_reference_6 as jlu_reference_6,
               jl.jl_reference_7 as jlu_reference_7,
               jl.jl_reference_8 as jlu_reference_8,
               jl.jl_reference_9 as jlu_reference_9,
               jl.jl_reference_10 as jlu_reference_10,
               jl.jl_tran_ccy as jlu_tran_ccy,
               jl.jl_tran_amount * -1 as jlu_tran_amount,
               jl.jl_base_rate as jlu_base_rate,
               jl.jl_base_ccy as jlu_base_ccy,
               jl.jl_base_amount * -1 as jlu_base_amount,
               jl.jl_local_rate as jlu_local_rate,
               jl.jl_local_ccy as jlu_local_ccy,
               jl.jl_local_amount * -1 as jlu_local_amount,
               user as jlu_created_by,
               sysdate as jlu_created_on,
               user as jlu_amended_by,
               sysdate as jlu_amended_on,
               c1Rec.lk_lookup_value1 as jlu_jrnl_type,
               jl.jl_effective_date as jlu_jrnl_date,
               lcDesc_Suspense as jlu_jrnl_description,
               jl.jl_jrnl_line_number as jlu_jrnl_source,
               jl.jl_jrnl_hdr_id as jlu_jrnl_source_jrnl_id,
               NULL as jlu_jrnl_authorised_by,
               NULL as jlu_jrnl_authorised_on,
               NULL as jlu_jrnl_validated_by,
               NULL as jlu_jrnl_validated_on,
               NULL as jlu_jrnl_posted_by,
               NULL as jlu_jrnl_posted_on,
               abs(jl.jl_tran_amount) as jlu_jrnl_total_hash_debit,
               abs(jl.jl_tran_amount) as jlu_jrnl_total_hash_credit,
               jh.jh_jrnl_pref_static_src as jlu_jrnl_pref_static_src,
               NULL as jlu_jrnl_ref_id,
               NULL as jlu_jrnl_rev_date,
               jl.jl_translation_date as jlu_translation_date,
               jl.jl_period_month as jlu_period_month,
               jl.jl_period_year as jlu_period_year,
               jl.jl_period_ltd as jlu_period_ltd,
               fdr.PG_COMMON.gcYesOrNo_No as jlu_jrnl_internal_period_flag,
               NULL as jlu_jrnl_ent_rate_set,
               NULL as jlu_type
          from rr_glint_suspense_line jle
          join slr.slr_jrnl_lines jl on jle.jl_jrnl_hdr_id = jl.jl_jrnl_hdr_id
                                    and jle.jl_jrnl_line_number = jl.jl_jrnl_line_number
                                    and jle.jl_effective_date = jl.jl_effective_date
                                    and jle.jl_epg_id = jl.jl_epg_id
          join slr.slr_jrnl_headers jh on jl.jl_jrnl_hdr_id = jh.jh_jrnl_id
                                      and jl.jl_effective_date = jh.jh_jrnl_date
                                      and jl.jl_epg_id = jh.jh_jrnl_epg_id          
          join rr_glint_temp_journal tj on jh.jh_jrnl_id = tj.jh_jrnl_id
                                       and jh.jh_jrnl_date = tj.jh_jrnl_date
                                       and jh.jh_jrnl_epg_id = tj.jh_jrnl_epg_id
         where tj.previous_flag = fdr.PG_COMMON.gcYesOrNo_No  --Ensure suspense journals are created for the first attempt at sending to GL
           and jle.jl_suspense_id = c1Rec.lk_lookup_key_id;

        /* Create the offset lines (i.e. mirror what is being sent to the GL). */
        Insert into slr.slr_jrnl_lines_unposted (
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
          jlu_type)
        Select jlu.jlu_jrnl_hdr_id as jlu_jrnl_hdr_id,
               2 as jlu_jrnl_line_number,
               jlu.jlu_fak_id as jlu_fak_id,
               jlu.jlu_eba_id as jlu_eba_id,
               jlu.jlu_jrnl_status as jlu_jrnl_status,
               jlu.jlu_jrnl_status_text as jlu_jrnl_status_text,
               jlu.jlu_jrnl_process_id as jlu_jrnl_process_id,
               jlu.jlu_description as jlu_description,
               jlu.jlu_source_jrnl_id as jlu_source_jrnl_id,
               jlu.jlu_effective_date as jlu_effective_date,
               jlu.jlu_value_date as jlu_value_date,
               jlu.jlu_entity as jlu_entity,
               jlu.jlu_epg_id as jlu_epg_id,
               jl.jl_account as jlu_account,
               jl.jl_segment_1 as jlu_segment_1,
               jl.jl_segment_2 as jlu_segment_2,
               jl.jl_segment_3 as jlu_segment_3,
               jl.jl_segment_4 as jlu_segment_4,
               jl.jl_segment_5 as jlu_segment_5,
               jl.jl_segment_6 as jlu_segment_6,
               jl.jl_segment_7 as jlu_segment_7,
               jl.jl_segment_8 as jlu_segment_8,
               jl.jl_segment_9 as jlu_segment_9,
               jl.jl_segment_10 as jlu_segment_10,
               jl.jl_attribute_1 as jlu_attribute_1,
               jl.jl_attribute_2 as jlu_attribute_2,
               jl.jl_attribute_3 as jlu_attribute_3,
               jl.jl_attribute_4 as jlu_attribute_4,
               jl.jl_attribute_5 as jlu_attribute_5,
               jl.jl_reference_1 as jlu_reference_1,
               jl.jl_reference_2 as jlu_reference_2,
               jl.jl_reference_3 as jlu_reference_3,
               jl.jl_reference_4 as jlu_reference_4,
               jl.jl_reference_5 as jlu_reference_5,
               jl.jl_reference_6 as jlu_reference_6,
               jl.jl_reference_7 as jlu_reference_7,
               jl.jl_reference_8 as jlu_reference_8,
               jl.jl_reference_9 as jlu_reference_9,
               jl.jl_reference_10 as jlu_reference_10,
               jl.jl_tran_ccy as jlu_tran_ccy,
               jl.jl_tran_amount as jlu_tran_amount,
               jl.jl_base_rate as jlu_base_rate,
               jl.jl_base_ccy as jlu_base_ccy,
               jl.jl_base_amount as jlu_base_amount,
               jl.jl_local_rate as jlu_local_rate,
               jl.jl_local_ccy as jlu_local_ccy,
               jl.jl_local_amount as jlu_local_amount,
               jlu.jlu_created_by as jlu_created_by,
               jlu.jlu_created_on as jlu_created_on,
               jlu.jlu_amended_by as jlu_amended_by,
               jlu.jlu_amended_on as jlu_amended_on,
               jlu.jlu_jrnl_type as jlu_jrnl_type,
               jlu.jlu_jrnl_date as jlu_jrnl_date,
               jlu.jlu_jrnl_description as jlu_jrnl_description,
               jlu.jlu_jrnl_source as jlu_jrnl_source,
               jlu.jlu_jrnl_source_jrnl_id as jlu_jrnl_source_jrnl_id,
               NULL as jlu_jrnl_authorised_by,
               NULL as jlu_jrnl_authorised_on,
               NULL as jlu_jrnl_validated_by,
               NULL as jlu_jrnl_validated_on,
               NULL as jlu_jrnl_posted_by,
               NULL as jlu_jrnl_posted_on,
               jlu.jlu_jrnl_total_hash_debit as jlu_jrnl_total_hash_debit,
               jlu.jlu_jrnl_total_hash_credit as jlu_jrnl_total_hash_credit,
               jlu.jlu_jrnl_pref_static_src as jlu_jrnl_pref_static_src,
               NULL as jlu_jrnl_ref_id,
               NULL as jlu_jrnl_rev_date,
               jlu.jlu_translation_date as jlu_translation_date,
               jlu.jlu_period_month as jlu_period_month,
               jlu.jlu_period_year as jlu_period_year,
               jlu.jlu_period_ltd as jlu_period_ltd,
               jlu.jlu_jrnl_internal_period_flag as jlu_jrnl_internal_period_flag,
               jlu.jlu_jrnl_ent_rate_set as jlu_jrnl_ent_rate_set,
               jlu.jlu_type as jlu_type
          from slr.slr_jrnl_lines_unposted jlu
          join rcv_glint_journal_line jl on jlu.jlu_jrnl_source_jrnl_id = jl.jl_jrnl_hdr_id
                                        and jlu.jlu_jrnl_source = jl.jl_jrnl_line_number
                                        and jlu.jlu_effective_date = jl.jl_effective_date
                                        and jlu.jlu_epg_id = jl.jl_epg_id
         where jl.jl_suspense_id = c1Rec.lk_lookup_key_id
           and jlu_jrnl_process_id = myProcessID;
        
       End If;

    End Loop;
  End If;

  fdr.PG_COMMON.pLogDebug(pinMessage => 'End Combo Check - GL Interface');
  dbms_application_info.set_module(
    module_name => NULL,
    action_name => NULL);
Exception
When Others Then
  /* Log the error. */
  dbms_application_info.set_action('Unhandled Exception');
  fdr.PR_Error (
    a_type => fdr.PG_COMMON.gcErrorEventType_Error,
    a_text => dbms_utility.format_error_backtrace,
    a_category => fdr.PG_COMMON.gcErrorCategory_Tech,
    a_error_source => lcUnitName,
    a_error_table => 'SLR_JRNL_LINES',
    a_row => NULL,
    a_error_field => NULL,
    a_stage => user,
    a_technology => fdr.PG_COMMON.gcErrorTechnology_PLSQL,
    a_value => NULL,
    a_entity => NULL,
    a_book => NULL,
    a_security => NULL,
    a_source_system => NULL,
    a_client_key => NULL,
    a_client_ver => NULL,
    a_lpg_id => NULL
  );

  /* Raise the error. */
  Raise;
End pcombinationcheck_glint;
/