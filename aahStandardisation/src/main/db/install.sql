-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in standardisation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@
define stn_user     = @stnUsername@
define stn_password = @stnPassword@
define stn_logon    = ~stn_user/~stn_password@~tns_alias

define fdr_user     = @fdrUsername@
define fdr_password = @fdrPassword@
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

define slr_user     = @slrUsername@
define slr_password = @slrPassword@
define slr_logon    = ~slr_user/~slr_password@~tns_alias

conn ~slr_logon

@@grants/tables/slr/slr_entity_periods.sql
@@grants/tables/slr/slr_eba_combinations.sql
@@grants/tables/slr/slr_fak_combinations.sql
@@grants/tables/slr/slr_eba_daily_balances.sql
@@grants/tables/slr/slr_jrnl_lines.sql
@@grants/tables/slr/slr_jrnl_headers.sql
@@grants/tables/slr/slr_entities.sql

conn ~gui_logon

@@grants/tables/gui/t_ui_departments.sql
@@grants/tables/gui/t_ui_roles.sql
@@grants/tables/gui/t_ui_user_details.sql
@@grants/tables/gui/t_ui_user_departments.sql
@@grants/tables/gui/t_ui_user_roles.sql
@@grants/tables/gui/t_ui_user_entities.sql

@@packages/gui/gui_pkg.hdr
@@packages/gui/gui_pkg.bdy

conn ~fdr_logon

@@data/fdr/fr_address.sql
@@data/fdr/fr_calendar.sql
@@data/fdr/fr_calendar_week.sql
@@data/fdr/fr_country.sql
@@data/fdr/fr_currency.sql
@@data/fdr/fr_db_upgrade_history.sql
@@data/fdr/fr_rate_type.sql
update fdr.fr_rate_type
set rty_active = 'I'
where rty_rate_type_id = 'FORWARD' and rty_active = 'A';
@@data/fdr/fr_party_type.sql
update fdr.fr_party_type fpt set fpt.pt_active = 'I' where fpt.pt_party_type_name in ( 'DEFAULT' , 'Counterparty' , 'Broker' , 'Governmental Agency' , 'Individual' , 'Clearing Agent' , 'Nostro Agent' , 'Business Unit' );
commit;
@@data/fdr/fr_city.sql
@@data/fdr/fr_party_legal.sql
@@data/fdr/fr_internal_proc_entity_type.sql
@@data/fdr/fr_internal_proc_entity.sql
@@data/fdr/fr_general_lookup_type.sql
@@data/fdr/fr_general_lookup.sql
@@data/fdr/fr_general_code_types.sql
@@data/fdr/fr_general_codes.sql
@@data/fdr/fr_org_hierarchy_type.sql
@@data/fdr/fr_org_node_type.sql
@@data/fdr/fr_global_parameter.sql
@@data/fdr/is_group.sql
@@data/fdr/fr_instr_type_superclass.sql
@@data/fdr/fr_instr_type_class.sql
@@data/fdr/fr_instrument_type.sql
@@data/fdr/fr_instrument.sql
update fr_general_codes set gc_active = 'A' where gc_gct_code_type_id = '12' and gc_client_code in ('B','P'); 
commit;
update fr_general_codes set gc_active = 'I' where gc_gct_code_type_id = '12' and gc_client_code not in ('B','P');
commit;
@@grants/tables/fdr/fr_acc_event_type.sql
@@grants/tables/fdr/fr_account_lookup.sql
@@grants/tables/fdr/fr_fx_rate.sql
@@grants/tables/fdr/fr_gaap.sql
@@grants/tables/fdr/fr_general_code_types.sql
@@grants/tables/fdr/fr_general_codes.sql
@@grants/tables/fdr/fr_general_lookup.sql
@@grants/tables/fdr/fr_gl_account.sql
@@grants/tables/fdr/fr_party_legal.sql
@@grants/tables/fdr/fr_posting_driver.sql
@@grants/tables/fdr/fr_posting_schema.sql
@@grants/tables/fdr/fr_stan_raw_acc_event.sql
@@grants/tables/fdr/fr_stan_raw_general_codes.sql
@@grants/tables/fdr/fr_stan_raw_general_lookup.sql
@@grants/tables/fdr/fr_stan_raw_org_hier_node.sql
@@grants/tables/fdr/fr_internal_proc_entity_type.sql
@@grants/tables/fdr/fr_stan_raw_org_hier_struc.sql
@@grants/tables/fdr/is_user.sql
@@grants/tables/fdr/is_groupuser.sql
@@grants/tables/fdr/is_group.sql
@@grants/tables/fdr/fr_rate_type.sql
@@grants/tables/fdr/fr_instr_insure_extend.sql
@@grants/tables/fdr/fr_instrument.sql
@@grants/tables/fdr/fr_trade.sql
@@grants/tables/fdr/fr_accounting_event_imp.sql
@@grants/tables/fdr/fr_party_type.sql
@@packages/fdr/pk_legal_entity.hdr
@@packages/fdr/pk_legal_entity.bdy
@@indices/fdr/fr_stan_raw_book.sql
@@indices/fdr/fr_stan_raw_general_codes.sql
@@indices/fdr/fr_stan_raw_gl_account.sql
@@indices/fdr/fr_stan_raw_org_hier_struc.sql
@@indices/fdr/fr_stan_raw_party_legal.sql
@@indices/fdr/fr_stan_raw_adjustment.sql
@@indices/fdr/fr_party_legal.sql

