create or replace view gui.vw_ui_segment_8_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
select distinct ie.iie_cover_signing_party as fdr_lookup_key,
       ie.iie_cover_signing_party as description 
from fdr.fr_instr_insure_extend ie
;
