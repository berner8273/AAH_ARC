insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 1  ,  'fxr-from_ccy'       , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_fx_rate_rval' )            , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )   , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 2  ,  'fxr-to_ccy'         , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_fx_rate_rval' )            , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )   , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 3  ,  'fxr-rate_dt'        , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_fx_rate_sval' )            , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'EFFDT' ) , ( select validation_level_id from stn.validation_level where validation_level_cd = 'set' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 4  ,  'le-functional_ccy'  , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_rval' )       , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'CCY' )   , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 6  ,  'lel-parent_le_id'   , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_link_rval' )  , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECD' )  , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 7  ,  'lel-child_le_id'    , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_legal_entity_link_rval' )  , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECD' )  , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 8  ,  'gcea-le_id'         , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_gl_combo_edit_asgn_rval' ) , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LECD' )  , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 9  ,  'gcea-ledger_cd'     , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_gl_combo_edit_asgn_rval' ) , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'LEDG' )  , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 10 ,  'gcer-acct_cd'       , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_gl_combo_edit_rule_rval' ) , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ACCT' )  , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 11 ,  'ud-dept_cd'         , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_user_detail_rval' )        , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'DEPT' )  , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values ( 12 ,  'ug-group_nm'        , ( select code_module_id from stn.code_module where code_module_nm = 'stn.pr_user_group_rval' )         , ( select validation_typ_id from stn.validation_type where validation_typ_cd = 'ROLE' )  , ( select validation_level_id from stn.validation_level where validation_level_cd = 'row' ) );
commit;