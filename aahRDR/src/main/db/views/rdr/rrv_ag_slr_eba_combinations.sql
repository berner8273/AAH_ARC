create or replace view rdr.rrv_ag_slr_eba_combinations
as
   select ec_epg_id,
          ec_fak_id,
          ec_eba_id,
          ec_attribute_1 as stream_id,
          ec_attribute_2 as tax_jurisdiction_cd,
          ec_attribute_3 as premium_typ,
          ec_attribute_4 as event_type
     from slr.slr_eba_combinations
;     
     
 