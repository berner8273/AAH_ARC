    create or replace view stn.accounting_event_default
    as
    select
           max ( case when fgl.lk_match_key1 = 'ACTIVE_FLAG'
                      then fgl.lk_lookup_value1
                 end )                                               active_flag
      from
           fdr.fr_general_lookup fgl
     where
           fgl.lk_lkt_lookup_type_code = 'ACCOUNTING_EVENT_DEFAULT'
         ;