create or replace view stn.pol_default
as
select
       max ( case when fgl.lk_match_key1 = 'SYSTEM_INSTANCE'
                  then fgl.lk_lookup_value1
             end )                                                  system_instance
     , max ( case when fgl.lk_match_key1 = 'RATE_TYPE_PREFIX'
                  then fgl.lk_lookup_value1
             end )                                                  rate_type_prefix
     , max ( case when fgl.lk_match_key1 = 'PARTY_LEGAL'
                  then fgl.lk_lookup_value1
             end )                                                  party_legal
     , max ( case when fgl.lk_match_key1 = 'POLICY_TAX'
                  then fgl.lk_lookup_value1
             end )                                                  policy_tax
     , max ( case when fgl.lk_match_key1 = 'BUY_OR_SELL'
                  then fgl.lk_lookup_value1
             end )                                                  buy_or_sell
     , max ( case when fgl.lk_match_key1 = 'POLICY_HOLDER_ADDRESS'
                  then fgl.lk_lookup_value1
             end )                                                  policy_holder_address
     , max ( case when fgl.lk_match_key1 = 'INSTRUMENT_TYPE'
                  then fgl.lk_lookup_value1
             end )                                                  instrument_type
     , max ( case when fgl.lk_match_key1 = 'EVENT_CODE'
                  then fgl.lk_lookup_value1
             end )                                                  event_code
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'POL_DEFAULT'
     ;