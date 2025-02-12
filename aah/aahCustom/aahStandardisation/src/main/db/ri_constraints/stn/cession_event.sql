alter table stn.cession_event add constraint fk_bt_cev     foreign key ( business_typ )       references stn.business_type              ( business_typ );
alter table stn.cession_event add constraint fk_et_cev     foreign key ( event_typ )          references stn.event_type                 ( event_typ );
alter table stn.cession_event add constraint fk_abasis_cev foreign key ( basis_cd )           references stn.posting_accounting_basis   ( basis_cd );
alter table stn.cession_event add constraint fk_ceptyp_cev foreign key ( premium_typ )        references stn.cession_event_premium_type ( premium_typ );
alter table stn.cession_event add constraint fk_be_cev     foreign key ( business_event_typ ) references stn.business_event             ( business_event_cd );