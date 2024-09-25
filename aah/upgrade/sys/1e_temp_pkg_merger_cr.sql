CREATE OR REPLACE PACKAGE BODY STN.temp_pkg_merger_cr AS

hFeedUUID1 raw(16);
hFeedUUID2 raw(16);
hFeedUUID3 raw(16);
hFeedUUID4 raw(16);
hFeedUUID5 raw(16);
hFeedUUID6 raw(16);
hFeedUUID7 raw(16);
hFeedUUID8 raw(16);
hFeedUUID9 raw(16);
hFeedUUID10 raw(16);
hFeedUUID11 raw(16);

hCorrelationId1 varchar2(40);
hCorrelationId2 varchar2(40);
hCorrelationId3 varchar2(40);
hCorrelationId4 varchar2(40);
hCorrelationId5 varchar2(40);
hCorrelationId6 varchar2(40);
hCorrelationId7 varchar2(40);
hCorrelationId8 varchar2(40);
hCorrelationId9 varchar2(40);
hCorrelationId10 varchar2(40);
hCorrelationId11 varchar2(40);


dEffDate varchar(30) :='to_date(''02-sep-2024'')';
dCurrentDate date;
dOpenPeriod date;
nExists number; 
sSourceTypeCd varchar2(2) := 'CA';
sChartfield varchar(3) := 'DNP';
sFeedSystemCD varchar(20) := 'AGM AGC Merger CR';
sJournalLineDesc varchar2(20) := 'AGM AGC Merger CR';
sJrnlSource varchar(20) := 'DEFAULT';
sJournalType varchar(20) := 'PERC';
sClearingAcct varchar(11) := '18860170-01'; -- Acquisition clg insurance 
sOOBAcct varchar(11) := '18860170-01'; --Out of Balance Account-Inv Sub
--sOOBAcct varchar(11) := '18250250-01'; --Out of Balance Account-Inv Sub
nCnt number;


PROCEDURE pResetTempJL IS

sSQL varchar(2000);

BEGIN

sSql := 'truncate table stn.temp_stn_journal_line';
execute immediate sSql; 

exception
    when others then raise_application_error(-20220, 'resettempjl '||sqlerrm);
END;

PROCEDURE pInitialize IS
sSqlTruncate varchar(100);
sMonth varchar(2);


BEGIN


select standard_hash('AGMAGC Merger1CR', 'MD5') into hFeedUUID1 from dual;
select standard_hash('AGMAGC Merger2CR', 'MD5') into hFeedUUID2 from dual;
select standard_hash('AGMAGC Merger3CR', 'MD5') into hFeedUUID3 from dual;
select standard_hash('AGMAGC Merger4CR', 'MD5') into hFeedUUID4 from dual;
select standard_hash('AGMAGC Merger5CR', 'MD5') into hFeedUUID5 from dual;
select standard_hash('AGMAGC Merger6CR', 'MD5') into hFeedUUID6 from dual;
select standard_hash('AGMAGC Merger7CR', 'MD5') into hFeedUUID7 from dual;
select standard_hash('AGMAGC Merger8CR', 'MD5') into hFeedUUID8 from dual;
select standard_hash('AGMAGC Merger9CR', 'MD5') into hFeedUUID9 from dual;
select standard_hash('AGMAGC Merger10CR', 'MD5') into hFeedUUID10 from dual;
select standard_hash('AGMAGC Merger11CR', 'MD5') into hFeedUUID11 from dual;

select standard_hash('AGMAGC Merger1CCR' ,'MD5') into hCorrelationId1 from dual;
select standard_hash('AGMAGC Merger2CCR' ,'MD5') into hCorrelationId2 from dual;
select standard_hash('AGMAGC Merger3CCR' ,'MD5') into hCorrelationId3 from dual;
select standard_hash('AGMAGC Merger4CCR' ,'MD5') into hCorrelationId4 from dual;
select standard_hash('AGMAGC Merger5CCR' ,'MD5') into hCorrelationId5 from dual;
select standard_hash('AGMAGC Merger6CR' ,'MD5') into hCorrelationId6 from dual;
select standard_hash('AGMAGC Merger7CCR' ,'MD5') into hCorrelationId7 from dual;
select standard_hash('AGMAGC Merger8CCR' ,'MD5') into hCorrelationId8 from dual;
select standard_hash('AGMAGC Merger9CCR' ,'MD5') into hCorrelationId9 from dual;
select standard_hash('AGMAGC Merger10CCR' ,'MD5') into hCorrelationId10 from dual;
select standard_hash('AGMAGC Merger11CCR' ,'MD5') into hCorrelationId11 from dual;


update fdr.fr_general_codes
set gc_active = 'I'
where gc_client_code = '14400330';


-- use the open cash period.  Expected to be march but this allows testing inenvironments that may have different open dates
select period_end 
into dOpenPeriod
from stn.period_status ps 
where event_class = 'CASH_TXN';

select extract(month from dOpenPeriod) into sMonth from dual;
IF length(sMonth) = 1 THEN
    sMonth := '0'||sMonth;
END IF;


select gp_todays_bus_date 
into dCurrentDate
from fdr.fr_global_parameter 
where gp_one_id = '1';

--dEffDate := least(dOpenPeriod, dCurrentDate);

-- effective date of new JL
IF dEffDate is null THEN
    rollback;
    raise_application_error(-20999,'Bad effDate');
END IF;


-- temp open obsolete event class
select count(*) into nCnt
from fdr.fr_general_lookup 
where 
    lk_lkt_lookup_type_code   = 'EVENT_CLASS_PERIOD' and 
    lk_match_key1 = 'BALANCE_OTHERS' and
    lk_match_key2 = extract(year from dOpenPeriod) and
    lk_match_key3 = sMonth;

IF nCnt = 1 THEN

    update fdr.fr_general_lookup 
    set lk_lookup_value1 = 'O'
    where 
        lk_lkt_lookup_type_code   = 'EVENT_CLASS_PERIOD' and 
        lk_match_key1 = 'BALANCE_OTHERS' and
        lk_match_key2 = to_char(extract(year from dOpenPeriod)) and
        lk_match_key3 = sMonth;
ELSE
    insert into fdr.fr_general_lookup(
        lk_lkt_lookup_type_code,
        lk_match_key1, 
        lk_match_key2,
        lk_match_key3,
        lk_match_key4,
        lk_lookup_value1,
        lk_lookup_value2,
        lk_lookup_value3,
        lk_lookup_value5,
        lk_lookup_value10)
    values
        ('EVENT_CLASS_PERIOD', 
        'BALANCE_OTHERS',
        to_char(extract(year from dOpenPeriod)),
        sMonth,
        to_char(extract(year from dOpenPeriod) ||'-'|| sMonth),
        'O',
        upper(to_char(trunc(last_day(add_months(dopenperiod,-1)))+1,'dd-mon-yyyy')),
        upper(to_char(dOpenPeriod,'dd-mon-yyyy')),
        'N',
        to_char('8000')
        );      
        
