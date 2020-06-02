create table stn.cev_premium_typ_override
(
   correlation_uuid      raw ( 16 )
,  event_typ_id          number
,  premium_typ_override  varchar2 ( 1 char )
)
;

  GRANT UPDATE ON "STN"."CEV_PREMIUM_TYP_OVERRIDE" TO "AUTOMATED_UNIT_TEST";
  GRANT SELECT ON "STN"."CEV_PREMIUM_TYP_OVERRIDE" TO "AUTOMATED_UNIT_TEST";
  GRANT INSERT ON "STN"."CEV_PREMIUM_TYP_OVERRIDE" TO "AUTOMATED_UNIT_TEST";
  GRANT DELETE ON "STN"."CEV_PREMIUM_TYP_OVERRIDE" TO "AUTOMATED_UNIT_TEST";
  GRANT ALTER ON "STN"."CEV_PREMIUM_TYP_OVERRIDE" TO "AUTOMATED_UNIT_TEST";
  GRANT SELECT ON "STN"."CEV_PREMIUM_TYP_OVERRIDE" TO "AAH_READ_ONLY";