package com.aptitudesoftware.test.aah.tests.cessionevent;

import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
import com.aptitudesoftware.test.aah.AAHCleardownOperations;
import com.aptitudesoftware.test.aah.AAHExpectedResult;
import com.aptitudesoftware.test.aah.AAHResourceConstants;
import com.aptitudesoftware.test.aah.AAHResources;
import com.aptitudesoftware.test.aah.AAHSeedTable;
import com.aptitudesoftware.test.aah.AAHStep;
import com.aptitudesoftware.test.aah.AAHTablenameConstants;
import com.aptitudesoftware.test.aah.AAHTest;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.ArrayList;
import com.aptitudesoftware.test.aah.AAHEventClassPeriodOperations;
import org.apache.log4j.Logger;
import org.testng.annotations.Test;

public class TestCessionEventStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestCessionEventStandardisation.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

    public void cleardown () throws Exception
{    
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_RATE_TYPE_LOOKUP,"RTYL_LOOKUP_KEY not in ( '1','SPOT','FORWARD','MAVG')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_LOG_TEXT);
    AAHCleardownOperations.clearTable(AAHTablenameConstants.LEGAL_ENTITY_LINK);
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_TRADE, "T_FDR_TRAN_NO NOT IN ('DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK_LOOKUP, "BOL_LOOKUP_KEY NOT IN ('DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK, "BO_BOOK_CLICODE NOT IN ('DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.INSURANCE_POLICY_FX_RATE);    
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INSTR_INSURE_EXTEND);
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INT_PROC_ENTITY_LOOKUP, "IPEL_LOOKUP_KEY NOT IN ('NVS','DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INTERNAL_PROC_ENTITY, "IPE_ENTITY_CLIENT_CODE not in ('NVS' , 'DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ENTITY_SCHEMA);     
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS_LOOKUP,"PBL_SIL_SYS_INST_CLICODE not in ('DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS,"PBU_PARTY_BUS_CLIENT_CODE not in ('DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_TYPE, "PLT_PL_PARTY_LEGAL_ID <> '1'");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.SLR_BM_ENTITY_PROCESSING_SET);                
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NODE_STRUCTURE, "ONS_ON_CHILD_ORG_NODE_ID  != 1");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NETWORK, "ON_ORG_NODE_CLIENT_CODE not in ('DEFAULT')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP,"PLL_LOOKUP_KEY not in ( '1','NVS')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_TYPE,"PLT_PL_PARTY_LEGAL_ID !='1'");   
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL,"PL_PARTY_LEGAL_CLICODE not in ( '1','NVS')");                
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_LPG_CONFIG);                
    AAHCleardownOperations.clearTable(AAHTablenameConstants.SLR_ENTITIES);                
    AAHCleardownOperations.clearTable(AAHTablenameConstants.SLR_ENTITY_PERIODS);                
super.cleardown();
}

    @Test
    public void testSingleValidFeed () throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testSingleValidFeed";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"));   
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx",
                "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 10 , 31 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseJournalLine);
        steps.add(AAHStep.DSRJournalLine);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);      

        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
	     AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );        
        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
        steps2.add(AAHStep.StandardiseCessionEvents);
        steps2.add(AAHStep.DSRCessionEvents);
        steps2.add(AAHStep.SLRUpdateDaysPeriods);
        steps2.add(AAHStep.SLRAccounts);
        steps2.add(AAHStep.SLRFXRates);
        steps2.add(AAHStep.SLRUpdateCurrencies);
        steps2.add(AAHStep.SLRUpdateFakSeg3);
        steps2.add(AAHStep.SLRUpdateFakSeg4);
        steps2.add(AAHStep.SLRUpdateFakSeg5);
        steps2.add(AAHStep.SLRUpdateFakSeg6);
        steps2.add(AAHStep.SLRUpdateFakSeg7);
        steps2.add(AAHStep.SLRUpdateFakSeg8);
        steps2.add(AAHStep.SLRpUpdateJLU);
        steps2.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps2) {
        	runStep(pStep.getName());
        }
        compareResults();
        cleardown ();
    }
       
    @Test
    public void testValidations () throws Exception
    {
    	   	
        final String TEST_NAME              = "testValidations";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
            AAHTablenameConstants.FR_LOG,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_LOG_ER,
            AAHResourceConstants.FR_LOG_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 1 , 1 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseCessionEvents);
        steps.add(AAHStep.DSRCessionEvents);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        runBasicTest(steps);
        cleardown ();
    }

    @Test
    public void testDayOnDayProcessing () throws Exception
    {    	
        final String TEST_NAME              = "testDayOnDayProcessing";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 1 , 2 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseCessionEvents);
        steps.add(AAHStep.DSRCessionEvents);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 5 ) );             
