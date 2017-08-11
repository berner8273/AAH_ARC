create table stn.line_of_business
(
    line_of_business_cd         varchar2 ( 5   char ) not null
,   line_of_business_descr      varchar2 ( 100 char ) not null
,   line_of_business_long_descr varchar2 ( 100 char ) not null
,   constraint pk_lob primary key ( line_of_business_cd )
);