create or replace view stn.row_val_error_log_default
as
select
       max ( case when fgl.lk_match_key1 = 'EVENT_TYPE'
                  then fgl.lk_lookup_value1
             end )                                         event_type
     , max ( case when fgl.lk_match_key1 = 'ERROR_STATUS'
                  then fgl.lk_lookup_value1
             end )                                         error_status
     , max ( case when fgl.lk_match_key1 = 'CATEGORY_ID'
                  then fgl.lk_lookup_value1
             end )                                         category_id
     , max ( case when fgl.lk_match_key1 = 'ERROR_TECHNOLOGY'
                  then fgl.lk_lookup_value1
             end )                                         error_technology
     , max ( case when fgl.lk_match_key1 = 'PROCESSING_STAGE'
                  then fgl.lk_lookup_value1
             end )                                         processing_stage
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'ROW_VAL_ERR_LOG_DEFAULTS'
     ;