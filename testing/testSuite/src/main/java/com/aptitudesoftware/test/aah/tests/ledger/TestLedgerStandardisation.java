package com.aptitudesoftware.test.aah.tests.ledger;

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

import org.apache.log4j.Logger;
import org.testng.annotations.Test;

public class TestLedgerStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestLedgerStandardisation.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );
   
    public void cleardown () throws Exception
	{		
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS_LOOKUP,"PBL_SIL_SYS_INST_CLICODE NOT IN ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS,"PBU_PARTY_BUS_CLIENT_CODE NOT IN ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NODE_STRUCTURE,"ONS_ON_CHILD_ORG_NODE_ID != 1");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NETWORK,"ON_ORG_NODE_CLIENT_CODE NOT IN ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INT_PROC_ENTITY_LOOKUP,"IPEL_LOOKUP_KEY NOT IN ('NVS','DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INTERNAL_PROC_ENTITY,"IPE_ENTITY_CLIENT_CODE NOT IN ('NVS','DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP,"PLL_LOOKUP_KEY not in ( '1','NVS')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_TYPE,"PLT_PL_PARTY_LEGAL_ID !='1'");                                     
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
                new AAHSeedTable( AAHTablenameConstants.LEDGER,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"
                ));

                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData.xlsx"
                    ));
        
                    SEED_TABLES.add(
                        new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
                        PATH_TO_TEST_RESOURCES,
                        "SeedData.xlsx"));              
                        
         SEED_TABLES.add(
             new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
             PATH_TO_TEST_RESOURCES,
             "SeedData.xlsx",
             "PL_PARTY_LEGAL_ID NOT IN ('1','NVS')"));
    	
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
            new AAHExpectedResult(AAHTablenameConstants.ER_ACCOUNTING_BASIS_LEDGER,
            AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.ACCOUNTING_BASIS_LEDGER_ER,
            AAHResourceConstants.ACCOUNTING_BASIS_LEDGER_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_ACCOUNTING_BASIS,
                AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.HOPPER_ACCOUNTING_BASIS_ER,
                AAHResourceConstants.HOPPER_ACCOUNTING_BASIS_AR));
    
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY_LEDGER,
            AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.LEGAL_ENTITY_LEDGER_ER,
            AAHResourceConstants.LEGAL_ENTITY_LEDGER_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_LEGAL_ENTITY_LEDGER,
                AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.HOPPER_LEGAL_ENTITY_LEDGER_ER,
                AAHResourceConstants.HOPPER_LEGAL_ENTITY_LEDGER_AR));
    
         ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_LEDGER,
                AAHTablenameConstants.LEDGER,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.LEDGER_ER,
                AAHResourceConstants.LEDGER_AR));
   
   	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_LOOKUP_LEDG,
            AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEDG_ER,
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEDG_AR,
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
//            "lk_lkt_lookup_type_code <> 'LEDGER_DEFAULT'"
//            ));  	
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_POSTING_SCHEMA,
            AAHTablenameConstants.FR_POSTING_SCHEMA,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_POSTING_SCHEMA_ER,
            AAHResourceConstants.FR_POSTING_SCHEMA_AR));
    	
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 ,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        runBasicTest(steps);
        cleardown ();
    }

    @Test
    public void testValidations () throws Exception
    {
        //edit this line
        final String TEST_NAME              = "testValidations";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();

        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );

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
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"
                ));
                
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "PL_PARTY_LEGAL_ID NOT IN ('1','NVS')"));            
        
    	
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
            new AAHExpectedResult(AAHTablenameConstants.ER_ACCOUNTING_BASIS_LEDGER,
            AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.ACCOUNTING_BASIS_LEDGER_ER,
            AAHResourceConstants.ACCOUNTING_BASIS_LEDGER_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY_LEDGER,
            AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.LEGAL_ENTITY_LEDGER_ER,
            AAHResourceConstants.LEGAL_ENTITY_LEDGER_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_LEDGER,
                AAHTablenameConstants.LEDGER,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.LEDGER_ER,
                AAHResourceConstants.LEDGER_AR));
    
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_ACCOUNTING_BASIS,
            AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_ACCOUNTING_BASIS_ER,
            AAHResourceConstants.HOPPER_ACCOUNTING_BASIS_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_LEGAL_ENTITY_LEDGER,
            AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_LEGAL_ENTITY_LEDGER_ER,
            AAHResourceConstants.HOPPER_LEGAL_ENTITY_LEDGER_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_LOOKUP_LEDG,
            AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEDG_ER,
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEDG_AR,
            "lk_lkt_lookup_type_code IN in ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_POSTING_SCHEMA,
            AAHTablenameConstants.FR_POSTING_SCHEMA,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_POSTING_SCHEMA_ER,
            AAHResourceConstants.FR_POSTING_SCHEMA_AR));

      cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        runBasicTest(steps);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );        
        cleardown ();
    }

    @Test
    public void testDayOnDayProcessing () throws Exception
    {
        //edit this line
        final String TEST_NAME              = "testDayOnDayProcessing";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();

        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );                

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
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day1.xlsx"
                ));
                
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
    	
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx",
            "PL_PARTY_LEGAL_ID NOT IN ('1','NVS')"));  
    	
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
                new AAHExpectedResult(AAHTablenameConstants.ER_ACCOUNTING_BASIS_LEDGER,
                AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.ACCOUNTING_BASIS_LEDGER_ER,
                AAHResourceConstants.ACCOUNTING_BASIS_LEDGER_AR));
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY_LEDGER,
            AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.LEGAL_ENTITY_LEDGER_ER,
            AAHResourceConstants.LEGAL_ENTITY_LEDGER_AR));

    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_LEDGER,
                AAHTablenameConstants.LEDGER,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.LEDGER_ER,
                AAHResourceConstants.LEDGER_AR));
      
    
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_ACCOUNTING_BASIS,
            AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_ACCOUNTING_BASIS_ER,
            AAHResourceConstants.HOPPER_ACCOUNTING_BASIS_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_LEGAL_ENTITY_LEDGER,
            AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_LEGAL_ENTITY_LEDGER_ER,
            AAHResourceConstants.HOPPER_LEGAL_ENTITY_LEDGER_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_LOOKUP_LEDG,
            AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEDG_ER,
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEDG_AR,
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));            
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_POSTING_SCHEMA,
            AAHTablenameConstants.FR_POSTING_SCHEMA,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_POSTING_SCHEMA_ER,
            AAHResourceConstants.FR_POSTING_SCHEMA_AR));

            ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
            steps.add(AAHStep.StandardiseLedgers);
            steps.add(AAHStep.DSRLedgers);
    
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );                
         cleardown (); 
         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017, 9 ,8 ) , 1 );
         
         setupTest();
        // //list steps to run here        
        for (AAHStep pStep : steps) {
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
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"
            ));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day2.xlsx"
                ));
                
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"));
    	
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx",
        "PL_PARTY_LEGAL_ID NOT IN ('1','NVS')"));            

