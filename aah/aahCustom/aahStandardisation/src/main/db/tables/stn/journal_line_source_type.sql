create table stn.journal_line_source_type
(
    source_typ_cd 	 varchar2 (30 ) not null
,   source_typ_descr varchar2 (100) not null
, constraint pk_styp_jl  PRIMARY KEY (source_typ_cd));