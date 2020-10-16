create or replace view rdr.rcv_glint_journal(
  jh_jrnl_id,                --Mandatory
  jh_jrnl_type,              --Mandatory
  jh_jrnl_date,              --Mandatory
  jh_jrnl_entity,            --Mandatory
  jh_jrnl_epg_id,            --Mandatory
  jh_jrnl_status,
  jh_jrnl_status_text,
  jh_jrnl_process_id,
  jh_jrnl_description,
  jh_jrnl_source,
  jh_jrnl_source_jrnl_id,
  jh_jrnl_pref_static_src,
  jh_jrnl_ref_id,
  jh_jrnl_rev_date,
  jh_jrnl_authorised_by,
  jh_jrnl_authorised_on,
  jh_jrnl_validated_by,
  jh_jrnl_validated_on,
  jh_jrnl_posted_by,
  jh_jrnl_posted_on,
  jh_jrnl_total_hash_debit,
  jh_jrnl_total_hash_credit,
  jh_jrnl_total_lines,
  jh_created_by,
  jh_created_on,
  jh_amended_by,
  jh_amended_on,
  jh_bus_posting_date,
  jh_jrnl_internal_period_flag,
  jh_jrnl_ent_rate_set,
  jh_jrnl_translation_date)
As
Select jh_jrnl_id,
       jh_jrnl_type,
       jh_jrnl_date,
       jh_jrnl_entity,
       jh_jrnl_epg_id,
       jh_jrnl_status,
       jh_jrnl_status_text,
       jh_jrnl_process_id,
       jh_jrnl_description,
       jh_jrnl_source,
       jh_jrnl_source_jrnl_id,
       jh_jrnl_pref_static_src,
       jh_jrnl_ref_id,
       jh_jrnl_rev_date,
       jh_jrnl_authorised_by,
       jh_jrnl_authorised_on,
       jh_jrnl_validated_by,
       jh_jrnl_validated_on,
       jh_jrnl_posted_by,
       jh_jrnl_posted_on,
       jh_jrnl_total_hash_debit,
       jh_jrnl_total_hash_credit,
       jh_jrnl_total_lines,
       jh_created_by,
       jh_created_on,
       jh_amended_by,
       jh_amended_on,
       jh_bus_posting_date,
       jh_jrnl_internal_period_flag,
       jh_jrnl_ent_rate_set,
       jh_jrnl_translation_date
  from slr.slr_jrnl_headers
 where 1=1
--Remove optional attributes as necessary, add other attributes as per the configuration.
--May wish to filter out journals that should never be sent to the GL (for example those journals that are posted into currently closed periods).
;
COMMENT ON TABLE rdr.rcv_glint_journal IS 'Configurable View on Journals that should be considered for sending to the GL.';