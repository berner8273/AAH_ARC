create or replace view stn.gla_default
as
select
       cast ( max ( case when fgl.lk_match_key1 = 'ADJUSTMENT_TYPE'
                         then fgl.lk_lookup_value1
                    end ) as number ( 1 , 0 ) )                      adjustment_type
     , max ( case when fgl.lk_match_key1 = 'ACCOUNT_GENUS'
                  then fgl.lk_lookup_value1
                  end )                                              account_genus
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'GLA_DEFAULT'
     ;