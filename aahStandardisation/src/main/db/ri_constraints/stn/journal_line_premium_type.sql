alter table stn.journal_line_premium_type add constraint fk_jlptyp_ptyp foreign key ( premium_typ ) references stn.premium_type ( premium_typ );