//        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );                    
//        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017, 9 ,8 ) , 1 );
        ArrayList<AAHStep> steps2 = new ArrayList<AAHStep> ();        
        
        //list steps to run here
        
        steps2.add(AAHStep.StandardiseLedgers);
        steps2.add(AAHStep.DSRLedgers);
        for (AAHStep pStep : steps2) {
        	runStep(pStep.getName());
        }
        
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );        
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
                new AAHSeedTable( AAHTablenameConstants.LEDGER,
                PATH_TO_TEST_RESOURCES,
                "SeedData-day3.xlsx"
                ));

                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-day3.xlsx"
                    ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));    	          
                
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx",
        "PL_PARTY_LEGAL_ID NOT IN ('1','NVS')"));

        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );                                
        cleardown ();
        setupTest();

        ArrayList<AAHStep> steps3 = new ArrayList<AAHStep> ();

        //list steps to run here
        
        steps3.add(AAHStep.StandardiseLedgers);
        steps3.add(AAHStep.DSRLedgers);
        for (AAHStep pStep : steps3) {
        	runStep(pStep.getName());
        }
        compareResults();
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY NOT IN ('1','NVS')" );                
        cleardown ();
    }
    
 

    @Test
    public void testProcessOnly () throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testValidations";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();

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
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"
                ));
                
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
 
         cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 ,1 ));
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        runBasicTest(steps);
        cleardown ();
    }
}
       
