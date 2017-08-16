create or replace view stn.user_default
as
select
       max ( case when fgl.lk_match_key1 = 'GROUP_NAME'            
                  then fgl.lk_lookup_value1
             end )                                                   group_name
     , max ( case when fgl.lk_match_key1 = 'ENTITY_ID'            
                  then fgl.lk_lookup_value1
             end )                                                   entity_id
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'USER_DEFAULT'
     ;