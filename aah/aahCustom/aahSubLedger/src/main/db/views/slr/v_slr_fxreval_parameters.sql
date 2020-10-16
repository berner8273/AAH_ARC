create or replace view slr.v_slr_fxreval_parameters as 
select 
       fgl.lk_match_key3   mth_nbr
     , fgl.lk_match_key2   year_nbr
     , fgl.lk_match_key1   event_class
     , fga.fga_gaap_id     accounting_basis
     , 'Y'                 run_fx_flag
  from
            fdr.fr_general_lookup fgl
 cross join fdr.fr_gaap           fga
 where fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
   and fgl.lk_lookup_value1        = 'O'
   and exists ( select null
                  from slr.slr_entity_rates er
                 where er.er_date      = to_date( fgl.lk_lookup_value3 , 'DD-MON-YYYY' )
                   and er.er_rate_type = 'MAVG' )
   and fga.fga_gaap_id  in ( 'US_GAAP' , 'US_STAT' , 'UK_GAAP' )
;