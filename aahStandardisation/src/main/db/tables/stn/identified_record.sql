create global temporary table stn.identified_record
(
    row_sid number ( 38 , 0 ) not null
,   constraint pk_ir primary key ( row_sid )
)
on commit delete rows
;