create or replace view stn.policy_tax
as
select
       fgc.gc_client_text1                          policy_id
     , fgc.gc_client_text2                          tax_jurisdiction_cd
     , fgc.gc_client_text3                          tax_jurisdiction_pct
     , fgc.gc_valid_from                            valid_from
     , fgc.gc_valid_to                              valid_to
  from
       fdr.fr_general_codes fgc
 where
       fgc.gc_gct_code_type_id = 'POLICY_TAX'
     ;