grant select on rdr.rrv_ag_slr_jrnl_lines to aah_rdr;
grant  select on rdr.rr_glint_journal_line to aah_glint;        
grant  update on rdr.rr_glint_journal_line to aah_glint;
grant select on rdr.rrv_ag_glint_jrnl_lines to  aah_rdr;
grant select on rdr.rrv_ag_stan_raw_acc_event to aah_rdr;
-- rrv_ag_slr_jrnl_headers -- removed extra hash
-- rrv_ag_slr_jrnl_lines -- removed extra hash

@@../aahCustom/aahSubLedger/src/main/db/packages/rdr/PG_GLINT.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/rdr/PG_GLINT.bdy;