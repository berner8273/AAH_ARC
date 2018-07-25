create or replace view stn.step_detail
as
select
       st.step_cd
     , ef.folder_name
     , pj.project_name
     , pt.project_type_cd
     , pc.process_name
     , pt.process_type_cd
     , pc.input_node_name
  from
            stn.step             st
       join stn.process          pc on st.process_id      = pc.process_id
       join stn.process_type     pt on pc.process_type_id = pt.process_type_id
       join stn.project          pj on pc.project_id      = pj.project_id
       join stn.project_type     pt on pj.project_type_id = pt.project_type_id
       join stn.execution_folder ef on pj.folder_id       = ef.folder_id
     ;