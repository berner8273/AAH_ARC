create or replace view rdr.rrv_ag_lookup_types
as
select
       'business_type'       as lookup_type
     , business_typ          as lookup_code
     , business_typ_descr    as lookup_descr
  from
       stn.business_type
union all
select
       'premium_type'        as lookup_type
     , premium_typ           as lookup_code
     , premium_typ_descr     as lookup_descr
  from
       stn.cession_event_premium_type
union all
select
       'premium_type'        as lookup_type
     , 'NVS'                 as lookup_code
     , 'No value specified'  as lookup_descr
  from
       dual
union all
select
       'policy_premium_type' as lookup_type
     , premium_typ           as lookup_code
     , premium_typ_descr     as lookup_descr
  from
       stn.policy_premium_type
union all
select 
       'execution_type'      as lookup_type
     , execution_typ         as lookup_code
     , execution_typ_descr   as lookup_descr 
  from
       stn.execution_type
union all
select
       fgc.gc_gct_code_type_id  lookup_type
     , fgc.gc_client_code       lookup_code
     , fgc.gc_client_text1      lookup_descr
  from
       fdr.fr_general_codes fgc
 where
       fgc.gc_gct_code_type_id  in ( 'JOURNAL_STATUS' , 'GLINT_JOURNAL_STATUS' )
   and fgc.gc_active            = 'A'
union all
select
       fgl.lk_lkt_lookup_type_code  lookup_type
     , fgl.lk_match_key1            lookup_code
     , fgl.lk_lookup_value1         lookup_descr
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code in ( 'EVENT_CLASS' , 'EVENT_GROUP' , 'EVENT_SUBGROUP' )
   and fgl.lk_active               = 'A'
union all
select
       'EVENT_TYPE'                  lookup_type
     , faet.aet_acc_event_type_id    lookup_code
     , faet.aet_acc_event_type_name  lookup_descr
  from
       fdr.fr_acc_event_type faet
 where
       faet.aet_active               = 'A'
;
