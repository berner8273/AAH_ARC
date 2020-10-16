create or replace view slr.scv_combination_check_jlu (
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
  epg_id,
  status)
as
select to_char(jlu_jrnl_hdr_id) || '_' || to_char(jlu_jrnl_line_number) as ci_input_id,  --Could change this to the FAK Combination ID if it causes issues (will then have to extrapolate back in the later processes).
       jlu_segment_1 || '_' || jlu_entity  as ci_ruleset,
       jlu_entity                                                     as ci_attribute_1, --le_id
       jlu_account                                                    as ci_attribute_2, --subaccount
       fga.ga_client_text4                                            as ci_attribute_3, --account
       case jlu_segment_1 when 'NVS' then null else jlu_segment_1 end as ci_attribute_4, --ledger_cd
       case jlu_segment_2 when 'NVS' then null else jlu_segment_2 end as ci_attribute_5, --basis_cd
       case jlu_segment_3 when 'NVS' then null else jlu_segment_3 end as ci_attribute_6, --dept_cd
       case jlu_segment_4 when 'NVS' then null else jlu_segment_4 end as ci_attribute_7, --affiliate
       jlu_segment_1 || '_' || jlu_entity                             as ci_attribute_8, --ledger/entity combo
       NULL                                                           as ci_attribute_9,
       NULL                                                           as ci_attribute_10,
       lk_lookup_key_id                                               as ci_suspense_id,
       jlu_epg_id                                                     as epg_id,
       jlu_jrnl_status                                                as status
  from slr_jrnl_lines_unposted jlu
  join slr_entities on jlu_entity = ent_entity
  left join fdr.fr_general_lookup on lk_lkt_lookup_type_code = 'COMBO_SUSPENSE'
                                 and lk_match_key1 = 'SCV_COMBINATION_CHECK_JLU'
                                 and (lk_match_key2 = jlu_jrnl_type or lk_match_key2 = 'ANY')
   join fdr.fr_gl_account fga on jlu.jlu_account = fga.ga_account_code;
comment on table slr.scv_combination_check_jlu is 'Configurable View to map Unposted Journal Lines to Combination Check Attributes.';