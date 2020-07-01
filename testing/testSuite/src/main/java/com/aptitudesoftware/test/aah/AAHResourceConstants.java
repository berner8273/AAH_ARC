package com.aptitudesoftware.test.aah;

import java.nio.file.Path;


public enum AAHResourceConstants
{
        ACCOUNTING_BASIS_LEDGER_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/accounting_basis_ledger.sql" ) )
    ,   ACCOUNTING_BASIS_LEDGER_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_accounting_basis_ledger.sql" ) )

    ,   BROKEN_FEED_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/broken_feed.sql" ) )
    ,   BROKEN_FEED_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_broken_feed.sql" ) )

    ,   CESSION_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/cession.sql" ) )
    ,   CESSION_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_cession.sql" ) )

    ,   CESSION_EVENT_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/cession_event.sql" ) )
    ,   CESSION_EVENT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_cession_event.sql" ) )

    ,   CESSION_LINK_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/cession_link.sql" ) )
    ,   CESSION_LINK_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_cession_link.sql" ) )

    ,   DEPARTMENT_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/department.sql" ) )
    ,   DEPARTMENT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_department.sql" ) )

    ,   ELIMINATION_LEGAL_ENTITY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/elimination_legal_entity.sql" ) )
    ,   ELIMINATION_LEGAL_ENTITY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_elimination_legal_entity.sql" ) )

    ,   EVENT_HIERARCHY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/event_hierarchy.sql" ) )
    ,   EVENT_HIERARCHY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_event_hierarchy.sql" ) )

    ,   EVENT_TYPE_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/event_type.sql" ) )
    ,   EVENT_TYPE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_event_type.sql" ) )

    ,   FEED_RECORD_COUNT_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/feed_record_count.sql" ) )
    ,   FEED_RECORD_COUNT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_feed_record_count.sql" ) )

    ,   FR_ACC_EVENT_TYPE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_acc_event_type.sql" ) )
    ,   FR_ACC_EVENT_TYPE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_acc_event_type.sql" ) )

    ,   FR_ACCOUNTING_EVENT_IMP_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_accounting_event_imp.sql" ) )
    ,   FR_ACCOUNTING_EVENT_IMP_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_accounting_event_imp.sql" ) )

    ,   FR_BOOK_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_book.sql" ) )
    ,   FR_BOOK_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_book.sql" ) )

    ,   FR_EVENT_GROUP_PERIOD_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_event_group_period.sql" ) )
    ,   FR_EVENT_GROUP_PERIOD_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_event_group_period.sql" ) )

    ,   FX_RATE_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/fx_rate.sql" ) )
    ,   FX_RATE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_fx_rate.sql" ) )

    ,   FR_FX_RATE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_fx_rate.sql" ) )
    ,   FR_FX_RATE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_fx_rate.sql" ) )

    ,   FR_GL_ACCOUNT_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_gl_account.sql" ) )
    ,   FR_GL_ACCOUNT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_gl_account.sql" ) )

    ,   FR_INSTR_INSURE_EXTEND_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_instr_insure_extend.sql" ) )
    ,   FR_INSTR_INSURE_EXTEND_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_instr_insure_extend.sql" ) )

    ,   FR_INSTRUMENT_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_instrument.sql" ) )
    ,   FR_INSTRUMENT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_instrument.sql" ) )

    ,   FR_LOG_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_log.sql" ) )
    ,   FR_LOG_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_log.sql" ) )

    ,   FR_GENERAL_CODES_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_general_codes.sql" ) )
    ,   FR_GL_CHARTFIELD_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_gl_chartfield.sql" ) )

    ,   FR_GENERAL_CODES_POLTJ_AR     ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_general_codes_poltj.sql" ) )
    ,   FR_POLICY_TAX_JURISDICTION_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_policy_tax_jurisdiction.sql" ) )

    ,   FR_GENERAL_CODES_GCE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_general_codes_gce.sql" ) )
    ,   FR_GENERAL_CODES_GCE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_general_codes_gce.sql" ) )

    ,   FR_GENERAL_LOOKUP_EH_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_general_lookup_eh.sql" ) )
    ,   FR_GENERAL_LOOKUP_EH_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_general_lookup_eh.sql" ) )

