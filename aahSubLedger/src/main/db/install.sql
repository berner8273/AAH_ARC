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
define fdr_user     = @fdrUsername@
define fdr_password = @fdrPassword@
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define slr_user     = @slrUsername@
define slr_password = @slrPassword@
define slr_logon    = ~slr_user/~slr_password@~tns_alias

conn ~fdr_logon

@@data/fdr/fr_gaap.sql
@@data/fdr/fr_posting_schema.sql

conn ~slr_logon

delete from slr.slr_entity_proc_group;
commit;

@@data/slr/slr_ledgers.sql
@@data/slr/slr_entity_sets.sql

exit