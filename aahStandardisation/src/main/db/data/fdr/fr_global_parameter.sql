insert into fdr.fr_global_parameter ( gp_one_id , gp_tomorrows_bus_date , gp_todays_bus_date , gp_max_adj_days_back , gp_last_month_end_date , gp_si_sys_inst_id , lpg_id )
  values ( 2 , ( select gp_tomorrows_bus_date from fdr.fr_global_parameter where lpg_id = 1 ) , ( select gp_tomorrows_bus_date from fdr.fr_global_parameter where lpg_id = 1 ) - 1 , 33 , sysdate , 'Client Static' , 2 );

update fr_global_parameter set gp_ca_processing_cal_name = 'AAH';
update fr_global_parameter set gp_max_retries            = 99;

commit;