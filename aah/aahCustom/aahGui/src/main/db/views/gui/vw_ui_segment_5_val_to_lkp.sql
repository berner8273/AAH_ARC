create or replace view gui.vw_ui_segment_5_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
select frgc.gc_client_code  as fdr_lookup_key,
        frgc.gc_client_text2 as description 
from fdr.fr_general_codes frgc
where frgc.gc_gct_code_type_id = 'GL_CHARTFIELD'
;
