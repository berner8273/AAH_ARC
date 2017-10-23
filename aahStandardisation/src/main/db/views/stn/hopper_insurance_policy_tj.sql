create or replace view stn.hopper_insurance_policy_tj
as
select
       fsrgc.srgc_gct_code_type_id policy_tax
     , fsrgc.srgc_client_code      policy_id_tax_cd
     , fsrgc.srgc_client_text1     policy_id
     , fsrgc.srgc_client_text2     tax_jurisdiction_cd
     , fsrgc.srgc_client_text3     tax_jurisdiction_pct
     , fsrgc.srgc_active           tax_jurisdiction_sts
     , fsrgc.event_status          event_status
     , fsrgc.message_id            message_id
     , fsrgc.process_id            process_id
     , fsrgc.lpg_id                lpg_id
     , fsrgc.srgc_valid_from       valid_from
     , fsrgc.srgc_valid_to         valid_to
  from
       fdr.fr_stan_raw_general_codes fsrgc
 where
       fsrgc.srgc_gct_code_type_id = 'POLICY_TAX'
  with
       check option
     ;