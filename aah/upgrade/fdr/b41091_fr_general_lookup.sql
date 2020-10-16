update fdr.fr_general_lookup
set lk_valid_to = to_date('31-DEC-2099', 'DD-MON-YYYY')
where lk_lkt_lookup_type_code = 'GL_MAPPING_SET_1';

update fdr.fr_general_lookup
set lk_effective_to = to_date('31-DEC-2099', 'DD-MON-YYYY')
where lk_lkt_lookup_type_code = 'GL_MAPPING_SET_1';

commit;