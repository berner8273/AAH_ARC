insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'SET_VAL_ERR_LOG_DEFAULTS' , 'Default values used by set based validations writing errors to FR_LOG' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'ROW_VAL_ERR_LOG_DEFAULTS' , 'Default values used by row based validations writing errors to FR_LOG' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'FXR_DEFAULT'              , 'Default values used in the FX rate standardisation process' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'GLA_DEFAULT'              , 'Default values used in the GL account standardisation process' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'DEPT_DEFAULT'             , 'Default values used in the department standardisation process' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'LE_DEFAULT'               , 'Default values used in the legal entity standardisation process' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'GCE_DEFAULT'              , 'Default values used in the GL combo edit standardisation process' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'COMBO_CHECK'              , 'Rules determining valid combo edit combinations' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'COMBO_APPLICABLE'         , 'Rules determining data checked by combo edit process' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'COMBO_RULESET'            , 'Rules used by combo edit process' );
insert into fdr.fr_general_lookup_type ( lkt_lookup_type_code , lkt_lookup_type_name ) values ( 'USER_DEFAULT'             , 'Default values used in the user standardisation process' );

commit;