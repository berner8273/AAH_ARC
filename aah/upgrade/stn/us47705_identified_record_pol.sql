declare
   c int;
begin
   select count(*) into c from user_tables where table_name = upper('identified_record_pol');
   if c = 1 then
      execute immediate 'drop table identified_record_pol';
   end if;       
end;
/
commit;

create table stn.identified_record_pol
(
    row_sid number ( 38 , 0 ) not null
,   constraint pk_pol_ir primary key ( row_sid )
);
commit;
/