conn ~stn_logon

@@tables/stn/accounting_basis_ledger.sql
@@tables/stn/broken_feed.sql
@@tables/stn/business_event.sql
@@tables/stn/business_type.sql
@@tables/stn/cession.sql
@@tables/stn/cession_event.sql
@@tables/stn/cev_valid.sql
@@tables/stn/cev_data.sql
@@tables/stn/cev_derived_plus_data.sql
@@tables/stn/cev_gaap_fut_accts_data.sql
@@tables/stn/cev_le_data.sql
@@tables/stn/cev_mtm_data.sql
@@tables/stn/cev_non_intercompany_data.sql
@@tables/stn/cev_intercompany_data.sql
@@tables/stn/cev_vie_data.sql
@@tables/stn/cev_premium_typ_override.sql
@@tables/stn/posting_method_derivation_gfa.sql
@@tables/stn/posting_account_derivation.sql
@@tables/stn/vie_posting_account_derivation.sql
@@tables/stn/posting_amount_negate_flag.sql
@@tables/stn/cession_event_premium_type.sql
@@tables/stn/cession_hierarchy.sql
@@tables/stn/cession_link.sql
@@tables/stn/cession_link_type.sql
@@tables/stn/cession_type.sql
@@tables/stn/code_module.sql
@@tables/stn/code_module_type.sql
@@tables/stn/db_tab_column.sql
@@tables/stn/db_table.sql
@@tables/stn/department.sql
@@tables/stn/event_hierarchy.sql
@@tables/stn/event_type.sql
@@tables/stn/execution_type.sql
@@tables/stn/feed.sql
@@tables/stn/feed_record_count.sql
@@tables/stn/feed_type.sql
@@tables/stn/feed_type_payload.sql
@@tables/stn/fx_rate.sql
@@tables/stn/fx_rate_type.sql
@@tables/stn/gl_account.sql
@@tables/stn/gl_account_category.sql
@@tables/stn/gl_account_hierarchy.sql
@@tables/stn/gl_chartfield.sql
@@tables/stn/gl_chartfield_type.sql
@@tables/stn/gl_combo_edit_assignment.sql
@@tables/stn/gl_combo_edit_process.sql
@@tables/stn/gl_combo_edit_rule.sql
@@tables/stn/identified_feed.sql
@@tables/stn/identified_record.sql
@@tables/stn/insurance_policy.sql
@@tables/stn/insurance_policy_fx_rate.sql
@@tables/stn/insurance_policy_tax_jurisd.sql
@@tables/stn/journal_line.sql
@@tables/stn/journal_line_premium_type.sql
@@tables/stn/journal_line_source_type.sql
@@tables/stn/ledger.sql
@@tables/stn/elimination_legal_entity.sql
@@tables/stn/legal_entity.sql
@@tables/stn/legal_entity_ledger.sql
@@tables/stn/legal_entity_link.sql
@@tables/stn/legal_entity_link_type.sql
@@tables/stn/legal_entity_type.sql
@@tables/stn/policy_premium_type.sql
@@tables/stn/posting_accounting_basis.sql
@@tables/stn/posting_accounting_basis_type.sql
@@tables/stn/posting_amount_derivation_type.sql
@@tables/stn/posting_amount_derivation.sql
@@tables/stn/posting_financial_calc.sql
@@tables/stn/posting_ledger.sql
@@tables/stn/posting_method.sql
@@tables/stn/posting_method_derivation_et.sql
@@tables/stn/posting_method_derivation_ic.sql
@@tables/stn/posting_method_derivation_le.sql
@@tables/stn/posting_method_derivation_mtm.sql
@@tables/stn/posting_method_derivation_rein.sql
@@tables/stn/posting_method_ledger.sql
@@tables/stn/process_code_module.sql
@@tables/stn/standardisation_log.sql
@@tables/stn/superseded_feed.sql
@@tables/stn/supersession_method.sql
@@tables/stn/validation.sql
@@tables/stn/validation_column.sql
@@tables/stn/validation_level.sql
@@tables/stn/validation_type.sql
@@tables/stn/vie_code.sql
@@tables/stn/vie_legal_entity.sql
@@tables/stn/vie_event_type.sql
@@tables/stn/vie_posting_method_ledger.sql
@@tables/stn/tax_jurisdiction.sql
@@views/stn/dept_default.sql
@@views/stn/feed_missing_record_count.sql
@@views/stn/fxr_default.sql
@@views/stn/gla_default.sql
@@views/stn/hopper_accounting_basis_ledger.sql
@@views/stn/hopper_gl_chartfield.sql
@@views/stn/hopper_gl_combo_edit_gc.sql
@@views/stn/hopper_gl_combo_edit_gl.sql
@@views/stn/hopper_legal_entity_alias.sql
@@views/stn/hopper_legal_entity_ledger.sql
@@views/stn/hopper_tax_jurisdiction.sql
@@views/stn/hopper_journal_line.sql
@@views/stn/journal_line_default.sql
@@views/stn/tax_jurisdiction_default.sql
@@views/stn/le_default.sql
@@views/stn/ledger_default.sql
@@views/stn/row_val_error_log_default.sql
@@views/stn/set_val_error_log_default.sql
@@views/stn/ce_default.sql
@@views/stn/insurance_policy_reference.sql
@@views/stn/validation_detail.sql
@@views/stn/policy_tax.sql
@@views/stn/cession_event_posting.sql
@@views/stn/cession_event_reversal_curr.sql
@@views/stn/cession_event_reversal_hist.sql
@@views/stn/cev_period_balances.sql
@@views/stn/period_status.sql
@@views/stn/gce_default.sql
@@views/stn/hopper_cession_event.sql
@@views/stn/hopper_insurance_policy.sql
@@views/stn/hopper_insurance_policy_tj.sql
@@views/stn/pol_default.sql
@@views/stn/event_hierarchy_default.sql
@@views/stn/hopper_event_hierarchy.sql
@@views/stn/hopper_event_category.sql
@@views/stn/hopper_event_class.sql
@@views/stn/hopper_event_group.sql
@@views/stn/hopper_event_subgroup.sql
@@views/stn/event_hierarchy_reference.sql
@@ri_constraints/stn/accounting_basis_ledger.sql
@@ri_constraints/stn/broken_feed.sql
@@ri_constraints/stn/cession.sql
@@ri_constraints/stn/cession_event.sql
@@ri_constraints/stn/cession_link.sql
@@ri_constraints/stn/code_module.sql
@@ri_constraints/stn/db_tab_column.sql
@@ri_constraints/stn/feed.sql
@@ri_constraints/stn/feed_record_count.sql
@@ri_constraints/stn/feed_type.sql
@@ri_constraints/stn/feed_type_payload.sql
@@ri_constraints/stn/fx_rate.sql
@@ri_constraints/stn/gl_account.sql
@@ri_constraints/stn/gl_chartfield.sql
@@ri_constraints/stn/gl_combo_edit_assignment.sql
@@ri_constraints/stn/gl_combo_edit_rule.sql
@@ri_constraints/stn/insurance_policy.sql
@@ri_constraints/stn/insurance_policy_fx_rate.sql
@@ri_constraints/stn/insurance_policy_tax_jurisd.sql
@@ri_constraints/stn/journal_line.sql
@@ri_constraints/stn/legal_entity.sql
@@ri_constraints/stn/legal_entity_ledger.sql
@@ri_constraints/stn/legal_entity_link.sql
@@ri_constraints/stn/posting_accounting_basis.sql
@@ri_constraints/stn/posting_amount_negate_flag.sql
@@ri_constraints/stn/posting_method_derivation_et.sql
@@ri_constraints/stn/posting_method_derivation_ic.sql
@@ri_constraints/stn/posting_method_derivation_le.sql
@@ri_constraints/stn/posting_method_derivation_link.sql
@@ri_constraints/stn/posting_method_derivation_mtm.sql
@@ri_constraints/stn/posting_method_ledger.sql
@@ri_constraints/stn/process_code_module.sql
@@ri_constraints/stn/superseded_feed.sql
@@ri_constraints/stn/validation.sql
@@ri_constraints/stn/validation_column.sql
@@ri_constraints/stn/vie_posting_method_ledger.sql
@@data/stn/business_event.sql
@@data/stn/business_type.sql
@@data/stn/cession_link_type.sql
@@data/stn/cession_type.sql
@@data/stn/code_module_type.sql
@@data/stn/code_module.sql
@@data/stn/process_code_module.sql
@@data/stn/validation_level.sql
@@data/stn/validation_type.sql
@@data/stn/db_table.sql
@@data/stn/db_tab_column.sql
@@data/stn/validation.sql
@@data/stn/validation_column.sql
@@data/stn/fx_rate_type.sql
@@data/stn/supersession_method.sql
@@data/stn/feed_type.sql
@@data/stn/feed_type_payload.sql
@@data/stn/gl_account_category.sql
@@data/stn/gl_chartfield_type.sql
@@data/stn/legal_entity_type.sql
@@data/stn/legal_entity_link_type.sql
@@data/stn/posting_accounting_basis_type.sql
@@data/stn/cession_event_premium_type.sql
@@data/stn/journal_line_premium_type.sql
@@data/stn/policy_premium_type.sql
@@data/stn/execution_type.sql
@@data/stn/vie_code.sql
@@data/stn/event_type.sql
@@data/stn/vie_event_type.sql
@@data/stn/posting_accounting_basis.sql
@@data/stn/posting_amount_derivation_type.sql
@@data/stn/posting_amount_derivation.sql
@@data/stn/posting_amount_negate_flag.sql
@@data/stn/posting_financial_calc.sql
@@data/stn/posting_ledger.sql
@@data/stn/posting_method.sql
@@data/stn/posting_method_derivation_et.sql
@@data/stn/posting_method_derivation_gfa.sql
@@data/stn/posting_method_derivation_ic.sql
@@data/stn/posting_method_derivation_le.sql
@@data/stn/posting_method_derivation_mtm.sql
@@data/stn/posting_method_derivation_rein.sql
@@data/stn/posting_method_ledger.sql
@@data/stn/vie_posting_method_ledger.sql
@@procedures/stn/pr_publish_log.sql
@@packages/stn/pk_eh.hdr
@@packages/stn/pk_eh.bdy
@@packages/stn/pk_fxr.hdr
@@packages/stn/pk_fxr.bdy
@@packages/stn/pk_gce.hdr
@@packages/stn/pk_gce.bdy
@@packages/stn/pk_gl_acct.hdr
@@packages/stn/pk_gl_acct.bdy
@@packages/stn/pk_glcf.hdr
@@packages/stn/pk_glcf.bdy
@@packages/stn/pk_dept.hdr
@@packages/stn/pk_dept.bdy
@@packages/stn/pk_le.hdr
@@packages/stn/pk_le.bdy
@@packages/stn/pk_ledg.hdr
@@packages/stn/pk_ledg.bdy
@@packages/stn/pk_lel.hdr
@@packages/stn/pk_lel.bdy
@@packages/stn/pk_le_hier.hdr
@@packages/stn/pk_le_hier.bdy
@@packages/stn/pk_feed_integrity.hdr
@@packages/stn/pk_feed_integrity.bdy
@@packages/stn/pk_tj.hdr
@@packages/stn/pk_tj.bdy
@@packages/stn/pk_cession_hier.hdr
@@packages/stn/pk_cession_hier.bdy
@@packages/stn/pk_pol.hdr
@@packages/stn/pk_pol.bdy
@@packages/stn/pk_jl.hdr
@@packages/stn/pk_jl.bdy
@@packages/stn/pk_cev.hdr
@@packages/stn/pk_cev.bdy
@@grants/tables/stn/insurance_policy.sql
@@grants/tables/stn/cession.sql
@@grants/tables/stn/cession_link.sql
@@grants/tables/stn/insurance_policy_fx_rate.sql
@@grants/tables/stn/insurance_policy_tax_jurisd.sql
@@grants/tables/stn/accounting_basis_ledger.sql
@@grants/tables/stn/business_type.sql
@@grants/tables/stn/execution_type.sql
@@grants/tables/stn/journal_line_premium_type.sql
@@grants/tables/stn/journal_line.sql
@@grants/tables/stn/event_hierarchy_reference.sql
@@grants/tables/stn/cession_event.sql


