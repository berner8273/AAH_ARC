DELETE FROM fdr.fr_general_lookup WHERE lk_match_key1 = 'VIE_SALVAGES_REC' and lk_lkt_lookup_type_code = 'EVENT_SUBGROUP';
COMMIT;

UPDATE fdr.fr_general_lookup SET lk_lookup_value1 = 'VIE_LOSS_RSRV'
WHERE lk_lookup_value1 = 'VIE_SALVAGES_REC' and lk_lkt_lookup_type_code = 'EVENT_HIERARCHY';
COMMIT;

UPDATE fdr.fr_general_lookup SET lk_lookup_value2 = 'VIE_LOSS_RSRV'
WHERE lk_lookup_value1 = 'VIE_LOSS_RSRV' and lk_lkt_lookup_type_code = 'EVENT_HIERARCHY';
COMMIT;



