create or replace view gui.vw_ui_segment_4_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
   select pl.pl_party_legal_clicode as fdr_lookup_key,
          pl.pl_full_legal_name as description 
     from fdr.fr_party_legal pl
;

