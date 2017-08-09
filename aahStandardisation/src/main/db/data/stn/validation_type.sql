insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 1 , 'CCY'   , 'Check that the value being validated is an ISO currency code.'                       , 'The ISO currency code is not defined in fdr.fr_currency_lookup.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 2 , 'EFFDT' , 'Check that the value being validated is consistent with the feed''s effective date.' , 'The date is not consistent with feed.effective_dt.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 3 , 'LECD'  , 'Check that the value being validated is a valid legal entity code.'                  , 'The legal entity is not defined in fdr.fr_party_legal/fdr.fr_org_network.' );
commit;