-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
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

define slr_user     = @slrUsername@
define slr_password = @slrPassword@
define slr_logon    = ~slr_user/~slr_password@~tns_alias

conn ~fdr_logon

delete from fdr.fr_entity_schema;
delete from fdr.fr_gaap;
delete from fdr.fr_posting_schema;
delete from fdr.fr_lpg_config;
delete from fdr.fr_account_lookup_param;
delete from fdr.fr_financial_amount;

conn ~slr_logon

delete from slr.slr_entities;
delete from slr.slr_eba_definitions;
delete from slr.slr_fak_definitions;
delete from slr.slr_fak_definitions;
delete from slr.slr_entity_grace_days;
delete from slr.slr_ledgers;
delete from slr.slr_entity_sets;
commit;

exit