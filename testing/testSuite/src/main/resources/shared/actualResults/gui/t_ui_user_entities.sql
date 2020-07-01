select
       tuudt.user_name
     , tuue.entity_id
  from
       gui.t_ui_user_entities tuue
  join
       gui.t_ui_user_details tuudt on tuudt.user_id = tuue.user_id