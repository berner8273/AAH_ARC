create or replace view rdr.rrv_ag_loader_posting_driver
as
select
       'Existing'                  change_status
     , fpd.pd_posting_driver_id
     , fpd.pd_posting_schema
     , fpd.pd_aet_event_type
     , fpd.pd_sub_event
     , fpd.pd_amount_type
     , fpd.pd_posting_code
     , fpd.pd_dr_or_cr
     , fpd.pd_transaction_no
     , fpd.pd_negate_flag1
     , fpd.pd_journal_type
     , fpd.pd_valid_from
     , fpd.pd_valid_to
  from
       fdr.fr_posting_driver fpd
 order by fpd.pd_posting_driver_id
;