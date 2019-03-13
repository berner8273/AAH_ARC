-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
--         :
-- -----------------------------------------------------------------------------------------

--whenever sqlerror exit failure

set serveroutput on
set define ~
set echo on

define fdr_logon=~1
define gui_logon=~2
define rdr_logon=~3
define sla_logon=~4
define slr_logon=~5
define stn_logon=~6
define sys_logon=~7
define unittest_login=~8

conn ~sys_logon as sysdba

begin
    for i in (
                 select
                        'alter system kill session ''' || vs.sid || ',' || vs.serial# || '''' kill_stmt
                   from
                        v$session vs
                  where exists
                               (
                                 select null
                                   from v$lock vl
                                  where lower(type) = 'to'
                                    and id1 in ( select object_id
                                                   from dba_objects
                                                  where lower(object_name) in ( 'posting_account_derivation'
                                                                              , 'vie_posting_account_derivation'
                                                                              , 'cev_data'
                                                                              , 'cev_premium_typ_override'
                                                                              , 'cev_mtm_data'
                                                                              , 'cev_gaap_fut_accts_data'
                                                                              , 'cev_le_data'
                                                                              , 'cev_non_intercompany_data'
                                                                              , 'cev_intercompany_data'
                                                                              , 'cev_vie_data' )
                                               )
                                    and vs.sid = vl.sid
                               )
             )
    loop
        execute immediate i.kill_stmt;
    end loop;
end;
/
conn ~stn_logon

truncate table stn.posting_account_derivation;
truncate table stn.vie_posting_account_derivation;
truncate table stn.cev_data;
truncate table stn.cev_premium_typ_override;
truncate table stn.cev_mtm_data;
truncate table stn.cev_gaap_fut_accts_data;
truncate table stn.cev_le_data;
truncate table stn.cev_non_intercompany_data;
truncate table stn.cev_intercompany_data;

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
drop package body stn.pk_ledg;
drop package      stn.pk_ledg;
drop package body stn.pk_lel;
drop package      stn.pk_lel;
drop package body stn.pk_le_hier;
drop package      stn.pk_le_hier;
drop package body stn.pk_gce;
drop package      stn.pk_gce;
drop package body stn.pk_tj;
drop package      stn.pk_tj;
drop package body stn.pk_pol;
drop package      stn.pk_pol;
drop package body stn.pk_eh;
drop package      stn.pk_eh;
drop package body stn.pk_jl;
drop package      stn.pk_jl;
drop package body stn.pk_cev;
drop package      stn.pk_cev;
drop package body stn.pk_cession_hier;
drop package      stn.pk_cession_hier;
drop package body stn.pk_posting_rules;
drop package      stn.pk_posting_rules;
drop view  stn.feed_missing_record_count;
drop view  stn.row_val_error_log_default;
drop view  stn.set_val_error_log_default;
drop view  stn.fxr_default;
drop view  stn.gla_default;
drop view  stn.dept_default;
drop view  stn.le_default;
drop view  stn.hopper_legal_entity_alias;
drop view  stn.gce_default;
drop view  stn.validation_detail;
drop view  stn.hopper_gl_chartfield;
drop view  stn.policy_tax;
drop view  stn.ce_default;
drop view  stn.cession_event_reversal_hist;
drop view  stn.cession_event_reversal_curr;
drop view  stn.cession_event_posting;
drop view  stn.cev_period_balances;
drop view  stn.period_status;
drop view  stn.hopper_gl_combo_edit_gc;
drop view  stn.hopper_gl_combo_edit_gl;
drop view  stn.hopper_tax_jurisdiction;
drop view  stn.tax_jurisdiction_default;
drop view  stn.hopper_cession_event;
drop view  stn.hopper_insurance_policy;
drop view  stn.hopper_insurance_policy_tj;
drop view  stn.insurance_policy_reference;
drop view  stn.pol_default;
drop view  stn.hopper_accounting_basis_ledger;
drop view  stn.hopper_legal_entity_ledger;
drop view  stn.hopper_journal_line;
drop view  stn.journal_line_default;
drop view  stn.ledger_default;
drop view  stn.hopper_event_hierarchy;
drop view  stn.hopper_event_class;
drop view  stn.hopper_event_category;
drop view  stn.hopper_event_group;
drop view  stn.hopper_event_subgroup;
drop view  stn.event_hierarchy_default;
drop view  stn.event_hierarchy_reference;
drop table stn.posting_amount_negate_flag;
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
drop table stn.legal_entity_link_type;
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
drop table stn.execution_type;
drop table stn.journal_line;
drop table stn.cession_event;
drop table stn.business_type;
drop table stn.posting_amount_derivation;
drop table stn.posting_amount_derivation_type;
drop table stn.posting_method_ledger;
drop table stn.posting_method_derivation_ic;
drop table stn.posting_method_derivation_le;
drop table stn.posting_method_derivation_mtm;
drop table stn.posting_method_derivation_rein;
drop table stn.posting_accounting_basis;
drop table stn.posting_accounting_basis_type;
drop table stn.posting_financial_calc;
drop table stn.posting_ledger;
drop table stn.posting_method;
drop table stn.cev_valid;
drop table stn.cev_data;
drop table stn.cev_gaap_fut_accts_data;
drop table stn.cev_le_data;
drop table stn.cev_mtm_data;
drop table stn.cev_non_intercompany_data;
drop table stn.cev_intercompany_data;
drop table stn.cev_premium_typ_override;
drop table stn.posting_method_derivation_gfa;
drop table stn.posting_account_derivation;
drop table stn.vie_posting_account_derivation;
drop table stn.vie_event_type;
drop table stn.event_type;
drop table stn.vie_legal_entity;
drop table stn.gl_combo_edit_assignment;
drop table stn.gl_combo_edit_rule;
drop table stn.gl_combo_edit_process;
drop table stn.tax_jurisdiction;
drop table stn.accounting_basis_ledger;
drop table stn.legal_entity_ledger;
drop table stn.ledger;
drop table stn.event_hierarchy;
drop table stn.gl_account_hierarchy;
drop table stn.policy_premium_type;
drop table stn.journal_line_premium_type;
drop table stn.cession_event_premium_type;
drop table stn.cession_hierarchy;
drop table stn.business_event;
drop table stn.business_event_category;
drop table stn.init_stat;
drop table stn.load_event_hierarchy;
drop table stn.load_business_event;
drop table stn.load_gaap_to_core;
drop table stn.load_posting_method_derivation;
drop table stn.load_vie_posting_method;
drop table stn.load_fr_posting_driver;
drop table stn.load_fr_account_lookup;
drop table stn.cev_vie_data;
drop table stn.journal_line_source_type;

