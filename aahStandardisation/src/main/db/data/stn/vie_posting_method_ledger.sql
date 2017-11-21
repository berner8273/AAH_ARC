insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WRITTEN_PREMIUM' ) , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_WP' )          , ( select vie_id from stn.vie_code where vie_cd = 2 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WRITTEN_PREMIUM' ) , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_WP' )          , ( select vie_id from stn.vie_code where vie_cd = 5 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WRITTEN_PREMIUM' ) , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_WP' )          , ( select vie_id from stn.vie_code where vie_cd = 6 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );

insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WP_WRITEOFF' )     , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_UN' )          , ( select vie_id from stn.vie_code where vie_cd = 2 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WP_WRITEOFF' )     , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_UN' )          , ( select vie_id from stn.vie_code where vie_cd = 5 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WP_WRITEOFF' )     , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_UN' )          , ( select vie_id from stn.vie_code where vie_cd = 6 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );

insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WP_ACCRN' )        , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_ACC' )         , ( select vie_id from stn.vie_code where vie_cd = 2 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WP_ACCRN' )        , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_ACC' )         , ( select vie_id from stn.vie_code where vie_cd = 5 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'WP_ACCRN' )        , ( select event_typ_id from stn.event_type where event_typ = 'VIEPF_ACC' )         , ( select vie_id from stn.vie_code where vie_cd = 6 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );

insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'UPR_INITIAL' )     , ( select event_typ_id from stn.event_type where event_typ = 'VIEPD_UPR_INITIAL' ) , ( select vie_id from stn.vie_code where vie_cd = 4 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
insert into stn.vie_posting_method_ledger ( input_basis_id , event_typ_id , vie_event_typ_id , vie_id , output_basis_id , ledger_id , fin_calc_id ) values ( ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select event_typ_id from stn.event_type where event_typ = 'UPR_INITIAL' )     , ( select event_typ_id from stn.event_type where event_typ = 'VIEPD_UPR_INITIAL' ) , ( select vie_id from stn.vie_code where vie_cd = 5 ) , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' ) , ( select fin_calc_id from stn.posting_financial_calc where fin_calc_cd = 'N/A' ) );
commit;