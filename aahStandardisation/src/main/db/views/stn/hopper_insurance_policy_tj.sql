create or replace view stn.hopper_insurance_policy_tj
as
select
       fsrgc.srgc_gct_code_type_id policy_tax
     , fsrgc.srgc_client_code      policy_id
     , fsrgc.srgc_client_text1     tax_jurisdiction_cd
     , fsrgc.srgc_active           tax_jurisdiction_sts
     , fsrgc.event_status          event_status
     , fsrgc.message_id            message_id
     , fsrgc.process_id            process_id
     , fsrgc.lpg_id                lpg_id
     , fsrgc.srgc_valid_from       valid_from
  from
       fdr.fr_stan_raw_general_codes fsrgc
 where
       fsrgc.srgc_gct_code_type_id = 'POLICY_TAX'
  with
       check option
     ;