select
       gcep.feed_uuid                    feed_uuid
	 , fsrgl.srlk_lkt_lookup_type_code   combo_rule_typ
	 , fsrgl.srlk_match_key1      	     combo_rule_or_set
	 , fsrgl.srlk_match_key2      	     combo_attr_or_rule
	 , fsrgl.srlk_match_key3      	     combo_condition
	 , fsrgl.srlk_match_key4      	     combo_condition_typ
	 , fsrgl.srlk_match_key5      	     combo_set_cd 
	 , fsrgl.srlk_lookup_value1   	     combo_action
     , trunc(fsrgl.srlk_effective_from)  effective_from
     , fsrgl.srlk_effective_to           effective_to
     , fsrgl.srlk_active                 combo_edit_sts
     , fsrgl.event_status                event_status
  from
            fdr.fr_stan_raw_general_lookup fsrgl
       join stn.gl_combo_edit_process     gcep    on to_number ( fsrgl.message_id ) = gcep.row_sid	   
 where
       fsrgl.srlk_lkt_lookup_type_code like 'COMBO%'