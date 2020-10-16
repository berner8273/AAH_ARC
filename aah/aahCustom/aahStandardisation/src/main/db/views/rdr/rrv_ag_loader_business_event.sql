create or replace view rdr.rrv_ag_loader_business_event
as
select
       'Existing'                  change_status
     , bev.business_event_seq_id
     , bev.business_event_cd
     , bev.business_event_descr
     , bec.business_event_category_descr
  from
       stn.business_event          bev
  join stn.business_event_category bec  on bev.business_event_category_cd = bec.business_event_category_cd
 order by business_event_seq_id
;