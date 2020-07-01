select
    (
    select distinct le.feed_uuid
          from stn.legal_entity le
         where le.step_run_sid =
               (
               select max(srl.step_run_sid)
               from  stn.step_run_log srl
               where srl.code_module_nm = 'PK_LE'
                 and srl.step_run_sid < ele.step_run_sid
               )
    )  feed_uuid
     , ele.legal_entity_link_typ
     , ele.le_1_cd
     , ele.le_2_cd
     , ele.elimination_le_cd
     , ele.path_to_le_1
     , ele.path_to_le_2
     , ele.common_parent_le_cd
  from
       stn.elimination_legal_entity ele