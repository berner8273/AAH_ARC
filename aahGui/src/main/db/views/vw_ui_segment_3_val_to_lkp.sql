create or replace view gui.vw_ui_segment_3_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
   select frb.bo_book_clicode as fdr_lookup_key,
          frb.bo_book_name as description 
     from fdr.fr_book frb
;

