/* CREATE GUI USER */

accept v_user_name    char prompt 'Username to create (must match AD username):';
accept v_first_name   char prompt 'User first name:';
accept v_last_name    char prompt 'User last name:';
accept v_email        char prompt 'User email address:';
declare p_user_name  varchar2(40)  := '&v_user_name';
        p_first_name varchar2(40)  := '&v_first_name';
        p_last_name  varchar2(40)  := '&v_last_name';
        p_email      varchar2(100) := '&v_email';

begin

insert into fdr.is_user
     ( isusr_id
     , isusr_name 
     , isusr_lock 
     , isusr_pms_pid 
     , isusr_client_code 
     , isusr_privileges 
     , isusr_passwd 
     , isusr_session_count 
     , isusr_passwd_change_req 
     , isusr_passwd_exp_period 
     , isusr_passwd_last_change 
     , isusr_description 
     , isusr_wrong_passwd_count 
     , isusr_account_lockout 
     , isusr_input_by 
     , isusr_input_time 
     , isusr_action )
select
     ( select max(fiu2.isusr_id) + 1 from fdr.is_user fiu2 )
     , p_user_name 
     , fiu.isusr_lock 
     , fiu.isusr_pms_pid 
     , fiu.isusr_client_code 
     , fiu.isusr_privileges 
     , fiu.isusr_passwd 
     , fiu.isusr_session_count 
     , fiu.isusr_passwd_change_req 
     , fiu.isusr_passwd_exp_period 
     , fiu.isusr_passwd_last_change 
     , p_user_name 
     , fiu.isusr_wrong_passwd_count 
     , fiu.isusr_account_lockout 
     , fiu.isusr_input_by 
     , fiu.isusr_input_time 
     , fiu.isusr_action
  from
       fdr.is_user fiu
 where
       isusr_name = 'fdr_user'
;

insert into fdr.is_groupuser
     ( isgu_grp_ref
     , isgu_usr_ref )
select
       ( select fig2.isgrp_id from is_group fig2    where fig2.isgrp_name = 'Microgen' )
     , ( select fiu2.isusr_id from fdr.is_user fiu2 where fiu2.isusr_name = p_user_name )
  from
       dual
;

insert into gui.t_ui_user_details
     ( user_id 
     , user_name 
     , user_first_name 
     , user_last_name 
     , user_department 
     , user_email_address 
     , user_entity 
     , user_input_by 
     , user_input_time 
     , user_action 
     , user_use_validity_period 
     , user_valid_from 
     , user_valid_to )
select
     ( select fiu2.isusr_id from fdr.is_user fiu2 where fiu2.isusr_name = p_user_name )
     , p_user_name 
     , p_first_name 
     , p_last_name 
     , tuud.USER_DEPARTMENT 
     , p_email 
     , tuud.USER_ENTITY 
     , tuud.USER_INPUT_BY 
     , tuud.USER_INPUT_TIME 
     , tuud.USER_ACTION 
     , tuud.USER_USE_VALIDITY_PERIOD 
     , tuud.USER_VALID_FROM 
     , tuud.USER_VALID_TO 
  from
       gui.t_ui_user_details tuud
 where
       user_name = 'fdr_user'
;

insert into gui.t_ui_user_roles
     ( user_id 
     , role_id 
     , ur_input_by 
     , ur_input_time 
     , ur_action )
select
     ( select fiu2.ISUSR_ID from fdr.is_user fiu2 where fiu2.ISUSR_NAME = p_user_name ) 
     , 'role.administrator'
     , user
     , sysdate
     , 'I'
  from
       dual
;

commit;

end;
/