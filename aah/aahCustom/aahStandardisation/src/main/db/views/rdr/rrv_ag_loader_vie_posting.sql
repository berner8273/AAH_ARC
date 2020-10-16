create or replace view rdr.rrv_ag_loader_vie_posting
as
select distinct
       'Existing'                  change_status
     , et.event_typ
     , vet.event_typ               vie_event_typ
     , case
         when pfc.fin_calc_cd = 'BOP'
          and vpml.vie_id     = '2'
          and vpml.sub_event  = 'NULL'
         then 'Consol balance'
         when pfc.fin_calc_cd = 'BOP'
          and vpml.vie_id     = '4'
          and vpml.sub_event  = 'DECONSOL'
         then 'Deconsol balance'
         when pfc.fin_calc_cd = 'MONTHLY'
          and vpml.vie_id     = '6'
          and vpml.sub_event  = 'NULL'
         then 'Monthly'
         else null
       end                         vie_typ
  from
       stn.vie_posting_method_ledger       vpml
  join stn.event_type                      et     on vpml.event_typ_id     = et.event_typ_id
  join stn.event_type                      vet    on vpml.vie_event_typ_id = vet.event_typ_id
  join stn.posting_financial_calc          pfc    on vpml.fin_calc_id      = pfc.fin_calc_id 
 where
       ( ( vie_id = '6' and fin_calc_cd = 'MONTHLY' )
      or ( vie_id = '2' and fin_calc_cd = 'BOP' )
      or ( vie_id = '4' and fin_calc_cd = 'BOP' ) )
 order by
       et.event_typ
     , vie_typ
     ;