create or replace view rdr.rcv_combination_check_glint (
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
  ci_suspense_id)
as
select to_char(jl_jrnl_hdr_id) || '_' || to_char(jl_jrnl_line_number) as ci_input_id,
       jh.jh_jrnl_source as ci_ruleset,
       jl_entity         as ci_attribute_1,
       jl_account        as ci_attribute_2,
       jl_tran_ccy       as ci_attribute_3,
       case jl_segment_1 when 'NVS' then null else jl_segment_1 end as ci_attribute_4,
       case jl_segment_2 when 'NVS' then null else jl_segment_2 end as ci_attribute_5,
       case jl_segment_3 when 'NVS' then null else jl_segment_3 end as ci_attribute_6,
       case jl_segment_4 when 'NVS' then null else jl_segment_4 end as ci_attribute_7,
       case jl_segment_5 when 'NVS' then null else jl_segment_5 end as ci_attribute_8,
       case jl_segment_6 when 'NVS' then null else jl_segment_6 end as ci_attribute_9,
       case jl_segment_7 when 'NVS' then null else jl_segment_7 end as ci_attribute_10,
       lk_lookup_key_id as ci_suspense_id
  from slr.slr_jrnl_lines
  join slr.slr_jrnl_headers jh on jl_jrnl_hdr_id = jh.jh_jrnl_id
                              and jl_epg_id = jh.jh_jrnl_epg_id
  join rr_glint_temp_journal tj on jl_jrnl_hdr_id = tj.jh_jrnl_id
                               and jl_epg_id = tj.jh_jrnl_epg_id
  join slr.slr_entities on ent_entity = jl_entity
                       and ent_combo_check_flag = 'Y'
  left join fdr.fr_general_lookup on lk_lkt_lookup_type_code = 'COMBO_SUSPENSE'
                                 and lk_match_key1 = 'RCV_COMBINATION_CHECK_GLINT'
                                 and (lk_match_key2 = jh.jh_jrnl_type or lk_match_key2 = 'ANY');
comment on table rdr.rcv_combination_check_glint is 'Configurable View to map Posted Journal Lines to Combination Check Attributes. Assumes the GL Interface Temporary Table has been populated by the interface (RR_GLINT_TEMP_JOURNAL).';