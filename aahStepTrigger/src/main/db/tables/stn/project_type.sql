create table stn.project_type
(
    project_type_id   number                not null
,   project_type_cd   varchar2 ( 50 char )  not null
,   project_type_desc varchar2 ( 150 char ) not null
,   constraint pk_project_type primary key ( project_type_id )
,   constraint uk_project_type unique      ( project_type_cd )
);