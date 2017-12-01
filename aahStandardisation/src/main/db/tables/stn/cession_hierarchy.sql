create global temporary table stn.cession_hierarchy
(
    insurance_policy_row_sid        number ( 38 , 0 )      not null
,   feed_uuid                       raw ( 16 )             not null
,   policy_id                       varchar2 ( 30 char )   not null
,   child_stream_id                 number ( 38 , 0 )      not null
,   child_cession_typ               varchar2 ( 2 char )    not null
,   child_le_id                     number ( 38 , 0 )      not null
,   parent_stream_id                number ( 38 , 0 )      not null
,   parent_cession_typ              varchar2 ( 2 char )    not null
,   parent_le_id                    number ( 38 , 0 )      not null
,   ceding_stream_id                number ( 38 , 0 )      not null
,   ultimate_parent_stream_id       number ( 38 , 0 )      not null
,   ledger_entity_le_id             number ( 38 , 0 )      not null
,   ledger_entity_le_cd             varchar2 ( 20 char )   not null
,   path_to_child_stream            varchar2 ( 2000 char ) not null
,   hierarchy_level                 number  ( 38 , 0 )     not null
,   constraint pk_chier primary key ( policy_id , child_stream_id )
)
on commit delete rows
;