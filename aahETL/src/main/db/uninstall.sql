-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to uninstall the users and roles which will be used AG's ETL processes.
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
                        'alter system kill session ''' || vs.sid || ',' || vs.serial# || ''' immediate' kill_stmt
                   from
                        v$session vs
                  where 
                        trim ( lower ( username ) ) in (
                                                         trim ( lower ( 'aah_ssis' ) )
                                                       , trim ( lower ( 'aah_read' ) )
                                                       , trim ( lower ( 'aah_report' ) )
                                                       , trim ( lower ( 'aah_ps' ) )
                                                       )
             )
    loop
        execute immediate i.kill_stmt;
    end loop;
end;
/

begin
    for i in (
                 select
                        'drop user ' || username || ' cascade' drop_stmt
                   from
                        dba_users
                  where
                        trim ( lower ( username ) ) in (
                                                         trim ( lower ( 'aah_ssis' ) )
                                                       , trim ( lower ( 'aah_read' ) )
                                                       , trim ( lower ( 'aah_report' ) )
                                                       , trim ( lower ( 'aah_ps' ) )
                                                       )
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
                        trim ( lower ( role ) ) in (
                                                     trim ( lower ( 'aah_load' ) )
                                                   , trim ( lower ( 'aah_read_only' ) )
                                                   , trim ( lower ( 'aah_rdr' ) )
                                                   , trim ( lower ( 'aah_glint' ) )
                                                   )
             )
    loop
        execute immediate i.drop_stmt;
    end loop;
end;
/

exit