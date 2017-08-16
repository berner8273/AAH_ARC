create table stn.process_code_module
(
    process_id     number not null
,   code_module_id number not null
,   constraint pk_pcm primary key ( process_id , code_module_id )
);