create or replace view slr.srv_combination_check_jte (ejt_type,ejt_description) as
select ejt_type,
       ejt_description
  from slr_ext_jrnl_types
union all
select 'ANY',
       'Any'
  from dual
order by 1;
comment on table slr.srv_combination_check_jte is 'Configurable View to collect all the Journal Types that could be used to fail combination checking with an additional "ANY" record to denote the suspense line applies to any journal type.';