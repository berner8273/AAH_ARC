create or replace view stn.dept_default
as
select
       max ( case when fgl.lk_match_key1 = 'BANKING_TRADING'
                  then fgl.lk_lookup_value1
             end )                                                banking_trading_ind
     , max ( case when fgl.lk_match_key1 = 'SYSTEM_INSTANCE'
                  then fgl.lk_lookup_value1
             end )                                                system_instance
     , max ( case when fgl.lk_match_key1 = 'BOOK_STATUS'
                  then fgl.lk_lookup_value1
             end )                                                book_status
     , max ( case when fgl.lk_match_key1 = 'INTERNAL_PROC_ENTITY'
                  then fgl.lk_lookup_value1
             end )                                                internal_proc_entity
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'DEPT_DEFAULT'
     ;