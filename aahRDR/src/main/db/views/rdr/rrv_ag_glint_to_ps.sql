create or replace view rdr.rrv_ag_glint_to_ps
(
   jl_jrnl_hdr_id,
   jl_jrnl_line_number,
   rgjl_id,
   rgjl_rgj_id,
   business_unit_gl,
   journal_id,
   journal_date,
   journal_line
)
as
   select sjl.jl_jrnl_hdr_id,
          sjl.jl_jrnl_line_number,
          gjl.rgjl_id,
          gjl.rgjl_rgj_id,
          gjl.business_unit_gl,
          gjl.journal_id,
          gjl.journal_date,
          gjl.journal_line
     from slr.slr_jrnl_lines sjl
          left join rdr.rr_glint_to_slr_ag gts
             on     sjl.jl_jrnl_hdr_id = gts.jl_jrnl_hdr_id
                and sjl.jl_jrnl_line_number = gts.jl_jrnl_line_number
          left join rdr.rr_glint_journal_line gjl
             on gts.rgjl_id = gjl.rgjl_id;