CREATE OR REPLACE VIEW "RDR"."RRV_AG_EVENT_CLASS_STATUS" AS (
SELECT
lk_match_key1 AS event_class
, lk_match_key4 AS business_period
, lk_lookup_value1 AS status_flag
, lk_lookup_value5 AS pending_glint_flag
, lk_lookup_value6 AS glint_date
FROM fdr.fr_general_lookup
WHERE lk_lkt_lookup_type_code =
'EVENT_CLASS_PERIOD'
);
COMMENT ON COLUMN "RDR"."RRV_AG_EVENT_CLASS_STATUS" ."BUSINESS_PERIOD" IS 'Date Format is "YYYY-MM"';
COMMENT ON COLUMN "RDR"."RRV_AG_EVENT_CLASS_STATUS" ."STATUS_FLAG" IS '"O"pen or "C"losed Flag';
COMMENT ON COLUMN "RDR"."RRV_AG_EVENT_CLASS_STATUS" ."PENDING_GLINT_FLAG" IS '"Y" = Authorized and Pending GLINT run';
COMMENT ON COLUMN "RDR"."RRV_AG_EVENT_CLASS_STATUS" ."GLINT_DATE" IS 'Date GLINT was run and by which user';