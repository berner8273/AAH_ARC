delete from 
    stn.vie_posting_method_ledger vpml
where 
    vpml.vie_event_typ_id in (
        select et.event_typ_id 
  from stn.event_type et
        where et.event_typ in ('VIELC_CNSS','VIELD_CNSS')
    );
 
delete from 
    stn.event_type et
where 
    et.event_typ in ('VIELC_CNSS','VIELD_CNSS');
    
commit;