create or replace force view gui.vw_ui_segment_5
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select frgc.gc_client_code as fdr_code,
       frgc.gc_client_text2 as fdr_description,
       frgc.gc_client_code as lookup_key,
       'Client Static' as source_system_id,
       null as parent_id,
       null as entity
from fdr.fr_general_codes frgc
where frgc.gc_gct_code_type_id = 'GL_CHARTFIELD'
;