    ,   FR_GENERAL_LOOKUP_GCE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_general_lookup_gce.sql" ) )
    ,   FR_GENERAL_LOOKUP_GCE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_general_lookup_gce.sql" ) )

    ,   FR_GENERAL_LOOKUP_LEA_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_general_lookup_lea.sql" ) )
    ,   FR_GENERAL_LOOKUP_LEA_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_general_lookup_lea.sql" ) )

    ,   FR_GENERAL_LOOKUP_LEDG_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_general_lookup_ledg.sql" ) )
    ,   FR_GENERAL_LOOKUP_LEDG_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_general_lookup_ledg.sql" ) )

    ,   FR_GLOBAL_PARAMETER_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_global_parameter.sql" ) )
    ,   FR_GLOBAL_PARAMETER_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_global_parameter.sql" ) )

    ,   FR_INTERNAL_PROC_ENTITY_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_internal_proc_entity.sql" ) )
    ,   FR_INTERNAL_PROC_ENTITY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_internal_proc_entity.sql" ) )

    ,   FR_JOURNAL_LINE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_journal_line.sql" ) )
    ,   FR_JOURNAL_LINE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_journal_line.sql" ) )

    ,   FR_LPG_CONFIG_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_lpg_config.sql" ) )
    ,   FR_LPG_CONFIG_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_lpg_config.sql" ) )

    ,   FR_ORG_NETWORK_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_org_network.sql" ) )
    ,   FR_ORG_NETWORK_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_org_network.sql" ) )

    ,   FR_ORG_NODE_STRUCTURE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_org_node_structure.sql" ) )
    ,   FR_ORG_NODE_STRUCTURE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_org_node_structure.sql" ) )

    ,   FR_PARTY_BUSINESS_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_party_business.sql" ) )
    ,   FR_PARTY_BUSINESS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_party_business.sql" ) )

    ,   FR_PARTY_LEGAL_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_party_legal.sql" ) )
    ,   FR_PARTY_LEGAL_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_party_legal.sql" ) )

    ,   FR_POSTING_SCHEMA_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_posting_schema.sql" ) )
    ,   FR_POSTING_SCHEMA_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_posting_schema.sql" ) )

    ,   FR_RATE_TYPE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_rate_type.sql" ) )
    ,   FR_RATE_TYPE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_rate_type.sql" ) )

    ,   FR_STAN_RAW_BOOK_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_book.sql" ) )
    ,   FR_STAN_RAW_BOOK_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_book.sql" ) )

    ,   FR_STAN_RAW_FX_RATE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_fx_rate.sql" ) )
    ,   FR_STAN_RAW_FX_RATE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_fx_rate.sql" ) )

    ,   FR_STAN_RAW_GL_ACCOUNT_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_gl_account.sql" ) )
    ,   FR_STAN_RAW_GL_ACCOUNT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_gl_account.sql" ) )

    ,   FR_STAN_RAW_INT_ENTITY_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_int_entity.sql" ) )
    ,   FR_STAN_RAW_INT_ENTITY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_int_entity.sql" ) )

    ,   FR_STAN_RAW_ORG_HIER_NODE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_org_hier_node.sql" ) )
    ,   FR_STAN_RAW_ORG_HIER_NODE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_org_hier_node.sql" ) )

    ,   FR_STAN_RAW_ORG_HIER_STRUC_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_org_hier_struc.sql" ) )
    ,   FR_STAN_RAW_ORG_HIER_STRUC_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_org_hier_struc.sql" ) )

    ,   FR_STAN_RAW_PARTY_BUSINESS_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_party_business.sql" ) )
    ,   FR_STAN_RAW_PARTY_BUSINESS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_party_business.sql" ) )

    ,   FR_STAN_RAW_PARTY_LEGAL_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_stan_raw_party_legal.sql" ) )
    ,   FR_STAN_RAW_PARTY_LEGAL_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_stan_raw_party_legal.sql" ) )

    ,   FR_TAX_JURISDICTION_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_tax_jurisdiction.sql" ) )
    ,   FR_TAX_JURISDICTION_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_tax_jurisdiction.sql" ) )

