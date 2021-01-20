delete fdr.fr_general_lookup l
where lk_lkt_lookup_type_code = 'COMBO_RULESET'
    and not exists (
        select lk_lkt_lookup_type_code, lk_match_key1, lk_match_key2, lk_lookup_value1, lk_lookup_key_id
        from (
            select lk_lkt_lookup_type_code, lk_match_key1, lk_match_key2, lk_lookup_value1, max(lk_lookup_key_id) lk_lookup_key_id
            from fdr.fr_general_lookup 
            where lk_lkt_lookup_type_code = 'COMBO_RULESET' 
            group by lk_lkt_lookup_type_code, lk_match_key1, lk_match_key2, lk_lookup_value1       
            ) t1
        where l.lk_lkt_lookup_type_code = t1.lk_lkt_lookup_type_code and l.lk_match_key1 = t1.lk_match_key1 and l.lk_match_key2 = t1.lk_match_key2 and l.lk_lookup_value1 = t1.lk_lookup_value1
            and l.lk_lookup_key_id = t1.lk_lookup_key_id
    
    ); 
commit; 
exec dbms_stats.gather_table_stats ( ownname => 'FDR' , tabname => 'fr_general_lookup' , cascade => true, no_invalidate => false );
/