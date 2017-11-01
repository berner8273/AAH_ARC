create or replace view stn.vie_event_cd
as
select
    ipr.stream_id stream_id
  , (case
        when ipr.VIE_STATUS is null
            then 1
        when ipr.VIE_STATUS = 'CONSO'
                and exists
                    (
                    select null
                    from slr.slr_entity_periods ep
                    where ipr.VIE_ACCT_DT between ep.ep_bus_period_start and ep.ep_bus_period_end 
                        and ep.ep_status = 'O'  
                    )
                and extract(day from ipr.VIE_EFFECTIVE_DT) = 1
            then 2
        when ipr.VIE_STATUS = 'CONSO'
                and exists
                    (
                    select null
                    from slr.slr_entity_periods ep
                    where ipr.VIE_ACCT_DT between ep.ep_bus_period_start and ep.ep_bus_period_end 
                        and ep.ep_status = 'O'  
                    )
                and extract(day from ipr.VIE_EFFECTIVE_DT+1) = 1
            then 3
        when ipr.VIE_STATUS = 'CONSO'
                and exists
                    (
                    select null
                    from slr.slr_entity_periods ep
                    where ipr.VIE_ACCT_DT < ep.ep_bus_period_start
                        and ep.ep_status = 'O'
                    )
            then 6
        when ipr.VIE_STATUS = 'DECONSO'
                and exists
                    (
                    select null
                    from slr.slr_entity_periods ep
                    where ipr.VIE_ACCT_DT between ep.ep_bus_period_start and ep.ep_bus_period_end 
                        and ep.ep_status = 'O'  
                    )
                and extract(day from ipr.VIE_EFFECTIVE_DT) = 1
            then 4
        when ipr.VIE_STATUS = 'DECONSO'
                and exists
                    (
                    select null
                    from slr.slr_entity_periods ep
                    where ipr.VIE_ACCT_DT between ep.ep_bus_period_start and ep.ep_bus_period_end 
                        and ep.ep_status = 'O'  
                    )
                and extract(day from ipr.VIE_EFFECTIVE_DT+1) = 1
            then 5
        when ipr.VIE_STATUS = 'DECONSO'
                and exists
                    (
                    select null
                    from slr.slr_entity_periods ep
                    where ipr.VIE_ACCT_DT < ep.ep_bus_period_start
                        and ep.ep_status = 'O'
                    )
            then 1
        else 1
    end) vie_cd
  from
       stn.insurance_policy_reference  ipr
     ;