create table stn.vie_legal_entity
(
    step_run_sid        number   ( 38 , 0 )   not null
,   basis_typ           varchar2 ( 20  char ) not null
,   le_cd               varchar2 ( 20  char ) not null
,   vie_le_cd           varchar2 ( 20  char ) not null
,   path_to_le          varchar2 ( 500 char ) not null
,   constraint pk_vle primary key ( step_run_sid , basis_typ , le_cd )
);