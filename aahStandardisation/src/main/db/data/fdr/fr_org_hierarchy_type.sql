INSERT INTO fdr.fr_org_hierarchy_type ("OHT_ORG_HIER_TYPE_ID","OHT_ORG_HIER_TYPE_NAME","OHT_ORG_HIER_CLIENT_CODE","OHT_ORG_HIER_CLASS","OHT_ACTIVE","OHT_INPUT_BY","OHT_AUTH_BY","OHT_AUTH_STATUS","OHT_VALID_FROM","OHT_VALID_TO","OHT_DELETE_TIME")
  VALUES (2,'STAT_REPORTING','STAT_REPORTING',NULL,'A','FDR Create','1','A',TO_DATE('2001/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS'),NULL);
INSERT INTO fdr.fr_org_hierarchy_type ("OHT_ORG_HIER_TYPE_ID","OHT_ORG_HIER_TYPE_NAME","OHT_ORG_HIER_CLIENT_CODE","OHT_ORG_HIER_CLASS","OHT_ACTIVE","OHT_INPUT_BY","OHT_AUTH_BY","OHT_AUTH_STATUS","OHT_VALID_FROM","OHT_VALID_TO","OHT_DELETE_TIME")
  VALUES (3,'GAAP_REPORTING','GAAP_REPORTING',NULL,'A','FDR Create','1','A',TO_DATE('2001/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS'),NULL);
INSERT INTO fdr.fr_org_hierarchy_type ("OHT_ORG_HIER_TYPE_ID","OHT_ORG_HIER_TYPE_NAME","OHT_ORG_HIER_CLIENT_CODE","OHT_ORG_HIER_CLASS","OHT_ACTIVE","OHT_INPUT_BY","OHT_AUTH_BY","OHT_AUTH_STATUS","OHT_VALID_FROM","OHT_VALID_TO","OHT_DELETE_TIME")
  VALUES (4,'STAT_CONSOLIDATION','STAT_CONSOLIDATION',NULL,'A','FDR Create','1','A',TO_DATE('2001/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS'),NULL);
INSERT INTO fdr.fr_org_hierarchy_type ("OHT_ORG_HIER_TYPE_ID","OHT_ORG_HIER_TYPE_NAME","OHT_ORG_HIER_CLIENT_CODE","OHT_ORG_HIER_CLASS","OHT_ACTIVE","OHT_INPUT_BY","OHT_AUTH_BY","OHT_AUTH_STATUS","OHT_VALID_FROM","OHT_VALID_TO","OHT_DELETE_TIME")
  VALUES (5,'GAAP_CONSOLIDATION','GAAP_CONSOLIDATION',NULL,'A','FDR Create','1','A',TO_DATE('2001/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS'),NULL);
INSERT INTO fdr.fr_org_hierarchy_type ("OHT_ORG_HIER_TYPE_ID","OHT_ORG_HIER_TYPE_NAME","OHT_ORG_HIER_CLIENT_CODE","OHT_ORG_HIER_CLASS","OHT_ACTIVE","OHT_INPUT_BY","OHT_AUTH_BY","OHT_AUTH_STATUS","OHT_VALID_FROM","OHT_VALID_TO","OHT_DELETE_TIME")
  VALUES (6,'SLR_LINK','SLR_LINK',NULL,'A','FDR Create','1','A',TO_DATE('2001/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS'),NULL);
commit;