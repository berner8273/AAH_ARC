-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which involve reporting.
--         :
-- -----------------------------------------------------------------------------------------

--whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@

define rdr_user     = @rdrUsername@
define rdr_password = @rdrPassword@
define rdr_logon    = ~rdr_user/~rdr_password@~tns_alias

conn ~rdr_logon

drop view rdr.rrv_accounting_basis_ledger;
drop view rdr.rrv_legal_entity_ledger;

exit