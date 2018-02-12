create view stn.period_status
as
select
       fgl.lk_match_key2 bus_year
     , fgl.lk_match_key3 bus_month
     , case
         when sum (
                   case
                   when lk_lookup_value1 <> 'C'
                   then 1
                   else 0
                   end
                  ) > 0
         then 'O'
         else 'C'
       end              status
  from 
       fdr.fr_general_lookup fgl
 where
       fgl.LK_LKT_LOOKUP_TYPE_CODE = 'EVENT_CLASS_PERIOD'
group by 
       fgl.lk_match_key2
     , fgl.lk_match_key3
;