insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'rate_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'from_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'to_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'rate_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'rate' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'acct_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'effective_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'acct_sts' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'acct_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'acct_cat' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'acct_descr' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_account' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'dept_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'effective_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'dept_sts' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'dept_descr' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'department' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'chartfield_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'chartfield_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'chartfield_descr' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'effective_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'chartfield_sts' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_chartfield' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'le_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'le_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'le_descr' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'functional_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'legal_entity_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'is_ledger_entity' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'is_interco_elim_entity' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'is_vie_consol_entity' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'parent_le_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'child_le_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'link_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'correlation_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'event_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'basis_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'stream_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'business_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'accounting_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'event_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'transaction_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'transaction_amt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'functional_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'functional_amt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'reporting_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'reporting_amt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_event' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'policy_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'original_policy_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'underwriting_le_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'external_reinsurer_le_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'accident_yr' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'close_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'expected_maturity_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'actual_maturity_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'underwriting_yr' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'policy_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'premium_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'is_mark_to_market' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'is_credit_default_swap' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'policy_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'from_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'to_ccy' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'rate' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'policy_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'tax_jurisdiction_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_tax_jurisd' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'policy_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'stream_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'le_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'has_profit_commissions' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'cession_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'gross_par_pct' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'net_par_pct' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'gross_premium_pct' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'net_premium_pct' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'ceding_commission_pct' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'pooling_pct' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'loss_layer_pct' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'start_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'stop_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'effective_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'termination_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'vie_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'vie_effective_dt' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'parent_stream_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'child_stream_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'link_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' ) , 'step_run_sid' );      

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'prc_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'le_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'ledger_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'prc_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'prc_descr' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'prc_typ' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'must_match' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_process' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'prc_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'acct_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'dept_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'product_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'affiliate_le_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'user_nm' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'first_nm' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'last_nm' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'email_address' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'dept_cd' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' ) , 'step_run_sid' );

insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'row_sid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'user_nm' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'group_nm' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'lpg_id' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'event_status' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'feed_uuid' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'no_retries' );
insert into stn.db_tab_column ( dbt_id , column_nm ) values ( ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' ) , 'step_run_sid' );
commit;