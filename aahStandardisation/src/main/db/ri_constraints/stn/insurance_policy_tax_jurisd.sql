alter table stn.insurance_policy_tax_jurisd add constraint fk_ip_iptj foreign key ( policy_id , feed_uuid ) references stn.insurance_policy ( policy_id , feed_uuid );