END IF;

commit;

exception
    when others then
           raise_application_error(-20110, 'initialize '||sqlerrm);


END; --pInitialize

PROCEDURE pFixAffiliate IS
-- Affiliates were not properly changed for AGCRP entries in AGRT transfer.
-- Scenario 10  will change the affiliate.  No balance changes.
-- needed reference data updated before the proper affiliates could be entered.

begin

update stn.temp_stn_journal_line set affiliate_le_id = 258 where counterparty_le_id = 61 and scenerio = 10; 
update stn.temp_stn_journal_line set affiliate_le_id = 289 where counterparty_le_id = 314 and scenerio = 10;

commit;

exception
    when others then 
        raise_application_error(-20225,'pFixAffiliate '||sqlerrm);

END; -- pFixAffiliate

PROCEDURE pInsertJournalLine (anScenerio number) IS


cursor cur is 
select
--    row_sid,
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
    step_run_sid
from stn.temp_stn_journal_line
where scenerio in (anScenerio);


type recCur is table of cur%rowtype index by binary_integer;
lrecCur recCur;

BEGIN

pInitialize;

dbms_output.put_line('starting bulk insert');
OPEN cur;
LOOP
    EXIT when cur%notfound;
    FETCH cur bulk collect into lrecCur limit 100000;
    FORALL i in lrecCur.first..lrecCur.last
    INSERT into stn.journal_line(

--        row_sid,
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
--    values lrecCur(i);
values 
    (   lrecCur(i).source_typ_cd,
        lrecCur(i).correlation_id,
        lrecCur(i).accounting_dt,
        lrecCur(i).le_id,
        lrecCur(i).journal_type,
        lrecCur(i).jrnl_source,
        lrecCur(i).acct_cd,
        lrecCur(i).basis_cd,
        lrecCur(i).ledger_cd,
        lrecCur(i).policy_id,
        lrecCur(i).stream_id,
        lrecCur(i).affiliate_le_id,
        lrecCur(i).counterparty_le_id,
        lrecCur(i).dept_cd,
        lrecCur(i).business_event_typ,
        lrecCur(i).journal_line_desc,
        lrecCur(i).journal_descr,
        lrecCur(i).chartfield_1,
        lrecCur(i).accident_yr,
        lrecCur(i).underwriting_yr,
        lrecCur(i).tax_jurisdiction_cd,
        lrecCur(i).event_seq_id,
        lrecCur(i).business_typ,
        lrecCur(i).premium_typ,
        lrecCur(i).owner_le_id,
        lrecCur(i).ultimate_parent_le_id,
        lrecCur(i).event_typ,
        lrecCur(i).transaction_ccy,
        lrecCur(i).transaction_amt,
        lrecCur(i).functional_ccy,
        lrecCur(i).functional_amt,
        lrecCur(i).reporting_ccy,
        lrecCur(i).reporting_amt,
        lrecCur(i).execution_typ,
        lrecCur(i).lpg_id,
        lrecCur(i).event_status,
        lrecCur(i).feed_uuid,
        lrecCur(i).no_retries,
        lrecCur(i).step_run_sid);
    
END LOOP;    


CLOSE cur;


pCreateFeed(anScenerio);

commit;

exception
    when others then
        rollback;
        raise_application_error(-20115,'pInsertJournalLine '||sqlerrm);

end; --pInsertJournalLine


PROCEDURE pUpdateSignOnBase IS

begin

update stn.temp_stn_journal_line
set
    transaction_amt = transaction_amt * -1,
    reporting_amt  = reporting_amt * -1,
    functional_amt = functional_amt * -1;

commit;

exception
    when others then
        raise_application_error(-20102,'updateSignOnBase '||sqlerrm);

END; -- pUpdateSignOnBase
PROCEDURE pCreateFeed (anScenerio number) IS 

lhFeedUUID raw(16);
lhCorrelationId varchar2(40);
nCnt number;
dEffDateFeed date := to_date('02-sep-24');

begin

pInitialize;

dbms_output.put_line('top of create_line');

   
    -- timestamp is in the unique key
    dbms_lock.sleep(1);
     
    CASE anScenerio
        WHEN  1 THEN  
            lhFeedUUID := hFeedUUID1;
            lhCorrelationId := hCorrelationId1; 
        WHEN  2 THEN  
            lhFeedUUID := hFeedUUID2;
            lhCorrelationId := hCorrelationId2;
        WHEN  3 THEN  
            lhFeedUUID := hFeedUUID3;
            lhCorrelationId := hCorrelationId3;
        WHEN  4 THEN  
            lhFeedUUID := hFeedUUID4;
            lhCorrelationId := hCorrelationId4;
        WHEN  5 THEN  
            lhFeedUUID := hFeedUUID5;
            lhCorrelationId := hCorrelationId5;
        WHEN  6 THEN  
            lhFeedUUID := hFeedUUID6;
            lhCorrelationId := hCorrelationId6;
        WHEN  7 THEN  
            lhFeedUUID := hFeedUUID7;
            lhCorrelationId := hCorrelationId7;
        WHEN  8 THEN  
            lhFeedUUID := hFeedUUID8;
            lhCorrelationId := hCorrelationId8;
        WHEN  9 THEN  
            lhFeedUUID := hFeedUUID9;
            lhCorrelationId := hCorrelationId9;            
        WHEN  10 THEN  
            lhFeedUUID := hFeedUUID10;
            lhCorrelationId := hCorrelationId10;
        WHEN  11 THEN  
            lhFeedUUID := hFeedUUID11;
            lhCorrelationId := hCorrelationId11;                        
        ELSE
            raise_application_error(-20113,'unexpected in loop = '||anScenerio||' '||sqlerrm);                            
    END CASE;    

dbms_output.put_line('after case');
    select count(*) 
    into nCnt 
    from STN.TEMP_STN_JOURNAL_LINE 
    where feed_uuid = lhFeedUUID; 

 
dbms_output.put_line('after ncnt '||deffdate);


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
        lhFeedUUID, --feed_uuid,
        'JOURNAL_LINE', --feed_typ,
        dEffDateFeed, --effective_date,
        sFeedSystemCD, --system_cd,
        'NONE', --stated_checksum,
        sysdate); --loaded_ts)        

dbms_output.put_line('after insert to feed');


    INSERT INTO stn.feed_record_count(
        feed_uuid,
        db_nm,
        table_nm,
        stated_record_cnt,
        actual_record_cnt)
    VALUES
        (lhFeedUUID, --feed_uuid,
        'STN', -- db_mn
        'JOURNAL_LINE', --table_nm
        nCnt, -- stated_reord_cnt
        null); --actual_record_cnt
