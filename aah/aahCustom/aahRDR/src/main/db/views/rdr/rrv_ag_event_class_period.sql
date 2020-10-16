create or replace view rdr.rrv_ag_event_class_period
as
select
       fgl.lk_match_key1                                    event_class
     , fgl.lk_match_key2                                    business_year
     , lpad( lk_match_key3 , 2 , '0' )                      business_month
     , fgl.lk_match_key2 || lpad(lk_match_key3,2,'0')       period
     , fgl.lk_lookup_value1                                 closed_status
     , closed_date.input_time                               locked_date
  from
       fdr.fr_general_lookup fgl
  left join ( 
               with input_time as
               (
                select lead(lk_input_time) over ( partition by fgla.lk_match_key1 , fgla.lk_match_key2 ,fgla.lk_match_key3 order by fgla.lk_input_time , fgla.lk_valid_from ) input_time
                , fgla.lk_match_key1 event_class
                , fgla.lk_match_key2 period_year
                , fgla.lk_match_key3 period_month
                , fgla.lk_lookup_value1 period_status
                , fgla.lk_valid_from    valid_from
                from fdr.fr_general_lookup_aud fgla
                where fgla.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
               )
                select input_time.input_time
                     , input_time.event_class
                     , input_time.period_year
                     , input_time.period_month
                     , input_time.period_status
                  from input_time
                 where period_status = 'O'
                   and input_time.valid_from = ( select max(FGLA.LK_valid_from)
                                                   from fdr.fr_general_lookup_aud fgla
                                                   where fgla.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
                                                      and fgla.lk_match_key1 = input_time.event_class
                                                      and fgla.lk_match_key2 = input_time.period_year
                                                      and fgla.lk_match_key3 = input_time.period_month 
                                                      and fgla.lk_lookup_value1 = input_time.period_status )
             ) closed_date
            on fgl.lk_match_key1 = closed_date.event_class
           and fgl.lk_match_key2 = closed_date.period_year
           and fgl.lk_match_key3 = closed_date.period_month
 where
       fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
   and fgl.lk_lookup_value1        = 'C'
union
select
       fgl.lk_match_key1                                    event_class
     , fgl.lk_match_key2                                    business_year
     , lpad( lk_match_key3 , 2 , '0' )                      business_month
     , fgl.lk_match_key2 || lpad( lk_match_key3 , 2 , '0' ) period
     , fgl.lk_lookup_value1                                 closed_status
     , null                                                 locked_date
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