    ,   FR_TRADE_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/fr_trade.sql" ) )
    ,   FR_TRADE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_fr_trade.sql" ) )

    ,   GL_ACCOUNT_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/gl_account.sql" ) )
    ,   GL_ACCOUNT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_gl_account.sql" ) )

    ,   GL_CHARTFIELD_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/gl_chartfield.sql" ) )
    ,   GL_CHARTFIELD_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_gl_chartfield.sql" ) )

    ,   JOURNAL_LINE_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/journal_line.sql" ) )
    ,   JOURNAL_LINE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_journal_line.sql" ) )

    ,   GL_COMBO_EDIT_ASSIGNMENT_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/gl_combo_edit_assignment.sql" ) )
    ,   GL_COMBO_EDIT_ASSIGNMENT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_gl_combo_edit_assignment.sql" ) )

    ,   GL_COMBO_EDIT_PROCESS_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/gl_combo_edit_process.sql" ) )
    ,   GL_COMBO_EDIT_PROCESS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_gl_combo_edit_process.sql" ) )

    ,   GL_COMBO_EDIT_RULE_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/gl_combo_edit_rule.sql" ) )
    ,   GL_COMBO_EDIT_RULE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_gl_combo_edit_rule.sql" ) )

    ,   HOPPER_ACCOUNTING_BASIS_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_accounting_basis.sql" ) )
    ,   HOPPER_ACCOUNTING_BASIS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_accounting_basis.sql" ) )

    ,   HOPPER_EVENT_CATEGORY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_event_category.sql" ) )
    ,   HOPPER_EVENT_CATEGORY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_event_category.sql" ) )

    ,   HOPPER_EVENT_CLASS_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_event_class.sql" ) )
    ,   HOPPER_EVENT_CLASS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_event_class.sql" ) )

    ,   HOPPER_EVENT_HIERARCHY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_event_hierarchy.sql" ) )
    ,   HOPPER_EVENT_HIERARCHY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_event_hierarchy.sql" ) )

    ,   HOPPER_EVENT_GROUP_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_event_group.sql" ) )
    ,   HOPPER_EVENT_GROUP_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_event_group.sql" ) )

    ,   HOPPER_EVENT_SUBGROUP_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_event_subgroup.sql" ) )
    ,   HOPPER_EVENT_SUBGROUP_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_event_subgroup.sql" ) )

    ,   HOPPER_CESSION_EVENT_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_cession_event.sql" ) )
    ,   HOPPER_CESSION_EVENT_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_cession_event.sql" ) )

    ,   HOPPER_GL_CHARTFIELD_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_gl_chartfield.sql" ) )
    ,   HOPPER_GL_CHARTFIELD_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_gl_chartfield.sql" ) )

    ,   HOPPER_JOURNAL_LINE_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_journal_line.sql" ) )
    ,   HOPPER_JOURNAL_LINE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_journal_line.sql" ) )

    ,   HOPPER_GL_COMBO_EDIT_GC_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_gl_combo_edit_gc.sql" ) )
    ,   HOPPER_GL_COMBO_EDIT_GC_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_gl_combo_edit_gc.sql" ) )

    ,   HOPPER_GL_COMBO_EDIT_GL_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_gl_combo_edit_gl.sql" ) )
    ,   HOPPER_GL_COMBO_EDIT_GL_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_gl_combo_edit_gl.sql" ) )

    ,   HOPPER_INSURANCE_POLICY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_insurance_policy.sql" ) )
    ,   HOPPER_INSURANCE_POLICY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_insurance_policy.sql" ) )

    ,   HOPPER_LEGAL_ENTITY_ALIAS_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_legal_entity_alias.sql" ) )
    ,   HOPPER_LEGAL_ENTITY_ALIAS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_legal_entity_alias.sql" ) )

    ,   HOPPER_LEGAL_ENTITY_LEDGER_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_legal_entity_ledger.sql" ) )
    ,   HOPPER_LEGAL_ENTITY_LEDGER_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_legal_entity_ledger.sql" ) )

