create or replace force view gui.vw_ui_segment_8
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
   select ie.iie_cover_signing_party as fdr_code,
          ie.iie_cover_signing_party as fdr_description,
          ie.iie_cover_signing_party as lookup_key,
          'Client Static' as source_system_id,
          null as parent_id,
          null as entity
     from fdr.fr_instr_insure_extend ie
;
