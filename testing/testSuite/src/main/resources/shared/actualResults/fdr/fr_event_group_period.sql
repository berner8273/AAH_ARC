select
       lk_match_key1
     , lk_match_key2
     , lk_match_key3
     , lk_lookup_value1
     , to_char(to_date(lk_lookup_value2,'DD-MM-YYYY'),'mm/dd/yyyy')
     , to_char(to_date(lk_lookup_value3,'DD-MM-YYYY'),'mm/dd/yyyy')
     , lk_lookup_value5
  from
       fdr.fr_general_lookup
 where
       lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
   and to_char(to_date(lk_lookup_value2,'DD-MM-YYYY'),'yyyy') = '2018'
