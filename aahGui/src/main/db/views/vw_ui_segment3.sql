create or replace force view gui.vw_ui_segment_3
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
   bequeath definer
as
   select frb.bo_book_clicode as "FDR_CODE",
          frb.bo_book_name as "FDR_DESCRIPTION",
          frb.bo_book_clicode as "LOOKUP_KEY",
          'Client Static' as "SOURCE_SYSTEM_ID",
          null as "PARENT_ID",
          null as "ENTITY"
     from fdr.fr_book frb
;
