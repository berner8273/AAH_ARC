create or replace TRIGGER "FDR"."FRTR_SR_GENERIC_OBJECT_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_GENERIC_OBJECT
    REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig(v_eventid);
   SELECT SQFR_STAN_RAW_GENERIC_OBJECT.NEXTVAL
      INTO :NEW.SRGO_RAW_OBJECT_ID
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRGO_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_SR_INSURANCE_POLICY_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_INSURANCE_POLICY   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT SQFR_STAN_RAW_INSURANCE_POLICY.NEXTVAL
      INTO :NEW.SRIN_RAW_INSURE_POLICY_ID
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRIN_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STANRAW_CASHCPNEVENT_SEQ"
  BEFORE INSERT
  on fr_stan_raw_cash_cpn_event
  REFERENCING OLD AS OLD NEW AS NEW
  for each row
/* FDR Standard Sequence Trigger AH 8/2/2001  Fri Aug 17 12:47:24 2007 */
/* default body for frtr_stan_raw_cash_flow_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
    pr_seq_trig (v_eventid);
   SELECT sqfr_stan_raw_cash_cpn_event.nextval
      INTO :new.src_raw_cash_flow_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRC_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_ACC_EVENT_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_ACC_EVENT   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
    Pr_Seq_Trig (v_eventid);
   SELECT SQFR_STAN_RAW_ACC_EVENT.nextval
      INTO :new.SRAE_RAW_ACC_EVENT_ID
      FROM DUAL;
    SELECT v_eventid
      INTO :NEW.SRAE_ACC_EVENT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_ADJUSTMENT_SEQ"
BEFORE INSERT
ON FR_STAN_RAW_ADJUSTMENT REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_adjustment.NEXTVAL
      INTO :NEW.sra_raw_adjustment_id
      FROM DUAL;

END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_GENERIC_STTL_SEQ"
  BEFORE INSERT
  on FR_STAN_RAW_GENERIC_SETTLE
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW

DECLARE
        v_eventid       varchar2(38);
BEGIN
   SELECT sqfr_stan_raw_generic_settle.nextval
      INTO :new.srgs_raw_generic_settle_id
      FROM DUAL;

   pr_seq_trig (v_eventid);
   SELECT v_eventid
      INTO :new.srgs_event_audit_id
      FROM DUAL;

END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_POSITION_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_POSITION   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 14:19:20 2003 */
/* default body for frtr_stan_raw_position_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_position.NEXTVAL
      INTO :NEW.srp_raw_position_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRP_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_PREMCLAIM_SEQ"
  BEFORE INSERT
  on FR_STAN_RAW_PREMIUM_CLAIM
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW

DECLARE
        v_eventid       varchar2(38);
BEGIN
   SELECT sqfr_stan_raw_premium_claim.nextval
      INTO :new.srpc_raw_premclaim_id
      FROM DUAL;

   pr_seq_trig (v_eventid);
   SELECT v_eventid
      INTO :new.srpc_event_audit_id
      FROM DUAL;

END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_SET_DETAIL_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_SETTLE_DETAIL   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 14:19:20 2003 */
/* default body for frtr_stan_raw_set_detail_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_settle_detail.NEXTVAL
      INTO :NEW.srs_raw_settle_detail_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRS_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_TRADE_NFFX_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_TRADE_NF_FX   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 14:19:20 2003 */
/* default body for frtr_stan_raw_trade_nffx_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_trade_nf_fx.NEXTVAL
      INTO :NEW.srtn_raw_trade_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRTN_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_TRADE_NFLD_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_TRADE_NF_LD   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 13:20:47 2003 */
/* default body for frtr_stan_raw_trade_nfld_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_trade_nf_ld.NEXTVAL
      INTO :NEW.srtn_raw_trade_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRTN_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_TRADE_NFOP_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_TRADE_NF_OPTION   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 14:19:20 2003 */
/* default body for FRTR_STAN_RAW_TRADE_NFOP_SEQ */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_trade_nf_option.NEXTVAL
      INTO :NEW.srtn_raw_trade_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRTN_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_TRADE_NFRE_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_TRADE_NF_REPO   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 14:19:20 2003 */
/* default body for frtr_stan_raw_trade_nfre_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_trade_nf_repo.NEXTVAL
      INTO :NEW.srtn_raw_trade_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRTN_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_TRD_FUNG_BD_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_TRADE_FUNG_BOND   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 14:19:20 2003 */
/* default body for frtr_stan_raw_trd_fung_bd_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_trade_fung_bond.NEXTVAL
      INTO :NEW.srtf_raw_trade_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRTF_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_TRD_FUNG_ET_SEQ"
  BEFORE INSERT
  ON FR_STAN_RAW_TRADE_FUNG_ETFO   REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
/* FDR Standard Sequence Trigger AH 8/2/2001  Wed May 07 14:19:20 2003 */
/* default body for frtr_stan_raw_trd_fung_et_seq */
DECLARE
        v_eventid       VARCHAR2(38);
BEGIN
        Pr_Seq_Trig (v_eventid);
   SELECT sqfr_stan_raw_trade_fung_etfo.NEXTVAL
      INTO :NEW.srtf_raw_trade_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRTF_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
create or replace TRIGGER "FDR"."FRTR_STAN_RAW_VAL_SEQ"
  BEFORE INSERT
  on fr_stan_raw_valuation
  REFERENCING OLD AS OLD NEW AS NEW
  for each row
/* FDR Standard Sequence Trigger AH 8/2/2001  Thu Jun 05 14:44:52 2003 */
/* default body for frtr_stan_raw_val_seq */
DECLARE
        v_eventid       varchar2(38);
BEGIN
        pr_seq_trig (v_eventid);
   SELECT sqfr_stan_raw_valuation.nextval
      INTO :new.srv_raw_valuation_id
      FROM DUAL;
   SELECT v_eventid
      INTO :NEW.SRV_AE_EVENT_AUDIT_ID
      FROM DUAL;
END;
/
alter sequence FDR.event_aud_id_seq MAXVALUE 9999999999999999999999999999;