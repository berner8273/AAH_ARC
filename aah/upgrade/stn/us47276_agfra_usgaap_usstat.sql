declare
  count_records integer;
begin
    select count(*) into count_records
	FROM stn.posting_method_derivation_rein
	WHERE le_1_cd = 'AGFRA'
	;

if count_records = 0 then
INSERT into stn.posting_method_derivation_rein ( le_1_cd , le_2_cd , chartfield_cd , reins_le_cd ) values ( 'AGFRA' , 'AGROL' , 'REIN2' , 'CA003' );
insert into stn.posting_method_derivation_rein ( le_1_cd , le_2_cd , chartfield_cd , reins_le_cd ) values ( 'AGFRA' , 'AGREL' , 'REIN2' , 'CA003' );
insert into stn.posting_method_derivation_rein ( le_1_cd , le_2_cd , chartfield_cd , reins_le_cd ) values ( 'AGFRA' , 'AGCRP' , 'REIN4' , 'CARA1' );
COMMIT;
END IF;
END;
/

declare
  count_records integer;
begin
    select count(*) into count_records
	FROM stn.posting_method_derivation_rein
	WHERE le_2_cd = 'AGFRA'
	;

if count_records = 0 then
INSERT into stn.posting_method_derivation_rein ( le_1_cd , le_2_cd , chartfield_cd , reins_le_cd ) values ( 'AGROL' , 'AGFRA' , 'REIN2' , 'CA003' );
insert into stn.posting_method_derivation_rein ( le_1_cd , le_2_cd , chartfield_cd , reins_le_cd ) values ( 'AGREL' , 'AGFRA' , 'REIN2' , 'CA003' );
insert into stn.posting_method_derivation_rein ( le_1_cd , le_2_cd , chartfield_cd , reins_le_cd ) values ( 'AGCRP' , 'AGFRA' , 'REIN4' , 'CARA1' );
COMMIT;
END IF;
END;
/