dbms_output.put_line('after insert to feed record count');

-- allow calling program to commit to keep transaction consistent
exception
    when others then
        rollback; 
        raise_application_error(-20116,'create feed '||sqlerrm||' '||nCnt||'x'||lhfeeduuid);
    
 
END; -- pCreateFeed
--------------------------------------------------------------------------------------------
function  fBuildSql (asWhere varchar, anScenerio number) return varchar IS 

sTop varchar(5000);
sOrder varchar(5000);
sSql varchar (5000);
sWhere varchar(500);
lhFeedUUID raw(16);
lhCorrelationId varchar2(40);



BEGIN

sWhere := asWhere;

CASE anScenerio
    WHEN  1 THEN  
        lhFeedUUID := hFeedUUID1;
        lhCorrelationId := hCorrelationId1; 
    WHEN  2 THEN  
        lhFeedUUID := hFeedUUID2;
        lhCorrelationId := hCorrelationId2;
    WHEN  3 THEN  
        lhFeedUUID := hFeedUUID3;
        lhCorrelationId := hCorrelationId3;
    WHEN  4 THEN  
        lhFeedUUID := hFeedUUID4;
        lhCorrelationId := hCorrelationId4;
    WHEN  5 THEN  
        lhFeedUUID := hFeedUUID5;
        lhCorrelationId := hCorrelationId5;
    WHEN  6 THEN  
        lhFeedUUID := hFeedUUID6;
        lhCorrelationId := hCorrelationId6;
    WHEN  7 THEN  
        lhFeedUUID := hFeedUUID7;
        lhCorrelationId := hCorrelationId7;
    WHEN  8 THEN  
        lhFeedUUID := hFeedUUID8;
        lhCorrelationId := hCorrelationId8;
    WHEN  9 THEN  
        lhFeedUUID := hFeedUUID9;
        lhCorrelationId := hCorrelationId9;
    WHEN  10 THEN  
        lhFeedUUID := hFeedUUID10;
        lhCorrelationId := hCorrelationId10;
    WHEN  11 THEN  
        lhFeedUUID := hFeedUUID11;
        lhCorrelationId := hCorrelationId11;                        
    ELSE
        raise_application_error(-20113,'unexpected anScenerio = '||anScenerio);                            
END CASE;    

--sWhere := sWhere || ' and fc.fc_segment_8 = ''51571'' ';

sTop := 
'INSERT INTO stn.temp_stn_journal_line ( '      ||
    'row_sid,  '                ||-- for now hardcode to zero.  It will get populated on insert into the real table
    'source_typ_cd, '           ||
    'correlation_id, '          ||
    'accounting_dt, '           ||
    'le_id, '                   ||
    'journal_type, '            ||
    'jrnl_source, '             ||
    'acct_cd, '                 ||
    'basis_cd, '                ||
    'ledger_cd, '               ||
    'policy_id, '               ||
    'stream_id, '               ||
    'affiliate_le_id, '         ||
    'counterparty_le_id, '      ||
    'dept_cd, '                 ||
    'business_event_typ,  '     ||
    'journal_line_desc, '       ||
    'journal_descr, '           ||
    'chartfield_1, '            ||
    'accident_yr, '             ||
    'underwriting_yr, '         ||
    'tax_jurisdiction_cd, '     ||
    'event_seq_id, '            ||
    'business_typ, '            ||
    'premium_typ, '             ||
    'owner_le_id, '             ||
    'ultimate_parent_le_id, '   ||
    'event_typ, '               ||
    'transaction_ccy, '         ||
    'transaction_amt, '         ||
    'functional_ccy, '          ||
    'functional_amt, '          ||
    'reporting_ccy, '           ||
    'reporting_amt, '           ||
    'execution_typ, '           ||
    'lpg_id, '                  ||
    'event_status, '            ||
    'feed_uuid, '               ||
    'no_retries, '              ||
    'step_run_sid, '            ||
    'scenerio, '                ||
    'eba_id) '                  ||
    'with le_map as ( '         ||
        ' select '                || 
            'le.le_cd as ReinsCo,' || 
            'lep.le_cd as le_cd ' ||
        'from ' ||
            'stn.legal_entity_link lel ' ||
            'join stn.legal_entity le  on le.le_id = lel.child_le_id and le.feed_uuid = lel.feed_uuid '  ||
            'join stn.legal_entity lep  on lep.le_id = lel.parent_le_id  and lep.feed_uuid = lel.feed_uuid '  ||
        'where '  ||
            'lel.step_run_sid = (select min(step_run_sid) from stn.legal_entity_link) ' ||
            'and lel.legal_entity_link_typ = ''SLR_LINK'' ' ||
            'and lep.le_cd in (''AGCRP'',''FSANY'',''FSAUK'',''AGREL'',''AGROL'',''AGFRA'') ' ||
            'order by lep.le_cd ) ' ||
