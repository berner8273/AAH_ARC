create or replace view rdr.rrv_ag_legal_entity_ledger
as
select
       fgl.lk_lkt_lookup_type_code   lookup_type_code
     , fgl.lk_lookup_value1          ledger_cd
     , fpl.pl_party_legal_clicode    le_cd
     , fgl.lk_effective_from         effective_from
     , fgl.lk_effective_to           effective_to
  from
       fdr.fr_general_lookup fgl
  join
       fdr.fr_party_legal fpl
    on fpl.pl_global_id = fgl.lk_lookup_value2
 where
       lk_lkt_lookup_type_code in ('LEGAL_ENTITY_LEDGER')
 order by
       ledger_cd
     , le_cd
     ;