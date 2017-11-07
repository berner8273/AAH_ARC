create or replace view rdr.rrv_slr_entity_periods
as
select
  ep_entity              
,  ep_bus_year           
,  ep_bus_period         
,  ep_period_type        
,  ep_status             
,  ep_cal_period_start   
,  ep_cal_period_end     
,  ep_bus_period_start   
,  ep_bus_period_end     
,  ep_bus_period_end_id  
,  ep_created_by         
,  ep_created_on         
,  ep_amended_by         
,  ep_amended_on         
from slr.slr_entity_periods
;
