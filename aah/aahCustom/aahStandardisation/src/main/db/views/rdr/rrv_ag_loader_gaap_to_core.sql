create or replace view rdr.rrv_ag_loader_gaap_to_core
as
select
       'Existing'                  change_status
     , psmdl.le_cd
  from
       stn.posting_method_derivation_le   psmdl
 order by le_cd
;