declare
    v_version         varchar2 ( 50 char ) := '1.10';
    v_version_exists  varchar2 ( 1 char );
begin
    select
           version_exists
           into
           v_version_exists
      from (
               select
                      case
                        when exists (select null
                                       from fdr.fr_db_upgrade_history
                                      where dbuh_description = 'Assured Guaranty'
                                        and dbuh_version     = v_version) 
                        then 'Y'
                        else 'N'
                      end                  version_exists      
                 from
                      dual
           );
    if v_version_exists = 'Y' then
        update fdr.fr_db_upgrade_history set dbuh_start_date = current_date where dbuh_version = v_version;
    elsif v_version_exists = 'N' then
        insert into fdr.fr_db_upgrade_history ( dbuh_db_script_name , dbuh_script_type , dbuh_version , dbuh_status , dbuh_start_date , dbuh_schema , dbuh_description , dbuh_location_info )
            values ( v_version , 'SQLPLUS' , v_version , 'FINISHED' , current_date , 'FDR' , 'Assured Guaranty' , '-' );
    end if;
commit;
end;
/