conn ~gui_logon

delete from gui.ui_general_lookup;
commit;

conn ~fdr_logon

drop package body fdr.pk_legal_entity;
drop package      fdr.pk_legal_entity;

delete from fdr.fr_db_upgrade_history        where dbuh_description                = 'Assured Guaranty';
delete from fdr.fr_global_parameter          where lpg_id = 2;
update fdr.fr_global_parameter set gp_ca_processing_cal_name = null;
delete from fdr.fr_trade                     where t_fdr_tran_no             not in ( 'DEFAULT' );
delete from fdr.fr_instrument                where i_instrument_id                != '1';
delete from fdr.fr_instr_type_lookup         where itl_lookup_key                 != 'DEFAULT';
delete from fdr.fr_instrument_type           where it_instr_type_client_code      != 'DEFAULT';
delete from fdr.fr_instr_type_class_lookup   where itcl_lookup_key                != 'DEFAULT';
delete from fdr.fr_instr_type_class          where itc_instr_type_class_name      != 'DEFAULT';
delete from fdr.fr_instr_type_sclass_lookup  where itscl_lookup_key               != 'DEFAULT';
delete from fdr.fr_instr_type_superclass     where itsc_instr_type_super_clicode  != 'DEFAULT';
delete from fdr.fr_instr_insure_extend;
delete from fdr.fr_book_lookup               where bol_lookup_key    != 'DEFAULT';
delete from fdr.fr_book                      where bo_book_clicode   != 'DEFAULT';
delete from fdr.fr_general_lookup            where lk_lkt_lookup_type_code in ( 'SET_VAL_ERR_LOG_DEFAULTS' , 'ROW_VAL_ERR_LOG_DEFAULTS' , 'FXR_DEFAULT' , 'GLA_DEFAULT' , 'DEPT_DEFAULT' , 'LE_DEFAULT' , 'GCE_DEFAULT' , 'COMBO_RULESET' , 'COMBO_CHECK' , 'COMBO_APPLICABLE' , 'TAX_JURISDICTION_DEFAULT' , 'POL_DEFAULT' , 'LEDGER_DEFAULT' , 'ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_HIERARCHY_DEFAULT' , 'EVENT_HIERARCHY','EVENT_CLASS', 'EVENT_GROUP', 'EVENT_SUBGROUP', 'EVENT_CATEGORY', 'JOURNAL_LINE_DEFAULT' , 'LEGAL_ENTITY_ALIAS' , 'CE_DEFAULT' , 'EVENT_TYPE' , 'EVENT_CLASS_PERIOD','CODE_BLOCK_BUSINESS_NAMES','GL_MAPPING_SET_1' );
delete from fdr.fr_general_lookup_type       where lkt_lookup_type_code    in ( 'SET_VAL_ERR_LOG_DEFAULTS' , 'ROW_VAL_ERR_LOG_DEFAULTS' , 'FXR_DEFAULT' , 'GLA_DEFAULT' , 'DEPT_DEFAULT' , 'LE_DEFAULT' , 'GCE_DEFAULT' , 'COMBO_RULESET' , 'COMBO_CHECK' , 'COMBO_APPLICABLE' , 'TAX_JURISDICTION_DEFAULT' , 'POL_DEFAULT' , 'LEDGER_DEFAULT' , 'ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_HIERARCHY_DEFAULT' , 'EVENT_HIERARCHY','EVENT_CLASS', 'EVENT_GROUP', 'EVENT_SUBGROUP', 'EVENT_CATEGORY', 'JOURNAL_LINE_DEFAULT' , 'LEGAL_ENTITY_ALIAS' , 'CE_DEFAULT' , 'EVENT_TYPE' , 'EVENT_CLASS_PERIOD','CODE_BLOCK_BUSINESS_NAMES','GL_MAPPING_SET_1' );
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
delete from fdr.fr_calendar                  where ca_calendar_name               in ( 'AAH' , 'AG_DEFAULT' );
delete from fdr.fr_rate_type_lookup          where rtyl_lookup_key                = 'MAVG';
delete from fdr.fr_rate_type                 where rty_rate_type_id               = 'MAVG';
update fdr.fr_rate_type
set rty_active = 'A'
where rty_rate_type_id = 'FORWARD' and rty_active <> 'A';
delete from fdr.fr_party_type                where pt_party_type_name             in ( 'Internal' , 'External' , 'Customer' );
update fdr.fr_party_type fpt set fpt.pt_active = 'A' where fpt.pt_party_type_name in ( 'DEFAULT' , 'Counterparty' , 'Broker' , 'Governmental Agency' , 'Individual' , 'Clearing Agent' , 'Nostro Agent' , 'Business Unit' );
delete from fdr.fr_city_lookup               where cil_ci_city_id                 = 'NVS';
delete from fdr.fr_city                      where ci_city_id                     = 'NVS';
delete from fdr.fr_general_codes             where gc_gct_code_type_id            in ( 'GL_CHARTFIELD' , 'TAX_JURISDICTION' , 'POLICY_TAX' , 'USER_TASKS' , 'JOURNAL_STATUS' , 'PS_JOURNAL_STATUS' , 'GLINT_JOURNAL_STATUS' ) or gc_gct_code_type_id like 'COMBO%';
delete from fdr.fr_general_code_types        where gct_code_type_id               in ( 'GL_CHARTFIELD' , 'TAX_JURISDICTION' , 'POLICY_TAX' , 'USER_TASKS' , 'JOURNAL_STATUS' , 'PS_JOURNAL_STATUS' , 'GLINT_JOURNAL_STATUS' ) or gct_code_type_id    like 'COMBO%';
delete from fdr.fr_org_hierarchy_type        where oht_org_hier_client_code       not in ( 'DEFAULT' );
delete from fdr.fr_org_node_type             where ont_org_node_type_name         not in ( 'DEFAULT' );
delete from fdr.is_groupuser                 where isgu_usr_ref                   != 3;
delete from fdr.is_user                      where isusr_name                     != 'fdr_user';
delete from fdr.is_group                     where isgrp_name                     = 'AG' ;
delete from fdr.fr_address                   where ad_address_clicode             != 'DEFAULT';

commit;

drop index fdr.fbi_fsrga_message_id;
drop index fdr.fbi_fsrb_message_id;
drop index fdr.fbi_fsrohs_message_id;
drop index fdr.fbi_fsrpl_message_id;
drop index fdr.fbi_fsra_message_id;
drop index fdr.fbi_pl_global_id;

conn ~gui_logon

drop package body gui.gui_pkg;
drop package gui.gui_pkg;

delete from gui.t_ui_user_departments;
delete from gui.t_ui_user_roles              where user_id                        != 3;
delete from gui.t_ui_user_entities;
delete from gui.t_ui_user_details            where user_name                      != 'fdr_user';
delete from gui.t_ui_departments             where department_id                  != 'DEFAULT';

conn ~rdr_logon

drop view rdr.rrv_ag_loader_account_lookup;
drop view rdr.rrv_ag_loader_business_event;
drop view rdr.rrv_ag_loader_event_hier;
drop view rdr.rrv_ag_loader_gaap_to_core;
drop view rdr.rrv_ag_loader_posting_driver;
drop view rdr.rrv_ag_loader_posting_method;
drop view rdr.rrv_ag_loader_vie_posting;