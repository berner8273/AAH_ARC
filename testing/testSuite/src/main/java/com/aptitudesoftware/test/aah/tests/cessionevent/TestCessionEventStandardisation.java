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
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_STAN_RAW_FX_RATE);	
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_FX_RATE);	
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_RATE_TYPE_LOOKUP,"RTYL_LOOKUP_KEY not in ( '1','SPOT','FORWARD','MAVG')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_RATE_TYPE,"RTY_RATE_TYPE_ID not in ( '1','SPOT','FORWARD','MAVG')");
    AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_LOG_TEXT);
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

        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
	    AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );        
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
    
}    
//     @Test
//     public void testValidations () throws Exception
//     {
    	
   	
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeed";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
//             AAHTablenameConstants.FR_LOG,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_LOG_ER,
//             AAHResourceConstants.FR_LOG_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 1 , 1 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);
//         runBasicTest(steps);
//         cleardown ();
//     }

//     @Test
//     public void testDoubleExecution () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testDoubleExecution";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 10 , 31 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.processJournalLines);
//         steps.add(AAHStep.processSLR);
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
// 				AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );        
//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }

//     @Test
//     public void testDayOnDayProcessing () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testDayOnDayProcessing";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 1 , 2 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 5 ) );
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
        
//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
// 				steps.add(AAHStep.processSLR);        
// 				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 16 ) );                

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
        
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "CONT_RSRV" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "LOSSES" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "OTHERS" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "OVERHEAD_TAX" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "PREM_COMM" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "01" , "PROFIT_COMM" );
//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
// 				steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }


//     @Test
//     public void testSingleValidFeedAG () throws Exception
//     {
//         //edit this line
//         final String TEST_NAME              = "testDayOnDayProcessing";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 30 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
// 			  steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }

//     @Test
//     public void testSingleValidFeedFV () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeedFV";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 30 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
// 			  steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }
    
// 		@Test
//     public void testSingleValidFeed92652 () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeed92652";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));


//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
// 			  steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }
    
//    @Test
//     public void testSingleValidFeedPGAAP () throws Exception
//     {
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeedPGAAP";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));


//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
// 			  steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }
    
//     @Test
//     public void testSingleValidFeedUK () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeedUK";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));


//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.processJournalLines);
// 			  steps.add(AAHStep.processSLR);        
// 			  AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );
			  
// 			  steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
// 			  steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }
       

//     @Test
//     public void testDayOnDayProcessingVIEConsol2 () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testDayOnDayProcessingVIEConsol2";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 10 , 31 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processDepartments);
//         steps.add(AAHStep.processInsurancePolicies);

//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "01" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "02" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "03" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "04" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "05" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "06" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "07" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "08" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "09" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "10" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "11" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "12" );
// 			  steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
// 			  steps.add(AAHStep.processSLR);        
        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
       
