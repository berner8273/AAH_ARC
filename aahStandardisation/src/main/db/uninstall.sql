-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
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

conn ~stn_logon

drop procedure stn.pr_publish_log;
drop package body stn.pk_dept;
drop package      stn.pk_dept;
drop package body stn.pk_fxr;
drop package      stn.pk_fxr;
drop package body stn.pk_gl_acct;
drop package      stn.pk_gl_acct;
drop package body stn.pk_feed_integrity;
drop package      stn.pk_feed_integrity;
drop package body stn.pk_glcf;
drop package      stn.pk_glcf;
drop package body stn.pk_le;
drop package      stn.pk_le;
drop package body stn.pk_lel;
drop package      stn.pk_lel;
drop package body stn.pk_le_hier;
drop package      stn.pk_le_hier;
drop package body stn.pk_gce;
drop package      stn.pk_gce;
drop package body stn.pk_tj;
drop package      stn.pk_tj;

drop view  stn.feed_missing_record_count;
drop view  stn.row_val_error_log_default;
drop view  stn.set_val_error_log_default;
drop view  stn.fxr_default;
drop view  stn.gla_default;
drop view  stn.dept_default;
drop view  stn.le_default;
drop view  stn.gce_default;
drop view  stn.validation_detail;
drop view  stn.hopper_gl_chartfield;
drop view  stn.cession_event_posting;
drop view  stn.hopper_gl_combo_edit_gc;
drop view  stn.hopper_gl_combo_edit_gl;
drop view  stn.hopper_tax_jurisdiction;
drop view  stn.tax_jurisdiction_default;
drop table stn.vie_posting_method_ledger;
drop table stn.process_code_module;
drop table stn.validation_column;
drop table stn.validation;
drop table stn.feed_type_payload;
drop table stn.db_tab_column;
drop table stn.db_table;
drop table stn.validation_level;
drop table stn.validation_type;
drop table stn.code_module;
drop table stn.code_module_type;
drop table stn.broken_feed;
drop table stn.feed_record_count;
drop table stn.superseded_feed;
drop table stn.identified_feed;
drop table stn.feed;
drop table stn.fx_rate;
drop table stn.fx_rate_type;
drop table stn.feed_type;
drop table stn.supersession_method;
drop table stn.identified_record;
drop table stn.standardisation_log;
drop table stn.gl_account;
drop table stn.gl_account_category;
drop table stn.department;
drop table stn.elimination_legal_entity;
drop table stn.gl_chartfield;
drop table stn.gl_chartfield_type;
drop table stn.legal_entity_link;
drop table stn.legal_entity;
drop table stn.legal_entity_type;
drop table stn.cession_link;
drop table stn.cession_link_type;
drop table stn.cession;
drop table stn.cession_type;
drop table stn.vie_code;
drop table stn.insurance_policy_fx_rate;
drop table stn.insurance_policy_tax_jurisd;
drop table stn.insurance_policy;
drop table stn.line_of_business;
drop table stn.premium_type;
drop table stn.cession_event;
drop table stn.business_type;
drop table stn.posting_method_ledger;
drop table stn.posting_method_derivation_ic;
drop table stn.posting_method_derivation_le;
drop table stn.posting_method_derivation_mtm;
drop table stn.posting_accounting_basis;
drop table stn.posting_accounting_basis_type;
drop table stn.posting_financial_calc;
drop table stn.posting_ledger;
drop table stn.posting_method;
drop table stn.vie_event_type;
drop table stn.event_type;
drop table stn.vie_legal_entity;
drop table stn.gl_combo_edit_assignment;
drop table stn.gl_combo_edit_rule;
drop table stn.gl_combo_edit_process;
drop table stn.gl_combo_edit_subject;
drop table stn.tax_jurisdiction;

conn ~fdr_logon

drop package body fdr.pk_legal_entity;
drop package      fdr.pk_legal_entity;

