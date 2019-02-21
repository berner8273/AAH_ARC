create or replace view rdr.rrv_ag_loader_posting_method
as
select
       'Existing'                  change_status
     , et.event_typ
     , psmdm.is_mark_to_market
     , psmdm.premium_typ
     , pab.basis_cd
     , psm.psm_cd
  from
       stn.posting_method_derivation_mtm   psmdm
  join stn.event_type                      et     on psmdm.event_typ_id = et.event_typ_id
  join stn.posting_accounting_basis        pab    on psmdm.basis_id     = pab.basis_id
  join stn.posting_method                  psm    on psmdm.psm_id       = psm.psm_id
 order by
       event_typ
     , is_mark_to_market
     , premium_typ
     , basis_cd desc
;