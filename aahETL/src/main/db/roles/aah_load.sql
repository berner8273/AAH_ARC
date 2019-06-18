create role aah_load;
grant create session                                              to aah_load;
grant insert , select          on stn.feed                        to aah_load;
grant insert , select          on stn.feed_record_count           to aah_load;
grant insert , select          on stn.gl_account                  to aah_load;
grant insert , select , delete on stn.gl_account_hierarchy        to aah_load;
grant insert , select          on stn.gl_chartfield               to aah_load;
grant insert , select          on stn.gl_combo_edit_process       to aah_load;
grant insert , select          on stn.gl_combo_edit_assignment    to aah_load;
grant insert , select          on stn.gl_combo_edit_rule          to aah_load;
grant insert , select          on stn.fx_rate                     to aah_load;
grant insert , select          on stn.ledger                      to aah_load;
grant insert , select          on stn.accounting_basis_ledger     to aah_load;
grant insert , select          on stn.legal_entity_ledger         to aah_load;
grant insert , select          on stn.department                  to aah_load;
grant insert , select          on stn.legal_entity                to aah_load;
grant insert , select          on stn.legal_entity_link           to aah_load;
grant insert , select          on stn.insurance_policy            to aah_load;
grant insert , select          on stn.insurance_policy_tax_jurisd to aah_load;
grant insert , select          on stn.insurance_policy_fx_rate    to aah_load;
grant insert , select          on stn.cession                     to aah_load;
grant insert , select          on stn.cession_link                to aah_load;
grant insert , select          on stn.cession_event               to aah_load;
grant insert , select          on stn.journal_line                to aah_load;
grant insert , select          on stn.tax_jurisdiction            to aah_load;
grant          select          on stn.event_type                  to aah_load;
grant insert , select          on stn.event_hierarchy             to aah_load;
grant 		   select 		   on stn.elimination_legal_entity 	  to aah_load;
grant 		   select 		   on stn.posting_method_derivation_rein to aah_load;


grant 		   select 		   on SLR.SLR_JRNL_HEADERS to aah_load;
grant 		   select 		   on SLR.SLR_JRNL_LINES to aah_load;
grant 		   select 		   on rdr.rrv_ag_event_hierarchy to aah_load;
grant 		   select 		   on SLR.SLR_JRNL_HEADERS_UNPOSTED to aah_load;
grant 		   select 		   on SLR.SLR_JRNL_LINES_UNPOSTED to aah_load;
grant 		   select 		   on fdr.fr_log to aah_load;
grant 		   select 		   on fdr.fr_general_codes to aah_load;
grant 		   select 		   on fdr.fr_general_lookup to aah_load;
grant 		   execute 		   on stn.f_event_status_desc to aah_load;


