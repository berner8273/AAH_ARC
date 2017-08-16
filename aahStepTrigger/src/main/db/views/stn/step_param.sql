create or replace view stn.step_param
as
select
       s.step_cd
     , pr.process_name
     , p.lpg_id
     , p.disable_accounting
  from
                 stn.step      s
            join stn.process   pr on s.process_id = pr.process_id
       left join (
                       select
                              ps.param_set_id
                            , max ( case when psi.param_set_item_cd = 'lpg_id'
                                         then psi.param_set_item_val
                                         else null
                                    end )                                      lpg_id
                            , max ( case when psi.param_set_item_cd = 'disable_accounting'
                                         then psi.param_set_item_val
                                         else null
                                    end )                                      disable_accounting
                         from
                                   stn.param_set      ps
                              join stn.param_set_item psi on ps.param_set_id = psi.param_set_id
                     group by
                              ps.param_set_id
                 )
                 p
              on s.param_set_id = p.param_set_id
     ;