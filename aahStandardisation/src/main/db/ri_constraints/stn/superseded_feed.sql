alter table stn.superseded_feed add constraint fk_sdg_f foreign key ( superseding_feed_sid ) references stn.feed ( feed_sid );
alter table stn.superseded_feed add constraint fk_sdd_f foreign key ( superseded_feed_sid )  references stn.feed ( feed_sid );
alter table stn.superseded_feed add constraint fk_sf_sr foreign key ( step_run_sid )         references stn.step_run ( step_run_sid );