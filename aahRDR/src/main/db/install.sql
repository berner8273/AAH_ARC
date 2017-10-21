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

conn ~stn_logon

@@grants/tables/stn/gl_account_hierarchy.sql

conn ~slr_logon

@@grants/tables/slr/slr_fak_combinations.sql
@@grants/tables/slr/slr_eba_combinations.sql
@@grants/tables/slr/slr_eba_daily_balances.sql

conn ~fdr_logon

@@grants/tables/fdr/fr_account_lookup.sql

conn ~rdr_logon

@@views/rdr/rrv_account_lookup.sql
@@views/rdr/rrv_accounting_basis_ledger.sql
@@views/rdr/rrv_accounting_event.sql
@@views/rdr/rrv_accounting_event_hierarchy.sql
@@views/rdr/rrv_business_unit.sql
@@views/rdr/rrv_combo_edit_rules.sql
@@views/rdr/rrv_department.sql
@@views/rdr/rrv_fx_rates.sql
@@views/rdr/rrv_gl_account_hierarchy.sql
@@views/rdr/rrv_gl_accounts.sql
@@views/rdr/rrv_insurance_policy.sql
@@views/rdr/rrv_insurance_policy_fx.sql
@@views/rdr/rrv_ledger.sql
@@views/rdr/rrv_legal_entity_ledger.sql
@@views/rdr/rrv_posting_driver.sql
@@views/rdr/rrv_program.sql
@@views/rdr/rrv_slr_eba_combinations_ag.sql
@@views/rdr/rrv_slr_fak_combinations_ag.sql
@@views/rdr/rrv_slr_eba_daily_balances_ag.sql
@@views/rdr/rrv_slr_fak_daily_balances_ag.sql
@@views/rdr/rrv_slr_jrnl_lines_ag.sql
@@views/rdr/rrv_tax_jurisdiction.sql

exit