select
       lo_event_type_id
     , lo_error_status
     , lo_category_id
     , lo_event_text
     , lo_table_in_error_name
     , lo_field_in_error_name
     , lo_error_value
     , lo_error_technology
     , lo_error_rule_ident
     , lo_todays_bus_date
     , lo_entity
     , lo_source_system
     , lo_processing_stage
     , lo_owner
     , code_module_nm
     , feed_uuid
     , lpg_id
  from
       er_fr_log