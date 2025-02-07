create table stn.journal_line
(
    row_sid                number ( 38 , 0 )     generated by default as identity not null
,		source_typ_cd					 varchar2(30 char)																			not null    
,   correlation_id         varchar2(40 char)                                     
,   accounting_dt          date                                                   not null
,   le_id                  number(38)                                             not null
,	journal_type		   varchar2(20 char)		                              not null
,	jrnl_source			   varchar2(40 char)									  not null
,   acct_cd                varchar2(20 char)                                      not null
,   basis_cd               varchar2(20 char)                                      not null
,   ledger_cd              varchar2(20 char)                                      not null
,   policy_id              varchar2(30 char)                                     
,   stream_id              number(38)                                            
,   affiliate_le_id        number(38)
,   counterparty_le_id     number(38)
,   dept_cd                varchar2(20 char)
,   business_event_typ     varchar2(20 char)															
,		journal_line_desc    	 varchar2(100 char)                                 
,   journal_descr          varchar2(50 byte)                                     
,   chartfield_1           varchar2(20 char)
,   accident_yr            number(4)
,   underwriting_yr        number(4)                                             
,   tax_jurisdiction_cd    varchar2(2 char)                                      
,   event_seq_id           number(38)
,   business_typ           varchar2(2 char)                                      
,   premium_typ            varchar2(1 char)
,   owner_le_id            number(38)                                            
,   ultimate_parent_le_id  number(38)                                            
,   event_typ              varchar2(20 char)     default 'NVS'
,   transaction_ccy        varchar2(3 char)                                       not null
,   transaction_amt        number(38,9)                                           not null
,   functional_ccy         varchar2(3 char)                                       not null
,   functional_amt         number(38,9)                                           not null
,   reporting_ccy          varchar2(3 char)                                       not null
,   reporting_amt          number(38,9)                                           not null
,   execution_typ          varchar2(30 char)                                     
,   lpg_id                 number(38)            default 2                        not null
,   event_status           varchar2(1 char)      default 'U'                      not null
,   feed_uuid              raw(16)                                                not null
,   no_retries             number(38)            default 0                        not null
,   step_run_sid           number(38)            default 0                        not null
,   constraint pk_jl      primary key ( row_sid )
,   constraint ck_acct_cd check       ( length ( acct_cd ) = 8 or length ( acct_cd ) = 11 )
);