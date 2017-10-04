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

define rdr_user     = @rdrUsername@
define rdr_password = @rdrPassword@
define rdr_logon    = ~rdr_user/~rdr_password@~tns_alias

conn ~rdr_logon

@@views/rdr/rrv_accounting_basis_ledger.sql
@@views/rdr/rrv_legal_entity_ledger.sql

exit