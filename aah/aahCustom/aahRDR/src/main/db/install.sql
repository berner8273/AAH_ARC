-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in reporting.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~
set echo on

define fdr_logon=~1
define gui_logon=~2
define rdr_logon=~3
define sla_logon=~4
define slr_logon=~5
define stn_logon=~6
define sys_logon=~7
define unittest_login=~8

conn ~stn_logon

@@grants/tables/stn/gl_account_hierarchy.sql
@@grants/tables/stn/business_event.sql
@@grants/tables/stn/business_event_category.sql
@@grants/tables/stn/business_type.sql
@@grants/tables/stn/execution_type.sql
@@grants/tables/stn/cession_event_premium_type.sql
@@grants/tables/stn/policy_premium_type.sql
@@grants/tables/stn/posting_method_derivation_rein.sql
@@grants/tables/stn/event_type.sql
@@grants/tables/stn/posting_accounting_basis.sql
@@grants/tables/stn/posting_financial_calc.sql
@@grants/tables/stn/posting_ledger.sql
@@grants/tables/stn/posting_method.sql
@@grants/tables/stn/posting_method_derivation_mtm.sql
@@grants/tables/stn/posting_method_ledger.sql
@@grants/tables/stn/vie_code.sql
@@grants/tables/stn/vie_event_type.sql
@@grants/tables/stn/vie_posting_method_ledger.sql

conn ~slr_logon

@@grants/tables/slr/slr_fak_combinations.sql
@@grants/tables/slr/slr_eba_combinations.sql
@@grants/tables/slr/slr_eba_daily_balances.sql
@@grants/tables/slr/slr_fak_daily_balances.sql
@@grants/tables/slr/slr_eba_bop_amounts.sql
@@grants/tables/slr/slr_fak_bop_amounts.sql
@@grants/tables/slr/slr_entity_periods.sql
@@grants/tables/slr/slr_entities.sql
@@grants/tables/slr/slr_jrnl_headers.sql
@@grants/tables/slr/slr_jrnl_headers_unposted.sql
@@grants/tables/slr/slr_jrnl_lines_unposted.sql

conn ~fdr_logon

@@grants/tables/fdr/fr_account_lookup.sql
@@grants/tables/fdr/fr_general_lookup_aud.sql
@@grants/tables/fdr/fr_posting_schema.sql
@@grants/tables/fdr/fr_stan_raw_acc_event.sql
@@grants/tables/fdr/fr_org_hier_levels.sql

conn ~gui_logon

@@grants/tables/gui/t_ui_role_tasks.sql
@@grants/tables/gui/t_ui_user_details.sql
@@grants/tables/gui/t_ui_user_roles.sql
@@grants/tables/gui/gui_jrnl_line_errors.sql
@@grants/tables/gui/gui_jrnl_lines_unposted.sql
@@grants/tables/gui/gui_jrnl_headers_unposted.sql

conn ~rdr_logon

@@views/rdr/rrv_ag_account_lookup.sql
@@views/rdr/rrv_ag_accounting_basis_ledger.sql
@@views/rdr/rrv_ag_accounting_event.sql
@@views/rdr/rrv_ag_accounting_event_imp.sql
@@views/rdr/rrv_ag_business_event.sql
@@views/rdr/rrv_ag_business_unit.sql
@@views/rdr/rrv_ag_combo_edit_rules.sql
@@views/rdr/rrv_ag_department.sql
@@views/rdr/rrv_ag_event_hierarchy.sql
@@views/rdr/rrv_ag_event_class_period.sql
@@views/rdr/rrv_ag_fx_rates.sql
@@views/rdr/rrv_ag_gl_account_hierarchy.sql
@@views/rdr/rrv_ag_gl_accounts.sql
@@views/rdr/rrv_ag_insurance_policy.sql
@@views/rdr/rrv_ag_insurance_policy_fx.sql
@@views/rdr/rrv_ag_ledger.sql
@@views/rdr/rrv_ag_legal_entity_ledger.sql
@@views/rdr/rrv_ag_lookup_types.sql
@@views/rdr/rrv_ag_posting_driver.sql
@@views/rdr/rrv_ag_program.sql
@@views/rdr/rrv_ag_slr_fak_combinations.sql
@@views/rdr/rrv_ag_slr_eba_combinations.sql
@@views/rdr/rrv_ag_slr_eba_daily_balances.sql
@@views/rdr/rrv_ag_slr_entity_periods.sql
@@views/rdr/rrv_ag_slr_ext_jrnl_types.sql
@@views/rdr/rrv_ag_slr_fak_daily_balances.sql
@@views/rdr/rrv_ag_slr_jrnl_lines.sql
@@views/rdr/rrv_ag_stan_raw_acc_event.sql
@@views/rdr/rrv_ag_tax_jurisdiction.sql
@@views/rdr/rrv_ag_user_roles_and_tasks.sql
@@views/rdr/rrv_ag_org_hierarchy_type.sql
@@views/rdr/rrv_ag_org_network.sql
@@views/rdr/rrv_ag_org_node_structure.sql
@@views/rdr/rrv_ag_org_hier_levels.sql
@@views/rdr/rrv_ag_slr_jrnl_headers.sql
@@views/rdr/rrv_ag_reinsurance.sql
@@views/rdr/rrv_ag_posting_derivation.sql
@@views/rdr/rrv_ag_glint_jrnl_lines.sql
@@views/rdr/rrv_ag_glint_to_ps.sql
@@views/rdr/rrv_ag_glint_jl_manual.sql
@@views/rdr/rrv_ag_glint_jl_processed.sql
@@views/rdr/rrv_ag_glint_jl_unposted.sql
@@views/rdr/rrv_ag_journal_lines.sql
@@views/rdr/rrv_ag_event_class_status.sql
