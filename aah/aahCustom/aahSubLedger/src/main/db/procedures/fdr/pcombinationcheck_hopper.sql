create or replace procedure fdr.pcombinationcheck_hopper (pinLPGID in fr_stan_raw_acc_event.lpg_id%TYPE)
As
/* Place this procedure within a hopper package and call from Standardisation rule(s) that populates the associated hopper. */
/* Amend the optimizer hints according to data profile. */
/* No COMMIT. */

/* Constants. */
lcUnitName        Constant all_procedures.procedure_name%TYPE := 'pCombinationCheck_Hopper';
lcTableName       Constant all_tables.table_name%TYPE := 'FR_STAN_RAW_ACC_EVENT';
lcViewName        Constant all_views.view_name%TYPE := 'FCV_COMBINATION_CHECK_HOPPER';

/* Variables. */
myErrorCount Pls_Integer;
myCount      Pls_Integer;
mySQL        Varchar2(32767);

Begin
  dbms_application_info.set_module(
    module_name => lcUnitName,
    action_name => 'Start');
  PG_COMMON.pLogDebug(pinMessage => 'Start Combo Check - Hopper');

  /* Parameter Check. */
  If pinLPGID is Null Then
    sys.dbms_standard.raise_application_error(-20000,'LPG not provided.',False);
  End If;

  /* Configure the optimizer hints for Combination Checking. */
  PG_COMBINATION_CHECK.gSQLHint_DeleteComboInput := '';
  PG_COMBINATION_CHECK.gSQLHint_DeleteComboError := '';
  PG_COMBINATION_CHECK.gSQLHint_InsertInput      := '/*+ no_parallel */';
  PG_COMBINATION_CHECK.gSQLHint_SelectInput      := '/*+ parallel */';
  PG_COMBINATION_CHECK.gSQLHint_InsertComboError := '/*+ no_parallel */';
  PG_COMBINATION_CHECK.gSQLHint_SelectComboError := '/*+ parallel */';

  /* Call the Combination Check for those hopper records that are to be processed by AAH. */
  PG_COMBINATION_CHECK.pCombinationCheck(
    pinObjectName   =>  lcViewName,
    pinFilter       =>  'lpg_id = ' || to_char(pinLPGID),
    pinBusinessDate =>  NULL,
    poutErrorCount  =>  myErrorCount);

  If myErrorCount > 0 Then
    /* Create Error for each combination check failure. */
    dbms_application_info.set_action('Create Error Log');
    Insert /*+ parallel */ into fr_log (
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
           PG_COMMON.gcErrorEventType_Error as lo_event_type_id,
           PG_COMMON.gcStatusFlag_Error as lo_error_status,
           PG_COMMON.gcErrorCategory_Tech as lo_category_id,
           'Combination Check Failure : Rule Set= ' || ce_ruleset || ' : Rule=' || ce_rule as lo_event_text,
           lcViewName as lo_table_in_error_name,
           to_number(ce_input_id) as lo_row_in_error_key_id,
           ce_attribute_name as lo_field_in_error_name,
           PG_COMMON.gcErrorTechnology_PLSQL as lo_error_technology,
           lcUnitName as lo_error_rule_ident,
           case ce_attribute_name When PG_COMBINATION_CHECK.gcAttribute_1 Then ce_attribute_1
                                  When PG_COMBINATION_CHECK.gcAttribute_2 Then ce_attribute_2
                                  When PG_COMBINATION_CHECK.gcAttribute_3 Then ce_attribute_3
                                  When PG_COMBINATION_CHECK.gcAttribute_4 Then ce_attribute_4
                                  When PG_COMBINATION_CHECK.gcAttribute_5 Then ce_attribute_5
                                  When PG_COMBINATION_CHECK.gcAttribute_6 Then ce_attribute_6
                                  When PG_COMBINATION_CHECK.gcAttribute_7 Then ce_attribute_7
                                  When PG_COMBINATION_CHECK.gcAttribute_8 Then ce_attribute_8
                                  When PG_COMBINATION_CHECK.gcAttribute_9 Then ce_attribute_9
                                  When PG_COMBINATION_CHECK.gcAttribute_10 Then ce_attribute_10
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
      from fr_combination_check_error;

    /* Update Hopper records that failed combination checking with Suspense Values. */
    dbms_application_info.set_action('Update Hopper with Suspense Values');
    mySQL := 'Update ' || lcTableName || ' Set ';
    myCount := 0;
    For c1Rec in (Select attribute, suspense_value
                    from fcv_combination_check_suspense
                   where data_set = (Select lk_lookup_value1
                                       from fr_general_lookup
                                      where lk_lkt_lookup_type_code = PG_COMBINATION_CHECK.gcLookupType_Suspense
                                        and lk_match_key1 = lcViewName
                                        and lk_active = PG_COMMON.gcActiveInactive_Active)) Loop
      myCount := myCount + 1;
      If myCount <> 1 Then
        mySQL := mySQL || ',';
      End If;
      mySQL := mySQL
            || c1Rec.attribute || ' = ' || sys.dbms_assert.enquote_literal(c1Rec.suspense_value);
    End Loop;
    mySQL := mySQL
          || ' where lpg_id = ' || to_char(pinLPGID)
          || '   and srae_raw_acc_event_id in (Select ce_input_id from fr_combination_check_error)';
    If myCount > 0 Then
      PG_COMMON.pExecuteSQL(pinSQL => mySQL);
    End If;
  End If;
  PG_COMMON.pLogDebug(pinMessage => 'End Combo Check - Hopper');
  dbms_application_info.set_module(
    module_name => NULL,
    action_name => NULL);
Exception
When Others Then
  /* Log the error. */
  dbms_application_info.set_action('Unhandled Exception');
  PR_Error (
    a_type => PG_COMMON.gcErrorEventType_Error,
    a_text => dbms_utility.format_error_backtrace,
    a_category => PG_COMMON.gcErrorCategory_Tech,
    a_error_source => lcUnitName,
    a_error_table => lcViewName,
    a_row => NULL,
    a_error_field => NULL,
    a_stage => user,
    a_technology => PG_COMMON.gcErrorTechnology_PLSQL,
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
End pcombinationcheck_hopper;
/