    ,   HOPPER_TAX_JURISDICTION_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/hopper_tax_jurisdiction.sql" ) )
    ,   HOPPER_TAX_JURISDICTION_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_hopper_tax_jurisdiction.sql" ) )

    ,   INSURANCE_POLICY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/insurance_policy.sql" ) )
    ,   INSURANCE_POLICY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_insurance_policy.sql" ) )

    ,   INSURANCE_POLICY_FX_RATE_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/insurance_policy_fx_rate.sql" ) )
    ,   INSURANCE_POLICY_FX_RATE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_insurance_policy_fx_rate.sql" ) )

    ,   INSURANCE_POLICY_TAX_JURISD_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/insurance_policy_tax_jurisd.sql" ) )
    ,   INSURANCE_POLICY_TAX_JURISD_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_insurance_policy_tax_jurisd.sql" ) )

    ,   IS_GROUPUSER_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/is_groupuser.sql" ) )
    ,   IS_GROUPUSER_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_is_groupuser.sql" ) )

    ,   IS_USER_AR ( AAHResources.getPathToResource ( "shared/actualResults/fdr/is_user.sql" ) )
    ,   IS_USER_ER ( AAHResources.getPathToResource ( "shared/expectedResults/fdr/er_is_user.sql" ) )

    ,   LEDGER_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/ledger.sql" ) )
    ,   LEDGER_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_ledger.sql" ) )

    ,   LEGAL_ENTITY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/legal_entity.sql" ) )
    ,   LEGAL_ENTITY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_legal_entity.sql" ) )

    ,   LEGAL_ENTITY_LEDGER_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/legal_entity_ledger.sql" ) )
    ,   LEGAL_ENTITY_LEDGER_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_legal_entity_ledger.sql" ) )

    ,   LEGAL_ENTITY_LINK_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/legal_entity_link.sql" ) )
    ,   LEGAL_ENTITY_LINK_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_legal_entity_link.sql" ) )

    ,   RDR_VIEW_COLUMNS_AR ( AAHResources.getPathToResource ( "shared/actualResults/rdr/rdr_view_columns.sql" ) )
    ,   RDR_VIEW_COLUMNS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/rdr/er_rdr_view_columns.sql" ) )

    ,   RR_GLINT_BATCH_CONTROL_AR ( AAHResources.getPathToResource ( "shared/actualResults/rdr/rr_glint_batch_control.sql" ) )
    ,   RR_GLINT_BATCH_CONTROL_ER ( AAHResources.getPathToResource ( "shared/expectedResults/rdr/er_rr_glint_batch_control.sql" ) )

    ,   RR_GLINT_JOURNAL_AR ( AAHResources.getPathToResource ( "shared/actualResults/rdr/rr_glint_journal.sql" ) )
    ,   RR_GLINT_JOURNAL_ER ( AAHResources.getPathToResource ( "shared/expectedResults/rdr/er_rr_glint_journal.sql" ) )

    ,   RR_GLINT_JOURNAL_LINE_AR ( AAHResources.getPathToResource ( "shared/actualResults/rdr/rr_glint_journal_line.sql" ) )
    ,   RR_GLINT_JOURNAL_LINE_ER ( AAHResources.getPathToResource ( "shared/expectedResults/rdr/er_rr_glint_journal_line.sql" ) )
    
    ,   RR_INTERFACE_CONTROL_AR ( AAHResources.getPathToResource ( "shared/actualResults/rdr/rr_interface_control.sql" ) )
    ,   RR_INTERFACE_CONTROL_ER ( AAHResources.getPathToResource ( "shared/expectedResults/rdr/er_rr_interface_control.sql" ) )
    
    ,   SLR_EBA_DAILY_BALANCES_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_eba_daily_balances.sql" ) )
    ,   SLR_EBA_DAILY_BALANCES_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_eba_daily_balances.sql" ) )

    ,   SLR_EBA_DEFINITIONS_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_eba_definitions.sql" ) )
    ,   SLR_EBA_DEFINITIONS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_eba_definitions.sql" ) )

    ,   SLR_ENTITIES_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_entities.sql" ) )
    ,   SLR_ENTITIES_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_entities.sql" ) )

