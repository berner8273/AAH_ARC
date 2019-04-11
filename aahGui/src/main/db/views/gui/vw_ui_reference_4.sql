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
        pl.pl_party_legal_clicode as "FDR_CODE",
        pl.pl_full_legal_name as "FDR_DESCRIPTION",
        pl.pl_party_legal_clicode as "LOOKUP_KEY",
        pl.pl_si_sys_inst_id as "SOURCE_SYSTEM_ID",
        null as "PARENT_ID",
        null as "ENTITY"
    from fdr.fr_party_legal pl
        join fdr.fr_party_type fpt 
            on pl.pl_pt_party_type_id = fpt.pt_party_type_id
        join fdr.fr_org_network fon
            on pl.pl_party_legal_id = fon.on_org_node_client_code
        join fdr.fr_org_node_structure fons
            on fons.ons_on_child_org_node_id = fon.on_org_node_id
    where pl.pl_active = 'A'
      and pl.pl_pt_party_type_id ='10'
      and fons.ons_oht_org_hier_type_id = '6'
    order by pl.pl_party_legal_clicod;