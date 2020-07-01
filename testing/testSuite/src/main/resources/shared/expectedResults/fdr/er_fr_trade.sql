select
       t_fdr_ver_no
     , t_fdr_tran_no
     , t_acc_event_type_code
     , i_instr_desc_line1
     , t_si_source_sys_inst_id
     , t_ag_agreement_id
     , t_pe_trader_id
     , t_si_alt_source_sys_inst_id
     , ts_trade_status_clicode
     , t_si_router_sys_inst_id
     , t_bo_book_id
     , t_tat_asset_type_id
     , t_pe_salesman_id
     , t_tc_capacity_id
     , t_source_tran_no
     , t_pbu_broker_party_bus_id
     , t_cu_coupon_currency_id
     , t_cu_coupon_settle_curr_id
     , t_price
     , t_pbu_ext_party_bus_id
     , t_pbu_int_party_bus_id
     , t_quantity
     , t_str_strategy_id
     , t_cu_brokerage_curr_id
     , ch_channel_clicode
     , t_trade_date
     , t_buy_or_sell
     , t_accounting_date
     , t_bo_repo_under_book_id
     , t_ibt_interbook_type_id
     , t_cu_alt_curr_id
     , t_input_by
     , t_auth_by
     , t_auth_status
     , t_client_text1
     , t_client_text2
     , t_client_text3
     , t_client_text4
     , t_client_date1
     , t_clean_consid
     , t_total_consid
     , t_ct_charge_type_id1
     , t_ct_charge_type_id2
     , t_ct_charge_type_id3
     , t_ct_charge_type_id4
     , t_charge_amount1
     , t_charge_amount2
     , t_charge_amount3
     , t_charge_amount4
     , lpg_id
     , cx_complexity_type_name
     , ad_address_clicode
  from
       er_fr_trade