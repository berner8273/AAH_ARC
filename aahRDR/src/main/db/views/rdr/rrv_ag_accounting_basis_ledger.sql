create or replace view rdr.rrv_ag_accounting_basis_ledger
as
select
       lk_lkt_lookup_type_code   lookup_type_code
     , lk_lookup_value1          accounting_basis_cd
     , lk_lookup_value2          ledger_cd
     , lk_effective_from         effective_from
     , lk_effective_to           effective_to
  from
       fdr.fr_general_lookup
 where
       lk_lkt_lookup_type_code in ('ACCOUNTING_BASIS_LEDGER')
     ;