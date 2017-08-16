alter table stn.cession_link add constraint fk_pc_cl  foreign key ( parent_stream_id , feed_uuid ) references stn.cession           ( stream_id , feed_uuid );
alter table stn.cession_link add constraint fk_cc_cl  foreign key ( child_stream_id  , feed_uuid ) references stn.cession           ( stream_id , feed_uuid );
alter table stn.cession_link add constraint fk_clt_cl foreign key ( link_typ )                     references stn.cession_link_type ( link_typ );