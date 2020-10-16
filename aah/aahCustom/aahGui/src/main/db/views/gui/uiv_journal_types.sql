create or replace view gui.uiv_journal_types as 
select
       ejt_type                                     jt_type
     , coalesce( ejt_short_desc , ejt_description ) jt_name
     , ejt_madj_flag                                jt_madj_ind
     , ejt_active_flag                              jt_status
     , ejt_requires_authorisation                   jt_requires_authorisation
     , ejt_jt_type                                  jt_journal_type
  from
       slr.slr_ext_jrnl_types
 where
       ejt_active_flag = 'A';
