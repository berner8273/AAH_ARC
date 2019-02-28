-- -----------------------------------------------------------------------------------------
-- filename: uninstall;
-- author  : andrew hall
-- purpose : Script to uninstall the objects which involve reporting.
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

conn ~rdr_logon

drop view rdr.rrv_ag_account_lookup;
drop view rdr.rrv_ag_accounting_basis_ledger;
drop view rdr.rrv_ag_accounting_event;
drop view rdr.rrv_ag_accounting_event_imp;
drop view rdr.rrv_ag_business_event;
drop view rdr.rrv_ag_business_unit;
drop view rdr.rrv_ag_combo_edit_rules;
drop view rdr.rrv_ag_department;
drop view rdr.rrv_ag_event_hierarchy;
drop view rdr.rrv_ag_fx_rates;
drop view rdr.rrv_ag_gl_account_hierarchy;
drop view rdr.rrv_ag_gl_accounts;
drop view rdr.rrv_ag_insurance_policy;
drop view rdr.rrv_ag_insurance_policy_fx;
drop view rdr.rrv_ag_ledger;
drop view rdr.rrv_ag_legal_entity_ledger;
drop view rdr.rrv_ag_lookup_types;
drop view rdr.rrv_ag_posting_driver;
drop view rdr.rrv_ag_program;
drop view rdr.rrv_ag_slr_eba_combinations;
drop view rdr.rrv_ag_slr_eba_daily_balances;
drop view rdr.rrv_ag_slr_entity_periods;
drop view rdr.rrv_ag_slr_ext_jrnl_types;
drop view rdr.rrv_ag_slr_fak_combinations;
drop view rdr.rrv_ag_slr_fak_daily_balances;
drop view rdr.rrv_ag_slr_jrnl_lines;
drop view rdr.rrv_ag_stan_raw_acc_event;
drop view rdr.rrv_ag_tax_jurisdiction;
drop view rdr.rrv_ag_user_roles_and_tasks;
drop view rdr.rrv_ag_org_hierarchy_type;
drop view rdr.rrv_ag_org_network;
drop view rdr.rrv_ag_org_node_structure;
drop view rdr.rrv_ag_org_hier_levels;
drop view rdr.rrv_ag_slr_jrnl_headers;
drop view rdr.rrv_ag_reinsurance;
drop view rdr.rrv_ag_posting_derivation;
drop view rdr.rrv_ag_glint_to_ps;
drop view rdr.rrv_ag_glint_jrnl_lines;