'SELECT  '                      || 
    '0,  '                      || 
    'sSourceTypeCd,'            ||
    'hCorrelationId /*correlation_id*/, '                                ||
    'dEffDate /*--accounting_dt*/, '                                     ||
    'pl.pl_global_id,  '   ||
    'sJournalType, '                                    ||
    'sJrnlSource,  '                                      ||
    'fc.fc_account , '                           ||
    'fc.fc_segment_2  /*basis_cd*/, '                                     ||
    'fc.fc_segment_1  /*ledger*/, '                                       ||
    'fc.fc_segment_8  /*policy*/, '                                       ||
    'ec.ec_attribute_1 /*stream_id*/  , '                                  ||
    'pl_aff.pl_global_id /*fc.fc_segment_4, --affiliate_le_id*/ , '           ||
    'null /*counterparty_le_id, JL_REFERENCE_7*/, '                       ||
    'decode(fc_segment_3,''NVS'',null,fc_segment_3) /*dept_cd*/ , '        ||
    'null /*--business_event_typ,JL_REFERENCE_5*/, '                        ||
    'sJournalLineDesc,   '                          ||
    'null /*--journal_descr, JL_REFERENCE_1*/, '                            ||
    'sChartfield,  '                                     ||
    'null /*accident_yr,JL_REFERENCE_6*/, '                               ||
    'null /*underwriting_yr,JL_REFERENCE_3 */,'                           ||
    'decode(ec_attribute_2,''NVS'',null,ec_attribute_2) /*tax_jurisdiction_cd*/, '                           ||
    'null /*--event_seq_id*/ , '                                            ||
    'fc_segment_7 /*business_typ*/, '                                    ||
    'decode(ec_attribute_3,''NVS'',null,ec_attribute_3) /*--premium_typ*/ , ' ||
    'null  /* owner_le_id,JL_REFERENCE_4*/ ,  '                            ||
    'null /*ultimate_parent_le_id,JL_REFERENCE_2*/ , '                     ||
    'ec_attribute_4 /*event_typ*/ , '                                     ||
    'fc.fc_ccy /*transaction_ccy*/, '                                    ||
    'b.eab_tran_ltd_balance /*--transaction_amt*/, '                       ||
    'decode(fc.fc_segment_1,''EURGAAPADJ'',''EUR'',''UKGAAP_ADJ'',''GBP'',''USD'') /*functional_ccy*/, '                                     ||
    'b.eab_local_ltd_balance /*functional_amt*/, '                       ||
    'decode(fc.fc_segment_1,''EURGAAPADJ'',''EUR'',''UKGAAP_ADJ'',''GBP'',''USD'')  /*reporting_ccy*/, '                                      ||
    'b.eab_base_ltd_balance /*reporting_amt*/, '                         ||
    'fc_segment_6 /*execution_typ*/ , '                                   ||
    '2 /*lpg_id*/, '                                                     ||
    '''U'' /*event_status*/, '                                           ||
    'hFeedUUID, '                                                        ||
    '0 /*no_retries*/, '                                                 ||
    '0 /*step_run_sid*/, '                                               ||
    'sScenerio /*scenerio*/, '                                          ||
    'ec.ec_eba_id '                                                     ||
'from '                                                                 ||
    'stn.insurance_policy_reference ip '                                ||
    'full outer join le_map map  on ip.le_cd = map.reinsco '                       || 
    
    'full outer join stn.insurance_policy_reference ip_parent ON ip.parent_stream_id = ip_parent.stream_id ' ||  
    'full outer join le_map map_parent  on ip_parent.le_cd = map_parent.reinsco '                                 ||
    
    'join slr.slr_eba_combinations ec on ip.stream_id = ec.ec_attribute_1 '                               ||
    'join slr.slr_fak_combinations fc ON ec.ec_fak_id = fc.fc_fak_id '                                     ||  
    'join stn.merger_balances b on b.eab_eba_id = ec.ec_eba_id '                                           || 
    
    'join fdr.fr_gl_account gla on gla.ga_account_code = fc.fc_account '                                   ||
    'join fdr.fr_party_legal pl on fc.fc_entity = pl.pl_party_legal_id  '                                  ||
    'right outer join fdr.fr_party_legal pl_aff on fc.fc_segment_4 = pl_aff.pl_party_legal_id '            ||
'where ' || 
    '(abs(b.eab_tran_ltd_balance) + abs( b.eab_base_ltd_balance) + abs(b.eab_local_ltd_balance)) <> 0 and  '            || 
    'ip.policy_version = (select max(p2.policy_version) from rdr.rrv_ag_insurance_policy p2 where ip.stream_id = p2.stream_id) and '||
    'fc.fc_account in ( ''22400000-01'' , ''31460150-01'' ) and ' ||
    'fc.fc_account <> ''13600100-01'' and ' ||
    'eab_balance_type = 50   '            ;
sOrder := 
    'order by '         ||
    'ip.stream_id,'     ||
    'ip.le_cd, '        ||
    'fc_segment_4,'     ||
    'fc.fc_entity, '    ||
    'fc_segment_7 ';    

--temp filter on specific stream
--sWhere := sWhere || ' AND ec_attribute_1 = ''20363801'' ';
--dbms_output.put_line (' pbuild sql  where '||sWhere);


sSQL:= sTop ||sWhere||sOrder;
sSql := replace(sSql,'hFeedUUID',''''||lhfeedUUID||'''');
sSql := replace(sSql,'sChartfield',''''||sChartfield||'''');
sSql := replace(sSql,'sJournalLineDesc',''''||sJournalLineDesc||'''');
sSql := replace(sSql,'sJrnlSource',''''||sJrnlSource||'''');
sSql := replace(sSql,'sJournalType',''''||sJournalType||'''');
sSql := replace(sSql,'dEffDate',''||dEffDate||'');
sSql := replace(sSql,'hCorrelationId',''''||lhCorrelationId||'''');
sSql := replace(sSql,'sSourceTypeCd',''''||sSourceTypeCd||'''');
sSql := replace(sSql,'sScenerio',''''||anScenerio||'''');


dbms_output.put_line('fBuildSql '||sSQL);
return sSql;


exception
    when others then
        raise_application_error(-20102,'pBuildSql '||sqlerrm);


END; --pBuildql

function  fBuildSqlNoStream (asWhere varchar, anScenerio number) return varchar IS 

sTop varchar(5000);
sOrder varchar(5000);
sSql varchar (5000);
sWhere varchar(500);
lhFeedUUID raw(16);
lhCorrelationId varchar2(40);



BEGIN

sWhere := asWhere;

CASE anScenerio
    WHEN  1 THEN  
        lhFeedUUID := hFeedUUID1;
        lhCorrelationId := hCorrelationId1; 
    WHEN  2 THEN  
        lhFeedUUID := hFeedUUID2;
        lhCorrelationId := hCorrelationId2;
    WHEN  3 THEN  
        lhFeedUUID := hFeedUUID3;
        lhCorrelationId := hCorrelationId3;
    WHEN  4 THEN  
        lhFeedUUID := hFeedUUID4;
        lhCorrelationId := hCorrelationId4;
    WHEN  5 THEN  
        lhFeedUUID := hFeedUUID5;
        lhCorrelationId := hCorrelationId5;
    WHEN  6 THEN  
        lhFeedUUID := hFeedUUID6;
        lhCorrelationId := hCorrelationId6;
    WHEN  7 THEN  
        lhFeedUUID := hFeedUUID7;
        lhCorrelationId := hCorrelationId7;
    WHEN  8 THEN  
        lhFeedUUID := hFeedUUID8;
        lhCorrelationId := hCorrelationId8;
    WHEN  9 THEN  
        lhFeedUUID := hFeedUUID9;
        lhCorrelationId := hCorrelationId9;        
    WHEN  10 THEN  
        lhFeedUUID := hFeedUUID10;
        lhCorrelationId := hCorrelationId10;
    WHEN  11 THEN  
        lhFeedUUID := hFeedUUID11;
        lhCorrelationId := hCorrelationId11;                        
    ELSE
        raise_application_error(-20113,'unexpected anScenerio = '||anScenerio);                            
END CASE;    

--sWhere := sWhere || ' and fc.fc_segment_8 = ''51571'' ';

sTop := 
'INSERT INTO stn.temp_stn_journal_line ( '      ||
    'row_sid,  '                ||-- for now hardcode to zero.  It will get populated on insert into the real table
    'source_typ_cd, '           ||
    'correlation_id, '          ||
    'accounting_dt, '           ||
    'le_id, '                   ||
    'journal_type, '            ||
    'jrnl_source, '             ||
    'acct_cd, '                 ||
    'basis_cd, '                ||
    'ledger_cd, '               ||
    'policy_id, '               ||
    'stream_id, '               ||
    'affiliate_le_id, '         ||
    'counterparty_le_id, '      ||
    'dept_cd, '                 ||
    'business_event_typ,  '     ||
    'journal_line_desc, '       ||
    'journal_descr, '           ||
    'chartfield_1, '            ||
    'accident_yr, '             ||
    'underwriting_yr, '         ||
    'tax_jurisdiction_cd, '     ||
    'event_seq_id, '            ||
    'business_typ, '            ||
    'premium_typ, '             ||
    'owner_le_id, '             ||
    'ultimate_parent_le_id, '   ||
    'event_typ, '               ||
    'transaction_ccy, '         ||
    'transaction_amt, '         ||
    'functional_ccy, '          ||
    'functional_amt, '          ||
    'reporting_ccy, '           ||
    'reporting_amt, '           ||
    'execution_typ, '           ||
    'lpg_id, '                  ||
    'event_status, '            ||
    'feed_uuid, '               ||
    'no_retries, '              ||
    'step_run_sid, '            ||
    'scenerio, '                ||
    'eba_id) '                  ||
--    'with le_map as ( '         ||
--        ' select '                || 
--            'le.le_cd as ReinsCo,' || 
--            'lep.le_cd as le_cd ' ||
--        'from ' ||
--            'stn.legal_entity_link lel ' ||
--            'join stn.legal_entity le  on le.le_id = lel.child_le_id and le.feed_uuid = lel.feed_uuid '  ||
--            'join stn.legal_entity lep  on lep.le_id = lel.parent_le_id  and lep.feed_uuid = lel.feed_uuid '  ||
--        'where '  ||
--            'lel.step_run_sid = (select min(step_run_sid) from stn.legal_entity_link) ' ||
--            'and lel.legal_entity_link_typ = ''SLR_LINK'' ' ||
--            'and lep.le_cd in (''AGCRP'',''FSANY'',''FSAUK'',''AGREL'',''AGROL'',''AGFRA'') ' ||
--            'order by lep.le_cd ) ' ||
'SELECT  '                      || 
    '0,  '                      || 
    'sSourceTypeCd,'            ||
    'hCorrelationId /*correlation_id*/, '                                ||
    'dEffDate /*--accounting_dt*/, '                                     ||
    'pl.pl_global_id,  '   ||
    'sJournalType, '                                    ||
    'sJrnlSource,  '                                      ||
    'fc.fc_account , '                           ||
    'fc.fc_segment_2  /*basis_cd*/, '                                     ||
    'fc.fc_segment_1  /*ledger*/, '                                       ||
    'decode(fc.fc_segment_8,''NVS'',null,-1,null,fc.fc_segment_8)  /*policy*/,'  || 
    'decode(ec.ec_attribute_1,''NVS'',null,ec.ec_attribute_1)  /*stream_id*/ ,' || 
    'pl_aff.pl_global_id /*fc.fc_segment_4, --affiliate_le_id*/ , '           ||
    'null /*counterparty_le_id, JL_REFERENCE_7*/, '                       ||
    'decode(fc_segment_3,''NVS'',null,fc_segment_3) /*dept_cd*/ , '        ||
    'null /*--business_event_typ,JL_REFERENCE_5*/, '                        ||
    'sJournalLineDesc,   '                          ||
    'null /*--journal_descr, JL_REFERENCE_1*/, '                            ||
    'sChartfield,  '                                     ||
    'null /*accident_yr,JL_REFERENCE_6*/, '                               ||
    'null /*underwriting_yr,JL_REFERENCE_3 */,'                           ||
    'decode(ec_attribute_2,''NVS'',null,ec_attribute_2) /*tax_jurisdiction_cd*/, '                           ||
    'null /*--event_seq_id*/ , '                                            ||
    'decode(fc_segment_7,''NVS'',null, fc_segment_7) /*business_typ*/, '     ||
    'decode(ec_attribute_3,''NVS'',null,ec_attribute_3) /*--premium_typ*/ , ' ||
    'null  /* owner_le_id,JL_REFERENCE_4*/ ,  '                            ||
    'null /*ultimate_parent_le_id,JL_REFERENCE_2*/ , '                     ||
    'ec_attribute_4 /*event_typ*/ , '                                     ||
    'fc.fc_ccy /*transaction_ccy*/, '                                    ||
    'b.eab_tran_ltd_balance /*--transaction_amt*/, '                       ||
    'decode(fc.fc_segment_1,''EURGAAPADJ'',''EUR'',''UKGAAP_ADJ'',''GBP'',''USD'') /*functional_ccy*/, '                                     ||
    'b.eab_local_ltd_balance /*functional_amt*/, '                       ||
    'decode(fc.fc_segment_1,''EURGAAPADJ'',''EUR'',''UKGAAP_ADJ'',''GBP'',''USD'')  /*reporting_ccy*/, '                                      ||
    'b.eab_base_ltd_balance /*reporting_amt*/, '                         ||
    'fc_segment_6 /*execution_typ*/ , '                                   ||
    '2 /*lpg_id*/, '                                                     ||
    '''U'' /*event_status*/, '                                           ||
    'hFeedUUID, '                                                        ||
    '0 /*no_retries*/, '                                                 ||
    '0 /*step_run_sid*/, '                                               ||
    'sScenerio /*scenerio*/, '                                          ||
    'ec.ec_eba_id '                                                     ||
