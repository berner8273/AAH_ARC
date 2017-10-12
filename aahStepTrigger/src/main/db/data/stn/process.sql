insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 1  , 'fx_rate-standardise'           , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 2  , 'mahr02_fx_rate'                , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_FX_RATE__enriched' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 3  , 'gl_account-standardise'        , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 4  , 'mahr11_gl_account'             , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 5  , 'department-standardise'        , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 6  , 'mahr10_book'                   , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 7  , 'gl_chartfield-standardise'     , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 8  , 'gl_chartfield-dsr'             , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 9  , 'legal_entity-standardise'      , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 10 , 'mahr03_party_legal'            , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_PARTY_LEGAL' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 11 , 'mahr04_party_business'         , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_PARTY_BUSINESS' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 12 , 'mahr08_org_hier_node'          , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_ORG_HIER_NODE__enriched' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 13 , 'mahr09_org_hier_struc'         , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_ORG_HIER_STRUC__enriched' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 14 , 'mahr17_int_entity'             , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_INT_ENTITY_enriched' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 15 , 'legal_entity_link-standardise' , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 16 , 'legal_entity-dsr'              , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 17 , 'legal_entity_hierarchies-dsr'  , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 18 , 'insurance_policy-standardise'  , ( select project_id from stn.project where project_name = 'StandardiseInsurancePolicyData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 19 , 'cession_event-standardise'     , ( select project_id from stn.project where project_name = 'StandardiseInsurancePolicyData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 20 , 'gl_combo_edit-standardise'     , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 21 , 'gl_combo_edit-dsr'             , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 22 , 'user-standardise'              , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 23 , 'tax_jurisdiction-standardise'  , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 24 , 'tax_jurisdiction-dsr'          , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 25 , 'maha01_acc_event'              , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_ACC_EVENT_enriched' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 26 , 'mahinp01_insurance_policy'     , ( select project_id from stn.project where project_name = 'mah_fdr_trans'                  and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_INSURANCE_POLICY' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 27 , 'policy_tax_jurisdiction-dsr'   , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 28 , 'fx_rate-subledger'             , ( select project_id from stn.project where project_name = 'Subledger'                      and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 29 , 'account-subledger'             , ( select project_id from stn.project where project_name = 'Subledger'                      and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 30 , 'ledger-standardise'            , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 31 , 'ledger-dsr'                    , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 32 , 'accounting_event-standardise'  , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 33 , 'accounting_event-dsr'          , ( select project_id from stn.project where project_name = 'DSRReferenceData'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 34 , 'journal_line-standardise'      , ( select project_id from stn.project where project_name = 'StandardiseReferenceData'       and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'Source' );
insert into stn.process ( process_id , process_name , project_id , process_type_id , input_node_name ) values ( 35 , 'maha02_adjustment_load'        , ( select project_id from stn.project where project_name = 'mah_common'                     and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core'   ) ) , ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) , 'FR_STAN_RAW_ADJUSTMENT_enriched' );

commit;