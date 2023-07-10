alter table rdr.rr_glint_batch_control modify rgbc_load_type varchar(100);
alter table rdr.rr_glint_batch_control modify rgbc_process_type varchar(40);
alter table rdr.rr_glint_temp_journal_line modify rgbc_load_type varchar(100);
alter table rdr.rr_glint_temp_journal_line modify rgbc_process_type varchar(40);

grant select on rdr.rrv_ag_slr_jrnl_lines to aah_rdr;
grant select on rdr.rr_glint_journal_line to aah_glint;        
grant update on rdr.rr_glint_journal_line to aah_glint;
grant select on rdr.rrv_ag_glint_jrnl_lines to aah_rdr;
grant select on rdr.rrv_ag_stan_raw_acc_event to aah_rdr;

@@../aahCustom/aahSubLedger/src/main/db/packages/rdr/PG_GLINT.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/rdr/PG_GLINT.bdy;
@@../aahCustom/aahRDR/src/main/db/views/rdr/rrv_ag_slr_jrnl_headers.sql;
@@../aahCustom/aahRDR/src/main/db/views/rdr/rrv_ag_slr_jrnl_lines.sql;