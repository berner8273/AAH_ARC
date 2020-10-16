create index fdr.idxfr_stan_raw_general_codes on fdr.fr_stan_raw_general_codes (to_char(trunc(to_number(message_id))));
create index gc_event_status on fdr.fr_stan_raw_general_codes (event_status);