alter table stn.vie_posting_method_ledger add constraint fk_iabasis_vpml  foreign key ( input_basis_id )   references stn.posting_accounting_basis ( basis_id );
alter table stn.vie_posting_method_ledger add constraint fk_oabasis_vpml  foreign key ( output_basis_id )  references stn.posting_accounting_basis ( basis_id );
alter table stn.vie_posting_method_ledger add constraint fk_et_vpml       foreign key ( event_typ_id )     references stn.event_type               ( event_typ_id );
alter table stn.vie_posting_method_ledger add constraint fk_vet_vpml      foreign key ( vie_event_typ_id ) references stn.vie_event_type           ( event_typ_id );
alter table stn.vie_posting_method_ledger add constraint fk_vie_vpml      foreign key ( vie_id )           references stn.vie_code                 ( vie_id );
alter table stn.vie_posting_method_ledger add constraint fk_pldgr_vpml    foreign key ( ledger_id )        references stn.posting_ledger           ( ledger_id );
alter table stn.vie_posting_method_ledger add constraint fk_fin_calc_vpml foreign key ( fin_calc_id )      references stn.posting_financial_calc   ( fin_calc_id );