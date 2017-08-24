create or replace view stn.pol_default
as
select
       max ( case when fgl.lk_match_key1 = 'SYSTEM_INSTANCE'
                  then fgl.lk_lookup_value1
             end )                                               system_instance
     , max ( case when fgl.lk_match_key1 = 'RATE_TYPE_PREFIX'
                  then fgl.lk_lookup_value1
             end )                                               rate_type_prefix
     , max ( case when fgl.lk_match_key1 = 'PARTY_LEGAL'
                  then fgl.lk_lookup_value1
             end )                                               party_legal
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'POL_DEFAULT'
     ;