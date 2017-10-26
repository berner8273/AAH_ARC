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
define stn_user     = @stnUsername@
define stn_password = @stnPassword@
define stn_logon    = ~stn_user/~stn_password@~tns_alias

define fdr_user     = @fdrUsername@
define fdr_password = @fdrPassword@
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define slr_user     = @slrUsername@
define slr_password = @slrPassword@
define slr_logon    = ~slr_user/~slr_password@~tns_alias

conn ~stn_logon
@@grants/tables/stn/business_type.sql
@@grants/tables/stn/insurance_policy.sql

conn ~fdr_logon

delete from fdr.fr_account_lookup_param;
@@data/fdr/fr_gaap.sql
@@data/fdr/fr_posting_schema.sql
@@data/fdr/fr_account_lookup_param.sql
@@data/fdr/fr_financial_amount.sql

conn ~slr_logon

delete from slr.slr_entity_proc_group;
commit;

@@data/slr/slr_ledgers.sql
@@data/slr/slr_entity_sets.sql
@@data/slr/slr_fak_segment_3.sql
@@data/slr/slr_fak_segment_4.sql
@@data/slr/slr_fak_segment_5.sql
@@data/slr/slr_fak_segment_6.sql
@@data/slr/slr_fak_segment_7.sql
@@data/slr/slr_fak_segment_8.sql
@@packages/slr/slr_pkg.hdr
@@packages/slr/slr_pkg.bdy

exit