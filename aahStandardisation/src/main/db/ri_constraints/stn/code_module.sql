alter table stn.code_module add constraint fk_cm_cmt foreign key ( code_module_typ_id ) references stn.code_module_type ( code_module_typ_id );