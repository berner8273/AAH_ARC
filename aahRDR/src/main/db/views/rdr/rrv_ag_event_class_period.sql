create or replace view rdr.rrv_ag_event_class_period
as
select
  lk_match_key1		event_class 
  ,lk_match_key2	business_year		
  ,lk_match_key3	business_month	
  ,lk_lookup_value1	closed_status
  ,lk_lookup_value4	closed_date
from fdr.fr_general_lookup
where lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
;
