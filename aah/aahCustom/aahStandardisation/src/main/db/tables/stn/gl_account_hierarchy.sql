create table stn.gl_account_hierarchy
(
    account_key            varchar2 ( 255 char )    not null
,   account_mapping_key    varchar2 ( 255 char )    not null
,   account_description    varchar2 ( 550 char )    null
,   account_type           varchar2 ( 255 char )    null
,   classification         varchar2 ( 255 char )    null
,   insurance_account      varchar2 ( 1 char )      null
,   hierarchy_key          varchar2 ( 5 char )      not null
,   hierarchy_name         varchar2 ( 70 char )     not null
,   level_1                varchar2 ( 255 char )    null
,   level_1_name           varchar2 ( 550 char )    null
,   level_1_order          varchar2 ( 50 char )     null
,   level_1_mapping        varchar2 ( 255 char )    null
,   level_2                varchar2 ( 255 char )    null
,   level_2_name           varchar2 ( 550 char )    null
,   level_2_order          varchar2 ( 50 char )     null
,   level_2_mapping        varchar2 ( 255 char )    null
,   level_3                varchar2 ( 255 char )    null
,   level_3_name           varchar2 ( 550 char )    null
,   level_3_order          varchar2 ( 50 char )     null
,   level_3_mapping        varchar2 ( 255 char )    null
,   level_4                varchar2 ( 255 char )    null
,   level_4_name           varchar2 ( 550 char )    null
,   level_4_order          varchar2 ( 50 char )     null
,   level_4_mapping        varchar2 ( 255 char )    null
,   level_5                varchar2 ( 255 char )    null
,   level_5_name           varchar2 ( 550 char )    null
,   level_5_order          varchar2 ( 50 char )     null
,   level_5_mapping        varchar2 ( 255 char )    null
,   level_6                varchar2 ( 255 char )    null
,   level_6_name           varchar2 ( 550 char )    null
,   level_6_order          varchar2 ( 50 char )     null
,   level_6_mapping        varchar2 ( 255 char )    null
,   level_7                varchar2 ( 255 char )    null
,   level_7_name           varchar2 ( 550 char )    null
,   level_7_order          varchar2 ( 50 char )     null
,   level_7_mapping        varchar2 ( 255 char )    null
,   level_8                varchar2 ( 255 char )    null
,   level_8_name           varchar2 ( 550 char )    null
,   level_8_order          varchar2 ( 50 char )     null
,   level_8_mapping        varchar2 ( 255 char )    null
,   level_9                varchar2 ( 255 char )    null
,   level_9_name           varchar2 ( 550 char )    null
,   level_9_order          varchar2 ( 50 char )     null
,   level_9_mapping        varchar2 ( 255 char )    null
,   level_10               varchar2 ( 255 char )    null
,   level_10_name          varchar2 ( 550 char )    null
,   level_10_order         varchar2 ( 50 char )     null
,   level_10_mapping       varchar2 ( 255 char )    null
,   level_11               varchar2 ( 255 char )    null
,   level_11_name          varchar2 ( 550 char )    null
,   level_11_order         varchar2 ( 50 char )     null
,   level_11_mapping       varchar2 ( 255 char )    null
,   level_12               varchar2 ( 255 char )    null
,   level_12_name          varchar2 ( 550 char )    null
,   level_12_order         varchar2 ( 50 char )     null
,   level_12_mapping       varchar2 ( 255 char )    null
,   level_13               varchar2 ( 255 char )    null
,   level_13_name          varchar2 ( 550 char )    null
,   level_13_order         varchar2 ( 50 char )     null
,   level_13_mapping       varchar2 ( 255 char )    null
,   level_14               varchar2 ( 255 char )    not null
,   level_14_name          varchar2 ( 550 char )    null
,   level_14_order         varchar2 ( 50 char )     null
,   level_14_mapping       varchar2 ( 255 char )    null
,   constraint pk_glah     primary key ( account_key )
);