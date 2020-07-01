select
       le_id
     , le_cd
     , le_descr
     , functional_ccy
     , legal_entity_typ
     , is_ledger_entity
     , is_interco_elim_entity
     , is_vie_consol_entity
     , is_standalone
     , rpt_cd
     , rpt_descr
     , feed_uuid
     , event_status
  from
       er_legal_entity