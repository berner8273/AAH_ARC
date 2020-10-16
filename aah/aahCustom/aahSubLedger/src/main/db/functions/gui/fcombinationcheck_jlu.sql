create or replace function gui.fcombinationcheck_jlu (
  pinJournalID in temp_gui_jrnl_lines_unposted.jlu_jrnl_hdr_id%TYPE,
  pinSessionID in temp_gui_jrnl_lines_unposted.user_session_id%TYPE
) Return Boolean
As
/* Place this function within the PGUI_JRNL_CUSTOM package and call from within the fnui_validate_jrnl_line function. */
/* Function assumes both Journal ID and Session ID are passed in. */
/* No COMMIT. */

/* Constants. */
lcUnitName        Constant all_procedures.procedure_name%TYPE := 'fCombinationCheck_JLU';
lcViewName        Constant all_views.view_name%TYPE := 'UCV_COMBINATION_CHECK_JLU';
lcErrorCode_Combo Constant slr.slr_error_message.em_error_code%TYPE := 'JL_COMBO';

/* Variables. */
myErrorCount Pls_Integer;
myReturn     Boolean := True; --True=Success, False=Error.

Begin
  dbms_application_info.set_module(
    module_name => lcUnitName,
    action_name => 'Start');
  fdr.PG_COMMON.pLogDebug(pinMessage => 'Start Combo Check - GUI Unposted Journal Lines');

  /* Configure the optimizer hints for Combination Checking. */
  fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboInput := '';
  fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboError := '';
  fdr.PG_COMBINATION_CHECK.gSQLHint_InsertInput      := '';
  fdr.PG_COMBINATION_CHECK.gSQLHint_SelectInput      := '';
  fdr.PG_COMBINATION_CHECK.gSQLHint_InsertComboError := '';
  fdr.PG_COMBINATION_CHECK.gSQLHint_SelectComboError := '';

  /* Call the Combination Check for the journal. */
  fdr.PG_COMBINATION_CHECK.pCombinationCheck(
    pinObjectName   =>  lcViewName,
    pinFilter       =>  'session_id = ' || sys.dbms_assert.enquote_literal(pinSessionID) || ' and journal_id = ' || pinJournalID,
    pinBusinessDate =>  NULL,
    poutErrorCount  =>  myErrorCount);

  If myErrorCount > 0 Then
    dbms_application_info.set_action('Create Journal Line Error');
    Insert into temp_gui_jrnl_line_errors (
      user_session_id,
      jle_jrnl_process_id,
      jle_jrnl_hdr_id,
      jle_jrnl_line_number,
      jle_error_code,
      jle_error_string,
      jle_created_by,
      jle_created_on,
      jle_amended_by,
      jle_amended_on)
    Select pinSessionID as user_session_id,
           0 as jle_jrnl_process_id,
           substr(ce_input_id,1,instr(ce_input_id,'_')-1) as jle_jrnl_hdr_id,
           substr(ce_input_id,instr(ce_input_id,'_')+1) as jle_jrnl_line_number,
           lcErrorCode_Combo as jle_error_code,
           replace(replace(em_error_message,'%1',ce_rule),'%2',ce_attribute_name) as jle_error_string,
           user as jle_created_by,
           sysdate as jle_created_on,
           user as jle_amended_by,
           sysdate as jle_amended_on
      from fdr.fr_combination_check_error
      join slr.slr_error_message on 1 = 1
     where em_error_code = lcErrorCode_Combo;

     myReturn := False;
  End If;

  If myReturn Then fdr.PG_COMMON.pLogDebug(pinMessage => 'myReturn=True'); Else fdr.PG_COMMON.pLogDebug(pinMessage => 'myReturn=False'); End If;
  fdr.PG_COMMON.pLogDebug(pinMessage => 'End Combo Check - GUI Unposted Journal Lines');
  dbms_application_info.set_module(
    module_name => NULL,
    action_name => NULL);
  Return myReturn;

Exception
When Others Then
  /* Log the error. */
  dbms_application_info.set_action('Unhandled Exception');
  fdr.PR_Error (
    a_type => fdr.PG_COMMON.gcErrorEventType_Error,
    a_text => dbms_utility.format_error_backtrace,
    a_category => fdr.PG_COMMON.gcErrorCategory_Tech,
    a_error_source => lcUnitName,
    a_error_table => 'TEMP_GUI_JRNL_LINES_UNPOSTED',
    a_row => pinJournalID,
    a_error_field => NULL,
    a_stage => user,
    a_technology => fdr.PG_COMMON.gcErrorTechnology_PLSQL,
    a_value => pinSessionID,
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
end fcombinationcheck_jlu;
/