declare
   c int;
begin
   select count(*) into c from user_tables where table_name = upper('cev_identified_record');
   if c = 1 then
      execute immediate 'drop table cev_identified_record';
   end if;
   select count(*) into c from all_views where view_name = upper('cession_event_reversal_hist');
   if c = 1 then
      execute immediate 'drop view cession_event_reversal_hist';
   end if;         
end;
/
commit;

create table stn.cev_identified_record
(
    row_sid number ( 38 , 0 ) not null
,   constraint pk_cev_ir primary key ( row_sid )
);
commit;
/

@@../aahCustom/aahStandardisation/src/main/db/views/stn/cession_event_reversal_hist.sql
