begin   
    -- change event status o N on bad record.    Leave the rest as E to get reprocessed
    -- expect 399    
    update stn.journal_line u
    set
        u.event_status = 'N',
        transaction_amt = 0,
        reporting_amt = 0
   where
        u.row_sid in (
            with
                row_to_keep as (select jl1.correlation_id, max(jl1.row_sid) good_row_sid from stn.journal_line jl1 where jl1.event_status = 'E' and jl1.ledger_cd = 'GO_CONSOL' and  jl1.acct_cd <> '13200100-01' and jl1.feed_uuid = 'D313DCD365CE6988E053D6830A0AD06B' group by  jl1.correlation_id)  -- select one entry from all the bad ones
            select jl.row_sid
            from
                stn.journal_line jl
                join row_to_keep on jl.correlation_id = row_to_keep.correlation_id
            where
                event_status = 'E' and
                ledger_cd <> 'CORE' and -- core ledger entries are ok
                acct_cd <> '13200100-01' and  -- entries to suspense are ok
                row_sid <> row_to_keep.good_row_sid);    -- keep 1 of the entries to the other account
   
     
   -- expected rowcount is 399 but will be zero if this is rerun
   IF sql%rowcount not in    (399,0)  THEN
        rollback;
        raise_application_error(-20999,'Wrong number of rows updated '||sql%rowcount);
   END IF;
   commit;
   end;
   /