// DAY 2       
        SEED_TABLES.clear();   
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"
            ));        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));                
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        setupTest();
        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
        steps2.add(AAHStep.StandardiseInsurancePolicies);
        steps2.add(AAHStep.DSRInsurancePolicies);
        steps2.add(AAHStep.DSRFXRates);
        steps2.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps2.add(AAHStep.StandardiseCessionEvents);
        steps2.add(AAHStep.DSRCessionEvents);
        steps2.add(AAHStep.SLRUpdateDaysPeriods);
        steps2.add(AAHStep.SLRAccounts);
        steps2.add(AAHStep.SLRFXRates);
        steps2.add(AAHStep.SLRUpdateCurrencies);
        steps2.add(AAHStep.SLRUpdateFakSeg3);
        steps2.add(AAHStep.SLRUpdateFakSeg4);
        steps2.add(AAHStep.SLRUpdateFakSeg5);
        steps2.add(AAHStep.SLRUpdateFakSeg6);
        steps2.add(AAHStep.SLRUpdateFakSeg7);
        steps2.add(AAHStep.SLRUpdateFakSeg8);
        steps2.add(AAHStep.SLRpUpdateJLU);
        steps2.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps2) {
        	runStep(pStep.getName());
        }
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 16 ) );

// DAY 3        
        SEED_TABLES.clear();   
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"
            ));        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));                
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "CONT_RSRV" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "LOSSES" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "OTHERS" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "OVERHEAD_TAX" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "PREM_COMM" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "PROFIT_COMM" );

        setupTest();
        ArrayList<AAHStep> steps3 = new ArrayList<AAHStep> ();
        steps3.add(AAHStep.StandardiseCessionEvents);
        steps3.add(AAHStep.DSRCessionEvents);
        steps3.add(AAHStep.SLRUpdateDaysPeriods);
        steps3.add(AAHStep.SLRAccounts);
        steps3.add(AAHStep.SLRFXRates);
        steps3.add(AAHStep.SLRUpdateCurrencies);
        steps3.add(AAHStep.SLRUpdateFakSeg3);
        steps3.add(AAHStep.SLRUpdateFakSeg4);
        steps3.add(AAHStep.SLRUpdateFakSeg5);
        steps3.add(AAHStep.SLRUpdateFakSeg6);
        steps3.add(AAHStep.SLRUpdateFakSeg7);
        steps3.add(AAHStep.SLRUpdateFakSeg8);
        steps3.add(AAHStep.SLRpUpdateJLU);
        steps3.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps3) {
        	runStep(pStep.getName());
        }
        compareResults();
        cleardown ();
    }


    @Test
    public void testSingleValidFeedAG () throws Exception
    {
        //edit this line
        final String TEST_NAME              = "testSingleValidFeedAG";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx",
                "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 30 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseCessionEvents);
        steps.add(AAHStep.DSRCessionEvents);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        runBasicTest(steps);
        cleardown ();
    }


    @Test
    public void testSingleValidFeedFV () throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testSingleValidFeedFV";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 30 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseCessionEvents);
        steps.add(AAHStep.DSRCessionEvents);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        runBasicTest(steps);
        cleardown ();
    }

    
		@Test
    public void testSingleValidFeed92652 () throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testSingleValidFeed92652";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));


        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseCessionEvents);
        steps.add(AAHStep.DSRCessionEvents);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        runBasicTest(steps);
        cleardown ();
    }
    
   @Test
    public void testSingleValidFeedPGAAP () throws Exception
    {
        //edit this line
        final String TEST_NAME              = "testSingleValidFeedPGAAP";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));


        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));            
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

            cleardown ();
            setupTest();
            AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
            ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
            //list steps to run here
            steps.add(AAHStep.StandardiseGLAccounts);
            steps.add(AAHStep.DSRGLAccounts);
            steps.add(AAHStep.StandardiseEventHierarchy);
            steps.add(AAHStep.DSREventHierarchy);
            steps.add(AAHStep.StandardiseLegalEntities);
            steps.add(AAHStep.DSRLegalEntities);
            steps.add(AAHStep.DSRPartyBusiness);
            steps.add(AAHStep.DSRInternalProcessEntities);
            steps.add(AAHStep.DSRDepartments);
            steps.add(AAHStep.DSRLegalEntityHierNodes);
            steps.add(AAHStep.StandardiseLegalEntityLinks);
            steps.add(AAHStep.DSRLegalEntityHierLinks);
            steps.add(AAHStep.DSRLegalEntitySupplementalData);
            steps.add(AAHStep.DSRLegalEntityHierarchyData);
            steps.add(AAHStep.SLRUpdateDaysPeriods);
            steps.add(AAHStep.StandardiseTaxJurisdiction);
            steps.add(AAHStep.DSRTaxJurisdiction);
            steps.add(AAHStep.StandardiseInsurancePolicies);
            steps.add(AAHStep.DSRInsurancePolicies);
            steps.add(AAHStep.DSRFXRates);
            steps.add(AAHStep.DSRPolicyTaxJurisdictions);
            steps.add(AAHStep.StandardiseCessionEvents);
            steps.add(AAHStep.DSRCessionEvents);
            steps.add(AAHStep.SLRUpdateDaysPeriods);
            steps.add(AAHStep.SLRAccounts);
            steps.add(AAHStep.SLRFXRates);
            steps.add(AAHStep.SLRUpdateCurrencies);
            steps.add(AAHStep.SLRUpdateFakSeg3);
            steps.add(AAHStep.SLRUpdateFakSeg4);
            steps.add(AAHStep.SLRUpdateFakSeg5);
            steps.add(AAHStep.SLRUpdateFakSeg6);
            steps.add(AAHStep.SLRUpdateFakSeg7);
            steps.add(AAHStep.SLRUpdateFakSeg8);
            steps.add(AAHStep.SLRpUpdateJLU);
            steps.add(AAHStep.SLRpProcess);
                for (AAHStep pStep : steps) {
                runStep(pStep.getName());
            }
            compareResults();
        
            cleardown ();
        }
            
    @Test
    public void testSingleValidFeedUK () throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testSingleValidFeedUK";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));


        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));            
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

            cleardown ();
            setupTest();
    
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseJournalLine);
        steps.add(AAHStep.DSRJournalLine);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);      

        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );
        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
        steps2.add(AAHStep.StandardiseCessionEvents);
        steps2.add(AAHStep.DSRCessionEvents);
        steps2.add(AAHStep.SLRUpdateDaysPeriods);
        steps2.add(AAHStep.SLRAccounts);
        steps2.add(AAHStep.SLRFXRates);
        steps2.add(AAHStep.SLRUpdateCurrencies);
        steps2.add(AAHStep.SLRUpdateFakSeg3);
        steps2.add(AAHStep.SLRUpdateFakSeg4);
        steps2.add(AAHStep.SLRUpdateFakSeg5);
        steps2.add(AAHStep.SLRUpdateFakSeg6);
        steps2.add(AAHStep.SLRUpdateFakSeg7);
        steps2.add(AAHStep.SLRUpdateFakSeg8);
        steps2.add(AAHStep.SLRpUpdateJLU);
        steps2.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps2) {
        	runStep(pStep.getName());
        }
        compareResults();
        cleardown ();
    }
       

    @Test
    public void testDayOnDayProcessingVIEConsol2 () throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testDayOnDayProcessingVIEConsol2";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx",
"LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseDepartments);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        setupTest();
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "01" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "02" );
		AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "03" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "04" );
		AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "05" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "06" );
		AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "07" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "08" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "09" );
	    AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "10" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "11" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "12" );

        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
        steps2.add(AAHStep.StandardiseCessionEvents);
        steps2.add(AAHStep.DSRCessionEvents);
        steps2.add(AAHStep.SLRUpdateDaysPeriods);
        steps2.add(AAHStep.SLRAccounts);
        steps2.add(AAHStep.SLRFXRates);
        steps2.add(AAHStep.SLRUpdateCurrencies);
        steps2.add(AAHStep.SLRUpdateFakSeg3);
        steps2.add(AAHStep.SLRUpdateFakSeg4);
        steps2.add(AAHStep.SLRUpdateFakSeg5);
        steps2.add(AAHStep.SLRUpdateFakSeg6);
        steps2.add(AAHStep.SLRUpdateFakSeg7);
        steps2.add(AAHStep.SLRUpdateFakSeg8);
        steps2.add(AAHStep.SLRpUpdateJLU);
        steps2.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps2) {
        	runStep(pStep.getName());
        }
        
        SEED_TABLES.clear();
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
       
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "10" );        
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 11, 01 ) );
        ArrayList<AAHStep> steps3 = new ArrayList<AAHStep> ();
        
        //list steps to run here
        steps3.add(AAHStep.StandardiseInsurancePolicies);
        steps3.add(AAHStep.DSRInsurancePolicies);
        steps3.add(AAHStep.DSRFXRates);
        steps3.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps3.add(AAHStep.StandardiseCessionEvents);        
  	    steps3.add(AAHStep.DSRCessionEvents);        			  			  
        steps3.add(AAHStep.SLRUpdateDaysPeriods);
        steps3.add(AAHStep.SLRAccounts);
        steps3.add(AAHStep.SLRFXRates);
        steps3.add(AAHStep.SLRUpdateCurrencies);
        steps3.add(AAHStep.SLRUpdateFakSeg3);
        steps3.add(AAHStep.SLRUpdateFakSeg4);
        steps3.add(AAHStep.SLRUpdateFakSeg5);
        steps3.add(AAHStep.SLRUpdateFakSeg6);
        steps3.add(AAHStep.SLRUpdateFakSeg7);
        steps3.add(AAHStep.SLRUpdateFakSeg8);
        steps3.add(AAHStep.SLRpUpdateJLU);
        steps3.add(AAHStep.SLRpProcess);

        setupTest();
        for (AAHStep pStep : steps3) {
        	runStep(pStep.getName());
        }
				compareResults();
				cleardown ();
    }

    @Test
    public void testDayOnDayProcessingVIEDeconsol () throws Exception
    {    	   	
        //edit this line
        final String TEST_NAME              = "testDayOnDayProcessingVIEDeConsol";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx",
"LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 15 ) );
               
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseDepartments);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseJournalLine);
        steps.add(AAHStep.DSRJournalLine);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        setupTest();
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "06" );
	    AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "07" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "08" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "09" );
		AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "10" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "11" );
        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
		steps2.add(AAHStep.StandardiseCessionEvents);        
		steps2.add(AAHStep.DSRCessionEvents);        
        steps2.add(AAHStep.SLRUpdateDaysPeriods);
        steps2.add(AAHStep.SLRAccounts);
        steps2.add(AAHStep.SLRFXRates);
        steps2.add(AAHStep.SLRUpdateCurrencies);
        steps2.add(AAHStep.SLRUpdateFakSeg3);
        steps2.add(AAHStep.SLRUpdateFakSeg4);
        steps2.add(AAHStep.SLRUpdateFakSeg5);
        steps2.add(AAHStep.SLRUpdateFakSeg6);
        steps2.add(AAHStep.SLRUpdateFakSeg7);
        steps2.add(AAHStep.SLRUpdateFakSeg8);
        steps2.add(AAHStep.SLRpUpdateJLU);
        steps2.add(AAHStep.SLRpProcess);        
        for (AAHStep pStep : steps2) {
        	runStep(pStep.getName());
        }

        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 01 , 20 ) );

        SEED_TABLES.clear();
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
            ArrayList<AAHStep> steps3 = new ArrayList<AAHStep> ();
            steps3.add(AAHStep.StandardiseInsurancePolicies);
            steps3.add(AAHStep.DSRInsurancePolicies);
            steps3.add(AAHStep.DSRFXRates);
            steps3.add(AAHStep.DSRPolicyTaxJurisdictions);
            setupTest();
            for (AAHStep pStep : steps3) {
                runStep(pStep.getName());
            }
 
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "12" );

        ArrayList<AAHStep> steps4 = new ArrayList<AAHStep> ();
        steps4.add(AAHStep.StandardiseCessionEvents);        
		steps4.add(AAHStep.DSRCessionEvents);        
        steps4.add(AAHStep.SLRUpdateDaysPeriods);
        steps4.add(AAHStep.SLRAccounts);
        steps4.add(AAHStep.SLRFXRates);
        steps4.add(AAHStep.SLRUpdateCurrencies);
        steps4.add(AAHStep.SLRUpdateFakSeg3);
        steps4.add(AAHStep.SLRUpdateFakSeg4);
        steps4.add(AAHStep.SLRUpdateFakSeg5);
        steps4.add(AAHStep.SLRUpdateFakSeg6);
        steps4.add(AAHStep.SLRUpdateFakSeg7);
        steps4.add(AAHStep.SLRUpdateFakSeg8);
        steps4.add(AAHStep.SLRpUpdateJLU);
        steps4.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps4) {
            runStep(pStep.getName());
        }

        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 02 , 19 ) );    
		SEED_TABLES.clear();
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ArrayList<AAHStep> steps5 = new ArrayList<AAHStep> ();
        steps5.add(AAHStep.StandardiseInsurancePolicies);
        steps5.add(AAHStep.DSRInsurancePolicies);
        steps5.add(AAHStep.DSRFXRates);
        steps5.add(AAHStep.DSRPolicyTaxJurisdictions);
        setupTest();
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "01" );

        ArrayList<AAHStep> steps6 = new ArrayList<AAHStep> ();
        steps6.add(AAHStep.StandardiseCessionEvents);        
		steps6.add(AAHStep.DSRCessionEvents);        
        steps6.add(AAHStep.SLRUpdateDaysPeriods);
        steps6.add(AAHStep.SLRAccounts);
        steps6.add(AAHStep.SLRFXRates);
        steps6.add(AAHStep.SLRUpdateCurrencies);
        steps6.add(AAHStep.SLRUpdateFakSeg3);
        steps6.add(AAHStep.SLRUpdateFakSeg4);
        steps6.add(AAHStep.SLRUpdateFakSeg5);
        steps6.add(AAHStep.SLRUpdateFakSeg6);
        steps6.add(AAHStep.SLRUpdateFakSeg7);
        steps6.add(AAHStep.SLRUpdateFakSeg8);
        steps6.add(AAHStep.SLRpUpdateJLU);
        steps6.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps6) {
            runStep(pStep.getName());
        }

        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 3 , 30 ) );

    	SEED_TABLES.clear();
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
           new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
           PATH_TO_TEST_RESOURCES,
           "SeedData-day4.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day4.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));


            ArrayList<AAHStep> steps7 = new ArrayList<AAHStep> ();
            steps7.add(AAHStep.StandardiseInsurancePolicies);
            steps7.add(AAHStep.DSRInsurancePolicies);
            steps7.add(AAHStep.DSRFXRates);
            steps7.add(AAHStep.DSRPolicyTaxJurisdictions);
            setupTest();
            for (AAHStep pStep : steps7) {
                runStep(pStep.getName());
            }
    
            AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "02" );

            ArrayList<AAHStep> steps8 = new ArrayList<AAHStep> ();
            steps8.add(AAHStep.StandardiseCessionEvents);        
            steps8.add(AAHStep.DSRCessionEvents);        
            steps8.add(AAHStep.SLRUpdateDaysPeriods);
            steps8.add(AAHStep.SLRAccounts);
            steps8.add(AAHStep.SLRFXRates);
            steps8.add(AAHStep.SLRUpdateCurrencies);
            steps8.add(AAHStep.SLRUpdateFakSeg3);
            steps8.add(AAHStep.SLRUpdateFakSeg4);
            steps8.add(AAHStep.SLRUpdateFakSeg5);
            steps8.add(AAHStep.SLRUpdateFakSeg6);
            steps8.add(AAHStep.SLRUpdateFakSeg7);
            steps8.add(AAHStep.SLRUpdateFakSeg8);
            steps8.add(AAHStep.SLRpUpdateJLU);
            steps8.add(AAHStep.SLRpProcess);
            for (AAHStep pStep : steps8) {
                runStep(pStep.getName());
            }
                    
     	compareResults();
        cleardown ();
    }

    

    @Test
    public void testPeriodIdentification () throws Exception
    {
        //edit this line
        final String TEST_NAME              = "testPeriodIdentification";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

            SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
            
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"));
                
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));    

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
"LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 15 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseCessionEvents);
        steps.add(AAHStep.DSRCessionEvents);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps) {
            runStep(pStep.getName());
        }                
     compareResults();

        cleardown ();
    }
    	
    	
    @Test
    public void testSingleValidFeedExceptions () throws Exception
    {   	
        //edit this line
        final String TEST_NAME              = "testSingleValidFeedExceptions";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
            AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
            AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
            AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
            AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
            AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 10 , 31 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        setupTest();
        for (AAHStep pStep : steps) {
            runStep(pStep.getName());
        }
    
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );

        LOG.debug ( "Set the business date" );

        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );
        
        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
        steps2.add(AAHStep.StandardiseCessionEvents);
        steps2.add(AAHStep.DSRCessionEvents);
        steps2.add(AAHStep.SLRUpdateDaysPeriods);
        steps2.add(AAHStep.SLRAccounts);
        steps2.add(AAHStep.SLRFXRates);
        steps2.add(AAHStep.SLRUpdateCurrencies);
        steps2.add(AAHStep.SLRUpdateFakSeg3);
        steps2.add(AAHStep.SLRUpdateFakSeg4);
        steps2.add(AAHStep.SLRUpdateFakSeg5);
        steps2.add(AAHStep.SLRUpdateFakSeg6);
        steps2.add(AAHStep.SLRUpdateFakSeg7);
        steps2.add(AAHStep.SLRUpdateFakSeg8);
        steps2.add(AAHStep.SLRpUpdateJLU);
        steps2.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps2) {
            runStep(pStep.getName());
        }

        compareResults();
        cleardown ();
    }

    @Test
    public void testDayOnDayProcessingVIEConsol () throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testDayOnDayProcessingVIEConsol";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();
        //Setup arrays here

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
            AAHTablenameConstants.BROKEN_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.BROKEN_FEED_ER,
            AAHResourceConstants.BROKEN_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
            AAHTablenameConstants.SUPERSEDED_FEED,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SUPERSEDED_FEED_ER,
            AAHResourceConstants.SUPERSEDED_FEED_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
            AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FEED_RECORD_COUNT_ER,
            AAHResourceConstants.FEED_RECORD_COUNT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
            AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.CESSION_EVENT_ER,
            AAHResourceConstants.CESSION_EVENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
            AAHTablenameConstants.HOPPER_CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
            AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 15 ) );
               
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseEventHierarchy);
        steps.add(AAHStep.DSREventHierarchy);
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);
        steps.add(AAHStep.StandardiseDepartments);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseJournalLine);
        steps.add(AAHStep.DSRJournalLine);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "06" );
	    AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "07" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "08" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "09" );
		AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "10" );
        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "11" );
        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
		steps2.add(AAHStep.StandardiseCessionEvents);        
		steps2.add(AAHStep.DSRCessionEvents);        
        steps2.add(AAHStep.SLRUpdateDaysPeriods);
        steps2.add(AAHStep.SLRAccounts);
        steps2.add(AAHStep.SLRFXRates);
        steps2.add(AAHStep.SLRUpdateCurrencies);
        steps2.add(AAHStep.SLRUpdateFakSeg3);
        steps2.add(AAHStep.SLRUpdateFakSeg4);
        steps2.add(AAHStep.SLRUpdateFakSeg5);
        steps2.add(AAHStep.SLRUpdateFakSeg6);
        steps2.add(AAHStep.SLRUpdateFakSeg7);
        steps2.add(AAHStep.SLRUpdateFakSeg8);
        steps2.add(AAHStep.SLRpUpdateJLU);
        steps2.add(AAHStep.SLRpProcess);        
        for (AAHStep pStep : steps2) {
        	runStep(pStep.getName());
        }
        SEED_TABLES.clear();
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

        setupTest();
        
        ArrayList<AAHStep> steps3 = new ArrayList<AAHStep> ();
        steps3.add(AAHStep.StandardiseInsurancePolicies);
        steps3.add(AAHStep.DSRInsurancePolicies);
        steps3.add(AAHStep.DSRFXRates);
        steps3.add(AAHStep.DSRPolicyTaxJurisdictions);
        for (AAHStep pStep : steps3) {
            runStep(pStep.getName());
        }

    AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "12" );

    ArrayList<AAHStep> steps4 = new ArrayList<AAHStep> ();
    steps4.add(AAHStep.StandardiseCessionEvents);        
    steps4.add(AAHStep.DSRCessionEvents);        
    steps4.add(AAHStep.SLRUpdateDaysPeriods);
    steps4.add(AAHStep.SLRAccounts);
    steps4.add(AAHStep.SLRFXRates);
    steps4.add(AAHStep.SLRUpdateCurrencies);
    steps4.add(AAHStep.SLRUpdateFakSeg3);
    steps4.add(AAHStep.SLRUpdateFakSeg4);
    steps4.add(AAHStep.SLRUpdateFakSeg5);
    steps4.add(AAHStep.SLRUpdateFakSeg6);
    steps4.add(AAHStep.SLRUpdateFakSeg7);
    steps4.add(AAHStep.SLRUpdateFakSeg8);
    steps4.add(AAHStep.SLRpUpdateJLU);
    steps4.add(AAHStep.SLRpProcess);
    for (AAHStep pStep : steps4) {
        runStep(pStep.getName());
    }

    AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 02 , 19 ) );    
    SEED_TABLES.clear();
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"
        ));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));        
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));
        
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day3.xlsx",
        "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

        setupTest();
    
    ArrayList<AAHStep> steps5 = new ArrayList<AAHStep> ();
    steps5.add(AAHStep.StandardiseInsurancePolicies);
    steps5.add(AAHStep.DSRInsurancePolicies);
    steps5.add(AAHStep.DSRFXRates);
    steps5.add(AAHStep.DSRPolicyTaxJurisdictions);
    for (AAHStep pStep : steps) {
        runStep(pStep.getName());
    }

    AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "01" );

    ArrayList<AAHStep> steps6 = new ArrayList<AAHStep> ();
    steps6.add(AAHStep.StandardiseCessionEvents);        
    steps6.add(AAHStep.DSRCessionEvents);        
    steps6.add(AAHStep.SLRUpdateDaysPeriods);
    steps6.add(AAHStep.SLRAccounts);
    steps6.add(AAHStep.SLRFXRates);
    steps6.add(AAHStep.SLRUpdateCurrencies);
    steps6.add(AAHStep.SLRUpdateFakSeg3);
    steps6.add(AAHStep.SLRUpdateFakSeg4);
    steps6.add(AAHStep.SLRUpdateFakSeg5);
    steps6.add(AAHStep.SLRUpdateFakSeg6);
    steps6.add(AAHStep.SLRUpdateFakSeg7);
    steps6.add(AAHStep.SLRUpdateFakSeg8);
    steps6.add(AAHStep.SLRpUpdateJLU);
    steps6.add(AAHStep.SLRpProcess);

    for (AAHStep pStep : steps6) {
        runStep(pStep.getName());
    }

    AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 3 , 30 ) );

    SEED_TABLES.clear();
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"
        ));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));        
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
       new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
       PATH_TO_TEST_RESOURCES,
       "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));
        
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
        PATH_TO_TEST_RESOURCES,
        "SeedData-day4.xlsx",
        "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

        setupTest();

        ArrayList<AAHStep> steps7 = new ArrayList<AAHStep> ();
        steps7.add(AAHStep.StandardiseInsurancePolicies);
        steps7.add(AAHStep.DSRInsurancePolicies);
        steps7.add(AAHStep.DSRFXRates);
        steps7.add(AAHStep.DSRPolicyTaxJurisdictions);
        for (AAHStep pStep : steps7) {
            runStep(pStep.getName());
        }

        AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "02" );

        ArrayList<AAHStep> steps8 = new ArrayList<AAHStep> ();
        steps8.add(AAHStep.StandardiseCessionEvents);        
        steps8.add(AAHStep.DSRCessionEvents);        
        steps8.add(AAHStep.SLRUpdateDaysPeriods);
        steps8.add(AAHStep.SLRAccounts);
        steps8.add(AAHStep.SLRFXRates);
        steps8.add(AAHStep.SLRUpdateCurrencies);
        steps8.add(AAHStep.SLRUpdateFakSeg3);
        steps8.add(AAHStep.SLRUpdateFakSeg4);
        steps8.add(AAHStep.SLRUpdateFakSeg5);
        steps8.add(AAHStep.SLRUpdateFakSeg6);
        steps8.add(AAHStep.SLRUpdateFakSeg7);
        steps8.add(AAHStep.SLRUpdateFakSeg8);
        steps8.add(AAHStep.SLRpUpdateJLU);
        steps8.add(AAHStep.SLRpProcess);
        for (AAHStep pStep : steps8) {
            runStep(pStep.getName());
        }

        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 3 , 31 ) );

        SEED_TABLES.clear();
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));        
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
           new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
           PATH_TO_TEST_RESOURCES,
           "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx"));
    
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day5.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

            setupTest();
                
            ArrayList<AAHStep> steps9 = new ArrayList<AAHStep> ();
            steps9.add(AAHStep.StandardiseCessionEvents);        
            steps9.add(AAHStep.DSRCessionEvents);        
            steps9.add(AAHStep.SLRUpdateDaysPeriods);
            steps9.add(AAHStep.SLRAccounts);
            steps9.add(AAHStep.SLRFXRates);
            steps9.add(AAHStep.SLRUpdateCurrencies);
            steps9.add(AAHStep.SLRUpdateFakSeg3);
            steps9.add(AAHStep.SLRUpdateFakSeg4);
            steps9.add(AAHStep.SLRUpdateFakSeg5);
            steps9.add(AAHStep.SLRUpdateFakSeg6);
            steps9.add(AAHStep.SLRUpdateFakSeg7);
            steps9.add(AAHStep.SLRUpdateFakSeg8);
            steps9.add(AAHStep.SLRpUpdateJLU);
            steps9.add(AAHStep.SLRpProcess);
 
            for (AAHStep pStep : steps9) {
                runStep(pStep.getName());
            }
    
            AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 4 , 30 ) );

            SEED_TABLES.clear();
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.FEED,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"
                ));
            
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));        
            
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
            
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
               new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
               PATH_TO_TEST_RESOURCES,
               "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
                
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx"));
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day6.xlsx",
                "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

                setupTest();
      
            AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "03" );    

            ArrayList<AAHStep> steps10 = new ArrayList<AAHStep> ();
            steps10.add(AAHStep.StandardiseCessionEvents);        
            steps10.add(AAHStep.DSRCessionEvents);        
            steps10.add(AAHStep.SLRUpdateDaysPeriods);
            steps10.add(AAHStep.SLRAccounts);
            steps10.add(AAHStep.SLRFXRates);
            steps10.add(AAHStep.SLRUpdateCurrencies);
            steps10.add(AAHStep.SLRUpdateFakSeg3);
            steps10.add(AAHStep.SLRUpdateFakSeg4);
            steps10.add(AAHStep.SLRUpdateFakSeg5);
            steps10.add(AAHStep.SLRUpdateFakSeg6);
            steps10.add(AAHStep.SLRUpdateFakSeg7);
            steps10.add(AAHStep.SLRUpdateFakSeg8);
            steps10.add(AAHStep.SLRpUpdateJLU);
            steps10.add(AAHStep.SLRpProcess);
    
            for (AAHStep pStep : steps10) {
                runStep(pStep.getName());
            }
           
     compareResults();
    cleardown ();
}

