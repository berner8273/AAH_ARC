alter table stn.feed_type add constraint fk_ft_p  foreign key ( process_id )             references stn.process ( process_id );
alter table stn.feed_type add constraint fk_ft_sm foreign key ( supersession_method_id ) references stn.supersession_method ( supersession_method_id );