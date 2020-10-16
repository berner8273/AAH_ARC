declare
  count_records integer;
begin
  select count(*) into count_records
    from stn.posting_method_derivation_mtm
where event_typ_id = 179;
    
  if count_records = 0 then

	INSERT INTO stn.posting_method_derivation_mtm (event_typ_id, is_mark_to_market, premium_typ, psm_id, basis_id) VALUES (179, 'N', 'I', 6, 1);
    INSERT INTO stn.posting_method_derivation_mtm (event_typ_id, is_mark_to_market, premium_typ, psm_id, basis_id) VALUES (179, 'N', 'U', 6, 1);
    INSERT INTO stn.posting_method_derivation_mtm (event_typ_id, is_mark_to_market, premium_typ, psm_id, basis_id) VALUES (179, 'N', 'M', 6, 1);
    COMMIT;

  end if;  
end;
/

declare
  count_records integer;
begin
  select count(*) into count_records
    from stn.posting_method_derivation_mtm
where event_typ_id = 120;
    
  if count_records = 0 then

	INSERT INTO stn.posting_method_derivation_mtm (event_typ_id, is_mark_to_market, premium_typ, psm_id, basis_id) VALUES (120, 'N', 'I', 6, 1);
    INSERT INTO stn.posting_method_derivation_mtm (event_typ_id, is_mark_to_market, premium_typ, psm_id, basis_id) VALUES (120, 'N', 'U', 6, 1);
    INSERT INTO stn.posting_method_derivation_mtm (event_typ_id, is_mark_to_market, premium_typ, psm_id, basis_id) VALUES (120, 'N', 'M', 6, 1);
    COMMIT;

  end if;  
end;
/

update stn.vie_posting_method_ledger 
set event_typ_id = 120
where event_typ_id = 14 and vie_event_typ_id in (120, 125);
COMMIT;

update stn.vie_posting_method_ledger 
set event_typ_id = 179
where event_typ_id = 215 and vie_event_typ_id in (179, 184);
COMMIT;