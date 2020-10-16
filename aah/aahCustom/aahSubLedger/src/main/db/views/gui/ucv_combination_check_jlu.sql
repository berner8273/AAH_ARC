create or replace view gui.ucv_combination_check_jlu (
  ci_input_id,
  ci_ruleset,
  ci_attribute_1,
  ci_attribute_2,
  ci_attribute_3,
  ci_attribute_4,
  ci_attribute_5,
  ci_attribute_6,
  ci_attribute_7,
  ci_attribute_8,
  ci_attribute_9,
  ci_attribute_10,
  ci_suspense_id,
  journal_id,
  session_id)
as
select to_char(jlu.jlu_jrnl_hdr_id) || '_' || to_char(jlu.jlu_jrnl_line_number) as ci_input_id,
       jlu.jlu_source_jrnl_id as ci_ruleset,
       jlu.jlu_entity         as ci_attribute_1,
       jlu.jlu_account        as ci_attribute_2,
       jlu.jlu_tran_ccy       as ci_attribute_3,
       case jlu.jlu_segment_1 when 'NVS' then null else jlu.jlu_segment_1 end as ci_attribute_4,
       case jlu.jlu_segment_2 when 'NVS' then null else jlu.jlu_segment_2 end as ci_attribute_5,
       case jlu.jlu_segment_3 when 'NVS' then null else jlu.jlu_segment_3 end as ci_attribute_6,
       case jlu.jlu_segment_4 when 'NVS' then null else jlu.jlu_segment_4 end as ci_attribute_7,
       case jlu.jlu_segment_5 when 'NVS' then null else jlu.jlu_segment_5 end as ci_attribute_8,
       case jlu.jlu_segment_6 when 'NVS' then null else jlu.jlu_segment_6 end as ci_attribute_9,
       case jlu.jlu_segment_7 when 'NVS' then null else jlu.jlu_segment_7 end as ci_attribute_10,
       lk_lookup_key_id as ci_suspense_id,
       jlu.jlu_jrnl_hdr_id as journal_id,
       jlu.user_session_id as session_id
  from temp_gui_jrnl_lines_unposted jlu
  join temp_gui_jrnl_headers_unposted jhu on jlu.user_session_id = jhu.user_session_id
                                         and jlu.jlu_jrnl_hdr_id = jhu.jhu_jrnl_id
  join slr.slr_entities on jlu.jlu_entity = ent_entity
                       and ent_combo_check_flag = 'Y'
  left join fdr.fr_general_lookup on lk_lkt_lookup_type_code = 'COMBO_SUSPENSE'
                                 and lk_match_key1 = 'UCV_COMBINATION_CHECK_JLU'
                                 and (lk_match_key2 = jhu.jhu_jrnl_type or lk_match_key2 = 'ANY');
comment on table gui.ucv_combination_check_jlu is 'Configurable View to map GUI Unposted Journal Lines to Combination Check Attributes. Requires Journal ID and Session ID for the combination check process to identify the relevant journal to check.';