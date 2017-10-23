-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which involve reporting.
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

conn ~rdr_logon

drop view rdr.rrv_account_lookup;
drop view rdr.rrv_accounting_basis_ledger;
drop view rdr.rrv_accounting_event;
drop view rdr.rrv_accounting_event_hierarchy;
drop view rdr.rrv_business_unit;
drop view rdr.rrv_combo_edit_rules;
drop view rdr.rrv_department;
drop view rdr.rrv_fx_rates;
drop view rdr.rrv_gl_account_hierarchy;
drop view rdr.rrv_gl_accounts;
drop view rdr.rrv_insurance_policy;
drop view rdr.rrv_insurance_policy_fx;
drop view rdr.rrv_ledger;
drop view rdr.rrv_legal_entity_ledger;
drop view rdr.rrv_posting_driver;
drop view rdr.rrv_program;
drop view rdr.rrv_slr_eba_combinations_ag;
drop view rdr.rrv_slr_eba_daily_balances_ag;
drop view rdr.rrv_slr_fak_combinations_ag;
drop view rdr.rrv_slr_fak_daily_balances_ag;
drop view rdr.rrv_slr_jrnl_lines_ag;
drop view rdr.rrv_tax_jurisdiction;

conn ~stn_logon

revoke select   on stn.gl_account_hierarchy    from rdr;

conn ~slr_logon

revoke select   on slr.slr_fak_combinations    from rdr;
revoke select   on slr.slr_eba_combinations    from rdr;
revoke select   on slr.slr_eba_daily_balances  from rdr;

conn ~fdr_logon

revoke select   on fdr.fr_account_lookup       from rdr;
revoke select   on fdr.fr_posting_schema       from rdr;

exit