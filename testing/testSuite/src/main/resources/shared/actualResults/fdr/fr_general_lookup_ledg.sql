select
       lk_lkt_lookup_type_code
     , lk_match_key1
     , lk_match_key2
     , lk_match_key3
     , lk_match_key4
     , lk_match_key5
     , lk_match_key6
     , lk_match_key7
     , lk_match_key8
     , lk_match_key9
     , lk_match_key10
     , lk_lookup_value1
     , lk_lookup_value2
     , lk_lookup_value3
     , lk_lookup_value4
     , lk_lookup_value5
     , lk_lookup_value6
     , lk_lookup_value7
     , lk_lookup_value8
     , lk_lookup_value9
     , lk_lookup_value10
     , trunc(lk_valid_from)
     , lk_valid_to
     , lk_active
     , trunc(lk_effective_from)
     , lk_effective_to
  from
       fdr.fr_general_lookup
 where
       lk_lkt_lookup_type_code in ('ACCOUNTING_BASIS_LEDGER','LEGAL_ENTITY_LEDGER')