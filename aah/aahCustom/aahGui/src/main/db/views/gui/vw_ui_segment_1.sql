create or replace view gui.vw_ui_segment_1
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select p.ps_posting_schema as "FDR_CODE",
       p.ps_posting_schema as "FDR_DESCRIPTION",
       p.ps_posting_schema as "LOOKUP_KEY",
      'Client Static'        as source_system_id,
       null as parent_id,
       null as entity
from fdr.fr_posting_schema p
;

