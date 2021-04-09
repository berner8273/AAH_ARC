delete from fdr.fr_batch_schedule where bs_object_name = 'parchive';
insert into fdr.fr_batch_schedule ( bs_object_name , lpg_id , bs_stage , bs_order_in_stage , bs_stage_owner , bs_object_type , bs_deployment_folder_name ) values ( 'parchive'                           , 1 , 'FDR' , 1 , 'FDR' , 'R' , 'aah' );
insert into fdr.fr_batch_schedule ( bs_object_name , lpg_id , bs_stage , bs_order_in_stage , bs_stage_owner , bs_object_type , bs_deployment_folder_name ) values ( 'parchive'                           , 2 , 'FDR' , 1 , 'FDR' , 'R' , 'aah' );
commit;