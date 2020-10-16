create or replace view gui.vw_ui_segment_2
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
   select distinct 
   fgl.lk_lookup_value1 as "FDR_CODE", 
   fgl.lk_lookup_value1 as "FDR_DESCRIPTION",
   fgl.lk_lookup_value1 as "LOOKUP_KEY",
   'Client Static'      as "SOURCE_SYSTEM_ID",
    NULL                as "PARENT_ID",
    NULL                as "ENTITY"   
   from fdr.fr_general_lookup fgl
    where fgl.lk_lkt_lookup_type_code like 'ACCOUNTING_BASIS%'
;



