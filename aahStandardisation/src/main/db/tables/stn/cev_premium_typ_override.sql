create table stn.cev_premium_typ_override
(
   correlation_uuid      raw ( 16 )
,  event_typ_id          number
,  premium_typ_override  varchar2 ( 1 char )
)
;

  GRANT SELECT ON "STN"."CEV_PREMIUM_TYP_OVERRIDE" TO "AAH_READ_ONLY";