-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the users and roles which will be used AG's ETL processes.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define sys_logon = ~1
define ps_password = ~2
define read_password = ~3
define report_password = ~4
define ssis_password = ~5
define unittest_login = ~8


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

@@roles/aah_load.sql
@@roles/aah_read_only.sql
@@roles/aah_rdr.sql
@@roles/aah_glint.sql
@@users/aah_ssis.sql ssis_password
@@users/aah_read.sql read_password
@@users/aah_report.sql report_password
@@users/aah_ps.sql ps_password

begin
    for i in (
                 select
                        'alter tablespace FDR_DATA add datafile ''/oradata/APTQA/datafile/FDR_DATA_FILE_2.dbf'' size 512m autoextend on next 5m maxsize unlimited' add_datafile
                   from
                        dual
                  where
                        not exists ( select null
                                       from dba_data_files
                                      where tablespace_name = 'FDR_DATA'
                                        and file_name       like '%FDR_DATA_FILE_2.dbf' )
             )
    loop
        execute immediate i.add_datafile;
    end loop;
end;
/

exit 