@Test
public void testSingleValidFeedLosses () throws Exception
{
    
    //edit this line
    final String TEST_NAME              = "testSingleValidFeedLosses";
    
    final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
    LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
    LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
    LOG.info( "Reseting environment");
    ER_TABLES.clear();
    SEED_TABLES.clear();
    //Setup arrays here

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"
        ));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));
    
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
        AAHTablenameConstants.BROKEN_FEED,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.BROKEN_FEED_ER,
        AAHResourceConstants.BROKEN_FEED_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
        AAHTablenameConstants.SUPERSEDED_FEED,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.SUPERSEDED_FEED_ER,
        AAHResourceConstants.SUPERSEDED_FEED_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
        AAHTablenameConstants.FEED_RECORD_COUNT,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.FEED_RECORD_COUNT_ER,
        AAHResourceConstants.FEED_RECORD_COUNT_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
        AAHTablenameConstants.CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.CESSION_EVENT_ER,
        AAHResourceConstants.CESSION_EVENT_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
        AAHTablenameConstants.HOPPER_CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
        AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
        AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
        AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
        
    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
        AAHTablenameConstants.SLR_JRNL_LINES,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.SLR_JRNL_LINES_ER,
        AAHResourceConstants.SLR_JRNL_LINES_AR));

    cleardown ();
    setupTest();
    AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 10 , 31 ) );
    ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
    //list steps to run here
    steps.add(AAHStep.StandardiseGLAccounts);
    steps.add(AAHStep.DSRGLAccounts);
    steps.add(AAHStep.StandardiseEventHierarchy);
    steps.add(AAHStep.DSREventHierarchy);
    steps.add(AAHStep.StandardiseLegalEntities);
    steps.add(AAHStep.DSRLegalEntities);
    steps.add(AAHStep.DSRPartyBusiness);
    steps.add(AAHStep.DSRInternalProcessEntities);
    steps.add(AAHStep.DSRDepartments);
    steps.add(AAHStep.DSRLegalEntityHierNodes);
    steps.add(AAHStep.StandardiseLegalEntityLinks);
    steps.add(AAHStep.DSRLegalEntityHierLinks);
    steps.add(AAHStep.DSRLegalEntitySupplementalData);
    steps.add(AAHStep.DSRLegalEntityHierarchyData);
    steps.add(AAHStep.SLRUpdateDaysPeriods);
    steps.add(AAHStep.StandardiseTaxJurisdiction);
    steps.add(AAHStep.DSRTaxJurisdiction);
    steps.add(AAHStep.StandardiseInsurancePolicies);
    steps.add(AAHStep.DSRInsurancePolicies);
    steps.add(AAHStep.DSRFXRates);
    steps.add(AAHStep.DSRPolicyTaxJurisdictions);    
    for (AAHStep pStep : steps) {
        runStep(pStep.getName());
    }

    AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
    ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
    steps2.add(AAHStep.StandardiseCessionEvents);
    steps2.add(AAHStep.DSRCessionEvents);
    steps2.add(AAHStep.SLRUpdateDaysPeriods);
    steps2.add(AAHStep.SLRAccounts);
    steps2.add(AAHStep.SLRFXRates);
    steps2.add(AAHStep.SLRUpdateCurrencies);
    steps2.add(AAHStep.SLRUpdateFakSeg3);
    steps2.add(AAHStep.SLRUpdateFakSeg4);
    steps2.add(AAHStep.SLRUpdateFakSeg5);
    steps2.add(AAHStep.SLRUpdateFakSeg6);
    steps2.add(AAHStep.SLRUpdateFakSeg7);
    steps2.add(AAHStep.SLRUpdateFakSeg8);
    steps2.add(AAHStep.SLRpUpdateJLU);
    steps2.add(AAHStep.SLRpProcess);
    for (AAHStep pStep : steps2) {
        runStep(pStep.getName());
    }
    compareResults();
    cleardown ();
}