delete from fdr.fr_global_parameter          where lpg_id = 2;
delete from fdr.fr_book_lookup               where bol_lookup_key    != 'DEFAULT';
delete from fdr.fr_book                      where bo_book_clicode   != 'DEFAULT';
delete from fdr.fr_general_lookup            where lk_lkt_lookup_type_code in ( 'SET_VAL_ERR_LOG_DEFAULTS' , 'ROW_VAL_ERR_LOG_DEFAULTS' , 'FXR_DEFAULT' , 'GLA_DEFAULT' , 'DEPT_DEFAULT' , 'LE_DEFAULT' , 'GCE_DEFAULT' , 'COMBO_RULESET' , 'COMBO_CHECK' , 'COMBO_APPLICABLE' );
delete from fdr.fr_general_lookup_type       where lkt_lookup_type_code    in ( 'SET_VAL_ERR_LOG_DEFAULTS' , 'ROW_VAL_ERR_LOG_DEFAULTS' , 'FXR_DEFAULT' , 'GLA_DEFAULT' , 'DEPT_DEFAULT' , 'LE_DEFAULT' , 'GCE_DEFAULT' , 'COMBO_RULESET' , 'COMBO_CHECK' , 'COMBO_APPLICABLE' );
delete from fdr.fr_fx_rate;
delete from fdr.fr_party_business_lookup     where pbl_lookup_key                 != 'DEFAULT';
delete from fdr.fr_party_business            where pbu_party_bus_client_code      != 'DEFAULT';
delete from fdr.fr_int_proc_entity_lookup    where ipel_ipe_internal_entity_id    != '1';
delete from fdr.fr_internal_proc_entity      where ipe_internal_entity_id         != '1';
delete from fdr.fr_internal_proc_entity_type where ipet_internal_proc_entity_code in ( 'DEPARTMENT' , 'OPERATING UNIT' );
delete from fdr.fr_party_legal_type          where plt_pl_party_legal_id          != '1';
delete from fdr.fr_party_legal_lookup        where pll_lookup_key                 != '1';
delete from fdr.fr_org_node_structure        where ons_on_child_org_node_id       != 1;
delete from fdr.fr_org_network               where on_org_node_client_code        not in ('DEFAULT');
delete from fdr.fr_entity_schema;
delete from fdr.fr_party_legal               where pl_party_legal_id              != '1';
delete from fdr.fr_currency_lookup           where cul_currency_lookup_code       not in ( 'NUL' );
delete from fdr.fr_currency                  where cu_currency_iso_code           not in ( 'NUL' );
delete from fdr.fr_country_lookup            where col_country_lookup_code        = 'XX';
delete from fdr.fr_country                   where co_country_iso_code            = 'XX';
delete from fdr.fr_calendar_week             where caw_ca_calendar_name           = 'AAH';
delete from fdr.fr_calendar                  where ca_calendar_name               = 'AAH';
delete from fdr.fr_rate_type_lookup          where rtyl_lookup_key                = 'MAVG';
delete from fdr.fr_rate_type                 where rty_rate_type_id               = 'MAVG';
delete from fdr.fr_party_type                where pt_party_type_name             in ( 'Internal' , 'External' , 'Customer' );
delete from fdr.fr_city_lookup               where cil_ci_city_id                 = 'NVS';
delete from fdr.fr_city                      where ci_city_id                     = 'NVS';
delete from fdr.fr_general_codes             where gc_gct_code_type_id            = 'GL_CHARTFIELD' or gc_gct_code_type_id like 'COMBO%';
delete from fdr.fr_general_code_types        where gct_code_type_id               = 'GL_CHARTFIELD' or gct_code_type_id    like 'COMBO%';
delete from fdr.fr_org_hierarchy_type        where oht_org_hier_client_code       not in ( 'DEFAULT' );
delete from fdr.fr_org_node_type             where ont_org_node_type_name         not in ( 'DEFAULT' );
commit;

drop index fbi_fsrfr_message_id;
drop index fbi_fsrga_message_id;
drop index fbi_fsrb_message_id;
drop index fbi_fsrgc_message_id;
drop index fbi_fsrohs_message_id;
drop index fbi_fsrpl_message_id;

revoke select                   on fdr.fr_general_lookup            from stn;
revoke select , insert , update on fdr.fr_stan_raw_general_codes    from stn;
revoke select , insert , update on fdr.fr_stan_raw_general_lookup   from stn;
revoke select                   on fdr.fr_internal_proc_entity_type from stn;
revoke select , insert , update on fdr.fr_stan_raw_org_hier_node    from stn;
revoke select , insert , update on fdr.fr_stan_raw_org_hier_struc   from stn;
revoke select                   on fdr.fr_posting_schema            from stn;
revoke select , insert , update on fdr.fr_general_code_types        from stn;
exit