'from '                                                                 ||
    'slr.slr_eba_combinations ec ' ||
    'join slr.slr_fak_combinations fc ON ec.ec_fak_id = fc.fc_fak_id '                                     ||  
    'join stn.merger_balances b on b.eab_eba_id = ec.ec_eba_id '                                           || 
    
    'join fdr.fr_gl_account gla on gla.ga_account_code = fc.fc_account '                                   ||
    'join fdr.fr_party_legal pl on fc.fc_entity = pl.pl_party_legal_id  '                                  ||
    'right outer join fdr.fr_party_legal pl_aff on fc.fc_segment_4 = pl_aff.pl_party_legal_id '            ||
'where ' || 
    '(abs(b.eab_tran_ltd_balance) + abs( b.eab_base_ltd_balance) + abs(b.eab_local_ltd_balance)) <> 0 and  '            || 
    --'ip.policy_version = (select max(p2.policy_version) from rdr.rrv_ag_insurance_policy p2 where ip.stream_id = p2.stream_id) and '||
    'fc.fc_account in (''22400000-01'', ''31460150-01'') and ' ||
    'fc.fc_account <> ''13600100-01'' and ' ||
    'eab_balance_type = 50 and  ' ||
    'fc_segment_4 not in (''FSAIC'',''FSABM'',''MACRP'') and  ' ||
    'fc_entity not in (''FSAIC'',''FSABM'',''MACRP'') and  ' ||
    'b.eab_eba_id NOT in (select eba_id from stn.temp_stn_journal_line) ';
