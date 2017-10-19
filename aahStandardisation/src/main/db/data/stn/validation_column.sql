insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'fxr-from_ccy' )            , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' )                   and column_nm = 'from_ccy' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'fxr-to_ccy' )              , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' )                   and column_nm = 'to_ccy' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'fxr-rate_dt' )             , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'fx_rate' )                   and column_nm = 'rate_dt' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'le-functional_ccy' )       , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity' )              and column_nm = 'functional_ccy' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'lel-parent_le_id' )        , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' )         and column_nm = 'parent_le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'lel-child_le_id' )         , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_link' )         and column_nm = 'child_le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'gcea-le_cd' )              , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' )  and column_nm = 'le_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'gcea-ledger_cd' )          , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_assignment' )  and column_nm = 'ledger_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'gcer-acct_cd' )            , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'gl_combo_edit_rule' )        and column_nm = 'acct_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'ud-dept_cd' )              , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_detail' )               and column_nm = 'dept_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'ug-group_nm' )             , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' )                and column_nm = 'group_nm' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'ug-employee_id' )          , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'user_group' )                and column_nm = 'employee_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'pol-transaction_ccy' )     , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' )          and column_nm = 'transaction_ccy' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'pol-underwriting_le_id' )  , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy' )          and column_nm = 'underwriting_le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'polfxr-to_ccy' )           , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' )  and column_nm = 'to_ccy' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'polfxr-from_ccy' )         , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'insurance_policy_fx_rate' )  and column_nm = 'from_ccy' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'cs-le_id' )                , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' )                   and column_nm = 'le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'cs-vie_acct_dt' )          , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' )                   and column_nm = 'vie_acct_dt' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'cs-vie_eff_dt' )           , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession' )                   and column_nm = 'vie_effective_dt' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'cl-stream_policies' )      , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' )              and column_nm = 'parent_stream_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'cl-stream_policies' )      , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'cession_link' )              and column_nm = 'child_stream_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'ledg-cldr_cd' )            , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'ledger' )                    and column_nm = 'cldr_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'abl-basis_cd' )            , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'accounting_basis_ledger' )   and column_nm = 'basis_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'lel-le_cd' )               , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'legal_entity_ledger' )       and column_nm = 'le_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-le_id' )                , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-owner_le_id' )          , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'owner_le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-affiliate_le_id' )      , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'affiliate_le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-counterparty_le_id' )   , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'counterparty_le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-ultimate_parent_le_id' ), ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'ultimate_parent_le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-accounting_dt' )        , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'accounting_dt' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-acct_cd' )              , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'acct_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-basis_cd' )             , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'basis_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-policy_id' )            , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'policy_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-stream_id' )            , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'stream_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-dept_cd' )              , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'dept_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-chartfield_1' )         , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'chartfield_1' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-tax_jurisdiction_cd' )  , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'tax_jurisdiction_cd' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-event_typ' )            , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'event_typ' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-le_id2' )               , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'le_id' ) );
insert into stn.validation_column ( validation_id , dtc_id ) values ( ( select validation_id from stn.validation where validation_cd = 'jl-transaction_sum' )      , ( select dtc_id from stn.db_tab_column where dbt_id = ( select dbt_id from stn.db_table where db_nm = 'stn' and table_nm = 'journal_line' )              and column_nm = 'transaction_amt' ) );

commit;