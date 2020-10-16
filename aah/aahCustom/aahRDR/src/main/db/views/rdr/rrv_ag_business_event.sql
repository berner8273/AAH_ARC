create or replace view rdr.rrv_ag_business_event
as
select
       business_event_cd
     , business_event_descr
     , business_event_category_cd
     , business_event_seq_id
  from
       stn.business_event
;