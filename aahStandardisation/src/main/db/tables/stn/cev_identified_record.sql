create global temporary table stn.cev_identified_record
(
    row_sid number ( 38 , 0 ) not null
,   constraint pk_cir primary key ( row_sid )
)
on commit delete rows
;