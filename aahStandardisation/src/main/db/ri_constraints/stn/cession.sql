alter table stn.cession add constraint fk_ip_c  foreign key ( policy_id , feed_uuid ) references stn.insurance_policy ( policy_id , feed_uuid );
alter table stn.cession add constraint fk_ct_c  foreign key ( cession_typ )           references stn.cession_type     ( cession_typ );