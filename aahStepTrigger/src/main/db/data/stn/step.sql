insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 1  , 'StandardiseFXRates'              , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'StandardiseReferenceData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'fx_rate-standardise'           and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 2  , 'DSRFXRates'                      , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr02_fx_rate'                and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 3  , 'StandardiseGLAccounts'           , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'StandardiseReferenceData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'gl_account-standardise'        and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 4  , 'DSRGLAccounts'                   , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr11_gl_account'             and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 5  , 'StandardiseDepartments'          , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'StandardiseReferenceData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'department-standardise'        and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 6  , 'DSRDepartments'                  , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr10_book'                   and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 7  , 'StandardiseGLChartfields'        , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'StandardiseReferenceData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'gl_chartfield-standardise'     and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 8  , 'DSRGLChartfields'                , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'DSRReferenceData'         and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'gl_chartfield-dsr'             and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 9  , 'StandardiseLegalEntities'        , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'StandardiseReferenceData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'legal_entity-standardise'      and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 10 , 'DSRLegalEntities'                , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr03_party_legal'            and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 11 , 'DSRPartyBusiness'                , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr04_party_business'         and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 12 , 'DSRLegalEntityHierNodes'         , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr08_org_hier_node'          and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 13 , 'DSRLegalEntityHierLinks'         , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr09_org_hier_struc'         and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 14 , 'DSRInternalProcessEntities'      , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'mah_common'               and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'core' ) )   and process_name = 'mahr17_int_entity'             and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 15 , 'StandardiseLegalEntityLinks'     , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'StandardiseReferenceData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'legal_entity_link-standardise' and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 16 , 'DSRLegalEntitySupplementalData'  , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'DSRReferenceData'         and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'legal_entity-dsr'              and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 17 , 'DSRLegalEntityHierarchyData'     , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'DSRReferenceData'         and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'legal_entity_hierarchies-dsr'  and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 18 , 'StandardiseGLComboEdit'          , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'StandardiseReferenceData' and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'gl_combo_edit-standardise'     and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'standardisation-reference-data' ) );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 19 , 'DSRGLComboEdit'                  , ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'DSRReferenceData'         and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'gl_combo_edit-dsr'             and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'dsr-reference-data' ) );
commit;