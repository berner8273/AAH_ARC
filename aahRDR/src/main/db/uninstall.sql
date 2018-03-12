-- -----------------------------------------------------------------------------------------
-- filename: uninstall;
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

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

conn ~rdr_logon

drop view rdr.rrv_ag_account_lookup;
drop view rdr.rrv_ag_accounting_basis_ledger;
drop view rdr.rrv_ag_accounting_event;
drop view rdr.rrv_ag_accounting_event_imp;
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
drop view rdr/rrv_ag_org_hierarchy_type;
drop view rdr/rrv_ag_org_network;
drop view rdr/rrv_ag_org_node_structure;
drop view rdr/rrv_ag_org_hier_levels;


conn ~stn_logon

revoke select   on stn.gl_account_hierarchy       from rdr;
revoke select   on stn.business_type              from rdr;
revoke select   on stn.execution_type             from rdr;
revoke select   on stn.cession_event_premium_type from rdr;
revoke select   on stn.policy_premium_type        from rdr;

conn ~slr_logon

revoke select   on slr.slr_fak_combinations    from rdr;
revoke select   on slr.slr_eba_combinations    from rdr;
revoke select   on slr.slr_fak_daily_balances  from rdr;
revoke select   on slr.slr_eba_daily_balances  from rdr;
revoke select   on slr.slr_eba_bop_amounts     from rdr;
revoke select   on slr.slr_fak_bop_amounts     from rdr;

conn ~fdr_logon

revoke select   on fdr.fr_account_lookup       from rdr;
revoke select   on fdr.fr_posting_schema       from rdr;
revoke select   on fdr.fr_stan_raw_acc_event   from rdr;

conn ~gui_logon

revoke select   on gui.t_ui_role_tasks         from rdr;
revoke select   on gui.t_ui_user_details       from rdr;
revoke select   on gui.t_ui_user_roles         from rdr;

exit