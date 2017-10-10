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

conn ~stn_logon

@@grants/tables/stn/gl_account_hierarchy.sql

conn ~rdr_logon

@@views/rdr/rrv_accounting_basis_ledger.sql
@@views/rdr/rrv_gl_account_hierarchy.sql
@@views/rdr/rrv_legal_entity_ledger.sql
@@views/rdr/rrv_slr_jrnl_lines_ag.sql

exit