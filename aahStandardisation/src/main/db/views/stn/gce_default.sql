create or replace view stn.gce_default
as
select
       max ( case when fgl.lk_match_key1 = 'RULE_SET'            
                  then fgl.lk_lookup_value1
             end )                                                   rule_set
     , max ( case when fgl.lk_match_key1 = 'LKT_CODE1'               
                  then fgl.lk_lookup_value1                          
             end )                                                   lkt_code1
     , max ( case when fgl.lk_match_key1 = 'LKT_CODE2'               
                  then fgl.lk_lookup_value1                          
             end )                                                   lkt_code2
     , max ( case when fgl.lk_match_key1 = 'LKT_CODE3'               
                  then fgl.lk_lookup_value1                          
             end )                                                   lkt_code3
     , max ( case when fgl.lk_match_key1 = 'ACTION'                  
                  then fgl.lk_lookup_value1                          
             end )                                                   action
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE1'              
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute1
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE2'              
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute2
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE3'              
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute3
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE4'              
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute4
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE5'              
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute5
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE6'              
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute6
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE_TYP4'          
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute_typ4
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE_TYP5'          
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute_typ5
     , max ( case when fgl.lk_match_key1 = 'ATTRIBUTE_TYP6'          
                  then fgl.lk_lookup_value1                          
             end )                                                   attribute_typ6
     , max ( case when fgl.lk_match_key1 = 'ACTIVE_FLAG'             
                  then fgl.lk_lookup_value1                          
             end )                                                   active_flag
     , max ( case when fgl.lk_match_key1 = 'HOPPER_STATUS'           
                  then fgl.lk_lookup_value1                          
             end )                                                   hopper_status
     , max ( sysdate )                                               effective_from
     , to_date ( max ( case when fgl.lk_match_key1 = 'EFFECTIVE_TO'
                            then fgl.lk_lookup_value1
                       end ) ,'YYYY-MM-DD')                          effective_to
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'GCE_DEFAULT'
     ;