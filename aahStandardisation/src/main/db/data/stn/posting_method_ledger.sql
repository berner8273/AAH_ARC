insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'MTM' )               , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE' )      , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'MTM' )               , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'MTM' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'MTM' )               , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'REVERSE' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'NON_MTM' )           , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE' )      , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'NON_MTM' )           , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT_MINUS_PARTNER' ) , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'STAT_ONLY' )         , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE' )      , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'STAT_ONLY' )         , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'REVERSE' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'GAAP_ONLY' )         , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'GAAP_TO_CORE' )      , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE' )      , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'STAT_ADJ' )          , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'STAT_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'GAAP_FUT_ACCTS' )    , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT_PLUS_PARTNER' )  , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'GAAP_FUT_ACCTS' )    , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'STAT_TO_GAAP_ADJ' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GAAP_ADJ' )  , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'STAT_TO_CORE' )      , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE' )      , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'INTERCOMPANY' )      , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_STAT' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE_SE' )   , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'INTERCOMPANY' )      , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'BER_STAT' ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'BER_STAT' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE_SE' )   , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'INTERCOMPANY' )      , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE_GE' )   , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
insert into stn.posting_method_ledger ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id , sub_event ) values ( ( select psm_id from stn.posting_method where psm_cd = 'INTERCOMPANY' )      , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'UK_GAAP' )  , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'UK_GAAP' )  , ( select ledger_id from stn.posting_ledger where ledger_cd = 'CORE_GE' )   , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'INPUT' )               , 'NULL' );
commit;