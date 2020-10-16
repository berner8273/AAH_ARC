
declare
  count_records integer;
begin
	select count(*) 
	INTO count_records
	from fdr.fr_gl_account
	where ga_account_code IN ( 
	'14400320-02',
	'14400330-02')	;    
	IF count_records > 0  THEN
		-- clear records created by fr_gl_account trigger af any
		DELETE FROM fdr.fr_gl_account_lookup 
		WHERE GAL_GA_ACCOUNT_CODE
		IN ( '14400320-02',
		'14400330-02')		;
    
		DELETE FROM fdr.fr_gl_account 
		WHERE ga_account_code IN ( 
		'14400320-02',
		'14400330-02');
		commit;
  end if;  
end;
/
insert into fdr.fr_gl_account ( ga_account_code , ga_account_name , ga_account_type , ga_account_adjustment_type , ga_active , ga_auth_by , ga_auth_status , ga_input_time , ga_valid_from , ga_valid_to , ga_input_by , ga_client_text2 , ga_client_text3 , ga_client_text4 , ga_revaluation_ind , ga_account_type_flag , ga_position_flag ) values ( '14400330-02' , 'Ceded Ceding Comm ADAC AFFIL' , 'B' , '0' , 'A' , 'Client Static' , 'A' , current_date , to_date ( '01/01/2010' , 'mm/dd/yyyy' ) , to_date ( '12/31/2099' , 'mm/dd/yyyy' ) , 'AG_SEED' , 'A' , 'GL' , '14400330' , 'N' , 'B' , 'N' );
commit;