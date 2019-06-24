CREATE OR REPLACE VIEW "RDR"."RRV_AG_JOURNAL_LINES"
AS
SELECT
    eh.event_class AS event_class
  , jh.jh_jrnl_entity AS business_unit
  , CASE WHEN jt.ejt_madj_flag = 'Y'
                    THEN 'Manual'
                    ELSE 'Automated'
            END AS manual_flag
  , jh.jh_jrnl_type AS journal_type
  , jh.jh_jrnl_status AS journal_status
  , jl.jl_type AS type
  , jl.jl_jrnl_hdr_id AS journal_header_id
  , jl.jl_jrnl_line_number AS journal_line_id
  , jl.jl_effective_date AS effective_date
  , jl.jl_value_date as value_date
  , jl.jl_segment_1 AS ledger
  , jl.jl_segment_4  AS affiliate
  , jl.jl_account AS account
  , jl.jl_segment_3 AS department
  , jl.jl_segment_5 AS chartfield1
  , jl.jl_segment_6 AS executiont_ype
  , jl.jl_segment_7 AS business_type
  , jl.jl_attribute_3 AS premium_type
  , jl.jl_segment_8 AS policy
  , jl.jl_attribute_1 AS stream
  , jl.jl_attribute_4 AS acc_event_type
  , jl.jl_attribute_2 AS tax_jurisdiction
  , CASE WHEN jl.jl_segment_1  ='UKGAAP_ADJ'
            THEN jl.jl_local_ccy 
            ELSE jl.jl_base_ccy
        END functional_ccy
  , CASE WHEN jl.jl_segment_1 ='UKGAAP_ADJ'
            THEN jl.jl_local_amount
            ELSE jl.jl_base_amount
        END functional_ccy_amt
  , jl.jl_tran_ccy AS transactional_ccy
  , jl.jl_tran_amount AS transactional_ccy_amt
  , bt.business_typ_descr AS business_type_name
  , pt.premium_typ_descr AS premium_type_name
  , eh.event_class_descr AS process
  , CONCAT (CONCAT (jl.jl_account,': '),gl.ga_account_name)AS account_descr
  , jh.jh_jrnl_posted_on as posted_date
  , jh.jh_jrnl_authorised_on as authorised_date
  , jh.jh_jrnl_validated_on as validated_date
  , jh.jh_created_on as created_date
  , jh.jh_created_by AS requestor
  , jh.jh_jrnl_authorised_by AS approver
  , CASE WHEN gjl.rgjl_id is not null
            THEN 'Y'
            ELSE 'N' 
        END AS glint_flag
  , gjl.event_status AS glint_status
  , gjl.rgjl_rgj_rgbc_id AS glint_header_id
  , gjl.rgjl_id AS glint_line_id
  , gjl.accounting_dt AS glint_acctng_date
FROM slr.slr_jrnl_lines jl
    LEFT JOIN slr.slr_jrnl_headers jh
        ON jl.jl_jrnl_hdr_id = jh.jh_jrnl_id
    LEFT JOIN rdr.rr_glint_to_slr_ag gts  
        ON jl.jl_jrnl_hdr_id = gts.jl_jrnl_hdr_id
        AND jl.jl_jrnl_line_number = gts.jl_jrnl_line_number
    LEFT JOIN rdr.rr_glint_journal_line gjl  
        ON gts.rgjl_id = gjl.rgjl_id
    LEFT JOIN slr.slr_ext_jrnl_types jt
        ON jt.ejt_type = jh.jh_jrnl_type
    LEFT JOIN rdr.rrv_ag_event_hierarchy eh
        ON jl.jl_attribute_4 = eh.event_type
    LEFT JOIN fdr.fr_gl_account gl
        ON jl.jl_account = gl.ga_account_code
    LEFT JOIN stn.business_type bt
        ON jl.jl_segment_7  = bt.business_typ
    LEFT JOIN stn.cession_event_premium_type pt
        ON jl.jl_attribute_3  = pt.premium_typ; 
COMMENT ON COLUMN "RDR"."RRV_AG_JOURNAL_LINES"."MANUAL_FLAG" IS 'Manual or Automated';
COMMENT ON COLUMN "RDR"."RRV_AG_JOURNAL_LINES"."FUNCTIONAL_CCY" IS 'Sourced from local ccy when ledger = UKGAAP_ADJ, else base ccy';
COMMENT ON COLUMN "RDR"."RRV_AG_JOURNAL_LINES"."FUNCTIONAL_CCY_AMT" IS 'Sourced from local ccy when ledger = UKGAAP_ADJ, else base ccy';
COMMENT ON COLUMN "RDR"."RRV_AG_JOURNAL_LINES"."GLINT_FLAG" IS 'Y = Processed into GLINT, N =  Still in SLR';
COMMENT ON COLUMN "RDR"."RRV_AG_JOURNAL_LINES"."GLINT_STATUS" IS 'GLINT status for process into PS';