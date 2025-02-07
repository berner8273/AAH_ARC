DROP VIEW RDR.RRV_AG_SLR_JRNL_LINES;

/* Formatted on 10/02/2024 4:43:19 PM (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW RDR.RRV_AG_SLR_JRNL_LINES
(
   JL_JRNL_HDR_ID,
   JL_JRNL_LINE_NUMBER,
   JL_FAK_ID,
   JL_EBA_ID,
   JL_JRNL_STATUS,
   JL_JRNL_STATUS_TEXT,
   JL_JRNL_PROCESS_ID,
   JL_DESCRIPTION,
   JL_SOURCE_JRNL_ID,
   EFFECTIVE_DATE,
   POSTING_PERIOD,
   BUSINESS_UNIT,
   JL_EPG_ID,
   SUB_ACCOUNT,
   LEDGER,
   ACCOUNTING_BASIS,
   DEPARTMENT,
   AFFILIATE,
   CHARTFIELD1,
   EXECUTION_TYPE,
   BUSINESS_TYPE,
   POLICY_ID,
   STREAM,
   TAX_JURISDICTION,
   PREMIUM_TYPE,
   ACCOUNTING_EVENT_TYPE,
   JOURNAL_DESCR,
   GROSS_STREAM_OWNER,
   UNDERWRITING_YEAR,
   OWNER_ENTITY,
   BUSINESS_EVENT_TYPE,
   ACCIDENT_YEAR,
   INT_EXT_COUNTERPARTY,
   CURRENCY,
   TRANSACTION_AMT,
   REPORTING_RATE,
   REPORTING_CURRENCY,
   REPORTING_AMT,
   FUNCTIONAL_RATE,
   FUNCTIONAL_CURRENCY,
   FUNCTIONAL_AMT,
   JL_CREATED_BY,
   JL_CREATED_ON,
   JL_AMENDED_BY,
   JL_AMENDED_ON,
   JL_RECON_STATUS,
   JL_TRANSLATION_DATE,
   JL_BUS_POSTING_DATE,
   JL_PERIOD_MONTH,
   JL_PERIOD_YEAR,
   JL_PERIOD_LTD,
   JL_TYPE,
   CORRELATION_UUID,
   EVENT_SEQ_ID,
   POSTING_INDICATOR,
   JLU_JRNL_TYPE,
   JLU_JRNL_DATE,
   JLU_JRNL_DESCRIPTION,
   JLU_JRNL_SOURCE,
   JLU_JRNL_SOURCE_JRNL_ID,
   JLU_JRNL_AUTHORISED_BY,
   JLU_JRNL_AUTHORISED_ON,
   JLU_JRNL_VALIDATED_BY,
   JLU_JRNL_VALIDATED_ON,
   JLU_JRNL_POSTED_BY,
   JLU_JRNL_POSTED_ON,
   JLU_JRNL_TOTAL_HASH_DEBIT,
   JLU_JRNL_TOTAL_HASH_CREDIT,
   JLU_JRNL_PREF_STATIC_SRC,
   JLU_JRNL_REF_ID,
   JLU_JRNL_REV_DATE,
   JLU_TRANSLATION_DATE,
   JLU_PERIOD_MONTH,
   JLU_PERIOD_YEAR,
   JLU_PERIOD_LTD,
   JLU_JRNL_INTERNAL_PERIOD_FLAG,
   JLU_JRNL_ENT_RATE_SET
)
   BEQUEATH DEFINER
AS
   SELECT jl.jl_jrnl_hdr_id,
          jl.jl_jrnl_line_number,
          jl.jl_fak_id,
          jl.jl_eba_id,
          jl.jl_jrnl_status,
          jl.jl_jrnl_status_text,
          jl.jl_jrnl_process_id,
          jl.jl_description,
          jl.jl_source_jrnl_id,
          jl.jl_effective_date effective_date,
          jl.jl_value_date posting_period,
          jl.jl_entity business_unit,
          jl.jl_epg_id,
          jl.jl_account sub_account,
          jl.jl_segment_1 ledger,
          jl.jl_segment_2 accounting_basis,
          jl.jl_segment_3 department,
          jl.jl_segment_4 affiliate,
          jl.jl_segment_5 chartfield1,
          jl.jl_segment_6 execution_type,
          jl.jl_segment_7 business_type,
          jl.jl_segment_8 policy_id,
          jl.jl_attribute_1 stream,
          jl.jl_attribute_2 tax_jurisdiction,
          jl.jl_attribute_3 premium_type,
          jl.jl_attribute_4 accounting_event_type,
          jl.jl_reference_1 journal_descr,
          jl.jl_reference_2 gross_stream_owner,
          jl.jl_reference_3 underwriting_year,
          jl.jl_reference_4 owner_entity,
          jl.jl_reference_5 business_event_type,
          jl.jl_reference_6 accident_year,
          jl.jl_reference_7 int_ext_counterparty,
          jl.jl_tran_ccy currency,
          jl.jl_tran_amount transaction_amt,
          jl.jl_base_rate reporting_rate,
          jl.jl_base_ccy reporting_currency,
          jl.jl_base_amount reporting_amt,
          jl.jl_local_rate functional_rate,
          jl.jl_local_ccy functional_currency,
          jl.jl_local_amount functional_amt,
          jl.jl_created_by,
          jl.jl_created_on,
          jl.jl_amended_by,
          jl.jl_amended_on,
          jl.jl_recon_status,
          jl.jl_translation_date,
          jl.jl_bus_posting_date,
          jl.jl_period_month,
          jl.jl_period_year,
          jl.jl_period_ltd,
          jl.jl_type,
          CAST (NULL AS VARCHAR (100)) correlation_uuid,
          CAST (NULL AS VARCHAR (100)) event_seq_id,
          CAST (NULL AS VARCHAR (100)) posting_indicator,
          NULL jlu_jrnl_type,
          NULL jlu_jrnl_date,
          NULL jlu_jrnl_description,
          NULL jlu_jrnl_source,
          NULL jlu_jrnl_source_jrnl_id,
          NULL jlu_jrnl_authorised_by,
          NULL jlu_jrnl_authorised_on,
          NULL jlu_jrnl_validated_by,
          NULL jlu_jrnl_validated_on,
          NULL jlu_jrnl_posted_by,
          NULL jlu_jrnl_posted_on,
          NULL jlu_jrnl_total_hash_debit,
          NULL jlu_jrnl_total_hash_credit,
          NULL jlu_jrnl_pref_static_src,
          NULL jlu_jrnl_ref_id,
          NULL jlu_jrnl_rev_date,
          NULL jlu_translation_date,
          NULL jlu_period_month,
          NULL jlu_period_year,
          NULL jlu_period_ltd,
          NULL jlu_jrnl_internal_period_flag,
          NULL jlu_jrnl_ent_rate_set
     FROM slr.slr_jrnl_lines jl
   UNION ALL
   SELECT jlu.jlu_jrnl_hdr_id,
          jlu.jlu_jrnl_line_number,
          jlu.jlu_fak_id,
          jlu.jlu_eba_id,
          jlu.jlu_jrnl_status,
          jlu.jlu_jrnl_status_text,
          jlu.jlu_jrnl_process_id,
          jlu.jlu_description,
          jlu.jlu_source_jrnl_id,
          jlu.jlu_effective_date,
          jlu.jlu_value_date,
          jlu.jlu_entity,
          jlu.jlu_epg_id,
          jlu.jlu_account,
          jlu.jlu_segment_1,
          jlu.jlu_segment_2,
          jlu.jlu_segment_3,
          jlu.jlu_segment_4,
          jlu.jlu_segment_5,
          jlu.jlu_segment_6,
          jlu.jlu_segment_7,
          jlu.jlu_segment_8,
          jlu.jlu_attribute_1,
          jlu.jlu_attribute_2,
          jlu.jlu_attribute_3,
          jlu.jlu_attribute_4,
          jlu.jlu_reference_1,
          jlu.jlu_reference_2,
          jlu.jlu_reference_3,
          jlu.jlu_reference_4,
          jlu.jlu_reference_5,
          jlu.jlu_reference_6,
          jlu.jlu_reference_7,
          jlu.jlu_tran_ccy,
          jlu.jlu_tran_amount,
          jlu.jlu_base_rate,
          jlu.jlu_base_ccy,
          jlu.jlu_base_amount,
          jlu.jlu_local_rate,
          jlu.jlu_local_ccy,
          jlu.jlu_local_amount,
          jlu.jlu_created_by,
          jlu.jlu_created_on,
          jlu.jlu_amended_by,
          jlu.jlu_amended_on,
          NULL jl_recon_status,
          NULL jl_translation_date,
          NULL jl_bus_posting_date,
          NULL jl_period_month,
          NULL jl_period_year,
          NULL jl_period_ltd,
          jlu.jlu_type,
          CAST (NULL AS VARCHAR (100)) correlation_uuid,
          CAST (NULL AS VARCHAR (100)) event_seq_id,
          CAST (NULL AS VARCHAR (100)) posting_indicator,
          jlu.jlu_jrnl_type,
          jlu.jlu_jrnl_date,
          jlu.jlu_jrnl_description,
          jlu.jlu_jrnl_source,
          jlu.jlu_jrnl_source_jrnl_id,
          jlu.jlu_jrnl_authorised_by,
          jlu.jlu_jrnl_authorised_on,
          jlu.jlu_jrnl_validated_by,
          jlu.jlu_jrnl_validated_on,
          jlu.jlu_jrnl_posted_by,
          jlu.jlu_jrnl_posted_on,
          jlu.jlu_jrnl_total_hash_debit,
          jlu.jlu_jrnl_total_hash_credit,
          jlu.jlu_jrnl_pref_static_src,
          jlu.jlu_jrnl_ref_id,
          jlu.jlu_jrnl_rev_date,
          jlu.jlu_translation_date,
          jlu.jlu_period_month,
          jlu.jlu_period_year,
          jlu.jlu_period_ltd,
          jlu.jlu_jrnl_internal_period_flag,
          jlu.jlu_jrnl_ent_rate_set
     FROM slr.slr_jrnl_lines_unposted jlu
   UNION ALL
   SELECT gjlu.jlu_jrnl_hdr_id,
          gjlu.jlu_jrnl_line_number,
          CAST (gjlu.jlu_fak_id AS VARCHAR2 (32)),
          CAST (gjlu.jlu_eba_id AS VARCHAR2 (32)),
          DECODE (jle.jle_error_code, NULL, gjlu.jlu_jrnl_status, 'E')
             jlu_jrnl_status,
          NVL (SUBSTR (jle.jle_error_string, 1, 20),
               gjlu.jlu_jrnl_status_text)
             jlu_jrnl_status_text,
          jlu_jrnl_process_id,
          jlu_description,
          jlu_source_jrnl_id,
          jlu_effective_date,
          jlu_value_date,
          jlu_entity,
          jlu_epg_id,
          jlu_account,
          jlu_segment_1,
          jlu_segment_2,
          jlu_segment_3,
          jlu_segment_4,
          jlu_segment_5,
          jlu_segment_6,
          jlu_segment_7,
          jlu_segment_8,
          jlu_attribute_1,
          jlu_attribute_2,
          jlu_attribute_3,
          jlu_attribute_4,
          jlu_reference_1,
          jlu_reference_2,
          jlu_reference_3,
          jlu_reference_4,
          jlu_reference_5,
          jlu_reference_6,
          jlu_reference_7,
          jlu_tran_ccy,
          jlu_tran_amount,
          jlu_base_rate,
          jlu_base_ccy,
          jlu_base_amount,
          jlu_local_rate,
          jlu_local_ccy,
          jlu_local_amount,
          jlu_created_by,
          jlu_created_on,
          jlu_amended_by,
          jlu_amended_on,
          NULL jl_recon_status,
          NULL jl_translation_date,
          NULL jl_bus_posting_date,
          NULL jl_period_month,
          NULL jl_period_year,
          NULL jl_period_ltd,
          NULL jl_type,
          NULL correlation_uuid,
          NULL event_seq_id,
          NULL posting_indicator,
          jlu_jrnl_type,
          jlu_jrnl_date,
          jlu_jrnl_description,
          jlu_jrnl_source,
          jlu_jrnl_source_jrnl_id,
          jlu_jrnl_authorised_by,
          jlu_jrnl_authorised_on,
          jlu_jrnl_validated_by,
          jlu_jrnl_validated_on,
          jlu_jrnl_posted_by,
          jlu_jrnl_posted_on,
          jlu_jrnl_total_hash_debit,
          jlu_jrnl_total_hash_credit,
          jlu_jrnl_pref_static_src,
          CAST (
             DECODE (jlu_jrnl_ref_id,
                     NULL, NULL,
                     STANDARD_HASH (jlu_jrnl_ref_id, 'MD5')) AS VARCHAR2 (32))
             jlu_jrnl_ref_id,
          jlu_jrnl_rev_date,
          jlu_translation_date,
          jlu_period_month,
          jlu_period_year,
          jlu_period_ltd,
          NULL jlu_jrnl_internal_period_flag,
          NULL jlu_jrnl_ent_rate_set
     FROM gui.gui_jrnl_lines_unposted gjlu
          LEFT JOIN
          (  SELECT jle1.jle_jrnl_hdr_id,
                    MIN (jle1.jle_error_code) jle_error_code,
                    MIN (jle1.jle_error_string) jle_error_string
               FROM gui.gui_jrnl_line_errors jle1
           GROUP BY jle1.jle_jrnl_hdr_id) jle
             ON gjlu.jlu_jrnl_hdr_id = jle.jle_jrnl_hdr_id;


GRANT SELECT ON RDR.RRV_AG_SLR_JRNL_LINES TO AAH_RDR;

GRANT SELECT ON RDR.RRV_AG_SLR_JRNL_LINES TO AAH_READ_ONLY;
