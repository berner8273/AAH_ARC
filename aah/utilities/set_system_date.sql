/* SET SYSTEM DATE IN FDR.FR_GLOBAL_PARAMETER and SLR.SLR_ENTITIES */

accept v_current_date date prompt 'Set system date (DD-MON-YYYY):';
begin
     for i in ( select lpg_id from fdr.fr_global_parameter ) loop 
         update fdr.fr_global_parameter set gp_todays_bus_date = to_date('&v_current_date','DD-MON-YYYY')-1 where lpg_id = i.lpg_id; 
         update slr.slr_entities e      set ent_business_date  = to_date('&v_current_date','DD-MON-YYYY')-1 where exists ( select null from fdr.fr_lpg_config l where l.lc_lpg_id = i.lpg_id and l.lc_grp_code = e.ent_entity );
         fdr.pr_roll_date ( i.lpg_id ); 
         for j in ( select ent_entity from slr.slr_entities ) loop 
             slr.slr_pkg.pROLL_ENTITY_DATE ( j.ent_entity , null , 'N' );
         end loop;
     end loop; 
end;
/

commit;