@Test
public void testDoubleExecution () throws Exception
{
    
    //edit this line
    final String TEST_NAME              = "testDoubleExecution";
    
    final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
    LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
    LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
    LOG.info( "Reseting environment");
    ER_TABLES.clear();
    SEED_TABLES.clear();
    //Setup arrays here

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"
        ));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));
    
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));
    
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
        
    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
        AAHTablenameConstants.BROKEN_FEED,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.BROKEN_FEED_ER,
        AAHResourceConstants.BROKEN_FEED_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
        AAHTablenameConstants.SUPERSEDED_FEED,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.SUPERSEDED_FEED_ER,
        AAHResourceConstants.SUPERSEDED_FEED_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
        AAHTablenameConstants.FEED_RECORD_COUNT,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.FEED_RECORD_COUNT_ER,
        AAHResourceConstants.FEED_RECORD_COUNT_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
        AAHTablenameConstants.CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.CESSION_EVENT_ER,
        AAHResourceConstants.CESSION_EVENT_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
        AAHTablenameConstants.HOPPER_CESSION_EVENT,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
        AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
        AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
        AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
        
    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
        AAHTablenameConstants.SLR_JRNL_LINES,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.SLR_JRNL_LINES_ER,
        AAHResourceConstants.SLR_JRNL_LINES_AR));

    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
        AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
        AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
        
    ER_TABLES.add(
        new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
        AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
        PATH_TO_TEST_RESOURCES,
        "ExpectedResults.xlsx",
        AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
        AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

    cleardown ();
    setupTest();
    AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 10 , 31 ) );
    ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
    //list steps to run here
    steps.add(AAHStep.StandardiseGLAccounts);
    steps.add(AAHStep.DSRGLAccounts);
    steps.add(AAHStep.StandardiseEventHierarchy);
    steps.add(AAHStep.DSREventHierarchy);
    steps.add(AAHStep.StandardiseLegalEntities);
    steps.add(AAHStep.DSRLegalEntities);
    steps.add(AAHStep.DSRPartyBusiness);
    steps.add(AAHStep.DSRInternalProcessEntities);
    steps.add(AAHStep.DSRDepartments);
    steps.add(AAHStep.DSRLegalEntityHierNodes);
    steps.add(AAHStep.StandardiseLegalEntityLinks);
    steps.add(AAHStep.DSRLegalEntityHierLinks);
    steps.add(AAHStep.DSRLegalEntitySupplementalData);
    steps.add(AAHStep.DSRLegalEntityHierarchyData);
    steps.add(AAHStep.SLRUpdateDaysPeriods);
    steps.add(AAHStep.StandardiseTaxJurisdiction);
    steps.add(AAHStep.DSRTaxJurisdiction);
    steps.add(AAHStep.StandardiseInsurancePolicies);
    steps.add(AAHStep.DSRInsurancePolicies);
    steps.add(AAHStep.DSRFXRates);
    steps.add(AAHStep.DSRPolicyTaxJurisdictions);
    steps.add(AAHStep.StandardiseJournalLine);
    steps.add(AAHStep.DSRJournalLine);
    steps.add(AAHStep.SLRUpdateDaysPeriods);
    steps.add(AAHStep.SLRAccounts);
    steps.add(AAHStep.SLRFXRates);
    steps.add(AAHStep.SLRUpdateCurrencies);
    steps.add(AAHStep.SLRUpdateFakSeg3);
    steps.add(AAHStep.SLRUpdateFakSeg4);
    steps.add(AAHStep.SLRUpdateFakSeg5);
    steps.add(AAHStep.SLRUpdateFakSeg6);
    steps.add(AAHStep.SLRUpdateFakSeg7);
    steps.add(AAHStep.SLRUpdateFakSeg8);
    steps.add(AAHStep.SLRpUpdateJLU);
    steps.add(AAHStep.SLRpProcess);      

    for (AAHStep pStep : steps) {
        runStep(pStep.getName());
    }

     AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
     AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
     AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
     AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
     AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
     AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
     AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );        
    ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();
    steps2.add(AAHStep.StandardiseCessionEvents);
    steps2.add(AAHStep.DSRCessionEvents);
    steps2.add(AAHStep.StandardiseCessionEvents);
    steps2.add(AAHStep.DSRCessionEvents);
    steps2.add(AAHStep.SLRUpdateDaysPeriods);
    steps2.add(AAHStep.SLRAccounts);
    steps2.add(AAHStep.SLRFXRates);
    steps2.add(AAHStep.SLRUpdateCurrencies);
    steps2.add(AAHStep.SLRUpdateFakSeg3);
    steps2.add(AAHStep.SLRUpdateFakSeg4);
    steps2.add(AAHStep.SLRUpdateFakSeg5);
    steps2.add(AAHStep.SLRUpdateFakSeg6);
    steps2.add(AAHStep.SLRUpdateFakSeg7);
    steps2.add(AAHStep.SLRUpdateFakSeg8);
    steps2.add(AAHStep.SLRpUpdateJLU);
    steps2.add(AAHStep.SLRpProcess);
    for (AAHStep pStep : steps2) {
        runStep(pStep.getName());
    }
    compareResults();
    cleardown ();
}

}
// }