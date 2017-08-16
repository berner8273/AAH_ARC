insert into stn.vie_code ( vie_cd , vie_cd_descr , sub_event ) values ( 1 , 'Not a VIE'                                                                , null );
insert into stn.vie_code ( vie_cd , vie_cd_descr , sub_event ) values ( 2 , 'New consolidation effective beginning of the period'                      , null );
insert into stn.vie_code ( vie_cd , vie_cd_descr , sub_event ) values ( 3 , 'New consolidation effective end of period'                                , null );
insert into stn.vie_code ( vie_cd , vie_cd_descr , sub_event ) values ( 4 , 'New deconsolidation effective beginning of the period'                    , 'DECONSOL' );
insert into stn.vie_code ( vie_cd , vie_cd_descr , sub_event ) values ( 5 , 'New deconsolidation effective end of period'                              , 'DECONSOL' );
insert into stn.vie_code ( vie_cd , vie_cd_descr , sub_event ) values ( 6 , 'Existing - the cession was a VIE in the prior month and is still a VIE'   , null );
commit;