create global temporary table slr.slr_fx_reval_temp 
   (           adjust_offset varchar2(20 byte) not null enable, 
               fx_accounting_event varchar2(20 byte) not null enable, 
               fx_gl_account varchar2(20 byte) not null enable, 
               jlu_rowid varchar2(20 byte) not null enable, 
                constraint slr_fx_reval_temp_pk primary key (adjust_offset, fx_accounting_event, jlu_rowid, fx_gl_account) enable
   ) on commit preserve rows
;
