-- script for user story 82311.  Clear transaction amount for policy 620320-C
-- it creates a journal line feed that will be processed during intra day or overnight

DECLARE

hFeedUUID raw(16);
hCorrelationId varchar2(40);
dEffDate date;
dCurrentDate date;
dOpenPeriod date;
nExists number; 

BEGIN


select standard_hash('fix 620320-C', 'MD5')
into hFeedUUID 
from dual;

select standard_hash('cid fix 620320-C' ,'MD5')
into hCorrelationId 
from dual;

select count(*) into nExists from stn.feed where feed_uuid = hFeedUUID;  

IF nExists = 1 THEN

    -- records exist.  This is being rerun
    select count(*) 
    into nExists 
    from stn.journal_line 
    where
        feed_uuid = hFeedUUID and
        event_status  = 'P';

    IF nExists > 0 THEN
        raise_application_error(-20999,'Entries already exist and have been processed.  This deployment can not be rerun.');
    END IF;

    delete from stn.journal_line where feed_uuid = hFeedUUID;
    delete from stn.feed_record_count where feed_uuid  = hFeedUUID;
    delete from stn.feed where feed_uuid = hFeedUUID;
 
END IF;                

-- use the open cash period
select period_end 
into dOpenPeriod
from stn.period_status ps 
where event_class = 'CASH_TXN';

select gp_todays_bus_date 
into dCurrentDate
from fdr.fr_global_parameter 
where gp_one_id = '1';

dEffDate := least(dOpenPeriod, dCurrentDate);

IF dEffDate is null THEN
    rollback;
    raise_application_error(-20999,'Bad effDate');
END IF;


INSERT INTO stn.feed(
    --feed_sid,
    feed_uuid,
    feed_typ,
    effective_dt,
    system_cd,
    stated_checksum,
    loaded_ts)
VALUES
    (--feed_sid,is identity column
    hFeedUUID, --feed_uuid,
    'JOURNAL_LINE', --feed_typ,
    dEffDate, --effective_date,
    '202403 fix 620320-C', --system_cd,
    'NONE', --stated_checksum,
    sysdate); --loaded_ts)        




INSERT INTO stn.feed_record_count(
    feed_uuid,
    db_nm,
    table_nm,
    stated_record_cnt,
    actual_record_cnt)
VALUES
    (hFeedUUID, --feed_uuid,
    'STN', -- db_mn
    'JOURNAL_LINE', --table_nm
    2, -- stated_reord_cnt
    null); --actual_record_cnt



-- AR Entry
INSERT INTO stn.journal_line (
    --row_sid,
    source_typ_cd,
    correlation_id,
    accounting_dt,
    le_id,
    journal_type,
    jrnl_source,
    acct_cd,
    basis_cd,
    ledger_cd,
    policy_id,
    stream_id,
    affiliate_le_id,
    counterparty_le_id,
    dept_cd,
    business_event_typ,
    journal_line_desc,
    journal_descr,
    chartfield_1,
    accident_yr,
    underwriting_yr,
    tax_jurisdiction_cd,
    event_seq_id,
    business_typ,
    premium_typ,
    owner_le_id,
    ultimate_parent_le_id,
    event_typ,
    transaction_ccy,
    transaction_amt,
    functional_ccy,
    functional_amt,
    reporting_ccy,
    reporting_amt,
    execution_typ,
    lpg_id,
    event_status,
    feed_uuid,
    no_retries,
    step_run_sid)
VALUES
    (--null, --row_sid,
    'CA', --source_typ_cd,
    hCorrelationId, --correlation_id,
    dEffDate, --accounting_dt
    171, --le_id,AGCRP
    'PERC', --journal_type,
    'PRE_ACCOUNTED_FEED', --jrnl_source,
    '13200100-01', --acct_cd,  direct AR
    'NVS', --basis_cd,
    'CORE', -- ledger
    '620320-C', -- policy
    20368836, --stream_id,
    null, --affiliate_le_id,
    6, --counterparty_le_id,
    null, -- dept_cd,
    'CASH_OFFSET', --business_event_typ,
    'Fix Trans Amt', --journal_line_desc,
    'Fix Trans Amt', --journal_descr,
    'DNP', -- chartfield_1
    null, --accident_yr,
    2013, --underwriting_yr,
    'NY', --tax_jurisdiction_cd,
    null, --event_seq_id,
    'D', --business_typ,
    'U', --premium_typ,
    6 ,-- owner_le_id,  
    6, --ultimate_parent_le_id,
    'WP_CASH_OFFSET', --event_typ,
    'USD', --transaction_ccy,
    -13.77, --transaction_amt,
    'USD', --functional_ccy,
    0, --functional_amt,
    'USD', --reporting_ccy,
    0, --reporting_amt,
    'NON_MTM', --execution_typ,
    2, --lpg_id,
    'U', --event_status,
    hFeedUUID,
    0, --no_retries,
    0); --step_run_sid,
        
-- other income entry
INSERT INTO stn.journal_line (
    --row_sid,
    source_typ_cd,
    correlation_id,
    accounting_dt,
    le_id,
    journal_type,
    jrnl_source,
    acct_cd,
    basis_cd,
    ledger_cd,
    policy_id,
    stream_id,
    affiliate_le_id,
    counterparty_le_id,
    dept_cd,
    business_event_typ,
    journal_line_desc,
    journal_descr,
    chartfield_1,
    accident_yr,
    underwriting_yr,
    tax_jurisdiction_cd,
    event_seq_id,
    business_typ,
    premium_typ,
    owner_le_id,
    ultimate_parent_le_id,
    event_typ,
    transaction_ccy,
    transaction_amt,
    functional_ccy,
    functional_amt,
    reporting_ccy,
    reporting_amt,
    execution_typ,
    lpg_id,
    event_status,
    feed_uuid,
    no_retries,
    step_run_sid)
VALUES
    (--null, --row_sid,
    'CA', --source_typ_cd,
    hCorrelationId, --correlation_id,
    dEffDate, --accounting_dt
    171, --le_id,AGCRP
    'PERC', --journal_type,
    'PRE_ACCOUNTED_FEED', --jrnl_source,
    '46300145-01', --acct_cd,  other income
    'NVS', --basis_cd,
    'CORE', -- ledger
    '620320-C', -- policy
    20368836, --stream_id,
    null, --affiliate_le_id,
    6, --counterparty_le_id,
    null, -- dept_cd,
    'CASH_OFFSET', --business_event_typ,
    'Fix Trans Amt', --journal_line_desc,
    'Fix Trans Amt', --journal_descr,
    'DNP', -- chartfield_1
    null, --accident_yr,
    2013, --underwriting_yr,
    'NY', --tax_jurisdiction_cd,
    null, --event_seq_id,
    'D', --business_typ,
    'U', --premium_typ,
    6 ,-- owner_le_id,  
    6, --ultimate_parent_le_id,
    'WP_CASH_OFFSET', --event_typ,
    'USD', --transaction_ccy,
    13.77, --transaction_amt,
    'USD', --functional_ccy,
    0, --functional_amt,
    'USD', --reporting_ccy,
    0, --reporting_amt,
    'NON_MTM', --execution_typ,
    2, --lpg_id,
    'U', --event_status,
    hFeedUUID,
    0, --no_retries,
    0); --step_run_sid,
        
commit;
end;    
/    
