select
       aet_acc_event_type_id
     , aet_acc_event_type_name  
     , aet_active
     , aet_input_by
     , trunc(aet_input_time)
  from
       fdr.fr_acc_event_type
  where
       aet_input_by in ( 'STN' )