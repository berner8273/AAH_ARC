insert into fdr.fr_address ( ad_address_id , ad_ci_city_id , ad_address_clicode , ad_at_address_type_id , ad_active , ad_input_by , ad_auth_by , ad_auth_status , ad_input_time , ad_valid_from, ad_valid_to )
    values ( 2 , '1' , 'NVS' , 1 , 'A' , user , '1' , 'A' , sysdate , sysdate , sysdate + 10000 );

commit;