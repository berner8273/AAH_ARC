-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
--         :
-- -----------------------------------------------------------------------------------------

--whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@
define stn_user     = @stnUsername@
define stn_password = @stnPassword@
define stn_logon    = ~stn_user/~stn_password@~tns_alias

define fdr_user     = @fdrUsername@
define fdr_password = @fdrPassword@
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define slr_user     = @slrUsername@
define slr_password = @slrPassword@
define slr_logon    = ~slr_user/~slr_password@~tns_alias

conn ~fdr_logon

delete from fdr.fr_entity_schema;
delete from fdr.fr_gaap;
delete from fdr.fr_posting_schema;
delete from fdr.fr_lpg_config;
delete from fdr.fr_account_lookup_param;
delete from fdr.fr_account_lookup;
delete from fdr.fr_posting_driver;
delete from fdr.fr_financial_amount;
delete from fdr.fr_acc_event_type    where aet_input_by not in ( 'FDR Create' , 'SPS' );
delete from fdr.fr_gl_account_lookup where exists ( select null from fdr.fr_gl_account ga where ga.ga_input_by = 'AG_SEED' and gal.gal_ga_account_code = ga.ga_account_code );
delete from fdr.fr_gl_account        where ga_input_by = 'AG_SEED';
commit;

conn ~slr_logon

drop package body slr.slr_pkg;
drop package      slr.slr_pkg;

delete from slr.slr_entities;
delete from slr.slr_eba_definitions;
delete from slr.slr_fak_definitions;
delete from slr.slr_fak_definitions;
delete from slr.slr_entity_grace_days;
delete from slr.slr_ledgers;
delete from slr.slr_entity_sets;
delete from slr.slr_fak_segment_8;
delete from slr.slr_fak_segment_7;
delete from slr.slr_fak_segment_6;
delete from slr.slr_fak_segment_5;
delete from slr.slr_fak_segment_4;
delete from slr.slr_fak_segment_3;
commit;

conn ~stn_logon
revoke select on stn.business_type      from slr;
revoke select on stn.insurance_policy   from slr;
revoke select on stn.execution_type   from slr;

exit