declare
  count_records integer;
begin
    select count(*) into count_records
    from stn.posting_method
    where psm_cd = 'EURGAAPADJ'
	  and rownum = 1;


if count_records = 0 then

insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'EURGAAPADJ', 'FR GAAP amounts to EURGAAPADJ ledger' );
commit;

end if;  
end;
/  