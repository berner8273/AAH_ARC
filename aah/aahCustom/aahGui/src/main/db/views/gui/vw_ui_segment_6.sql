create or replace view gui.vw_ui_segment_6
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select et.execution_typ as fdr_code,
       et.execution_typ_descr as fdr_description,
       et.execution_typ as lookup_key,
       'Client Static' as source_system_id,
       null as parent_id,
       null as entity
from stn.execution_type et
;
