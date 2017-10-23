create table stn.project
(
    project_id      number               not null
,   project_name    varchar2 ( 50 char ) not null
,   project_type_id number               not null
,   folder_id       number               not null
,   constraint pk_project primary key ( project_id )
,   constraint uk_project unique      ( project_name , folder_id )
);