    ,   SLR_ENTITY_ACCOUNTS_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_entity_accounts.sql" ) )
    ,   SLR_ENTITY_ACCOUNTS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_entity_accounts.sql" ) )

    ,   SLR_ENTITY_GRACE_DAYS_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_entity_grace_days.sql" ) )
    ,   SLR_ENTITY_GRACE_DAYS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_entity_grace_days.sql" ) )

    ,   SLR_ENTITY_PROC_GROUP_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_entity_proc_group.sql" ) )
    ,   SLR_ENTITY_PROC_GROUP_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_entity_proc_group.sql" ) )

    ,   SLR_ENTITY_RATES_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_entity_rates.sql" ) )
    ,   SLR_ENTITY_RATES_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_entity_rates.sql" ) )

    ,   SLR_FAK_DAILY_BALANCES_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_fak_daily_balances.sql" ) )
    ,   SLR_FAK_DAILY_BALANCES_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_fak_daily_balances.sql" ) )

    ,   SLR_FAK_DEFINITIONS_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_fak_definitions.sql" ) )
    ,   SLR_FAK_DEFINITIONS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_fak_definitions.sql" ) )

    ,   SLR_JRNL_LINES_AR ( AAHResources.getPathToResource ( "shared/actualResults/slr/slr_jrnl_lines.sql" ) )
    ,   SLR_JRNL_LINES_ER ( AAHResources.getPathToResource ( "shared/expectedResults/slr/er_slr_jrnl_lines.sql" ) )

    ,   SUPERSEDED_FEED_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/superseded_feed.sql" ) )
    ,   SUPERSEDED_FEED_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_superseded_feed.sql" ) )

    ,   TAX_JURISDICTION_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/tax_jurisdiction.sql" ) )
    ,   TAX_JURISDICTION_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_tax_jurisdiction.sql" ) )

    ,   T_UI_DEPARTMENTS_AR ( AAHResources.getPathToResource ( "shared/actualResults/gui/t_ui_departments.sql" ) )
    ,   T_UI_DEPARTMENTS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/gui/er_t_ui_departments.sql" ) )

    ,   T_UI_USER_DETAILS_AR ( AAHResources.getPathToResource ( "shared/actualResults/gui/t_ui_user_details.sql" ) )
    ,   T_UI_USER_DETAILS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/gui/er_t_ui_user_details.sql" ) )

    ,   T_UI_USER_DEPARTMENTS_AR ( AAHResources.getPathToResource ( "shared/actualResults/gui/t_ui_user_departments.sql" ) )
    ,   T_UI_USER_DEPARTMENTS_ER ( AAHResources.getPathToResource ( "shared/expectedResults/gui/er_t_ui_user_departments.sql" ) )

    ,   T_UI_USER_ROLES_AR ( AAHResources.getPathToResource ( "shared/actualResults/gui/t_ui_user_roles.sql" ) )
    ,   T_UI_USER_ROLES_ER ( AAHResources.getPathToResource ( "shared/expectedResults/gui/er_t_ui_user_roles.sql" ) )

    ,   T_UI_USER_ENTITIES_AR ( AAHResources.getPathToResource ( "shared/actualResults/gui/t_ui_user_entities.sql" ) )
    ,   T_UI_USER_ENTITIES_ER ( AAHResources.getPathToResource ( "shared/expectedResults/gui/er_t_ui_user_entities.sql" ) )

    ,   USER_DETAIL_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/user_detail.sql" ) )
    ,   USER_DETAIL_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_user_detail.sql" ) )

    ,   USER_GROUP_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/user_group.sql" ) )
    ,   USER_GROUP_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_user_group.sql" ) )

    ,   VIE_LEGAL_ENTITY_AR ( AAHResources.getPathToResource ( "shared/actualResults/stn/vie_legal_entity.sql" ) )
    ,   VIE_LEGAL_ENTITY_ER ( AAHResources.getPathToResource ( "shared/expectedResults/stn/er_vie_legal_entity.sql" ) )
    ;

    private Path pathToResource;

    AAHResourceConstants ( final Path pPathToResource )
    {
        this.pathToResource  = pPathToResource;
    }

    public Path getPathToResource ()
    {
        return pathToResource;
    }
}