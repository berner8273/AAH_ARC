create table stn.posting_method_derivation_link
(
    psm_mtm_row_sid_1             number ( 38 , 0 )    not null
,   psm_mtm_row_sid_2             number ( 38 , 0 )    not null
,   constraint uk_psmdl           primary key ( psm_mtm_row_sid_1 , psm_mtm_row_sid_2 )
,   constraint ck_row_sid         check       ( psm_mtm_row_sid_1 <> psm_mtm_row_sid_2 )
);