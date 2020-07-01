select
       frc.feed_uuid
     , frc.db_nm
     , frc.table_nm
     , frc.stated_record_cnt
     , frc.actual_record_cnt
  from
       er_feed_record_count frc