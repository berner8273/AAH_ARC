create or replace view gui.vw_ui_segment_5_rel_value
(
   fdr_code,
   lookup_value
) as
select frgc.gc_client_code,
       frgc.gc_client_code 
from fdr.fr_general_codes frgc
where frgc.gc_gct_code_type_id = 'GL_CHARTFIELD'
;

