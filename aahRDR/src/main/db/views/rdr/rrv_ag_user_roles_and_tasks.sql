create or replace view rdr.rrv_ag_user_roles_and_tasks
as
select distinct
    ud.user_name as user_name, 
    ur.role_id as role, 
    rt.task_id as tasks,
    gc.gc_client_text1 as task_group,
    gc.gc_description as description,
    gc.gc_client_text3 as menu,
    gc.gc_client_text4 as sub_menu        
from gui.t_ui_user_roles ur
left outer join gui.t_ui_user_details ud on ud.user_id = ur.user_id 
left join gui.t_ui_role_tasks rt on ur.role_id = rt.role_id
left outer join fdr.fr_general_codes gc on gc.gc_general_code_id = rt.task_id 
where gc.gc_gct_code_type_id = 'USER_TASKS'
;