create table stn.execution_folder
(
    folder_id   number               not null
,   folder_name varchar2 ( 50 char ) not null
,   constraint pk_folder primary key ( folder_id )
,   constraint uk_folder unique      ( folder_name )
);