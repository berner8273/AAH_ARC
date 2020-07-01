-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to drop the user which the automated unit test suite executes as.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@
define sys_user     = @sysUsername@
define sys_password = @sysPassword@
define sys_logon    = ~sys_user/~sys_password@~tns_alias

conn ~sys_logon as sysdba

begin
    for i in (
                 select
                        'drop user ' || username || ' cascade' drop_stmt
                   from
                        dba_users
                  where
                        trim ( lower ( username ) ) = trim ( lower ( '@databaseTestUsername@' ) ) 
             )
    loop
        execute immediate i.drop_stmt;
    end loop;
end;
/

begin
    for i in (
                 select
                        'drop role ' || role drop_stmt
                   from
                        dba_roles
                  where
                        trim ( lower ( role ) ) = trim ( lower ( 'automated_unit_test' ) ) 
             )
    loop
        execute immediate i.drop_stmt;
    end loop;
end;
/

exit