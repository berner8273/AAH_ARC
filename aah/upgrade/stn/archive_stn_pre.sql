declare
nCount1  NUMBER;

begin

SELECT count(*) into nCount1 FROM dba_tables where table_name = 'CESSION_EVENT_BAK';

IF nCount1 = 0  THEN  
   execute immediate 'create table cession_event_bak as select * from cession_event where 1 = 2';
ELSE
    execute immediate 'truncate table cession_event_bak';
END IF;

END;

declare
nCount  NUMBER;
nSavedCount NUMBER;

begin

select count(*) into nSavedCount from (
select t.* FROM STN.CESSION_EVENT t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - 182);

execute immediate 'insert into CESSION_EVENT_BAK '||q'[(SELECT t.* FROM STN.CESSION_EVENT t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - 182)]';

select count(*) into nCount from cession_event_bak;
IF nCount = nSavedCount THEN
 execute immediate 'truncate table cession_event';
 execute immediate 'insert /*+APPEND*/ into cession_event (select * from cession_event_bak)';
END IF;  

end;

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

declare
nCount  NUMBER;
nSavedCount NUMBER;

begin

select count(*) into nSavedCount from (
select t.* FROM STN.cession t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - 182);

execute immediate 'insert into cession_bak '||q'[(SELECT t.* FROM STN.cession t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts > SYSDATE  - 182)]';          

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