select
       tuudt.user_name
     , tuudp.department_id
  from
       gui.t_ui_user_departments tuudp
  join
       gui.t_ui_user_details tuudt on tuudt.user_id = tuudp.user_id