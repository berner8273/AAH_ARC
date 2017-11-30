create or replace view rdr.rrv_ag_lookup_types
as select
   'business_type' as lookup_type,
    business_typ as lookup_code,
    bu_derivation_method as lookup_descr
   from stn.business_type
union all     
select 'premium_type' as lookup_type,
        premium_typ as lookup_code,
        premium_typ_descr as lookup_descr
         from stn.premium_type
union all         
select 'execution_type' as lookup_type,
        execution_typ as lookup_code,
        execution_typ_descr as lookup_descr 
from stn.execution_type
;
