create or replace view stn.ledger_default
as
select
       max ( case when fgl.lk_match_key1 = 'ACTIVE_FLAG'
                  then fgl.lk_lookup_value1
             end )                                               active_flag
     , max ( case when fgl.lk_match_key1 = 'LEDGER_GROUP'
                  then fgl.lk_lookup_value1
             end )                                               ledger_group
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'LEDGER_DEFAULT'
     ;