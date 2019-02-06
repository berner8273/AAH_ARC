create index i_cev_data on stn.cev_data ( correlation_uuid );
create index stn.idx_cev_data_comp1 on stn.cev_data (premium_typ, correlation_uuid, event_typ);
create index stn.idx_cev_data_comp2 on stn.cev_data (gaap_fut_accts_flag, premium_typ);