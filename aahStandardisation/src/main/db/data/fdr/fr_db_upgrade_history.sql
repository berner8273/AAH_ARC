insert into fdr.fr_db_upgrade_history ( dbuh_db_script_name , dbuh_script_type , dbuh_version , dbuh_status , dbuh_start_date , dbuh_schema , dbuh_description , dbuh_location_info )
    values ( '1-1-0' , 'SQLPLUS' , '1-1-0', 'FINISHED', current_date , 'FDR' , 'Assured Guaranty' , '-' );
commit;