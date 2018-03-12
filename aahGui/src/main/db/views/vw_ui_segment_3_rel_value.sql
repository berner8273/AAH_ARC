create or replace view gui.vw_ui_segment_3_rel_value
(
   fdr_code,
   lookup_value
) as
select frb.bo_book_clicode,
          frb.bo_book_clicode 
from fdr.fr_book frb
;
