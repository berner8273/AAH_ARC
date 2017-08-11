create or replace view stn.fxr_default
as
select
       max ( case when fgl.lk_match_key1 = 'SYSTEM_INSTANCE'
                  then fgl.lk_lookup_value1
             end )                                               system_instance
     , max ( case when fgl.lk_match_key1 = 'PARTY_LEGAL'
                  then fgl.lk_lookup_value1
             end )                                               party_legal
     , cast ( max ( case when fgl.lk_match_key1 = 'NO_1_1_DAYS'
                         then fgl.lk_lookup_value1
                    end ) as number ( 38 , 0 ) )                 no_1_1_days
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'FXR_DEFAULT'
     ;