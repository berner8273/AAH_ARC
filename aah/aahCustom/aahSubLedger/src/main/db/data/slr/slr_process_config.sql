insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'FX_AG_RULE0_USGAAP' , 'FXREVALUE'     , 'FXREVALUE'     , 'E' , 'L' , null , null , 'TRANS-BASE' );
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'FX_AG_RULE0_USSTAT' , 'FXREVALUE'     , 'FXREVALUE'     , 'E' , 'L' , null , null , 'TRANS-BASE' );
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'FX_AG_RULE0_UKGAAP' , 'FXREVALUE'     , 'FXREVALUE'     , 'E' , 'L' , null , null , 'TRANS-LOCAL' );
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'FX_AG_RULE2_USGAAP' , 'FXREVALUE'     , 'FXREVALUE'     , 'E' , 'P' , null , null , 'TRANS-BASE' );
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'FX_AG_RULE2_USSTAT' , 'FXREVALUE'     , 'FXREVALUE'     , 'E' , 'P' , null , null , 'TRANS-BASE' );
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'FX_AG_RULE2_UKGAAP' , 'FXREVALUE'     , 'FXREVALUE'     , 'E' , 'P' , null , null , 'TRANS-LOCAL' );
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'PLRETEARNINGS01'    , 'PLRETEARNINGS' , 'PLRETEARNINGS' , 'E' , 'L' , null , null , 'DEFAULT' );
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'PLRETEARNINGS02'    , 'PLRETEARNINGS' , 'PLRETEARNINGS' , 'E' , 'L' , null , null , 'DEFAULT' ); 
insert into slr.slr_process_config ( pc_config , pc_p_process , pc_jt_type , pc_fak_eba_flag , pc_aggregation , pc_fx_manage_ccy , pc_custom_procedure , pc_method ) values ( 'PLRETEARNINGS03'    , 'PLRETEARNINGS' , 'PLRETEARNINGS' , 'E' , 'L' , null , null , 'DEFAULT' );
commit;