sOrder := 
    'order by '         ||
--    'ip.stream_id,'     ||
--    'ip.le_cd, '        ||
    'fc_segment_4,'     ||
    'fc.fc_entity, '    ||
    'fc_segment_7 ';    

--temp filter on specific stream
--sWhere := sWhere || ' AND ec_attribute_1 = ''20363801'' ';
--dbms_output.put_line (' pbuild sql  where '||sWhere);


sSQL:= sTop ||sWhere||sOrder;
sSql := replace(sSql,'hFeedUUID',''''||lhfeedUUID||'''');
sSql := replace(sSql,'sChartfield',''''||sChartfield||'''');
sSql := replace(sSql,'sJournalLineDesc',''''||sJournalLineDesc||'''');
sSql := replace(sSql,'sJrnlSource',''''||sJrnlSource||'''');
sSql := replace(sSql,'sJournalType',''''||sJournalType||'''');
sSql := replace(sSql,'dEffDate',''||dEffDate||'');
sSql := replace(sSql,'hCorrelationId',''''||lhCorrelationId||'''');
sSql := replace(sSql,'sSourceTypeCd',''''||sSourceTypeCd||'''');
sSql := replace(sSql,'sScenerio',''''||anScenerio||'''');


dbms_output.put_line('fBuildSqlNoStream '||sSQL);
return sSql;


exception
    when others then
        raise_application_error(-20120,'pBuildSqlNoStream '||sqlerrm);


END; --pBuildql


PROCEDURE pUpdateRefData IS

-- use the most recent JL in slr_jrnl_lines to get the reference data used for an eba 

Begin
update stn.temp_stn_journal_line u
set 
    (journal_descr,
    ultimate_parent_le_id,
    underwriting_yr,
    owner_le_id,
    business_event_Typ,
    accident_yr, 
    counterparty_le_id) = (
select
    jl_reference_1 ,
    jl_reference_2 ,
    jl_reference_3 ,
    jl_reference_4 ,
    jl_reference_5 ,
    jl_reference_6 ,
    jl_reference_7
    FROM
(WITH JL as
(select
    jl_eba_id, 
    jl_source_jrnl_id,
    jl_reference_1 ,
    jl_reference_2 ,
    jl_reference_3 ,
    jl_reference_4 ,
    jl_reference_5 ,
    jl_reference_6 ,
    jl_reference_7 
FROM
    (select 
        jl_eba_id, 
        jl_source_jrnl_id,
        jl_reference_1 ,
        jl_reference_2 ,
        jl_reference_3 ,
        jl_reference_4 ,
        jl_reference_5 ,
        jl_reference_6 ,
        jl_reference_7 ,
        row_number ()
        over (partition by jl_eba_id  order by jl_source_jrnl_id desc)   rn
    FROM
        (select 
            jl_eba_id,
            jl_source_jrnl_id,
            substr(jl_reference_1,1,50) jl_reference_1 ,
            to_char(pl2.pl_global_id) jl_reference_2,
            decode(jl_reference_3,'NVS',null,jl_reference_3) jl_reference_3 ,
            to_char(pl4.pl_global_id) jl_reference_4 ,
            decode(to_char(jl_reference_5),'NVL',null,to_char(jl_reference_5)) jl_reference_5,
            decode(jl_reference_6,'NVS',null, jl_reference_6) jl_reference_6 ,
            to_char(pl7.pl_global_id) jl_reference_7
        from 
            slr.slr_jrnl_lines jl1,
            fdr.fr_party_legal pl2,
            fdr.fr_party_legal pl4,
            fdr.fr_party_legal pl7
        where 
            jl1.jl_reference_2 = pl2.pl_party_legal_id and 
            jl1.jl_reference_4 = pl4.pl_party_legal_id and
            jl1.jl_reference_7 = pl7.pl_party_legal_id 
            ))
    where rn = 1)      
select 
        jl_reference_1 ,
        jl_reference_2 ,
        jl_reference_3 ,
        jl_reference_4 ,
        jl_reference_5 ,
        jl_reference_6 ,
        jl_reference_7 
from JL
where
    u.eba_id = JL.jl_eba_id));
           
            
exception
    when others then
        raise_application_error(-20115, 'updateRefData '||sqlerrm);

END;  --pUpdateRefData

procedure pCreateJL(anScenerio number, asBaseEntryType varchar, asThisEntryType varchar, asSign varchar, asAcct varchar, asEntity varchar, asAffiliate varchar) IS

nSign number;
sAcct varchar(11);
sEntity varchar(3);
sAffiliate varchar(3);

BEGIN

IF asSign = 'CHANGE' THEN
    nSign := -1;
ELSIF asSign = 'RTS' THEN
    nSign := 1;
ELSE
    raise_application_error(-20104,'Unexpected asSign = '||asSign);
END IF;    


IF asAcct = 'CHANGE' THEN 
    IF anScenerio = 2 THEN
        sAcct := sClearingAcct;
    ELSE 
        sAcct := sOOBAcct;
    END IF;
ELSIF asAcct = 'RTS' THEN
    sAcct := null;
ELSE
    raise_application_error(-20106,'Unexpected asAcct = '||asAcct);
END IF;            

IF asEntity = 'CHANGE' THEN
    sEntity := '171'; -- agcrp
ELSIF asEntity = 'RTS' THEN
    sEntity := null;
ELSIF asEntity = 'CA002' THEN
    sEntity := 193;
ELSE
    raise_application_error(-20106,'Unexpected asEntity = '||asEntity);
END IF;        


--select pl_global_id into sEntity from fdr.fr_party_legal where pl_party_legal_id = asEntity;

IF asAffiliate = 'CHANGE' THEN
    sAffiliate := '171';
ELSIF asAffiliate = 'RTS' THEN
    sAffiliate := null;
ELSE
    raise_application_error(-20106,'Unexpected asAffiliate = '||asAffiliate);
END IF;    
         

INSERT INTO stn.temp_stn_journal_line (
    row_sid,
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
    step_run_sid,
    scenerio,
    balance_type,
    entry_type,
    eba_id) 
SELECT 
    row_sid,
    source_typ_cd,
    correlation_id,
    accounting_dt,
    nvl(sEntity,le_id), -- le_id,
    journal_type,
    jrnl_source, 
    nvl(sAcct, acct_cd), --acct_cd, 
    basis_cd, 
    ledger_cd, 
    policy_id, 
    stream_id, 
    nvl(sAffiliate,affiliate_le_id), --affiliate_le_id,
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
    transaction_amt * nSign,
    functional_ccy, 
    functional_amt * nSign,
    reporting_ccy,
    reporting_amt * nSign,
    execution_typ,
    lpg_id,
    event_status,
    feed_uuid,
    no_retries,
    step_run_sid,
    anScenerio,
    balance_type,
    asThisEntryType,
    eba_id
from
    stn.temp_stn_journal_line
where
    entry_type = asBaseEntryType;

       
exception
    when others then
        raise_application_error(-20103,'pCreateJL '||sqlerrm);

END; --pCreateJLs

PROCEDURE pCreateEntries IS

BEGIN

-- direct
pCreateJL(1,'1A','1B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(1,'1A','1C','CHANGE','RTS','CHANGE','RTS');
pCreateJL(1,'1A','1D','RTS','CHANGE','CHANGE','RTS');

-- interco FSANY>AGCRP
pCreateJL(2,'2A','2B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(2,'3A','3B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(2,'4A','4B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(2,'5A','5B','CHANGE','CHANGE','RTS','RTS');

-- Foreign subs
pCreateJL(3,'10A','10B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(3,'10A','10C','CHANGE','RTS','RTS','CHANGE');
pCreateJL(3,'10A','10D','RTS','CHANGE','RTS','CHANGE');

pCreateJL(3,'11A','11B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(3,'11A','11C','CHANGE','RTS','CHANGE','RTS');
pCreateJL(3,'11A','11D','RTS','CHANGE','CHANGE','RTS');


-- AGREL

pCreateJL(4,'6A','6B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(4,'6A','6C','CHANGE','RTS','CHANGE','RTS');
pCreateJL(4,'6A','6D','RTS','CHANGE','CHANGE','RTS');


pCreateJL(4,'7A','7D','RTS','CHANGE','RTS','CHANGE');
pCreateJL(4,'7A','7B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(4,'7A','7C','CHANGE','RTS','RTS','CHANGE');


--ceded external
pCreateJL(5,'18A','18B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(5,'18A','18C','CHANGE','RTS','CHANGE','RTS');
pCreateJL(5,'18A','18D','RTS','CHANGE','CHANGE','RTS');

-- close elim companies

pCreateJL(6,'19A','19B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(6,'19A','19C','CHANGE','RTS','CA002','RTS');
pCreateJL(6,'19A','19D','RTS','CHANGE','CA002','RTS');

-- putting balance into a consol company.  they don't book to affiliates.
update stn.temp_stn_journal_line
set affiliate_le_id = null
where scenerio = 6 and entry_type in ('19C','19D');


pCreateJL(7,'20A','20B','CHANGE','CHANGE','RTS','RTS');


--Assumed prem rec affil manual without stream
pCreateJL(8,'21A','21B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(8,'21A','21C','CHANGE','RTS','CHANGE','RTS');
pCreateJL(8,'21A','21D','RTS','CHANGE','CHANGE','RTS');

-- don't think I have to change the affilate
--pCreateJL(8,'22A','22B','CHANGE','CHANGE','RTS','RTS');
--pCreateJL(8,'22A','22C','CHANGE','RTS','RTS','CHANGE');
--pCreateJL(8,'22A','22D','RTS','CHANGE','RTS','CHANGE');




-- insurance suspense,and others 
pCreateJL(9,'23A','23B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(9,'23A','23C','CHANGE','RTS','CHANGE','RTS');
pCreateJL(9,'23A','23D','RTS','CHANGE','CHANGE','RTS');


--10 affiliate - check these 
pCreateJL(10,'24A','24B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(10,'24A','24C','CHANGE','RTS','RTS','CHANGE');
pCreateJL(10,'24A','24D','RTS','CHANGE','RTS','CHANGE');



-- 11 AGREL assumed PGAAP from FSAUK.  Gets booked into FSANY
pCreateJL(11,'25A','25B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(11,'25A','25C','CHANGE','RTS','CHANGE','RTS');
pCreateJL(11,'25A','25D','RTS','CHANGE','CHANGE','RTS');


pCreateJL(11,'26A','26B','CHANGE','CHANGE','RTS','RTS');
pCreateJL(11,'26A','26C','CHANGE','RTS','RTS','CHANGE');
pCreateJL(11,'26A','26D','RTS','CHANGE','RTS','CHANGE');



commit;

exception
    when others then
        raise_application_error(-20105,'pCreateEntries '||sqlerrm);



END; -- pCreateEntries

PROCEDURE pGetBalances IS

sWhere varchar(5000);
sSql varchar(5000);
nScenerio number;



BEGIN


-- direct 
nScenerio := 1;
    sWhere := ' and  map.le_cd = ''FSANY'' and map_parent.le_cd is null and fc.fc_entity = ''FSANY'' ';-- do not move MACRP, manual to FSAUK and manual to EF030.  filter on fc entity will do this
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;

update stn.temp_stn_journal_line set balance_type = '1', entry_type = '1A' where scenerio = 1;

commit;


-- interco FSANY > AGCRP
nScenerio := 2;
sWhere := ' AND (map_parent.le_cd = ''FSANY'' and  map.le_cd = ''AGCRP'' and fc.fc_entity <> ''CA005'' and fc.fc_entity <> ''CA003'' )'; 
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '2', entry_type = '2A' where scenerio = 2 and business_Typ in ('CA','C') and le_id = 256;
update stn.temp_stn_journal_line set balance_type = '3', entry_type = '3A' where scenerio = 2 and business_Typ = 'AA' and le_id = 171;
update stn.temp_stn_journal_line set balance_type = '4', entry_type = '4A' where scenerio = 2 and business_Typ = 'AA' and le_id = 209;
update stn.temp_stn_journal_line set balance_type = '5', entry_type = '5A' where scenerio = 2 and business_Typ = 'CA' and le_id = 209;

commit;



-- foreign subs
nScenerio := 3;
sWhere := ' AND (map_parent.le_cd in (''FSAUK'',''AGFRA'')  and  map.le_cd = ''FSANY'' and fc.fc_entity <> ''EF030'' and fc.fc_entity <> ''CA003'' and fc.fc_entity <> ''CA005'' )'; 
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '10', entry_type = '10A' where scenerio = 3 and business_Typ in ('CA', 'C') and le_id IN (289, 258);
update stn.temp_stn_journal_line set balance_type = '11', entry_type = '11A' where scenerio = 3 and business_Typ in ('AA','A') and le_id = 256;

commit;


-- AGREL
nScenerio := 4;
sWhere := ' AND map.le_cd = ''AGREL'' and map_parent.le_cd = ''FSANY''  and fc.fc_entity <> ''CA003'' and fc.fc_entity <> ''CA005'' and fc.fc_entity <> ''EA030'' and fc.fc_entity <> ''CARA1'' '; 
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '6', entry_type = '6A' where scenerio = 4 and business_Typ in ('CA', 'C') and le_id = 256;
update stn.temp_stn_journal_line set balance_type = '7', entry_type = '7A' where scenerio = 4 and business_Typ = 'AA' and le_id = 182;

commit;


-- Ceded External
nScenerio := 5;
sWhere := ' AND map_parent.le_cd = ''FSANY'' and map.le_cd is null and fc.fc_entity <>''CA005'' and fc.fc_entity <> ''CA003'' and fc.fc_entity <> ''EM020'' and fc_entity <> ''CARA1''  and fc.fc_entity <> ''MACRP'' and fc.fc_entity <> ''FSAIC'' and fc.fc_entity <> ''FSABM''';  
sWhere := sWhere || ' and fc.fc_segment_4 not in (''MACRP'',''FSABM'',''FSAIC'')';
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '18', entry_type = '18A' where scenerio = 5;
commit;


-- Close companies into CA002
nScenerio := 6;
sWhere :=           ' AND fc.fc_entity in (''CA005'' , ''EF030'',''EM020'',''CARA1'')';
sWhere := sWhere || ' AND NOT (fc_entity = ''CARA1'' and map_parent.le_cd = ''FSANY'' and  map.le_cd = ''AGCRP'')';
sWhere := sWhere || ' AND NOT (fc_entity = ''EM020'' and  fc.fc_segment_4 in (''FSABM'',''FSAIC''))';
--sWhere := ' AND fc.fc_entity in (''CARA1'')';
dbms_output.put_line(swhere);
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '19', entry_type = '19A' where scenerio = 6;
commit;


-- FSAUK to AGCRP PGAAP that gets booked to FSANY.  AGREL handled in a later scerario
nScenerio := 7;
sWhere := ' AND map.le_cd in (''AGCRP'') and map_parent.le_cd in (''FSAUK'') and  fc_account like ''%-02'' and fc_segment_7 = ''CA'' and fc.fc_entity in (''FSANY'', ''CARA1'')';   
dbms_output.put_line(swhere);
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '20', entry_type = '20A' where scenerio = 7;
commit;

--13300210 assumed prem rec affil  no streams



-- move affiliate on AGRT transfer FSAU to FSAUK
nScenerio := 10;
sWhere := ' and  fc_segment_4 = ''FSANY'' and   substr(fc_account,1,8) = 21400450 and fc_segment_7 = ''AA'' ' ; 
sWhere := sWhere || ' and   ec.ec_attribute_1 in (select distinct jl_attribute_1 from slr.slr_jrnl_lines where jl_segment_7 = ''AA'' and  jl_reference_7  in (''FSAU'',''AGFR'')   and jl_entity = ''AGCRP'' and jl_segment_4 = ''FSANY'' and jl_effective_date < ''31-JUL-2024'' and substr(jl_account,1,8) = 21400450) '; 
dbms_output.put_line(swhere);
sSQL := fBuildSqlNoStream(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '24', entry_type = '24A' where scenerio = 10;
commit;

-- FSAUK to AGREL PGAAP that gets booked to FSANY.  AGREL handled in a later scerario
nScenerio := 11;
sWhere := ' AND map.le_cd in (''AGREL'') and map_parent.le_cd in (''FSAUK'') and  fc_account like ''%-02'' and fc_segment_7 in (''CA'',''AA'') and fc.fc_entity in (''FSANY'', ''AGREL'')';   
dbms_output.put_line(swhere);
sSQL := fBuildSql(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '25', entry_type = '25A' where scenerio = 11 and business_typ = 'CA';
update stn.temp_stn_journal_line set balance_type = '26', entry_type = '26A' where scenerio = 11 and business_typ = 'AA';
commit;

nScenerio := 8;
sWhere := ' AND  fc_entity = ''FSANY'' and  substr(fc_account,1,8) in (22400000, 31460150)'; 
   
dbms_output.put_line(swhere);
sSQL := fBuildSqlNoStream(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '21', entry_type = '21A' where scenerio = 8;
commit;


-- insurance suspense, ceded fvunearned premium, direct UPR
nScenerio := 9;
sWhere := ' AND  fc_entity = ''FSANY'' and  substr(fc_account,1,8) in (13600100,13800200,21300200, 15600270, 15600230, 26000200, 26000250, 13800210, 13800215, 21300300, 22300110,22300100, 18250220, 28700315, 18900230, 28400200, 18900629, 18900628, 18900200,15600210, 26800997, 15300110, 26500200, 13200100, 28700330, 15700100, 15700150,28350260)'; 
dbms_output.put_line(swhere);
sSQL := fBuildSqlNoStream(sWhere,nScenerio);
execute immediate sSQL;
update stn.temp_stn_journal_line set balance_type = '23', entry_type = '23A' where scenerio = 9;
commit;



DBMS_STATS.GATHER_TABLE_STATS ('STN','TEMP_STN_JOURNAL_LINE');

commit;

exception
    when others then
        raise_application_error(-20107,'pGetBalances '||sqlerrm);

END; --pGetBalances

procedure pFixBusType IS

begin

update stn.temp_stn_journal_line
set event_typ = 'WRITTEN_PREM_NOMINAL' 
where event_typ = 'WRITTEN_PREMIUM_NOMINAL';

update stn.temp_stn_journal_line
set dept_cd = null
where
    dept_cd = 0 and
    entry_type in ('10C', '10D');


update stn.temp_stn_journal_line
set policy_id =  substr(policy_id,1,5)||'-'||substr(policy_id,6,2)  
where
entry_type in ('18C','18D') and 
 policy_id in (
'32012E1',
'32012A1',
'32012D1',
'32847C1',
'32847C2',
'32847C3',
'32847C4',
'32847C5',
'32847C6',
'33584A1');


commit;

exception
    when others then
        raise_application_error(-20112,'pFixBusType '||sqlerrm);



END;
procedure pRunProcess IS

begin

pResetTempJL;
pInitialize;
pGetBalances;   
pUpdateRefData;
pUpdateSignOnBase;
pCreateEntries;
pFixAffiliate;
pFixBusType;


update fdr.fr_general_codes
set gc_active = 'A'
where gc_client_code = '14400330';
commit;



exception
    when others then
        rollback;
        raise_application_error(-20101,'pRunProcess '||sqlerrm);

END; -- pRunProcess

END ; --package
/