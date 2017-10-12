create or replace view rdr.rrv_slr_eba_combinations_ag
as
   select ec_epg_id,
          ec_fak_id,
          ec_eba_id,
          ec_attribute_1 as stream_id,
          ec_attribute_2 as tax_jurisdiction_cd,
          ec_attribute_3 as premium_typ
     from slr.slr_eba_combinations
;     
     
 