alter table stn.gl_combo_edit_process add constraint fk_gceps_gcr foreign key ( prc_subject ) references stn.gl_combo_edit_subject ( prc_subject );