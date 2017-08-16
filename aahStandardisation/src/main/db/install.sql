-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in standardisation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@
define stn_user     = @stnUsername@
define stn_password = @stnPassword@
define stn_logon    = ~stn_user/~stn_password@~tns_alias

define fdr_user     = @fdrUsername@
define fdr_password = @fdrPassword@
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

conn ~gui_logon

@@grants/tables/gui/t_ui_user_details.sql
@@grants/tables/gui/t_ui_user_departments.sql
@@grants/tables/gui/t_ui_user_roles.sql
@@grants/tables/gui/t_ui_user_entities.sql

conn ~fdr_logon

@@data/fdr/fr_calendar.sql
@@data/fdr/fr_calendar_week.sql
@@data/fdr/fr_country.sql
@@data/fdr/fr_currency.sql
@@data/fdr/fr_rate_type.sql
@@data/fdr/fr_party_type.sql
@@data/fdr/fr_city.sql
@@data/fdr/fr_party_legal.sql
@@data/fdr/fr_internal_proc_entity_type.sql
@@data/fdr/fr_internal_proc_entity.sql
@@data/fdr/fr_general_lookup_type.sql
@@data/fdr/fr_general_lookup.sql
@@data/fdr/fr_general_code_types.sql
@@data/fdr/fr_org_hierarchy_type.sql
@@data/fdr/fr_org_node_type.sql
@@data/fdr/fr_global_parameter.sql
@@data/fdr/is_group.sql
@@grants/tables/fdr/fr_general_code_types.sql
@@grants/tables/fdr/fr_general_lookup.sql
@@grants/tables/fdr/fr_posting_schema.sql
@@grants/tables/fdr/fr_stan_raw_general_codes.sql
@@grants/tables/fdr/fr_stan_raw_general_lookup.sql
@@grants/tables/fdr/fr_stan_raw_org_hier_node.sql
@@grants/tables/fdr/fr_internal_proc_entity_type.sql
@@grants/tables/fdr/fr_stan_raw_org_hier_struc.sql
@@grants/tables/fdr/is_user.sql
@@grants/tables/fdr/is_groupuser.sql
@@grants/tables/fdr/is_group.sql
@@packages/fdr/pk_legal_entity.hdr
@@packages/fdr/pk_legal_entity.bdy
@@indices/fdr/fr_stan_raw_book.sql
@@indices/fdr/fr_stan_raw_fx_rate.sql
@@indices/fdr/fr_stan_raw_general_codes.sql
@@indices/fdr/fr_stan_raw_gl_account.sql
@@indices/fdr/fr_stan_raw_org_hier_struc.sql
@@indices/fdr/fr_stan_raw_party_legal.sql

conn ~stn_logon

