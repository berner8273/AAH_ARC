create or replace view rdr.rrv_stan_raw_acc_event
as
select
        srae_raw_acc_event_id        
     ,  srae_acc_event_type          event_type
     ,  srae_sub_event_id            
     ,  srae_acc_event_id            
     ,  srae_accevent_date           accounting_dt
     ,  srae_dimension_3             program    
     ,  srae_dimension_4             affiliate    
     ,  srae_dimension_5             accident_year
     ,  srae_dimension_6             underwriting_year
     ,  srae_dimension_7             policy_id
     ,  srae_dimension_8             stream_id
     ,  srae_dimension_9             tax_jurisdiction
     ,  srae_dimension_10            ledger
     ,  srae_dimension_11            execution_type
     ,  srae_dimension_12            business_type
     ,  srae_dimension_13            owner_entity
     ,  srae_dimension_14            premium_type
     ,  srae_dimension_15            journal_descr
     ,  srae_gl_book                 
     ,  srae_gl_entity               business_unit             
     ,  srae_instr_super_class       
     ,  srae_instrument_code         
     ,  srae_gl_party_business_code  
     ,  srae_gl_person_code          
     ,  srae_iso_currency_code       transaction_ccy
     ,  srae_client_amount1          transaction_amt
     ,  srae_client_spare_id2        issue_type
     ,  srae_client_spare_id3        ultimate_parent_le_id
     ,  srae_client_spare_id5        functional_ccy
     ,  srae_client_spare_id6        functional_amt
     ,  srae_client_spare_id7        reporting_ccy
     ,  srae_client_spare_id8        reporting_amt
     ,  srae_client_spare_id9        is_mark_to_market
     ,  srae_client_spare_id10       vie_cd
     ,  srae_client_spare_id11       business_event_type
     ,  srae_client_spare_id1        
     ,  srae_client_spare_id4
     ,  srae_dimension_1             
     ,  srae_dimension_2                    
     ,  srae_il_instr_leg_id         
     ,  srae_posting_date            
     ,  srae_source_system           
     ,  srae_source_tran_no          
     ,  srae_value_date              
     ,  srae_nostro_account          
     ,  srae_pos_neg_flag            
     ,  srae_input_by                
     ,  srae_input_time              
     ,  srae_one                     
     ,  arrival_time                 
     ,  event_error_string           
     ,  event_status                 
     ,  lpg_id                       
     ,  srae_party_sys_inst_code     
     ,  srae_static_sys_inst_code    
     ,  srae_instr_sys_inst_code     
     ,  srae_client_spare_id12       
     ,  srae_client_spare_id13       
     ,  srae_client_spare_id14       
     ,  srae_client_spare_id15       
     ,  srae_client_spare_id16       
     ,  srae_client_spare_id17       
     ,  srae_client_spare_id18       
     ,  srae_client_spare_id19       
     ,  srae_client_spare_id20       
     ,  srae_client_date1            
     ,  srae_client_date2            
     ,  srae_client_date3            
     ,  srae_client_date4            
     ,  srae_client_date5            
  from
       fdr.fr_stan_raw_acc_event
;