@@indices/stn/cession_event.sql
@@indices/stn/cev_data.sql
@@indices/stn/cev_valid.sql

/*
 * Capture statistics across STN
 */

-- Commented out per user story 26774
--exec dbms_stats.gather_schema_stats ( ownname => 'STN' , cascade => true );

/*
 * Lie to the optimiser by shipping statistics at build time
 */

conn ~stn_logon

exec dbms_stats.set_table_prefs ( 'STN' , 'POSTING_ACCOUNT_DERIVATION'     , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'VIE_POSTING_ACCOUNT_DERIVATION' , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_DATA'                       , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_PREMIUM_TYP_OVERRIDE'       , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_MTM_DATA'                   , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_GAAP_FUT_ACCTS_DATA'        , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_DERIVED_PLUS_DATA'          , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_LE_DATA'                    , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_NON_INTERCOMPANY_DATA'      , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_INTERCOMPANY_DATA'          , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');
exec dbms_stats.set_table_prefs ( 'STN' , 'CEV_VIE_DATA'                   , 'GLOBAL_TEMP_TABLE_STATS' , 'SESSION');

exec dbms_stats.create_stat_table   ( ownname => user , stattab => 'INIT_STAT' );
@@data/stn/init_stat.sql
@@grants/tables/stn/init_stat.sql

conn ~fdr_logon

-- Commented out per user story 26774
--exec dbms_stats.gather_schema_stats ( ownname => 'FDR' , cascade => true );

exec dbms_stats.import_table_stats ( ownname => user , tabname => 'FR_STAN_RAW_INSURANCE_POLICY' , statown => 'STN', stattab => 'INIT_STAT' , cascade => true );
exec dbms_stats.import_table_stats ( ownname => user , tabname => 'FR_STAN_RAW_FX_RATE'          , statown => 'STN', stattab => 'INIT_STAT' , cascade => true );
exec dbms_stats.import_table_stats ( ownname => user , tabname => 'FR_STAN_RAW_GENERAL_CODES'    , statown => 'STN', stattab => 'INIT_STAT' , cascade => true );
exec dbms_stats.import_table_stats ( ownname => user , tabname => 'FR_STAN_RAW_GENERAL_LOOKUP'   , statown => 'STN', stattab => 'INIT_STAT' , cascade => true );

/*
 * Finish shipping statistics at build time
 */

/* Increment fdr.sqfr_trade sequence */
select fdr.sqfr_trade.nextval from dual;

exit