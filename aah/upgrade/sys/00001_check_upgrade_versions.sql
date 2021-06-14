declare
    c_prior_upgrade    constant varchar2 ( 50 char )  := '1-8-1';
    c_current_upgrade  constant varchar2 ( 50 char )  := '1-8-2';
 --   c_core_version     constant varchar2 ( 50 char )  := 'V4.10b2.6 /O';
    c_core_version     constant varchar2 ( 50 char )  := 'V4.40b5 /O';
     v_custom_error_msg varchar2 ( 300 char ) := 'The upgrade must be applied to AAH customized version ' || c_prior_upgrade || ' or ' || c_current_upgrade || ', this environment is version ';
    v_core_error_msg   varchar2 ( 300 char ) := 'The upgrade must be applied to AAH core version ' || c_core_version || ', this environment is version ';
    v_version_custom   varchar2 ( 50 char );
    v_version_core     varchar2 ( 50 char );
    wrong_aah_custom_version exception;
    wrong_aah_core_version   exception;
    pragma exception_init ( wrong_aah_custom_version , -20001 );
    pragma exception_init ( wrong_aah_core_version   , -20002 );
begin
    /* Check AAH custom version */
    begin
        select
               dbuh_version
               into
               v_version_custom
          from (
                   select
                          dbuh_version
                        , row_number () over ( order by dbuh_start_date desc ) start_dt_rank
                     from
                          fdr.fr_db_upgrade_history
                    where
                          dbuh_description = 'Assured Guaranty'
               )
         where
               start_dt_rank = 1
             ;
        v_custom_error_msg := v_custom_error_msg || v_version_custom;
        if v_version_custom not in ( c_prior_upgrade , c_current_upgrade ) then
            dbms_output.put_line ( v_custom_error_msg );
            raise_application_error ( -20001 , v_custom_error_msg );
        end if;
    end;
    /* Check AAH core version */
    begin
        select
               dbuh_version
               into
               v_version_core
          from (
                   select
                          dbuh_version
                        , row_number () over ( order by dbuh_start_date desc , dbuh_version desc ) start_dt_rank
                     from
                          fdr.fr_db_upgrade_history
                    where
                          dbuh_description <> 'Assured Guaranty'
               )
         where
               start_dt_rank = 1
             ;
        v_core_error_msg := v_core_error_msg || v_version_core;
        if v_version_core != c_core_version then
            dbms_output.put_line ( v_core_error_msg );
            raise_application_error ( -20002 , v_core_error_msg );
        end if;
    end;
end;
/