select
       tuudt.user_name
     , tuur.role_id
  from
       gui.t_ui_user_roles tuur
  join
       gui.t_ui_user_details tuudt on tuudt.user_id = tuur.user_id