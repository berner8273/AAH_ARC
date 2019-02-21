alter table stn.journal_line add constraint fk_bt_jl   foreign key ( business_typ ) 	 references stn.business_type             ( business_typ );
alter table stn.journal_line add constraint fk_ptyp_jl foreign key ( premium_typ )  	 references stn.journal_line_premium_type ( premium_typ );
alter table stn.journal_line add constraint fk_styp_jl foreign key ( source_typ_cd) 	 references stn.journal_line_source_typ   ( source_typ_cd );
alter table stn.journal_line add constraint fk_be_jl   foreign key ( business_event_typ) references stn.business_event		 	  ( business_event_cd );