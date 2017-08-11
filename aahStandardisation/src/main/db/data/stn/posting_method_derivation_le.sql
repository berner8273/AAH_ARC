insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'AG_LONDON' , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_STAT' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'AGFP'      , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_STAT' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'MBUK'      , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_STAT' ) );
commit;