-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in reporting.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = aptci
define stn_user     = stn
define stn_password = NZ784FBLUJesbJvA
define stn_logon    = ~stn_user/~stn_password@~tns_alias

define fdr_user     = fdr
define fdr_password = bJGeTSP2PbMikw4d
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define gui_user     = gui
define gui_password = KWDfdtQqoa3A2nE5
define gui_logon    = ~gui_user/~gui_password@~tns_alias

define slr_user     = slr
define slr_password = xJ4V8iyBJ7UuVSx6
define slr_logon    = ~slr_user/~slr_password@~tns_alias

define rdr_user     = rdr
define rdr_password = HuJJnYnTr8LRwJqL
define rdr_logon    = ~rdr_user/~rdr_password@~tns_alias

define sys_user     = aptitude
define sys_password = iK3BQ8QvbuhSvaAU
define sys_logon    = ~sys_user/~sys_password@~tns_alias

--define fdr_logon    = ~1
--define gui_logon    = ~2
--define rdr_logon    = ~3
--define sla_logon    = ~4
--define slr_logon    = ~5
--define stn_logon    = ~6
--define sys_logon    = ~7
--define unittest_login   = ~8

conn ~stn_logon

@@grants/tables/stn/gl_account_hierarchy.sql
@@grants/tables/stn/business_type.sql
@@grants/tables/stn/execution_type.sql
@@grants/tables/stn/cession_event_premium_type.sql
@@grants/tables/stn/policy_premium_type.sql
@@grants/tables/stn/posting_method_derivation_rein.sql
@@grants/tables/stn/event_type.sql
@@grants/tables/stn/posting_ledger.sql
@@grants/tables/stn/posting_method.sql
@@grants/tables/stn/posting_accounting_basis.sql
@@grants/tables/stn/posting_method_derivation_mtm.sql
@@grants/tables/stn/posting_financial_calc.sql
@@grants/tables/stn/posting_method_ledger.sql
@@grants/tables/stn/vie_event_type.sql
@@grants/tables/stn/vie_code.sql
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

conn ~fdr_logon

@@grants/tables/fdr/fr_account_lookup.sql
@@grants/tables/fdr/fr_posting_schema.sql
@@grants/tables/fdr/fr_stan_raw_acc_event.sql
@@grants/tables/fdr/fr_org_hier_levels.sql

conn ~gui_logon

@@grants/tables/gui/t_ui_role_tasks.sql
@@grants/tables/gui/t_ui_user_details.sql
@@grants/tables/gui/t_ui_user_roles.sql

conn ~rdr_logon

@@views/rdr/rrv_ag_account_lookup.sql
@@views/rdr/rrv_ag_accounting_basis_ledger.sql
@@views/rdr/rrv_ag_accounting_event.sql
@@views/rdr/rrv_ag_accounting_event_imp.sql
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

exit