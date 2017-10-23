create table stn.gl_account_hierarchy
(
    account_key            number   ( 18 , 0 )      not null
,   account_mapping_key    number   ( 18 , 0 )      not null
,   account_description    varchar2 ( 50 char )     null
,   account_type           varchar2 ( 30 char )     null
,   classification         varchar2 ( 20 char )     null
,   hierarchy_key          varchar2 ( 2 char )      not null
,   hierarchy_name         varchar2 ( 50 char )     not null
,   level_1                varchar2 ( 30 char )     null
,   level_1_name           varchar2 ( 50 char )     null
,   level_2                varchar2 ( 30 char )     null
,   level_2_name           varchar2 ( 50 char )     null
,   level_3                varchar2 ( 30 char )     null
,   level_3_name           varchar2 ( 50 char )     null
,   level_4                varchar2 ( 30 char )     null
,   level_4_name           varchar2 ( 50 char )     null
,   level_5                varchar2 ( 30 char )     null
,   level_5_name           varchar2 ( 50 char )     null
,   level_6                varchar2 ( 30 char )     null
,   level_6_name           varchar2 ( 50 char )     null
,   level_7                varchar2 ( 30 char )     null
,   level_7_name           varchar2 ( 50 char )     null
,   level_8                varchar2 ( 30 char )     null
,   level_8_name           varchar2 ( 50 char )     null
,   level_9                varchar2 ( 30 char )     null
,   level_9_name           varchar2 ( 50 char )     null
,   level_10               varchar2 ( 30 char )     null
,   level_10_name          varchar2 ( 50 char )     null
,   level_11               varchar2 ( 30 char )     null
,   level_11_name          varchar2 ( 50 char )     null
,   level_12               varchar2 ( 30 char )     null
,   level_12_name          varchar2 ( 50 char )     null
,   level_13               varchar2 ( 30 char )     null
,   level_13_name          varchar2 ( 50 char )     null
,   level_14               number   ( 18 , 0 )      not null
,   level_14_name          varchar2 ( 50 char )     null
,   constraint pk_glah     primary key ( account_key )
);