create or replace view slr.v_slr_fxreval_rule1_eventunion(accounting_basis , execution_type, premium_type, business_type, event_class, event_type, adjust_offset) as 
select distinct
  accounting_basis,
  execution_type,
  premium_type,
  business_type,
  event_class,
  fx_event_type as event_type,
  'Adjust' as adjust_offset
from slr.V_SLR_FXREVAL_RULE0_ACCTS
where accounting_basis = 'US_STAT'
UNION
select distinct 
  accounting_basis,
  execution_type,
  premium_type,
  business_type,
  event_class,
  fx_event_type as event_type,
  'Adjust' as adjust_offset
from slr.V_SLR_FXREVAL_RULE2_EVENTS
where accounting_basis = 'US_STAT'
UNION
select distinct 
  accounting_basis,
  execution_type,
  premium_type,
  business_type,
  event_class,
  source_event as event_type,
  'NVS' as adjust_offset
from slr.V_SLR_FXREVAL_RULE1_EVENTS
where accounting_basis = 'US_STAT'
ORDER BY 5,6,2,3,4;