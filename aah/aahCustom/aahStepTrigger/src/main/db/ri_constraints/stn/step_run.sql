alter table stn.step_run add constraint fk_sr_st foreign key ( step_id ) references stn.step ( step_id );