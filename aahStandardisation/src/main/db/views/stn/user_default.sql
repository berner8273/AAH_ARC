create or replace view stn.user_default
as
select
       max ( case when fgl.lk_match_key1 =        'GROUP_NAME'            
                  then fgl.lk_lookup_value1
             end )                                                      group_name
     , max ( case when fgl.lk_match_key1 =        'DEPARTMENT_ID'            
                  then fgl.lk_lookup_value1
             end )                                                      department_id
     , max ( case when fgl.lk_match_key1 =        'ENTITY_ID'            
                  then fgl.lk_lookup_value1
             end )                                                      entity_id
     , cast ( max ( case when fgl.lk_match_key1 = 'LOCK_FLAG'         
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                lock_flag
     , max ( case when fgl.lk_match_key1 =        'PASSWD'            
                  then fgl.lk_lookup_value1
             end )                                                      passwd
     , cast ( max ( case when fgl.lk_match_key1 = 'PMS_PID'           
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                pms_pid
     , cast ( max ( case when fgl.lk_match_key1 = 'PRIVILEGES_FLAG'   
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                privileges_flag
     , cast ( max ( case when fgl.lk_match_key1 = 'SESSION_COUNT'     
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                session_count
     , cast ( max ( case when fgl.lk_match_key1 = 'PASSWD_CHANGE_REQ' 
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                passwd_change_req
     , cast ( max ( case when fgl.lk_match_key1 = 'PASSWD_EXP_PERIOD' 
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                passwd_exp_period
     , cast ( max ( case when fgl.lk_match_key1 = 'WRONG_PASSWD_COUNT'
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                wrong_passwd_count
     , cast ( max ( case when fgl.lk_match_key1 = 'ACCOUNT_LOCKOUT'   
                  then fgl.lk_lookup_value1
             end ) as number ( 1 , 0 ) )                                account_lockout
     , max ( case when fgl.lk_match_key1 =        'PARTY_TYPE'            
                  then fgl.lk_lookup_value1
             end )                                                      party_type
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'USER_DEFAULT'
     ;