grant 		   select 		   on SLR.SLR_JRNL_HEADERS to aah_load;
grant 		   select 		   on SLR.SLR_JRNL_LINES to aah_load;
grant 		   select 		   on rdr.rrv_ag_event_hierarchy to aah_load;
grant 		   select 		   on SLR.SLR_JRNL_HEADERS_UNPOSTED to aah_load;
grant 		   select 		   on SLR.SLR_JRNL_LINES_UNPOSTED to aah_load;
grant 		   select 		   on fdr.fr_log to aah_load;
grant 		   select 		   on fdr.fr_general_codes to aah_load;
grant 		   select 		   on fdr.fr_general_lookup to aah_load;
grant 		   select 		   on rdr.rr_glint_to_slr_ag to aah_load;
grant 		   execute 		   on stn.f_event_status_desc to aah_load;



grant insert , select, delete  on stn.cession_event to aah_load;
grant insert , select, update  on stn.journal_line to aah_load;

