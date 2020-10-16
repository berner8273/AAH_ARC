create or replace view stn.hopper_tax_jurisdiction
as
select
       fsrgc.srgc_client_code      tax_jurisdiction_cd
     , fsrgc.srgc_client_text2     tax_jurisdiction_descr
     , fsrgc.srgc_valid_from       effective_dt
     , fsrgc.srgc_active           tax_jurisdiction_sts
     , fsrgc.srgc_gct_code_type_id srgc_gct_code_type_id
     , fsrgc.event_status          event_status
     , fsrgc.message_id            message_id
     , fsrgc.process_id            process_id
     , fsrgc.lpg_id                lpg_id
  from
       fdr.fr_stan_raw_general_codes fsrgc
 where
       fsrgc.srgc_gct_code_type_id = 'TAX_JURISDICTION'
  with
       check option
     ;