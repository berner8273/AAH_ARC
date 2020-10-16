delete from fdr.fr_general_lookup_aud where lk_lookup_key_id in (
select lk_lookup_key_id from fdr.fr_general_lookup where lk_match_key1 = 'CASH_OFFSETS' 
    and lk_lookup_value1 = 'O' and lk_auth_status is not null );
delete from fdr.fr_general_lookup where lk_match_key1 = 'CASH_OFFSETS' and lk_lookup_value1 = 'O';
commit;