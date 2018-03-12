insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'FX_RATE'          , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'GL_ACCOUNT'       , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'DEPARTMENT'       , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'GL_CHARTFIELD'    , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'LEGAL_ENTITY'     , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'LEGAL_ENTITY'     , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'CESSION_EVENT'    , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'INSURANCE_POLICY' , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'INSURANCE_POLICY' , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'INSURANCE_POLICY' , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'INSURANCE_POLICY' , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'INSURANCE_POLICY' , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'GL_COMBO_EDIT'    , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'GL_COMBO_EDIT'    , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'GL_COMBO_EDIT'    , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'TAX_JURISDICTION' , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'tax_jurisdiction' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'LEDGER'           , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'ledger' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'LEDGER'           , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'accounting_basis_ledger' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'LEDGER'           , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_ledger' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'EVENT_HIERARCHY'  , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'event_hierarchy' ) );
insert into stn.feed_type_payload ( feed_typ , dbt_id ) values ( 'JOURNAL_LINE'     , ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' ) );
commit;