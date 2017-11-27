insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 1  ,  'fxr-from_ccy'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_fx_rate_rval' )            , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 2  ,  'fxr-to_ccy'                 , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_fx_rate_rval' )            , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 3  ,  'fxr-rate_dt'                , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_fx_rate_sval' )            , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'EFFDT' )         , ( select validation_level_id from stn.validation_level where validation_level_cd = 'set' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 4  ,  'le-functional_ccy'          , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 6  ,  'lel-parent_le_id'           , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_link_rval' )  , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECD' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 7  ,  'lel-child_le_id'            , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_link_rval' )  , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECD' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 8  ,  'gcea-le_cd'                 , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_gl_combo_edit_asgn_rval' ) , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECD' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 9  ,  'gcea-ledger_cd'             , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_gl_combo_edit_asgn_rval' ) , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEDG' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 10 ,  'gcer-acct_cd'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_gl_combo_edit_rule_rval' ) , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ACCT' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 11 ,  'ud-dept_cd'                 , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_user_detail_rval' )        , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'DEPT' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 12 ,  'ug-group_nm'                , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_user_group_rval' )         , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ROLE' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 13 ,  'ug-employee_id'             , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_user_group_rval' )         , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'EID' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 14 ,  'pol-transaction_ccy'        , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 15 ,  'pol-underwriting_le_id'     , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEID' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 16 ,  'polfxr-to_ccy'              , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 17 ,  'polfxr-from_ccy'            , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 18 ,  'cs-le_id'                   , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEID' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 19 ,  'cs-vie_acct_dt'             , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'VIEACCTDT' )     , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 20 ,  'cs-vie_eff_dt'              , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'VIEEFFDT' )      , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 21 ,  'cl-stream_policies'         , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'POLICYSAME' )    , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 22 ,  'ledg-cldr_cd'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_ledger_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CLDR' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 23 ,  'abl-basis_cd'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_ledger_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'BASIS' )         , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 24 ,  'lel-le_cd'                  , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_ledger_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECD' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 25 ,  'jl-le_id'                   , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEID' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 26 ,  'jl-affiliate_le_id'         , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEID' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 27 ,  'jl-owner_le_id'             , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEID' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 28 ,  'jl-ultimate_parent_le_id'   , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEID' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 29 ,  'jl-counterparty_le_id'      , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEID' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 30 ,  'jl-accounting_dt'           , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ACCTDT' )        , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 31 ,  'jl-acct_cd'                 , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ACCT' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 32 ,  'jl-basis_cd'                , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ACCT' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 33 ,  'jl-policy_id'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'POLICY' )        , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 34 ,  'jl-stream_id'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'STREAM' )        , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 35 ,  'jl-dept_cd'                 , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'DEPT' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 36 ,  'jl-chartfield_1'            , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CFIELD1' )       , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 37 ,  'jl-tax_jurisdiction_cd'     , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'TAXJURIS' )      , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 38 ,  'jl-event_typ'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ACCT' )          , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 39 ,  'jl-le_id-comparison'        , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECOMPARE' )     , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 40 ,  'jl-transaction_sum'         , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'JLBALTRAN' )     , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 41 ,  'ce-stream_id'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'STREAM' )        , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 42 ,  'ce-basis_cd'                , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'BASIS' )         , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 43 ,  'ce-transaction_ccy'         , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 44 ,  'ce-functional_ccy'          , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 45 ,  'ce-reporting_ccy'           , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )           , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 46 ,  'ce-event_typ'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'EVENT' )         , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 47 ,  'ce-business_event_typ'      , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'BUSEVENT' )      , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 48 ,  'ce-correlation_uuid'        , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_cession_event_rval' )      , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CORRUUID' )      , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 49 ,  'jl-functional_sum'          , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'JLBALFUNC' )     , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 50 ,  'jl-reporting_sum'           , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_journal_line_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'JLBALREPT' )     , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 51 ,  'lel-parent_slr_link_le_id'  , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_link_rval' )  , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEISLEDGER' )    , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 52 ,  'lel-child_slr_link_le_id'   , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_link_rval' )  , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LENOTLEDGE' )    , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 53 ,  'cs-le_id-slr_link'          , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_policy_rval' )             , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'NOSLRLINK' )     , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 54 ,  'le-id-change'               , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEIDCHANGE' )    , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );

commit;