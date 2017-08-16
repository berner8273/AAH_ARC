insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'MTM'          , 'Mark-to-market method' );
insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'NON_MTM'      , 'Non mark-to-market method' );
insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'STAT_ONLY'    , 'STAT only postings' );
insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'GAAP_ONLY'    , 'GAAP only postings' );
insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'GAAP_TO_STAT' , 'Post GAAP amounts to STAT ledger' );
insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'STAT_ADJ'     , 'Post STAT adjustment ledger' );
insert into stn.posting_method ( psm_cd , psm_descr ) values ( 'INTERCOMPANY' , 'Post intercompany eliminations' );
commit;