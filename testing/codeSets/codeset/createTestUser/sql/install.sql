-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to create the user which the automated unit test suite executes as.
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

create user @databaseTestUsername@ identified by @databaseTestPassword@;

create role automated_unit_test;

grant select on dba_objects to automated_unit_test;

grant create session , create table , drop any table to automated_unit_test;

begin
    for i in ( select owner , table_name from dba_tables where upper ( owner ) in ( 'STN' , 'FDR' , 'GUI' , 'SLR' , 'RDR' , 'SLA' ) ) loop
        execute immediate 'grant select, update, delete, insert, alter on ' || i.owner || '.' || i.table_name || ' to automated_unit_test';
        dbms_output.put_line ( 'grant select, update, delete on ' || i.owner || '.' || i.table_name || ' to automated_unit_test' ); 
    end loop;

    declare
        v_owner     dba_views.owner%type;
        v_view_name dba_views.view_name%type;
    begin
        for i in ( select owner , view_name from dba_views where upper ( owner ) in ( 'STN' , 'FDR' , 'GUI' , 'SLR' , 'RDR' , 'SLA' ) ) loop
            v_owner     := i.owner;
            v_view_name := i.view_name;
            execute immediate 'grant select on ' || i.owner || '.' || i.view_name || ' to automated_unit_test';
            dbms_output.put_line ( 'grant select on ' || i.owner || '.' || i.view_name || ' to automated_unit_test' ); 
        end loop;
    exception
        when others then
            dbms_output.put_line ( 'FAIL :: grant select on ' || v_owner || '.' || v_owner || ' to automated_unit_test' );
    end;

    for i in ( select distinct owner, object_name from dba_procedures where upper ( owner ) in ( 'STN' , 'FDR' , 'GUI' , 'SLR' , 'RDR' , 'SLA' ) and object_type in ( 'PROCEDURE' , 'PACKAGE' , 'FUNCTION' ) ) loop
        execute immediate 'grant execute on ' || i.owner || '.' || i.object_name || ' to automated_unit_test';
        dbms_output.put_line ( 'grant execute on ' || i.owner || '.' || i.object_name || ' to automated_unit_test' ); 
    end loop;
end;
/

grant unlimited tablespace to @databaseTestUsername@;

grant automated_unit_test to @databaseTestUsername@;

exit