insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 1  , 'DEAL_CLOSED'                            , 'Deal Closed or Policy Incepted'                                                           , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Opening Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 2  , 'PREM_SUPPLEMENT'                        , 'Premium Supplements (Step Up Premium)'                                                    , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Opening Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 3  , 'ENTITY_ACQUISITION'                     , 'Acquisition of a new entity'                                                              , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Opening Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 4  , 'PASSAGE_OF_TIME'                        , 'Passage of time'                                                                          , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 5  , 'CASH_RECPT_CMMT_PREM'                   , 'Cash Receipt for Commitment Premium'                                                      , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 6  , 'CASH_RECPT_TAWAC_FEE'                   , 'Cash Receipt for TAWAC Fees'                                                              , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 7  , 'CASH_RECPT_SURV_FEE'                    , 'Cash Receipt for Surveillance Fee'                                                        , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 8  , 'CASH_RECPT'                             , 'Cash Receipt'                                                                             , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 9  , 'CASH_RECPT_SALVAGE'                     , 'Cash Receipt for Salvage & Subrogation'                                                   , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 10 , 'CASH_RECPT_LAE_RCVRY'                   , 'Cash Receipt for LAE Recovery'                                                            , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 11 , 'CASH_RECPT_LOSSMIT'                     , 'Cash Receipt for Loss Mitigation'                                                         , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 12 , 'CASH_PMT_CLAIM'                         , 'Cash Payment of a claim'                                                                  , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 13 , 'CASH_PMT_SALVAGE'                       , 'Cash Payment to Reinsurers for Salvage & Subrogation'                                     , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 14 , 'CASH_PMT_LAE'                           , 'Cash Payment of Loss Adjusted Expenses (LAE)'                                             , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 15 , 'CASH_PMT_LOSSMIT'                       , 'Cash Payment for Loss Mitigation'                                                         , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 16 , 'PARTIAL_BOND_CALLED'                    , 'Partial Bond Called'                                                                      , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 17 , 'PARTIAL_REFUNDING'                      , 'Partial Refunding of Obligation (e.g., to take advantage of lower interest rates)'        , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 18 , 'PARTIAL_LEGAL_DEF'                      , 'Partial Legal Defeasance of Bond'                                                         , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 19 , 'PARTIAL_ECONOMIC_DEF'                   , 'Partial Economic Defeasance of Bond'                                                      , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 20 , 'PARTIAL_BOND_PUR_LM'                    , 'Partial Bond purchase for Loss Mitigation '                                               , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 21 , 'PARTIAL_REASSUMPTION'                   , 'Partial Re-assumption of Reinsurance Cession (Internal or External)'                      , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 22 , 'CHNG_PAR_OS'                            , 'Material changes to PAR Outstanding (Quarterly)'                                          , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 23 , 'CHNG_RISK_RATING'                       , 'Risk Rating Changes'                                                                      , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 24 , 'CHNG_REINS_RATING'                      , 'Rating changes (downgrades/upgrades) of Reinsurers'                                       , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 25 , 'TAWAC_AMEND_UPDATE'                     , 'Amendments/Updates to the deal (TAWACs) '                                                 , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 26 , 'NON_ADMIT_RECORDING'                    , 'Recording of Non-Admits'                                                                  , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 27 , 'CANCEL_CORRECT'                         , 'Cancellation and Correction of a transaction or business event'                           , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 28 , 'FULL_BOND_CALLED'                       , 'Full Bond Called'                                                                         , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 29 , 'FULL_REFUNDING'                         , 'Full Refunding of Obligation (e.g., to take advantage of lower interest rates)'           , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 30 , 'FULL_LEGAL_DEF'                         , 'Full Legal Defeasance of Bond'                                                            , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 31 , 'FULL_ECONOMIC_DEF'                      , 'Full Economic Defeasance of Bond'                                                         , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 32 , 'FULL_BOND_PUR_LM'                       , 'Full Bond Purchase for Loss Mitigation'                                                   , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 33 , 'COMMUTATION'                            , 'Full Commutation or Re-assumption of Reinsurance Cession (Internal or External)'          , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 34 , 'BOND_MATURITY'                          , 'Bond Maturity'                                                                            , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 35 , 'POLICY_TERMINATION'                     , 'Termination of a Policy '                                                                 , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 36 , 'POLICY_MATURITY'                        , 'Maturity of a Policy '                                                                    , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 37 , 'STLMT_REASSUMP_REINS'                   , 'Settlement on Commutation or Re-assumption of Reinsurance Cession (Internal or External)' , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 38 , 'WRITE_OFF'                              , 'Write-Off'                                                                                , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Closing Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 39 , 'MANUAL_JOURNAL'                         , 'Manual Journals'                                                                          , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 40 , 'FAIR_VALUE_ADJ'                         , 'Fair Value Adjustment'                                                                    , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 41 , 'PGAAP_ADJ'                              , 'Purchase GAAP Adjustment'                                                                 , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Opening Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 42 , 'POLICY_DIRTY'                           , 'Policy Dirty'                                                                             , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 43 , 'ABOB_CASH'                          	, 'ABOB Cash Journal Entries'                                                                , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 44 , 'ABOB_PROFIT_COMM'                       , 'ABOB_Profit Comission Journal Entries'                                                    , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Opening Position Event' ) );
insert into stn.business_event ( business_event_seq_id , business_event_cd , business_event_descr , business_event_category_cd ) values ( 45 , 'ABOB_TRADE_CREDIT'                      , 'ABOB Trade Credit Journal Entries'                                                        , ( select business_event_category_cd from stn.business_event_category where business_event_category_descr = 'Holding Position Event' ) );
commit;