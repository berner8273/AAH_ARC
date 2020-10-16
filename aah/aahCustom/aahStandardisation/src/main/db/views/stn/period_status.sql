create or replace view stn.period_status
as
select
       fgl.lk_match_key1                                    event_class
     , fgl.lk_match_key2                                    business_year
     , lpad( lk_match_key3 , 2 , '0' )                      business_month
     , fgl.lk_match_key2 || lpad( lk_match_key3 , 2 , '0' ) period
     , fgl.lk_lookup_value1                                 status
     , to_date( fgl.lk_lookup_value2 , 'DD-MON-YYYY' )      period_start
     , to_date( fgl.lk_lookup_value3 , 'DD-MON-YYYY' )      period_end
  from
       fdr.fr_general_lookup fgl
  join ( select
                min( fgl2.lk_match_key2 || lpad( lk_match_key3 , 2 , '0') ) min_period
              , fgl2.lk_match_key1                                          event_class
           from
                fdr.fr_general_lookup fgl2
          where
                fgl2.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
            and fgl2.lk_lookup_value1        = 'O'
          group by
                fgl2.lk_match_key1
       ) open_period
    on fgl.lk_match_key2||lk_match_key3 = open_period.min_period
   and fgl.lk_match_key1                = open_period.event_class
 where
       fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
;