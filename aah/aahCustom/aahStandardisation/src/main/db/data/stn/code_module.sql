insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 1  , 'stn.pr_fx_rate_rval'            , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 2  , 'stn.pr_fx_rate_sval'            , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_SVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 3  , 'stn.pr_legal_entity_rval'       , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 4  , 'stn.pr_legal_entity_link_rval'  , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 5  , 'stn.pr_gl_combo_edit_asgn_rval' , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 6  , 'stn.pr_gl_combo_edit_rule_rval' , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 9  , 'stn.pr_policy_rval'             , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 10 , 'stn.pr_ledger_rval'             , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 11 , 'stn.pr_journal_line_rval'       , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 12 , 'stn.pr_cession_event_rval'      , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_RVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 13 , 'stn.pr_event_hier_sval'         , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_SVAL' ) );
insert into stn.code_module ( code_module_id , code_module_nm , code_module_typ_id ) values ( 14 , 'stn.pr_cession_event_sval'      , ( select code_module_typ_id from stn.code_module_type where code_module_typ_cd = 'STD_SVAL' ) );
commit;