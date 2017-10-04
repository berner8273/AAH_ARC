create table stn.gl_account_hierarchy
(
    account_key            varchar2 ( 255 char )    not null
,   account_mapping_key    varchar2 ( 255 char )    not null
,   account_description    varchar2 ( 255 char )    not null
,   account_type           varchar2 ( 255 char )    not null
,   classification         varchar2 ( 255 char )    not null
,   hierarchy_key          varchar2 ( 1 char )      not null
,   hierarchy_name         varchar2 ( 28 char )     not null
,   level_1                varchar2 ( 255 char )    null
,   level_1_name           varchar2 ( 255 char )    null
,   level_2                varchar2 ( 255 char )    null
,   level_2_name           varchar2 ( 255 char )    null
,   level_3                varchar2 ( 255 char )    null
,   level_3_name           varchar2 ( 255 char )    null
,   level_4                varchar2 ( 255 char )    null
,   level_4_name           varchar2 ( 255 char )    null
,   level_5                varchar2 ( 255 char )    null
,   level_5_name           varchar2 ( 255 char )    null
,   level_6                varchar2 ( 255 char )    null
,   level_6_name           varchar2 ( 255 char )    null
,   level_7                varchar2 ( 255 char )    null
,   level_7_name           varchar2 ( 255 char )    null
,   level_8                varchar2 ( 255 char )    null
,   level_8_name           varchar2 ( 255 char )    null
,   level_9                varchar2 ( 255 char )    null
,   level_9_name           varchar2 ( 255 char )    null
,   level_10               varchar2 ( 255 char )    null
,   level_10_name          varchar2 ( 255 char )    null
,   level_11               varchar2 ( 255 char )    null
,   level_11_name          varchar2 ( 255 char )    null
,   level_12               varchar2 ( 255 char )    null
,   level_12_name          varchar2 ( 255 char )    null
,   level_13               varchar2 ( 255 char )    null
,   level_13_name          varchar2 ( 255 char )    null
,   level_14               varchar2 ( 255 char )    null
,   level_14_name          varchar2 ( 255 char )    null
,   constraint pk_glah     primary key ( account_key )
);