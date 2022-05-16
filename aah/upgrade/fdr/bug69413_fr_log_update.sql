update fdr.fr_log 
set LO_TABLE_IN_ERROR_NAME = 'cession_event'
where trunc(LO_EVENT_DATETIME) = '11-MAY-22'
 AND LO_TABLE_IN_ERROR_NAME = 'gl_account'
 AND LO_FIELD_IN_ERROR_NAME = 'acct_cd'
 AND LO_ERROR_STATUS = 'E';
 commit;