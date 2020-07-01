select
       atc.owner
     , atc.table_name      view_name
     , atc.column_name
     , atc.data_type
     , atc.data_length
     , atc.data_precision
     , atc.nullable
     , atc.column_id
  from
       all_tab_columns atc
where
       lower(atc.table_name) like 'rrv_ag\_%' escape '\'