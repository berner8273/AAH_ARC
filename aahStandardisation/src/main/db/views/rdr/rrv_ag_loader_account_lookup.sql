create or replace view rdr.rrv_ag_loader_account_lookup
as
select
       'Existing'                  change_status
     , fal.al_posting_code
     , fal.al_lookup_1
     , fal.al_lookup_2
     , fal.al_lookup_3
     , fal.al_lookup_4
     , fal.al_account
     , fal.al_valid_from
     , fal.al_valid_to
  from
       fdr.fr_account_lookup fal
 order by fal.al_id
;