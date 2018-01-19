-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in reporting.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@

define stn_user     = @stnUsername@
define stn_password = @stnPassword@
define stn_logon    = ~stn_user/~stn_password@~tns_alias

define rdr_user     = @rdrUsername@
define rdr_password = @rdrPassword@
define rdr_logon    = ~rdr_user/~rdr_password@~tns_alias

define fdr_user     = @fdrUsername@
define fdr_password = @fdrPassword@
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define slr_user     = @slrUsername@
define slr_password = @slrPassword@
define slr_logon    = ~slr_user/~slr_password@~tns_alias

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

conn ~stn_logon

@@grants/tables/stn/gl_account_hierarchy.sql
@@grants/tables/stn/business_type.sql
@@grants/tables/stn/execution_type.sql
@@grants/tables/stn/premium_type.sql

conn ~slr_logon

@@grants/tables/slr/slr_fak_combinations.sql
@@grants/tables/slr/slr_eba_combinations.sql
@@grants/tables/slr/slr_eba_daily_balances.sql
@@grants/tables/slr/slr_eba_bop_amounts.sql
@@grants/tables/slr/slr_fak_bop_amounts.sql
@@grants/tables/slr/slr_entity_periods.sql

conn ~fdr_logon

@@grants/tables/fdr/fr_account_lookup.sql
@@grants/tables/fdr/fr_posting_schema.sql
@@grants/tables/fdr/fr_stan_raw_acc_event.sql

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

exit