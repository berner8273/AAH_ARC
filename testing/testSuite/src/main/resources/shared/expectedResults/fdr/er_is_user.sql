select
       isusr_id
     , isusr_name
     , isusr_lock
     , isusr_pms_pid
     , isusr_privileges
    -- , isusr_passwd
     , isusr_session_count
     , isusr_passwd_change_req
     , isusr_passwd_exp_period
     , isusr_wrong_passwd_count
     , isusr_account_lockout
  from
       er_is_user
