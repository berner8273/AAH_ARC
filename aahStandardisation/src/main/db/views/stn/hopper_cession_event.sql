create or replace view stn.hopper_cession_event
as
select
       fsrae.srae_gl_entity              business_unit
     , fsrae.srae_gl_book                book_cd
     , fsrae.srae_dimension_1            chartfield_1
     , fsrae.srae_dimension_2            dept_cd
     , fsrae.srae_dimension_3            counterparty_le_cd
     , fsrae.srae_dimension_4            affiliate_le_cd
     , fsrae.srae_dimension_5            accident_yr
     , fsrae.srae_dimension_6            underwriting_yr
     , fsrae.srae_dimension_7            policy_id
     , fsrae.srae_dimension_8            stream_id
     , fsrae.srae_dimension_9            tax_jurisdiction_cd
     , fsrae.srae_dimension_10           ledger_cd
     , fsrae.srae_dimension_11           execution_typ
     , fsrae.srae_dimension_12           business_typ
     , fsrae.srae_dimension_13           owner_le_id
     , fsrae.srae_dimension_14           premium_typ
     , fsrae.srae_dimension_15           journal_descr
     , fsrae.srae_client_spare_id3       ultimate_parent_stream_id
     , fsrae.srae_client_spare_id4       event_typ
     , fsrae.srae_client_spare_id5       functional_ccy
     , fsrae.srae_client_spare_id6       functional_amt
     , fsrae.srae_client_spare_id7       reporting_ccy
     , fsrae.srae_client_spare_id8       reporting_amt
     , fsrae.srae_client_spare_id9       is_mark_to_market
     , fsrae.srae_client_spare_id10      vie_cd
     , fsrae.srae_client_spare_id11      business_event_typ
     , fsrae.srae_client_spare_id12      event_seq_id
     , fsrae.srae_client_spare_id13      policy_typ
     , fsrae.srae_client_spare_id14      correlation_uuid
     , fsrae.srae_acc_event_type         aah_event_typ
     , fsrae.srae_iso_currency_code      transaction_ccy
     , fsrae.srae_client_amount1         transaction_amt
     , fsrae.srae_pos_neg_flag           transaction_pos_neg
     , fsrae.srae_sub_event_id           sub_event
     , fsrae.srae_accevent_date          accounting_dt
     , fsrae.srae_gl_party_business_code party_business_le_cd
     , fsrae.srae_party_sys_inst_code    party_business_system_cd
     , fsrae.srae_instr_super_class      srae_instr_super_class
     , fsrae.srae_static_sys_inst_code   srae_static_sys_inst_code
     , fsrae.srae_instr_sys_inst_code    srae_instr_sys_inst_code
     , fsrae.srae_gl_person_code         srae_gl_person_code
     , fsrae.srae_source_system          srae_source_system
     , fsrae.srae_instrument_code        srae_instrument_code
     , fsrae.srae_dimension_11           basis_cd
     , fsrae.srae_posting_date           posting_dt
     , fsrae.event_status                event_status
     , fsrae.message_id                  message_id
     , fsrae.process_id                  process_id
     , fsrae.lpg_id                      lpg_id
  from
       fdr.fr_stan_raw_acc_event fsrae
     ;