update fdr.fr_general_codes set gc_client_text1 = 'In Error'
where gc_gct_code_type_id = 'JOURNAL_STATUS' and gc_general_code_id = 'E';
update fdr.fr_general_codes set gc_client_text1 = 'In Progress (Manual Only)'
where gc_gct_code_type_id = 'JOURNAL_STATUS' and gc_general_code_id = 'M';
update fdr.fr_general_codes set gc_client_text1 = 'Awaiting Authorisation'
where gc_gct_code_type_id = 'JOURNAL_STATUS' and gc_general_code_id = 'R';

declare
  count_records integer;
begin
  select count(*) into count_records
    from fdr.fr_general_codes
where gc_gct_code_type_id = 'JOURNAL_STATUS' and gc_general_code_id = 'F';
    
  if count_records = 0 then

    insert into fdr.fr_general_codes ( gc_general_code_id , gc_gct_code_type_id , gc_client_code , gc_client_text1 , gc_active ) values ( 'F' , 'JOURNAL_STATUS'       , 'F' , 'Rejected'             				, 'A' );
	COMMIT;

  end if;  
end;
/

declare
  count_records integer;
begin
  select count(*) into count_records
    from fdr.fr_general_codes
where gc_gct_code_type_id = 'JOURNAL_STATUS' and gc_general_code_id = 'X';
    
  if count_records = 0 then

    insert into fdr.fr_general_codes ( gc_general_code_id , gc_gct_code_type_id , gc_client_code , gc_client_text1 , gc_active ) values ( 'X' , 'JOURNAL_STATUS'       , 'X' , 'Critical Error'             		, 'A' );
	COMMIT;

  end if;  
end;
/

declare
  count_records integer;
begin
  select count(*) into count_records
    from fdr.fr_general_codes
where gc_gct_code_type_id = 'JOURNAL_STATUS' and gc_general_code_id = 'Q';
    
  if count_records = 0 then

    insert into fdr.fr_general_codes ( gc_general_code_id , gc_gct_code_type_id , gc_client_code , gc_client_text1 , gc_active ) values ( 'Q' , 'JOURNAL_STATUS'       , 'Q' , 'Queued for Posting'             	, 'A' );
	COMMIT;

  end if;  
end;
/

commit;