create or replace view gui.vw_ui_segment_5
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
where frgc.gc_gct_code_type_id = 'GL_CHARTFIELD' and gc_client_text1 = 'CHARTFIELD_1'
union all 
   SELECT 'NVS' AS fdr_code,
          'NVS' AS fdr_description,
          'NVS' AS lookup_key,
          'Client Static' AS source_system_id,
          NULL AS parent_id,
          NULL AS entity from dual
union all          
   SELECT 'DNP' AS fdr_code,
          'DO NOT POST' AS fdr_description,
          'DNP' AS lookup_key,
          'Client Static' AS source_system_id,
          NULL AS parent_id,
          NULL AS entity from dual
;
