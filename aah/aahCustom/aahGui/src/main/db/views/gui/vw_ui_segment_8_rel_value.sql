create or replace view gui.vw_ui_segment_8_rel_value
(
   fdr_code,
   lookup_value
) as
select distinct ie.iie_cover_signing_party,
       ie.iie_cover_signing_party 
from fdr.fr_instr_insure_extend ie
;

