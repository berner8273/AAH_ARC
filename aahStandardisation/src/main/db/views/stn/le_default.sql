create or replace view stn.le_default
as
select
       max ( case when fgl.lk_match_key1 = 'SYSTEM_INSTANCE'
                  then fgl.lk_lookup_value1
             end )                                               system_instance
     , max ( case when fgl.lk_match_key1 = 'ACTIVE_FLAG'
                  then fgl.lk_lookup_value1
             end )                                               active_flag
     , max ( case when fgl.lk_match_key1 = 'INTERNAL_EXTERNAL_IND'
                  then fgl.lk_lookup_value1
             end )                                               internal_external_ind
     , max ( case when fgl.lk_match_key1 = 'ORG_NODE_TYPE'
                  then fgl.lk_lookup_value1
             end )                                               org_node_type
     , max ( case when fgl.lk_match_key1 = 'BASE_CCY'
                  then fgl.lk_lookup_value1
             end )                                               base_ccy
     , cast ( max ( case when fgl.lk_match_key1 = 'NO_GRACE_DAYS'
                         then fgl.lk_lookup_value1
                    end ) as number ( 38 , 0 ) )                 no_grace_days
     , cast ( max ( case when fgl.lk_match_key1 = 'SLR_LPG_ID'
                         then fgl.lk_lookup_value1
                    end ) as number ( 38 , 0 ) )                 slr_lpg_id
     , max ( case when fgl.lk_match_key1 = 'EPG_ID'
                  then fgl.lk_lookup_value1
             end )                                               epg_id
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'LE_DEFAULT'
     ;