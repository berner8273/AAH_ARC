CREATE OR REPLACE PACKAGE FDR."FDR_CUSTOM_ARCHIVING_PKG" AS
---------------------------------------------------------------------------------
-- Id:          $Id: FDR_CUSTOM_ARCHIVING_PKG.sql,v 1 2012/05/22 16:03:51 abulgajewska Exp $
--
-- Description: Package contains custom procedures which can be used during automatic archiving process.
-- Set the name of procedure in archive cntrl table ( in fields before or after archive procedure)
-- to execute chosen procedure during automatic archiving process
---------------------------------------------------------------------------------
-- History:
-- 2012/06/18: basic version of package created
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Types
---------------------------------------------------------------------------------
TYPE CNTRL_TABLE_ARRAY IS TABLE OF FR_ARCHIVE_CTL%ROWTYPE;

---------------------------------------------------------------------------------
-- PROCEDURES
---------------------------------------------------------------------------------

PROCEDURE pCUST_RollFAKBalancesToME        (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            );

PROCEDURE pRollFAKBalancesToME              (         pEntity                   SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                                                      pArchRecCounter           out INTEGER
                                            );

PROCEDURE pRollFAKBalancesToME              (         pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pYear                     in SLR_ENTITY_PERIODS.ep_bus_year%type,
                                                      pPeriod                   in SLR_ENTITY_PERIODS.ep_bus_period%type,
                                                      pArchRecCounter           out INTEGER
                                                );

PROCEDURE pCUST_RollEBABalancesToME        (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            );

PROCEDURE pRollEBABalancesToME              (         pEntity                   SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type,
                                                      pArchRecCounter           out INTEGER
                                                );

PROCEDURE pRollEBABalancesToME              (         pEntity                   SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pYear                     SLR_ENTITY_PERIODS.ep_bus_year%type,
                                                      pPeriod                   SLR_ENTITY_PERIODS.ep_bus_period%type,
                                                      pArchRecCounter           out INTEGER
                                                );

PROCEDURE pCUST_RollFAKBlncsAcrossPrds     (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            );

PROCEDURE pRollFAKBalances_AP               ( pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                               pBatchSize                in INTEGER DEFAULT NULL,
                                               pDate                     in FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                                               pYear                     in SLR_ENTITY_PERIODS.ep_bus_year%type DEFAULT NULL,
                                               pPeriod                   in SLR_ENTITY_PERIODS.ep_bus_period%type DEFAULT NULL,
                                               pArchRecCounter           out INTEGER
                                              );

PROCEDURE pRollEBABalances_AP               (  pEntity                   SLR_ENTITIES.ENT_ENTITY%type,
                                               pBatchSize                in INTEGER DEFAULT NULL,
                                               pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                                               pYear                     SLR_ENTITY_PERIODS.ep_bus_year%type DEFAULT NULL,
                                               pPeriod                   SLR_ENTITY_PERIODS.ep_bus_period%type DEFAULT NULL,
                                               pArchRecCounter           out INTEGER
                                              );

PROCEDURE pCUST_RollEBABlncsAcrossPrds     (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            );

PROCEDURE pCUST_ArchiveEBABalances_After    (         pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE DEFAULT NULL,
                                                      pArchRecCounter           out INTEGER
                                            );


PROCEDURE pCUST_ArchiveFAKBalances_After    (         pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE DEFAULT NULL,
                                                      pArchRecCounter           out INTEGER
                                            );


PROCEDURE pArchiveEBABalances_After   (         pEpgId                    SLR_ENTITY_PROC_GROUP.EPG_ID%type,
                                                pBatchSize                in INTEGER DEFAULT NULL,
                                                pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                                                pArchRecCounter           out INTEGER
                                       );


PROCEDURE pArchiveFAKBalances_After   (         pEpgId                    SLR_ENTITY_PROC_GROUP.EPG_ID%type,
                                                pBatchSize                in INTEGER DEFAULT NULL,
                                                pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                                                pArchRecCounter           out INTEGER
                                       );

PROCEDURE pCUST_ArchiveHopper_Before (            pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                      );

PROCEDURE pLoadArchCntrList              (        pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  cnrl_tbl_list             out CNTRL_TABLE_ARRAY
                                         );

PROCEDURE pCUST_ArchiveBeforeProcess (            pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                      );

PROCEDURE pCUST_ArchiveAfterProcess     (         pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                        );

PROCEDURE PGRANT_PRIVILIGES;

PROCEDURE pRollFAKBalancesToME_full              (    pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     in FR_GLOBAL_PARAMETER.gp_todays_bus_date%type,
                                                      pArchRecCounter           out INTEGER
                                                );
PROCEDURE pRollEBABalancesToME_full              (    pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     in FR_GLOBAL_PARAMETER.gp_todays_bus_date%type,
                                                      pArchRecCounter           out INTEGER
                                                );

-------------------------------------------------------------------------------------------------------------------------

END FDR_CUSTOM_ARCHIVING_PKG;
/