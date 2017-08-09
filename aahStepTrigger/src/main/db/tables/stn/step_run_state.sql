create table stn.step_run_state
(
    step_run_sid            number                              not null
,   step_run_status_id      number                              not null
,   step_run_state_start_ts timestamp default current_timestamp not null
,   constraint pk_step_run_state primary key ( step_run_sid , step_run_status_id )
,   constraint uk_step_run_state unique      ( step_run_sid , step_run_state_start_ts )
);