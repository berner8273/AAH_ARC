declare
  count_records integer;
begin
    select count(*) into count_records
    from stn.posting_method_ledger
    where psm_id = ( select psm_id from stn.posting_method where psm_cd = 'EURGAAPADJ' )
	  and input_basis_id = ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' )
	  and output_basis_id = ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' )
	  and ledger_id = ( select ledger_id from stn.posting_ledger where ledger_cd = 'EURGAAPADJ' )
	  and fin_calc_id = ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )
	  and rownum = 1
	  ;


if count_records = 0 then
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) 
values ( ( select psm_id from stn.posting_method where psm_cd = 'EURGAAPADJ' ),
         ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' ), 
         ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' ), 
         ( select ledger_id from stn.posting_ledger where ledger_cd = 'EURGAAPADJ' ),
         ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' ),
         'NULL' );
commit;

end if;  
end;
/  

declare
  count_records integer;
begin
    select count(*) into count_records
    from stn.posting_method_ledger
    where psm_id = ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' )
	  and input_basis_id = ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' )
	  and output_basis_id = ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' )
	  and ledger_id = ( select ledger_id from stn.posting_ledger where ledger_cd = 'EURGAAPADJ' )
	  and fin_calc_id = ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )
	  and rownum = 1
	  ;


if count_records = 0 then
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) 
values ( ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ),
         ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' ), 
         ( select basis_id from stn.posting_accounting_basis where basis_cd = 'FR_RPT' ), 
         ( select ledger_id from stn.posting_ledger where ledger_cd = 'EURGAAPADJ' ),
         ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' ),
         'NULL' );
commit;

end if;  
end;
/  