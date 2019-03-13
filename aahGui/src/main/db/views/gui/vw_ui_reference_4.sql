create or replace view gui.vw_ui_reference_4
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
    select 
        le.le_cd as "FDR_CODE",
        le.le_descr as "FDR_DESCRIPTION",
        le.le_cd as "LOOKUP_KEY",
        'Client Static' as "SOURCE_SYSTEM_ID",
        null as "PARENT_ID",
        null as "ENTITY"    
    from 
        stn.legal_entity le
    join 
        stn.legal_entity_link lel on le_id=lel.child_le_id
    where 
        le.legal_entity_typ='INTERNAL'
        and is_ledger_entity='N'
        and lel.legal_entity_link_typ='SLR_LINK'
    order by le.le_cd
;