insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 1  , 'CCY'           , 'Check that the value being validated is an ISO currency code.'                                           , 'The ISO currency code is not defined in fdr.fr_currency_lookup.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 2  , 'EFFDT'         , 'Check that the value being validated is consistent with the feed''s effective date.'                     , 'The date is not consistent with feed.effective_dt.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 3  , 'LECD'          , 'Check that the value being validated is a valid legal entity code.'                                      , 'The legal entity is not defined in fdr.fr_party_legal/fdr.fr_org_network.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 4  , 'LEDG'          , 'Check that the value being validated is a valid ledger code.'                                            , 'The ledger code is not defined in fdr.fr_posting_schema.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 5  , 'ACCT'          , 'Check that the value being validated is a valid account code.'                                           , 'The account code is not defined in fdr.fr_gl_account.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 6  , 'DEPT'          , 'Check that the value being validated is a valid department code.'                                        , 'The department code is not defined in fdr.fr_book.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 7  , 'ROLE'          , 'Check that the value being validated is a valid user role.'                                              , 'The user role is not defined in gui.t_ui_roles.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 8  , 'EID'           , 'Check that the value being validated is linked to valid record in stn.user_detail.'                      , 'The stn.user_detail record containing this employee_id failed validation.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 9  , 'LEID'          , 'Check that the value being validated is a valid legal entity ID.'                                        , 'The legal entity is not defined in fdr.fr_party_legal/fr_org_network' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 10 , 'POLICYSAME'    , 'Check that the policy IDs being compared are the same.'                                                  , 'The policies being compared were expected to be the same but are not.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 11 , 'CLDR'          , 'Check that the value being validated is a valid calendar code.'                                          , 'The calendar code is not defined in fdr.fr_calendar.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 12 , 'BASIS'         , 'Check that the value being validated is a valid accounting basis code.'                                  , 'The accounting basis code is not defined in fdr.fr_gaap or needs to be categorized as ''R''.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 13 , 'ACCTDT'        , 'Check that the accounting date is within the open period.'                                               , 'The accounting date was expected to be within open period but is not.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 14 , 'JLBALTRAN'     , 'Check that total transaction debits and credits equal zero'                                              , 'The sum of the transactional debits and credits does not equal zero.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 15 , 'VIEACCTDT'     , 'Check that the VIE accounting date is not null'                                                          , 'The stn.vie_acct_dt cannot be null when stn.vie_status is ''CONSO'' or ''DECONSO''.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 16 , 'VIEEFFDT'      , 'Check that the VIE effective date is not null'                                                           , 'The stn.vie_effective_dt cannot be null when stn.vie_status is ''CONSO'' or ''DECONSO''.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 17 , 'STREAM'        , 'Check that the value being validated is a valid cession stream ID.'                                      , 'The stream ID is not defined in fdr.fr_trade.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 18 , 'EVENT'         , 'Check that the value being validated is a valid event type.'                                             , 'The event type code is not defined in fdr.fr_acc_event_type.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 19 , 'BUSEVENT'      , 'Check that the value being validated is a valid business event type.'                                    , 'The business event type code is not defined in fdr.fr_general_lookup.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 20 , 'CORRUUID'      , 'Check that the records tied to this correlation UUID are valid.'                                         , 'The records with this correlation uuid are not all valid.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 21 , 'TAXJURIS'      , 'Check that the value being validated is a valid tax juridiction.'                                        , 'The tax jurisdiction is not valid.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 22 , 'CFIELD1'       , 'Check that the value being validated is a valid chartfield1.'                                            , 'The chartfield 1 value is not valid.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 23 , 'POLICY'        , 'Check that the value being validated is a valid policy ID.'                                              , 'The policy is not valid.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 24 , 'JLBALFUNC'     , 'Check that total functional debits and credits equal zero'                                               , 'The sum of the functional debits and credits does not equal zero.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 25 , 'JLBALREPT'     , 'Check that total reporting debits and credits equal zero'                                                , 'The sum of the reporting debits and credits does not equal zero.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 26 , 'LECOMPARE'     , 'Check that the legal entity IDs being compared are not the same.'                                        , 'The legal entities compared to one another are the same.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 27 , 'LEISLEDGER'    , 'Check that the legal entity ID is a ledger entity.'                                                      , 'The legal entity is not a ledger entity.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 28 , 'LENOTLEDGE'    , 'Check that the legal entity ID is not a ledger entity.'                                                  , 'The legal entity is a ledger entity.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 29 , 'NOSLRLINK'     , 'Check that the legal entity has a corresponding SLR_LINK legal entity link.'                             , 'The legal entity has no corresponding SLR_LINK legal_entity_link record.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 30 , 'LEIDCHANGE'    , 'Check that the le_id and le_cd are consistent with each other over time.'                                , 'The le_cd referred to by this record''s le_id has changed.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 31 , 'PLSTRCOMBO'    , 'Check that the combination of policy and stream are legal.'                                              , 'The combination of policy ID and stream ID is not known.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 32 , 'JLBALFOUT'     , 'Check that total transaction debits and credits that passed row-level validations equal zero.'           , 'The sum of the transaction debits and credits that passed row level validations does not equal zero.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 33 , 'JLBALROUT'     , 'Check that total reporting debits and credits that passed row-level validations equal zero.'             , 'The sum of the transaction debits and credits that passed row level validations does not equal zero.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 34 , 'JLBALTOUT'     , 'Check that total transaction debits and credits that passed row-level validations equal zero.'           , 'The sum of the transaction debits and credits that passed row level validations does not equal zero.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 35 , 'EVENTCLASS'    , 'Check that the descriptions assigned to event classes are consistent across a feed.'                     , 'The description of this event class is not consistent across the records being processed.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 36 , 'EVENTCAT'      , 'Check that the descriptions assigned to event categories are consistent across a feed.'                  , 'The description of this event category is not consistent across the records being processed.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 37 , 'EVENTGROUP'    , 'Check that the descriptions assigned to event groups are consistent across a feed.'                      , 'The description of this event group is not consistent across the records being processed.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 38 , 'EVENTSBGRP'    , 'Check that the descriptions assigned to event sub-groups are consistent across a feed.'                  , 'The description of this event subgroup is not consistent across the records being processed.' );
insert into stn.validation_type ( validation_typ_id , validation_typ_cd , validation_typ_descr , validation_typ_err_msg ) values ( 39 , 'POLRELATED'    , 'Check that the standardisation is part of the Insurance Policy feed for error re-submission.'            , 'This standardisation error is part of the Insurance Policy Feed.' );
commit;