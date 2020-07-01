select
       fl.lo_event_type_id
     , fl.lo_error_status
     , fl.lo_category_id
     , fl.lo_event_text
     , fl.lo_table_in_error_name
     , fl.lo_field_in_error_name
     , fl.lo_error_value
     , fl.lo_error_technology
     , fl.lo_error_rule_ident
     , fl.lo_todays_bus_date
     , fl.lo_entity
     , fl.lo_source_system
     , fl.lo_processing_stage
     , fl.lo_owner
     , fl.lo_client_spare02      code_module_nm
     , fd.feed_uuid
     , fl.lpg_id
  from
                 fdr.fr_log fl
       left join stn.feed   fd on fl.lo_client_spare03 = fd.feed_sid