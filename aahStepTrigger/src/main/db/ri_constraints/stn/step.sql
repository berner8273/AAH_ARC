alter table stn.step add constraint fk_s_p  foreign key ( process_id )   references stn.process   ( process_id );
alter table stn.step add constraint fk_s_ps foreign key ( param_set_id ) references stn.param_set ( param_set_id );