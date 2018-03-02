--create or replace view rdr.rrv_ag_event_class_period
--as
select
       fgl.lk_match_key1                              event_class
     , fgl.lk_match_key2                              business_year
     , lpad(lk_match_key3,2,'0')                      business_month
     , fgl.lk_match_key2||lpad(lk_match_key3,2,'0')   period
     , fgl.lk_lookup_value1                           closed_status
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
   and fgl.lk_lookup_value1        = 'C'
union
select
       fgl.lk_match_key1                              event_class
     , fgl.lk_match_key2                              business_year
     , lpad(lk_match_key3,2,'0')                      business_month
     , fgl.lk_match_key2||lpad(lk_match_key3,2,'0')   period
     , fgl.lk_lookup_value1                           closed_status
  from
       fdr.fr_general_lookup fgl
  join ( select
                min(fgl2.lk_match_key2||fgl2.lk_match_key3)   min_period
              , fgl2.lk_match_key1                            event_class
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