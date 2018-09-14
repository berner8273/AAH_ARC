create or replace view gui.vw_ui_reference_7
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
   select pl.pl_party_legal_clicode as "FDR_CODE",
          pl.pl_full_legal_name as "FDR_DESCRIPTION",
          pl.pl_party_legal_clicode as "LOOKUP_KEY",
          pl.pl_si_sys_inst_id as "SOURCE_SYSTEM_ID",
          null as "PARENT_ID",
          null as "ENTITY"
     from fdr.fr_party_legal pl
    where pl.pl_pt_party_type_id in 
    (select pt_party_type_id from fdr.fr_party_type where pt_party_type_name = 'Ledger Entity')        
;
