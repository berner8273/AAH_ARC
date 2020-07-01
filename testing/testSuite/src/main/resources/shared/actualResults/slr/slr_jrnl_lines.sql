select
       fc.fc_account           acct_cd
     , fc.fc_ccy               ccy
     , fc.fc_entity            business_unit
     , fc.fc_epg_id            epg_id
     , fc.fc_segment_1         fak_segment_1
     , fc.fc_segment_2         fak_segment_2
     , fc.fc_segment_3         fak_segment_3
     , fc.fc_segment_4         fak_segment_4
     , fc.fc_segment_5         fak_segment_5
     , fc.fc_segment_6         fak_segment_6
     , fc.fc_segment_7         fak_segment_7
     , fc.fc_segment_8         fak_segment_8
     , fc.fc_segment_9         fak_segment_9
     , fc.fc_segment_10        fak_segment_10
     , ec.ec_attribute_1       eba_attribute_1
     , ec.ec_attribute_2       eba_attribute_2
     , ec.ec_attribute_3       eba_attribute_3
     , ec.ec_attribute_4       eba_attribute_4
     , ec.ec_attribute_5       eba_attribute_5
     , jl.jl_jrnl_status       jl_jrnl_status
     , jl.jl_effective_date    jl_effective_date
     , jl.jl_value_date        jl_value_date
     , jl.jl_entity            jl_entity
     , jl.jl_account           jl_account
     , jl.jl_segment_1         jl_segment_1
     , jl.jl_segment_2         jl_segment_2
     , jl.jl_segment_3         jl_segment_3
     , jl.jl_segment_4         jl_segment_4
     , jl.jl_segment_5         jl_segment_5
     , jl.jl_segment_6         jl_segment_6
     , jl.jl_segment_7         jl_segment_7
     , jl.jl_segment_8         jl_segment_8
     , jl.jl_segment_9         jl_segment_9
     , jl.jl_segment_10        jl_segment_10
     , jl.jl_attribute_1       jl_attribute_1
     , jl.jl_attribute_2       jl_attribute_2
     , jl.jl_attribute_3       jl_attribute_3
     , jl.jl_attribute_4       jl_attribute_4
     , jl.jl_attribute_5       jl_attribute_5
     , jl.jl_reference_1       jl_reference_1
     , jl.jl_reference_2       jl_reference_2
     , jl.jl_reference_3       jl_reference_3
     , jl.jl_reference_4       jl_reference_4
     , jl.jl_reference_5       jl_reference_5
     , jl.jl_reference_6       jl_reference_6
     , jl.jl_reference_7       jl_reference_7
     , jl.jl_reference_8       jl_reference_8
     , jl.jl_reference_9       jl_reference_9
     , jl.jl_reference_10      jl_reference_10
     , jl.jl_tran_ccy          jl_tran_ccy
     , jl.jl_tran_amount       jl_tran_amount
     , jl.jl_base_rate         jl_base_rate
     , jl.jl_base_ccy          jl_base_ccy
     , jl.jl_base_amount       jl_base_amount
     , jl.jl_local_rate        jl_local_rate
     , jl.jl_local_ccy         jl_local_ccy
     , jl.jl_local_amount      jl_local_amount
     , jl.jl_period_month      jl_period_month
     , jl.jl_period_year       jl_period_year
     , jl.jl_period_ltd        jl_period_ltd
     , jl.jl_type              jl_type
  from
            slr.slr_jrnl_lines       jl
       join slr.slr_fak_combinations fc on jl.jl_fak_id = fc.fc_fak_id
       join slr.slr_eba_combinations ec on jl.jl_eba_id = ec.ec_eba_id