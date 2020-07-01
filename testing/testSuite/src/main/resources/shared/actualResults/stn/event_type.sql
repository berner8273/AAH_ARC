select
       et.event_typ
  from
       stn.event_type et
 where
       exists (
                  select
                         null
                    from
                         fdr.fr_acc_event_type faet
                   where
                         faet.aet_acc_event_type_id = et.event_typ
                     and faet.aet_input_by          = ( 'STN' )
              )