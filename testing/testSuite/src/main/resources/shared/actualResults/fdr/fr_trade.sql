select
       ft.t_fdr_ver_no
     , ft.t_fdr_tran_no
     , ft.t_acc_event_type_code
     , fi.i_instr_desc_line1
     , ft.t_si_source_sys_inst_id
     , ft.t_ag_agreement_id
     , ft.t_pe_trader_id
     , ft.t_si_alt_source_sys_inst_id
     , fts.ts_trade_status_clicode
     , ft.t_si_router_sys_inst_id
     , ft.t_bo_book_id
     , ft.t_tat_asset_type_id
     , ft.t_pe_salesman_id
     , ft.t_tc_capacity_id
     , ft.t_source_tran_no
     , ft.t_pbu_broker_party_bus_id
     , ft.t_cu_coupon_currency_id
     , ft.t_cu_coupon_settle_curr_id
     , ft.t_price
     , ft.t_pbu_ext_party_bus_id
     , ft.t_pbu_int_party_bus_id
     , ft.t_quantity
     , ft.t_str_strategy_id
     , ft.t_cu_brokerage_curr_id
     , fch.ch_channel_clicode
     , ft.t_trade_date
     , ft.t_buy_or_sell
     , ft.t_accounting_date
     , ft.t_bo_repo_under_book_id
     , ft.t_ibt_interbook_type_id
     , ft.t_cu_alt_curr_id
     , ft.t_input_by
     , ft.t_auth_by
     , ft.t_auth_status
     , ft.t_client_text1
     , ft.t_client_text2
     , ft.t_client_text3
     , ft.t_client_text4
     , ft.t_client_date1
     , ft.t_clean_consid
     , ft.t_total_consid
     , ft.t_ct_charge_type_id1
     , ft.t_ct_charge_type_id2
     , ft.t_ct_charge_type_id3
     , ft.t_ct_charge_type_id4
     , ft.t_charge_amount1
     , ft.t_charge_amount2
     , ft.t_charge_amount3
     , ft.t_charge_amount4
     , ft.lpg_id
     , fct.cx_complexity_type_name
     , fa.ad_address_clicode
  from
                 fdr.fr_trade           ft
            join fdr.fr_instrument      fi   on ft.t_i_instrument_id       = fi.i_instrument_id
       left join fdr.fr_address         fa   on ft.t_ad_address_id         = fa.ad_address_id
            join fdr.fr_complexity_type fct  on ft.t_cx_complexity_type_id = fct.cx_complexity_type_id
            join fdr.fr_trade_status    fts  on ft.t_ts_trade_status_id    = fts.ts_trade_status_id
       left join fdr.fr_channel         fch  on ft.t_ch_channel_id         = fch.ch_channel_id