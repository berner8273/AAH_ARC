create table stn.elimination_legal_entity
(
    step_run_sid           number   ( 38 , 0 )   not null
,   legal_entity_link_typ  varchar2 ( 30  char ) not null
,   le_1_cd                varchar2 ( 20  char ) not null
,   le_2_cd                varchar2 ( 20  char ) not null
,   elimination_le_cd      varchar2 ( 20  char ) not null
,   path_to_le_1           varchar2 ( 500 char ) not null
,   path_to_le_2           varchar2 ( 500 char ) not null
,   common_parent_le_cd    varchar2 ( 20  char ) not null
,   constraint pk_ele primary key ( step_run_sid , legal_entity_link_typ , le_1_cd , le_2_cd )
);