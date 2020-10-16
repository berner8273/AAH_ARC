delete from 
    fdr.fr_general_lookup fgl
where 
    fgl.lk_match_key1 in ('VIELC_CNSS','VIELD_CNSS')
    and fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY';
 
delete from 
    fdr.fr_acc_event_type faet
where 
    faet.aet_acc_event_type_id in ('VIELC_CNSS','VIELD_CNSS');
 
delete from 
    fdr.fr_posting_driver 
where 
    pd_aet_event_type in ('VIELC_CNSS','VIELD_CNSS');
    
commit;