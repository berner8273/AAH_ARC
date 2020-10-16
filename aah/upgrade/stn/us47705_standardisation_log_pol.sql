declare
   c int;
begin
   select count(*) into c from user_tables where table_name = upper('standardisation_log_pol');
   if c = 1 then
      execute immediate 'drop table standardisation_log_pol';
   end if;       
end;
/
commit;

create table stn.standardisation_log_pol
(
    event_datetime      date                  default sysdate not null
,   table_in_error_name varchar2 ( 240 char )                 not null
,   row_in_error_key_id number                                not null
,   error_value         varchar2 ( 240 char )                 not null
,   lpg_id              number                                not null
,   event_text          varchar2 ( 1000 char )                not null
,   field_in_error_name varchar2 ( 240 char )                 not null
,   event_type          number   ( 12 )                       not null
,   error_status        varchar2 ( 1 char )                   not null
,   category_id         number   ( 12 )                       not null
,   error_technology    varchar2 ( 240 char )                 not null
,   processing_stage    varchar2 ( 240 char )                 not null
,   todays_business_dt  date                  default sysdate not null
,   source_cd           varchar2 ( 20 char )  default 'NVS'   not null
,   owner               varchar2 ( 240 char ) default user    not null
,   rule_identity       varchar2 ( 240 char )                 not null
,   code_module_nm      varchar2 ( 240 char )                 not null
,   step_run_sid        number                default 0       not null
,   feed_sid            number                default 0       not null
);

CREATE INDEX I_ERROR_NAME_KEY_ID ON STN.STANDARDISATION_LOG_POL
(TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID);

commit;
/