create or replace procedure slr.pcombinationcheck_jlu (
  pinepgid     in slr_entity_proc_group.epg_id%type,
  pinprocessid in slr_job_statistics.js_process_id%type,
  pinstatus    in slr_jrnl_lines_unposted.jlu_jrnl_status%type := 'U'
)
as
/* Place this procedure within the SLR_CLIENT_PROCEDURES_PKG package (or on-site equivalent) and call after pValidateJournals in the pProcess_SLR procedure. */
/* Procedure assumes both EPG and Process ID are passed in. */
/* Procedure assumes all entities within an EPG have the same combination checking flag set. */
/* Amend the optimizer hints according to data profile. */
/* Procedure COMMITs at the end. */

/* Constants. */
lcunitname        constant all_procedures.procedure_name%type := 'pCombinationCheck_JLU';
lcviewname        constant all_views.view_name%type := 'SCV_COMBINATION_CHECK_JLU';
lcerrorcode_combo constant slr_error_message.em_error_code%type := 'JL_COMBO';

/* Variables. */
myerrorcount pls_integer;

begin
  dbms_application_info.set_module(
    module_name => lcunitname,
    action_name => 'Start');
  fdr.pg_common.plogdebug(pinmessage => 'Start Combo Check - Unposted Journal Lines');

  /* Configure the optimizer hints for Combination Checking. */
  fdr.pg_combination_check.gsqlhint_deletecomboinput := '';
  fdr.pg_combination_check.gsqlhint_deletecomboerror := '';
  fdr.pg_combination_check.gsqlhint_insertinput      := '/*+ no_parallel */';
  fdr.pg_combination_check.gsqlhint_selectinput      := '/*+ parallel */';
  fdr.pg_combination_check.gsqlhint_insertcomboerror := '/*+ no_parallel */';
  fdr.pg_combination_check.gsqlhint_selectcomboerror := '/*+ parallel */';

  /* Call the Combination Check for those journals that are not in error yet - use the [sub-]partitioning key. */
  fdr.pg_combination_check.pcombinationcheck(
    pinobjectname   =>  lcviewname,
    pinfilter       =>  'epg_id = ' || sys.dbms_assert.enquote_literal(pinepgid) || ' and status = ' || sys.dbms_assert.enquote_literal(pinstatus),
    pinbusinessdate =>  null,
    pouterrorcount  =>  myerrorcount);

  if myerrorcount > 0 then
    dbms_application_info.set_action('Create Journal Line Error');
    insert /*+ parallel */ into slr_jrnl_line_errors (
      jle_jrnl_process_id,
      jle_jrnl_hdr_id,
      jle_jrnl_line_number,
      jle_error_code,
      jle_error_string,
      jle_created_by,
      jle_created_on,
      jle_amended_by,
      jle_amended_on)
    select /*+ parallel */
           pinprocessid as jle_jrnl_process_id,
           substr(ce_input_id,1,instr(ce_input_id,'_')-1) as jle_jrnl_hdr_id,
           substr(ce_input_id,instr(ce_input_id,'_')+1) as jle_jrnl_line_number,
           lcerrorcode_combo as jle_error_code,
           replace(replace(em_error_message,'%1',ce_rule),'%2',ce_attribute_name) as jle_error_string,
           user as jle_created_by,
           sysdate as jle_created_on,
           user as jle_amended_by,
           sysdate as jle_amended_on
      from fdr.fr_combination_check_error
      join slr.slr_error_message on 1 = 1
     where em_error_code = lcerrorcode_combo;
  end if;

  /* Remove the combination input/error records and commit the journal error records. */
  commit;

  fdr.pg_common.plogdebug(pinmessage => 'End Combo Check - Unposted Journal Lines');
  dbms_application_info.set_module(
    module_name => null,
    action_name => null);
exception
when others then
  /* Log the error. */
  dbms_application_info.set_action('Unhandled Exception');
  fdr.pr_error (
    a_type => fdr.pg_common.gcerroreventtype_error,
    a_text => dbms_utility.format_error_backtrace,
    a_category => fdr.pg_common.gcerrorcategory_tech,
    a_error_source => lcunitname,
    a_error_table => 'SLR_JRNL_LINES_UNPOSTED',
    a_row => null,
    a_error_field => null,
    a_stage => user,
    a_technology => fdr.pg_common.gcerrortechnology_plsql,
    a_value => null,
    a_entity => null,
    a_book => null,
    a_security => null,
    a_source_system => null,
    a_client_key => null,
    a_client_ver => null,
    a_lpg_id => null
  );

  /* Raise the error. */
  raise;
end pcombinationcheck_jlu;
/