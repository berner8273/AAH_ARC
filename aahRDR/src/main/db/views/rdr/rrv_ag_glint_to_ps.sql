CREATE OR REPLACE VIEW RDR.RRV_AG_GLINT_TO_PS
(
   JL_JRNL_HDR_ID,
   JL_JRNL_LINE_NUMBER,
   RGJL_ID,
   RGJL_RGJ_ID,
   BUSINESS_UNIT,
   JOURNAL_ID,
   JOURNAL_DATE,
   JOURNAL_LINE
)
AS
   SELECT DISTINCT gts.jl_jrnl_hdr_id,
                   gts.jl_jrnl_line_number,
                   gjl.rgjl_id,
                   gjl.rgjl_rgj_id,
                   gjl.business_unit_gl,
                   gjl.journal_id,
                   gjl.journal_date,
                   gjl.journal_line
     FROM rdr.rr_glint_journal_line gjl
          JOIN rdr.rr_glint_to_slr_ag gts ON gts.rgjl_id = gjl.rgjl_id;