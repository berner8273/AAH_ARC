create table stn.legal_entity_link
(
    row_sid           number   ( 38 , 0 )             generated by default as identity not null
,   parent_le_id      number   ( 38 , 0 )                                              not null
,   child_le_id       number   ( 38 , 0 )                                              not null
,   basis_typ         varchar2 ( 30 char )                                             not null
,   lpg_id            number   ( 38 , 0 ) default 1                                    not null
,   event_status      varchar2 ( 1 char ) default 'U'                                  not null
,   feed_uuid         raw ( 16 )                                                       not null
,   no_retries        number ( 38 , 0 )   default 0                                    not null
,   step_run_sid      number ( 38 , 0 )   default 0                                    not null
,   constraint pk_lelk primary key ( row_sid )
,   constraint uk_lelk unique      ( parent_le_id, child_le_id, basis_typ, feed_uuid )
,   constraint ck_parent_child_le_id check ( parent_le_id <> child_le_id )
);