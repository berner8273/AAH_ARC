select
    (
    select distinct le.feed_uuid
          from stn.legal_entity le
         where le.step_run_sid =
               (
               select max(srl.step_run_sid)
               from  stn.step_run_log srl
               where srl.code_module_nm = 'PK_LE'
                 and srl.step_run_sid < vle.step_run_sid
               )
    )  feed_uuid
     , vle.legal_entity_link_typ
     , vle.le_cd
     , vle.vie_le_cd
     , vle.path_to_le
  from
       stn.vie_legal_entity vle
