declare
  count_records integer;
begin
    select count(*) into count_records
    from stn.posting_accounting_basis
    where basis_cd = 'FR_RPT'
	  and rownum = 1;


if count_records = 0 then

insert into stn.posting_accounting_basis ( basis_cd , basis_typ , basis_grp ) values ( 'FR_RPT'  , 'GAAP' , 'EC' );
commit;

end if;  
end;
/  