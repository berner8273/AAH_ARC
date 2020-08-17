create or replace view rdr.rcv_glint_journal_line
(
   JL_JRNL_HDR_ID,
   MAN_JE_ID,
   JL_JRNL_LINE_NUMBER,
   JL_FAK_ID,
   JL_EBA_ID,
   JL_JRNL_STATUS,
   JL_JRNL_STATUS_TEXT,
   JL_JRNL_PROCESS_ID,
   JL_DESCRIPTION,
   JL_SOURCE_JRNL_ID,
   JL_EFFECTIVE_DATE,
   JL_VALUE_DATE,
   JL_ENTITY,
   JL_EPG_ID,
   JL_ACCOUNT,
   JL_SUB_ACCOUNT,
   JL_SEGMENT_1,
   JL_SEGMENT_2,
   JL_SEGMENT_3,
   JL_SEGMENT_4,
   JL_SEGMENT_5,
   PROGRAM_CODE,
   JL_SEGMENT_7,
   JL_SEGMENT_8,
   JL_SEGMENT_9,
   JL_SEGMENT_10,
   JL_ATTRIBUTE_1,
   JL_ATTRIBUTE_2,
   JL_ATTRIBUTE_3,
   JL_ATTRIBUTE_4,
   JL_ATTRIBUTE_5,
   JL_REFERENCE_1,
   JL_REFERENCE_2,
   JL_REFERENCE_3,
   JL_REFERENCE_4,
   JL_REFERENCE_5,
   JL_REFERENCE_6,
   JL_REFERENCE_7,
   JL_REFERENCE_8,
   JL_REFERENCE_9,
   JL_REFERENCE_10,
   JL_TRAN_CCY,
   JL_TRAN_AMOUNT,
   JL_BASE_RATE,
   JL_BASE_CCY,
   JL_BASE_AMOUNT,
   JL_LOCAL_RATE,
   JL_LOCAL_CCY,
   JL_LOCAL_AMOUNT,
   JL_CREATED_BY,
   JL_CREATED_ON,
   JL_AMENDED_BY,
   JL_AMENDED_ON,
   JL_RECON_STATUS,
   EVENT_CLASS,
   CREDIT_AMT,
   DEBIT_AMT,
   EVENT_STATUS,
   SLR_PROCESS_ID,
   MANUAL_JE,
   JH_JRNL_TYPE,
   JH_JRNL_DESCRIPTION
)
AS
  SELECT /*+parallel*/ 
          jl_jrnl_hdr_id,
          CASE WHEN jt.ejt_madj_flag = 'Y' THEN jl_jrnl_hdr_id ELSE 0 END
             AS jl_jrnl_hdr_id2,
          CAST (jl_jrnl_line_number AS NUMBER (12, 0)) AS jl_jrnl_line_number,
          jl_fak_id,
          jl_eba_id,
          jl_jrnl_status,
          jl_jrnl_status_text,
          CAST (jl_jrnl_process_id AS NUMBER (8, 0)) AS jl_jrnl_process_id,
          CAST (NVL (jl_description, ' ') AS VARCHAR2 (30)) AS jl_description,
          CAST (jl_source_jrnl_id AS VARCHAR2 (10)) AS jl_source_jrnl_id,
          jl_effective_date,
          jl_value_date,
          CAST (jl_entity AS VARCHAR2 (5)) AS jl_entity,
          jl_epg_id,
          CAST (gl.ga_client_text4 AS VARCHAR2 (10)) AS jl_account,
          jl_account AS jl_sub_account,
          CAST (
             CASE WHEN jl_segment_1 = 'NVS' THEN ' ' ELSE jl_segment_1 END AS VARCHAR2 (10))
             AS jl_segment_1,
          CASE WHEN jl_segment_2 = 'NVS' THEN ' ' ELSE jl_segment_2 END
             AS jl_segment_2,
          CAST (
             CASE WHEN jl_segment_3 = 'NVS' THEN ' ' ELSE jl_segment_3 END AS VARCHAR2 (10))
             AS jl_segment_3,
          CAST (
             CASE WHEN jl_segment_4 = 'NVS' THEN ' ' ELSE jl_segment_4 END AS VARCHAR2 (5))
             AS jl_segment_4,
          CAST (
             CASE WHEN jl_segment_5 = 'NVS' THEN ' ' ELSE jl_segment_5 END AS VARCHAR2 (10))
             AS jl_segment_5,
          CASE WHEN jl_entity LIKE 'E%' THEN 'MNCON' ELSE ' ' END
             AS program_code,
          CASE WHEN jl_segment_7 = 'NVS' THEN ' ' ELSE jl_segment_7 END
             AS jl_segment_7,
          CASE WHEN jl_segment_8 = 'NVS' THEN ' ' ELSE jl_segment_8 END
             AS jl_segment_8,
          CASE WHEN jl_segment_9 = 'NVS' THEN ' ' ELSE jl_segment_9 END
             AS jl_segment_9,
          CASE WHEN jl_segment_10 = 'NVS' THEN ' ' ELSE jl_segment_10 END
             AS jl_segment_10,
          CASE WHEN jl_attribute_1 = 'NVS' THEN ' ' ELSE jl_attribute_1 END
             AS jl_attribute_1,
          CASE WHEN jl_attribute_2 = 'NVS' THEN ' ' ELSE jl_attribute_2 END
             AS jl_attribute_2,
          CASE WHEN jl_attribute_3 = 'NVS' THEN ' ' ELSE jl_attribute_3 END
             AS jl_attribute_3,
          CASE WHEN jl_attribute_4 = 'NVS' THEN ' ' ELSE jl_attribute_4 END
             AS jl_attribute_4,
          CASE WHEN jl_attribute_5 = 'NVS' THEN ' ' ELSE jl_attribute_5 END
             AS jl_attribute_5,
          CASE WHEN jl_reference_1 = 'NVS' THEN ' ' ELSE jl_reference_1 END
             AS jl_reference_1,
          CASE WHEN jl_reference_2 = 'NVS' THEN ' ' ELSE jl_reference_2 END
             AS jl_reference_2,
          CASE WHEN jl_reference_3 = 'NVS' THEN ' ' ELSE jl_reference_3 END
             AS jl_reference_3,
          CASE WHEN jl_reference_4 = 'NVS' THEN ' ' ELSE jl_reference_4 END
             AS jl_reference_4,
          CASE WHEN jl_reference_5 = 'NVS' THEN ' ' ELSE jl_reference_5 END
             AS jl_reference_5,
          CASE WHEN jl_reference_6 = 'NVS' THEN ' ' ELSE jl_reference_6 END
             AS jl_reference_6,
          CASE WHEN jl_reference_7 = 'NVS' THEN ' ' ELSE jl_reference_7 END
             AS jl_reference_7,
          CASE WHEN jl_reference_8 = 'NVS' THEN ' ' ELSE jl_reference_8 END
             AS jl_reference_8,
          CASE WHEN jl_reference_9 = 'NVS' THEN ' ' ELSE jl_reference_9 END
             AS jl_reference_9,
          CASE WHEN jl_reference_10 = 'NVS' THEN ' ' ELSE jl_reference_10 END
             AS jl_reference_10,
          CAST (jl_tran_ccy AS VARCHAR2 (3)) AS jl_tran_ccy,
          ROUND (jl_tran_amount, 2) AS jl_tran_amount,
          jl_base_rate,
          CASE
             WHEN JL_SEGMENT_1 = 'UKGAAP_ADJ'
             THEN
                CAST (jl_local_ccy AS VARCHAR2 (3))
             ELSE
                CAST (jl_base_ccy AS VARCHAR2 (3))
          END
             AS jl_base_ccy,
          CASE
             WHEN JL_SEGMENT_1 = 'UKGAAP_ADJ' THEN ROUND (jl_local_amount, 2)
             ELSE ROUND (jl_base_amount, 2)
          END
             AS jl_base_amount,
          jl_local_rate,
          jl_local_ccy,
          ROUND (jl_local_amount, 2) AS jl_local_amount,
          jl_created_by,
          jl_created_on,
          jl_amended_by,
          jl_amended_on,
          jl_recon_status,
          NVL (fgl.lk_lookup_value3, ' ') AS event_class,
          CASE
             WHEN jl_tran_amount < 0 THEN ROUND (jl_tran_amount, 2)
             ELSE 0
          END
             AS credit_amt,
          CASE
             WHEN jl_tran_amount >= 0 THEN ROUND (jl_tran_amount, 2)
             ELSE 0
          END
             AS debit_amt,
          'U' AS event_status,
          jl.jl_jrnl_process_id,
          jt.ejt_madj_flag,
          NVL (jh.jh_jrnl_type, ' ') AS jh_jrnl_type,
          CASE
             WHEN jt.ejt_madj_flag = 'Y'
             THEN
                NVL (jh.jh_jrnl_description, ' ')
             ELSE
                ' '
          END
             AS jh_jrnl_description
     FROM slr.slr_jrnl_lines jl
          LEFT JOIN fdr.fr_general_lookup fgl
             ON     jl.jl_attribute_4 = fgl.lk_match_key1
                AND fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
                AND (   (    jl.jl_segment_1 = 'UKGAAP_ADJ'
                         AND fgl.lk_lookup_value5 = 'N')
                     OR jl.jl_segment_1 <> 'UKGAAP_ADJ')
          LEFT JOIN fdr.fr_gl_account gl
             ON jl.jl_account = gl.ga_account_code
          LEFT JOIN rdr.rr_glint_temp_journal jh
             ON jh.jh_jrnl_id = jl.jl_jrnl_hdr_id
          LEFT JOIN slr.slr_ext_jrnl_types jt
             ON jt.ejt_type = jh.jh_jrnl_type
    WHERE jh.jh_jrnl_internal_period_flag = 'N'
    AND (EXISTS
                     (SELECT NULL
                        FROM fdr.fr_general_lookup fgl2
                       WHERE     fgl.lk_lookup_value3 = fgl2.lk_match_key1
                             AND fgl2.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
                             AND jl.jl_effective_date <= (select min(period_end) from stn.period_status)));

COMMENT ON TABLE RDR.RCV_GLINT_JOURNAL_LINE IS 'Configurable View on Journal Lines that should be considered for sending to the GL.';