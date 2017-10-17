alter table stn.legal_entity_alias add constraint fk_le_lea foreign key ( le_id , feed_uuid ) references stn.legal_entity ( le_id , feed_uuid );