@@tables/stn/broken_feed.sql
@@tables/stn/business_type.sql
@@tables/stn/cession.sql
@@tables/stn/cession_event.sql
@@tables/stn/cession_link.sql
@@tables/stn/cession_link_type.sql
@@tables/stn/cession_type.sql
@@tables/stn/code_module.sql
@@tables/stn/code_module_type.sql
@@tables/stn/db_tab_column.sql
@@tables/stn/db_table.sql
@@tables/stn/department.sql
@@tables/stn/event_type.sql
@@tables/stn/feed.sql
@@tables/stn/feed_record_count.sql
@@tables/stn/feed_type.sql
@@tables/stn/feed_type_payload.sql
@@tables/stn/fx_rate.sql
@@tables/stn/fx_rate_type.sql
@@tables/stn/gl_account.sql
@@tables/stn/gl_account_category.sql
@@tables/stn/gl_chartfield.sql
@@tables/stn/gl_chartfield_type.sql
@@tables/stn/gl_combo_edit_assignment.sql
@@tables/stn/gl_combo_edit_process.sql
@@tables/stn/gl_combo_edit_rule.sql
@@tables/stn/identified_feed.sql
@@tables/stn/identified_record.sql
@@tables/stn/insurance_policy.sql
@@tables/stn/insurance_policy_fx_rate.sql
@@tables/stn/insurance_policy_tax_jurisd.sql
@@tables/stn/elimination_legal_entity.sql
@@tables/stn/legal_entity.sql
@@tables/stn/legal_entity_link.sql
@@tables/stn/legal_entity_type.sql
@@tables/stn/line_of_business.sql
@@tables/stn/posting_accounting_basis.sql
@@tables/stn/posting_accounting_basis_type.sql
@@tables/stn/posting_financial_calc.sql
@@tables/stn/posting_ledger.sql
@@tables/stn/posting_method.sql
@@tables/stn/posting_method_derivation_ic.sql
@@tables/stn/posting_method_derivation_le.sql
@@tables/stn/posting_method_derivation_mtm.sql
@@tables/stn/posting_method_ledger.sql
@@tables/stn/premium_type.sql
@@tables/stn/process_code_module.sql
@@tables/stn/standardisation_log.sql
@@tables/stn/superseded_feed.sql
@@tables/stn/supersession_method.sql
@@tables/stn/user_detail.sql
@@tables/stn/user_group.sql
@@tables/stn/validation.sql
@@tables/stn/validation_column.sql
@@tables/stn/validation_level.sql
@@tables/stn/validation_type.sql
@@tables/stn/vie_code.sql
@@tables/stn/vie_legal_entity.sql
@@tables/stn/vie_event_type.sql
@@tables/stn/vie_posting_method_ledger.sql
@@views/stn/dept_default.sql
@@views/stn/feed_missing_record_count.sql
@@views/stn/fxr_default.sql
@@views/stn/gla_default.sql
@@views/stn/hopper_gl_chartfield.sql
@@views/stn/hopper_gl_combo_edit_gc.sql
@@views/stn/hopper_gl_combo_edit_gl.sql
@@views/stn/le_default.sql
@@views/stn/row_val_error_log_default.sql
@@views/stn/set_val_error_log_default.sql
@@views/stn/validation_detail.sql
@@views/stn/cession_event_posting.sql
@@views/stn/gce_default.sql
@@views/stn/user_default.sql
@@ri_constraints/stn/broken_feed.sql
@@ri_constraints/stn/cession.sql
@@ri_constraints/stn/cession_event.sql
@@ri_constraints/stn/cession_link.sql
@@ri_constraints/stn/code_module.sql
@@ri_constraints/stn/db_tab_column.sql
@@ri_constraints/stn/feed.sql
@@ri_constraints/stn/feed_record_count.sql
@@ri_constraints/stn/feed_type.sql
@@ri_constraints/stn/feed_type_payload.sql
@@ri_constraints/stn/fx_rate.sql
@@ri_constraints/stn/gl_account.sql
@@ri_constraints/stn/gl_chartfield.sql
@@ri_constraints/stn/gl_combo_edit_assignment.sql
@@ri_constraints/stn/gl_combo_edit_rule.sql
@@ri_constraints/stn/insurance_policy.sql
@@ri_constraints/stn/insurance_policy_fx_rate.sql
@@ri_constraints/stn/insurance_policy_tax_jurisd.sql
@@ri_constraints/stn/legal_entity.sql
@@ri_constraints/stn/legal_entity_link.sql
@@ri_constraints/stn/posting_accounting_basis.sql
@@ri_constraints/stn/posting_method_derivation_ic.sql
@@ri_constraints/stn/posting_method_derivation_le.sql
@@ri_constraints/stn/posting_method_derivation_mtm.sql
@@ri_constraints/stn/posting_method_ledger.sql
@@ri_constraints/stn/process_code_module.sql
@@ri_constraints/stn/superseded_feed.sql
@@ri_constraints/stn/user_group.sql
@@ri_constraints/stn/validation.sql
@@ri_constraints/stn/validation_column.sql
@@ri_constraints/stn/vie_posting_method_ledger.sql
@@data/stn/business_type.sql
@@data/stn/cession_link_type.sql
@@data/stn/cession_type.sql
@@data/stn/code_module_type.sql
@@data/stn/code_module.sql
@@data/stn/process_code_module.sql
@@data/stn/validation_level.sql
@@data/stn/validation_type.sql
@@data/stn/db_table.sql
@@data/stn/db_tab_column.sql
@@data/stn/validation.sql
@@data/stn/validation_column.sql
@@data/stn/fx_rate_type.sql
@@data/stn/supersession_method.sql
@@data/stn/feed_type.sql
@@data/stn/feed_type_payload.sql
@@data/stn/gl_account_category.sql
@@data/stn/gl_chartfield_type.sql
@@data/stn/legal_entity_type.sql
@@data/stn/posting_accounting_basis_type.sql
@@data/stn/premium_type.sql
@@data/stn/vie_code.sql
@@data/stn/line_of_business.sql
@@data/stn/event_type.sql
@@data/stn/vie_event_type.sql
@@data/stn/posting_accounting_basis.sql
@@data/stn/posting_financial_calc.sql
@@data/stn/posting_ledger.sql
@@data/stn/posting_method.sql
@@data/stn/posting_method_derivation_ic.sql
@@data/stn/posting_method_derivation_le.sql
@@data/stn/posting_method_derivation_mtm.sql
@@data/stn/posting_method_ledger.sql
@@data/stn/vie_posting_method_ledger.sql
@@procedures/stn/pr_publish_log.sql
@@packages/stn/pk_fxr.hdr
@@packages/stn/pk_fxr.bdy
@@packages/stn/pk_gce.hdr
@@packages/stn/pk_gce.bdy
@@packages/stn/pk_gl_acct.hdr
@@packages/stn/pk_gl_acct.bdy
@@packages/stn/pk_glcf.hdr
@@packages/stn/pk_glcf.bdy
@@packages/stn/pk_dept.hdr
@@packages/stn/pk_dept.bdy
@@packages/stn/pk_le.hdr
@@packages/stn/pk_le.bdy
@@packages/stn/pk_lel.hdr
@@packages/stn/pk_lel.bdy
@@packages/stn/pk_le_hier.hdr
@@packages/stn/pk_le_hier.bdy
@@packages/stn/pk_user.hdr
@@packages/stn/pk_user.bdy
@@packages/stn/pk_feed_integrity.hdr
@@packages/stn/pk_feed_integrity.bdy

exit