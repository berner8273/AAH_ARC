select
       iu.isusr_id
     , iu.isusr_name
     , iu.isusr_lock
     , iu.isusr_pms_pid
     , iu.isusr_privileges
     --, iu.isusr_passwd
     , iu.isusr_session_count
     , iu.isusr_passwd_change_req
     , iu.isusr_passwd_exp_period
     , iu.isusr_wrong_passwd_count
     , iu.isusr_account_lockout
  from
       fdr.is_user iu
