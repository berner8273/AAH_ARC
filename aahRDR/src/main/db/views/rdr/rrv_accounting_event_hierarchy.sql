create or replace view rdr.rrv_accounting_event_hierarchy
as
select
       fgl.lk_lkt_lookup_type_code   lookup_type_code
     , fgl.lk_lookup_value8          event_class_cd
     , fgl.lk_lookup_value9          event_class_descr
     , fgl.lk_lookup_value6          event_group_cd
     , fgl.lk_lookup_value7          event_group_descr
     , fgl.lk_lookup_value4          event_sub_group_cd
     , fgl.lk_lookup_value5          event_sub_group_descr
     , fgl.lk_match_key1             accounting_event_cd
     , fgl.lk_lookup_value1          accounting_event_descr
     , fgl.lk_lookup_value2          business_event_cd
     , fgl.lk_lookup_value3          business_event_descr
  from
       fdr.fr_general_lookup fgl
 where
       lk_lkt_lookup_type_code in ('ACCOUNTING_EVENT')
 order by
       event_class_cd
     , event_group_cd
     , event_sub_group_cd
     , accounting_event_cd
     ;