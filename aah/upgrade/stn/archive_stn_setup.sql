declare
nCount1  NUMBER;

begin

SELECT count(*) into nCount1 FROM dba_tables where upper(table_name) = 'CESSION_EVENT_BAK';

DBMS_OUTPUT.PUT_LINE(' count1 '||to_char(nCount1));

IF nCount1 = 0  THEN  
   execute immediate 'create table cession_event_bak as select * from cession_event where 1 = 2';
   DBMS_OUTPUT.PUT_LINE(' create' );
ELSE
    execute immediate 'truncate table cession_event_bak';
    DBMS_OUTPUT.PUT_LINE(' truncate ' );
END IF;

END;
/

declare
nCount  NUMBER;
nSavedCount NUMBER;
nDays NUMBER;


begin

select count(*) into nSavedCount from (
select t.* FROM STN.CESSION_EVENT t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - (select arct_archive_days from fdr.fr_archive_ctl where arct_table_name = 'CESSION_EVENT'));

DBMS_OUTPUT.PUT_LINE(' countSavedcount '||to_char(nSavedCount));

execute immediate 'insert into CESSION_EVENT_BAK '||q'[(SELECT t.* FROM STN.CESSION_EVENT t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - (select arct_archive_days from fdr.fr_archive_ctl where arct_table_name = 'CESSION_EVENT'))]';

select count(*) into nCount from cession_event_bak;
IF nCount = nSavedCount THEN
dbms_output.put_line(to_char(nCount)||' : '||to_char(nSavedCount));
 execute immediate 'truncate table cession_event';
 execute immediate 'insert /*+APPEND*/ into cession_event (select * from cession_event_bak)';
END IF;  

end;
/

declare
nCount1  NUMBER;

begin

 execute immediate 'alter table stn.cession_link disable constraint fk_cc_cl';
 execute immediate 'alter table stn.cession_link disable constraint fk_pc_cl';

SELECT count(*) into nCount1 FROM dba_tables where upper(table_name) = 'CESSION_BAK';

IF nCount1 = 0  THEN  
   execute immediate 'create table cession_bak as select * from cession where 1 = 2';
ELSE
    execute immediate 'truncate table cession_bak';
END IF;

END;
/

declare
nCount  NUMBER;
nSavedCount NUMBER;

begin

select count(*) into nSavedCount from (
select t.* FROM STN.cession t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - (select arct_archive_days from fdr.fr_archive_ctl where arct_table_name = 'CESSION'));

execute immediate 'insert into cession_BAK '||q'[(SELECT t.* FROM STN.cession t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - (select arct_archive_days from fdr.fr_archive_ctl where arct_table_name = 'CESSION'))]';          

select count(*) into nCount from cession_bak;
IF nCount = nSavedCount THEN
 
 execute immediate 'truncate table cession';
 execute immediate 'insert /*+APPEND*/ into cession (select * from cession_bak)';

END IF;  

commit;

execute immediate 'drop table cession_bak';
execute immediate 'drop table cession_event_bak';

end;
/