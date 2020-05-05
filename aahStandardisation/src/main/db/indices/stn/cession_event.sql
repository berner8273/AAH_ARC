create index i_cev_uuid on stn.cession_event ( correlation_uuid );
create index idx_cession_event_acct_mon on stn.cession_event(stream_id,trunc(accounting_dt, 'fmmonth'));
create index gc_event_status on stn.cession_event (event_status);