create or replace view stn.user_default
as
select
       max ( case when fgl.lk_match_key1 = 'GROUP_NAME'            
                  then fgl.lk_lookup_value1
             end )                                                   group_name
     , max ( case when fgl.lk_match_key1 = 'ENTITY_ID'            
                  then fgl.lk_lookup_value1
             end )                                                   entity_id
     , max ( case when fgl.lk_match_key1 = 'DEPARTMENT_ID'            
                  then fgl.lk_lookup_value1
             end )                                                   department_id
     , max ( case when fgl.lk_match_key1 = 'DEFAULT_PW'            
                  then fgl.lk_lookup_value1
             end )                                                   default_pw
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'USER_DEFAULT'
     ;