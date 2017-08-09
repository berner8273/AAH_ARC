create table stn.step_run_status
(
    step_run_status_id   number           not null
,   step_run_status_cd   varchar2 ( 50 )  not null
,   step_run_status_desc varchar2 ( 150 ) not null
,   constraint pk_step_run_status primary key ( step_run_status_id )
,   constraint uk_step_run_status unique      ( step_run_status_cd )
);