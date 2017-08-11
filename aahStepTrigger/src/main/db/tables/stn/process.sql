create table stn.process
(
    process_id      number                                 not null
,   project_id      number                                 not null
,   process_name    varchar2 ( 50  char )                  not null
,   process_type_id number                                 not null
,   input_node_name varchar2 ( 200 char ) default 'Source' not null 
,   constraint pk_process primary key ( process_id )
,   constraint uk_process unique      ( project_id , process_name , process_type_id )
);