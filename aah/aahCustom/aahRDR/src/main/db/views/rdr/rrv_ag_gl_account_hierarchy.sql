create or replace view rdr.rrv_ag_gl_account_hierarchy
as
select
       glah.account_key           account_key
     , glah.account_mapping_key   account_mapping_key
     , glah.account_description   account_description
     , glah.account_type          account_type
     , glah.classification        classification
     , glah.insurance_account     insurance_account
     , glah.hierarchy_key         hierarchy_key
     , glah.hierarchy_name        hierarchy_name
     , glah.level_1               level_1
     , glah.level_1_name          level_1_name
     , glah.level_1_order         level_1_order
     , glah.level_1_mapping       level_1_mapping
     , glah.level_2               level_2
     , glah.level_2_name          level_2_name
     , glah.level_2_order         level_2_order
     , glah.level_2_mapping       level_2_mapping
     , glah.level_3               level_3
     , glah.level_3_name          level_3_name
     , glah.level_3_order         level_3_order
     , glah.level_3_mapping       level_3_mapping
     , glah.level_4               level_4
     , glah.level_4_name          level_4_name
     , glah.level_4_order         level_4_order
     , glah.level_4_mapping       level_4_mapping
     , glah.level_5               level_5
     , glah.level_5_name          level_5_name
     , glah.level_5_order         level_5_order
     , glah.level_5_mapping       level_5_mapping
     , glah.level_6               level_6
     , glah.level_6_name          level_6_name
     , glah.level_6_order         level_6_order
     , glah.level_6_mapping       level_6_mapping
     , glah.level_7               level_7
     , glah.level_7_name          level_7_name
     , glah.level_7_order         level_7_order
     , glah.level_7_mapping       level_7_mapping
     , glah.level_8               level_8
     , glah.level_8_name          level_8_name
     , glah.level_8_order         level_8_order
     , glah.level_8_mapping       level_8_mapping
     , glah.level_9               level_9
     , glah.level_9_name          level_9_name
     , glah.level_9_order         level_9_order
     , glah.level_9_mapping       level_9_mapping
     , glah.level_10              level_10
     , glah.level_10_name         level_10_name
     , glah.level_10_order        level_10_order
     , glah.level_10_mapping      level_10_mapping
     , glah.level_11              level_11
     , glah.level_11_name         level_11_name
     , glah.level_11_order        level_11_order
     , glah.level_11_mapping      level_11_mapping
     , glah.level_12              level_12
     , glah.level_12_name         level_12_name
     , glah.level_12_order        level_12_order
     , glah.level_12_mapping      level_12_mapping
     , glah.level_13              level_13
     , glah.level_13_name         level_13_name
     , glah.level_13_order        level_13_order
     , glah.level_13_mapping      level_13_mapping
     , glah.level_14              level_14
     , glah.level_14_name         level_14_name
     , glah.level_14_order        level_14_order
     , glah.level_14_mapping      level_14_mapping
  from
       stn.gl_account_hierarchy glah
     ;