declare
  count_records integer;
begin
	 select count(*) into count_records FROM stn.posting_method_derivation_le WHERE le_cd = 'AGFRA';
	if count_records = 0 then
		insert into stn.posting_method_derivation_le (le_cd,psm_id) values ('AGFRA',6);
		COMMIT;
	END IF;
	count_records :=0;
  select count(*) into count_records FROM stn.load_gaap_to_core WHERE le_cd = 'AGFRA';
	if count_records = 0 then
		insert into stn.load_gaap_to_core (le_cd) values ('AGFRA');
		COMMIT;
	END IF;
END;
/
