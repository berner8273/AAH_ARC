declare
  count_records integer;
begin
    select count(*) into count_records
    from stn.posting_ledger
    where ledger_cd = 'EURGAAPADJ'
	  and rownum = 1;


if count_records = 0 then

insert into stn.posting_ledger ( ledger_cd ) values ( 'EURGAAPADJ' );
commit;

end if;  
end;
/  