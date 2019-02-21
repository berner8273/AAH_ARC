insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'AG_LONDON' , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'AGFP'      , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'MBUK'      , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'MBIU1'     , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'AGFPI'     , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'AGRFP'     , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ) );
insert into stn.posting_method_derivation_le ( le_cd , psm_id ) values ( 'FSAUK'     , ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' ) );
commit;