//         cleardown ();
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "10" );        
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 1` , 01 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        
//         //list steps to run here
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
			  
			  
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processDepartments);
//         steps.add(AAHStep.processSLR);          
        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
// 				compareResults();
// 				cleardown ();
//     }

//     @Test
//     public void testDayOnDayProcessingVIEDeconsol () throws Exception
//     {    	   	
//         //edit this line
//         final String TEST_NAME              = "testDayOnDayProcessingVIEDeConsol";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 15 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processDepartments);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.processJournalLines);        
//         steps.add(AAHStep.processSLR);        
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "06" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "07" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "08" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "09" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "10" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "11" );

// 			  steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
// 			  steps.add(AAHStep.processSLR);        
        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
        
//         cleardown ();
//         setupTest();
 
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 01 , 20 ) );
//         steps.add(AAHStep.processInsurancePolicies);               
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "12" );        
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
//         steps.add(AAHStep.processSLR);          
        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
// 		SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
        
//         cleardown ();
//         setupTest();
 
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 01 , 20 ) );
//         steps.add(AAHStep.processInsurancePolicies);               
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "12" );        
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
//         steps.add(AAHStep.processSLR);                  
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
// 			 SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

// 				cleardown ();
// 				setupTest();
				
// 				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 3 , 30 ) );
				
//         steps.add(AAHStep.processInsurancePolicies);               
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "02" );        
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
//         steps.add(AAHStep.processSLR);          
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }						
// 				compareResults();
//         cleardown ();
//     }

    

//     @Test
//     public void testPeriodIdentification () throws Exception
//     {
//         //edit this line
//         final String TEST_NAME              = "testPeriodIdentification";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_FAK_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.SLR_EBA_COMBINATIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTIONS,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 15 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         compareResults();
//         cleardown ();
//     }
    	
    	
//     @Test
//     public void testSingleValidFeedExceptions () throws Exception
//     {   	
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeedExceptions";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_EBA_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_EBA_DAILY_BALANCES_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DAILY_BALANCES,
//             AAHTablenameConstants.SLR_FAK_DAILY_BALANCES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_ER,
//             AAHResourceConstants.SLR_FAK_DAILY_BALANCES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 10 , 31 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
// 				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );        
//         LOG.debug ( "Set the business date" );

//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "CONT_RSRV" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "LOSSES" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OTHERS" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "OVERHEAD_TAX" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PREM_COMM" );
//         AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "10" , "PROFIT_COMM" );

//         steps.add(AAHStep.StandardiseCessionEvents);
//         steps.add(AAHStep.DSRCessionEvents);
//         steps.add(AAHStep.processSLR);        
//         runBasicTest(steps);
//         cleardown ();
//     }

//     @Test
//     public void testDayOnDayProcessingVIEConsol () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testDayOnDayProcessingVIEConsol";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));


//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 15 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processDepartments);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.processJournalLines);        
//         steps.add(AAHStep.processSLR);        
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "06" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "07" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "08" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "09" );
// 			  AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "10" );
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "11" );
// 			  steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
// 			  steps.add(AAHStep.processSLR);        
        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));
            
//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 1 , 20 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
// 				steps.add(AAHStep.processInsurancePolicies);        
// 				AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2017" , "12" );
// 				steps.add(AAHStep.StandardiseCessionEvents);        
// 				steps.add(AAHStep.DSRCessionEvents);        
// 				steps.add(AAHStep.processSLR);        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//     SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));
       
//         cleardown (); 
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 2 , 19 ) );
//         steps.add(AAHStep.processInsurancePolicies);               
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "01" );        
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
//         steps.add(AAHStep.processSLR);                  
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
// 				SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day4.xlsx"));

// 				cleardown ();
// 				setupTest();
				
// 				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 3 , 30 ) );
				
//         steps.add(AAHStep.processInsurancePolicies);               
//         AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "02" );        
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
//         steps.add(AAHStep.processSLR);  
//         setupTest();        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }						
// 				SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day5.xlsx"));

// 				cleardown ();
// 				setupTest();
				
// 				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 3 , 31 ) );			
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
//         steps.add(AAHStep.processSLR);  
//         setupTest();        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }						
// 				SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));
            
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day6.xlsx"));
        
// 				cleardown ();
// 				setupTest();
				
// 				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 4 , 30 ) );			
// 				AAHEventClassPeriodOperations.setCloseStatusAll ( "C" , "2018" , "03" );
//         steps.add(AAHStep.StandardiseCessionEvents);        
// 			  steps.add(AAHStep.DSRCessionEvents);        
//         steps.add(AAHStep.processSLR);  
//         setupTest();        
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }						
// 				compareResults();
//         cleardown ();

//     @Test
//     public void testSingleValidFeedLosses () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeedLosses";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();
//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));
        
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_BROKEN_FEED,
//             AAHTablenameConstants.BROKEN_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.BROKEN_FEED_ER,
//             AAHResourceConstants.BROKEN_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SUPERSEDED_FEED,
//             AAHTablenameConstants.SUPERSEDED_FEED,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SUPERSEDED_FEED_ER,
//             AAHResourceConstants.SUPERSEDED_FEED_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FEED_RECORD_COUNT,
//             AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FEED_RECORD_COUNT_ER,
//             AAHResourceConstants.FEED_RECORD_COUNT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_EVENT,
//             AAHTablenameConstants.CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_EVENT_ER,
//             AAHResourceConstants.CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_CESSION_EVENT,
//             AAHTablenameConstants.HOPPER_CESSION_EVENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_CESSION_EVENT_ER,
//             AAHResourceConstants.HOPPER_CESSION_EVENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ACCOUNTING_EVENT_IMP,
//             AAHTablenameConstants.FR_ACCOUNTING_EVENT_IMP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_ER,
//             AAHResourceConstants.FR_ACCOUNTING_EVENT_IMP_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
//             AAHTablenameConstants.SLR_JRNL_LINES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_JRNL_LINES_ER,
//             AAHResourceConstants.SLR_JRNL_LINES_AR));

//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 10 , 31 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processGLAccounts);
//         steps.add(AAHStep.processEventHierarchies);
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processTaxJurisdictions);
//         steps.add(AAHStep.processInsurancePolicies);
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 12 , 02 ) );
// 			  steps.add(AAHStep.StandardizeCessionEvents);
// 				steps.add(AAHStep.DSRCessionEvents);
// 				steps.add(AAHStep.processSLR);
//         runBasicTest(steps);
//         cleardown ();

//     }
// }
// }