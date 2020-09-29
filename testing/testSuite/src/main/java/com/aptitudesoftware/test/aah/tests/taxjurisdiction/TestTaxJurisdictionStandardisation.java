package com.aptitudesoftware.test.aah.tests.taxjurisdiction;

import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
// import com.aptitudesoftware.test.aah.AAHCleardownOperations;
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

public class TestTaxJurisdictionStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestTaxJurisdictionStandardisation.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

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
                        new AAHExpectedResult(AAHTablenameConstants.ER_TAX_JURISDICTION,
                        AAHTablenameConstants.FR_GENERAL_CODES,
                        PATH_TO_TEST_RESOURCES,
                        "ExpectedResults.xlsx",
                        AAHResourceConstants.TAX_JURISDICTION_ER,
                        AAHResourceConstants.TAX_JURISDICTION_AR,
                        "GC_GCT_CODE_TYPE_ID in ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));
    
                        ER_TABLES.add(
                            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_TAX_JURISDICTION,
                            AAHTablenameConstants.FR_STAN_RAW_GENERAL_CODES,
                            PATH_TO_TEST_RESOURCES,
                            "ExpectedResults.xlsx",
                            AAHResourceConstants.HOPPER_TAX_JURISDICTION_ER,
                            AAHResourceConstants.HOPPER_TAX_JURISDICTION_AR,
                            "SRGC_GCT_CODE_TYPE_ID <> 'TAX_JURISDICTION'"));
    

                cleardown ();
                AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );
                ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

                steps.add(AAHStep.StandardiseTaxJurisdiction);
                steps.add(AAHStep.DSRTaxJurisdiction);

                runBasicTest(steps);
                cleardown ();
    }              
    
        @Test
        public void testFeedSupersession () throws Exception
        {   	
            //edit this line
            final String TEST_NAME              = "testFeedSupersession";
            
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
                            new AAHExpectedResult(AAHTablenameConstants.ER_TAX_JURISDICTION,
                            AAHTablenameConstants.FR_GENERAL_CODES,
                            PATH_TO_TEST_RESOURCES,
                            "ExpectedResults.xlsx",
                            AAHResourceConstants.TAX_JURISDICTION_ER,
                            AAHResourceConstants.TAX_JURISDICTION_AR,
                            "GC_GCT_CODE_TYPE_ID in ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));
        
    
            cleardown ();
            AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );
            ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
            steps.add(AAHStep.StandardiseTaxJurisdiction);
            steps.add(AAHStep.DSRTaxJurisdiction);

            runBasicTest(steps);
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
                        new AAHExpectedResult(AAHTablenameConstants.ER_TAX_JURISDICTION,
                        AAHTablenameConstants.FR_GENERAL_CODES,
                        PATH_TO_TEST_RESOURCES,
                        "ExpectedResults.xlsx",
                        AAHResourceConstants.TAX_JURISDICTION_ER,
                        AAHResourceConstants.TAX_JURISDICTION_AR,
                        "GC_GCT_CODE_TYPE_ID in ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));
    
    

         cleardown ();
         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );

         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
         steps.add(AAHStep.StandardiseTaxJurisdiction);
         steps.add(AAHStep.DSRTaxJurisdiction);
         steps.add(AAHStep.StandardiseTaxJurisdiction);
         steps.add(AAHStep.DSRTaxJurisdiction);

         runBasicTest(steps);
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

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day1.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day1.xlsx"));

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
                        new AAHExpectedResult(AAHTablenameConstants.ER_TAX_JURISDICTION,
                        AAHTablenameConstants.FR_GENERAL_CODES,
                        PATH_TO_TEST_RESOURCES,
                        "ExpectedResults.xlsx",
                        AAHResourceConstants.TAX_JURISDICTION_ER,
                        AAHResourceConstants.TAX_JURISDICTION_AR,
                        "GC_GCT_CODE_TYPE_ID in ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));
    
                        ER_TABLES.add(
                            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_TAX_JURISDICTION,
                            AAHTablenameConstants.FR_STAN_RAW_GENERAL_CODES,
                            PATH_TO_TEST_RESOURCES,
                            "ExpectedResults.xlsx",
                            AAHResourceConstants.HOPPER_TAX_JURISDICTION_ER,
                            AAHResourceConstants.HOPPER_TAX_JURISDICTION_AR,
                            "SRGC_GCT_CODE_TYPE_ID = 'TAX_JURISDICTION'"));
    
                cleardown ();
                AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );
                ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
                steps.add(AAHStep.StandardiseTaxJurisdiction);
                steps.add(AAHStep.DSRTaxJurisdiction);
                for (AAHStep pStep : steps) {
                    runStep(pStep.getName());
                }        
                SEED_TABLES.clear();
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.FEED,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-Day2.xlsx"
                    ));
                
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-Day2.xlsx"));
        
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-Day2.xlsx"));
                    setupTest();
                    for (AAHStep pStep : steps) {
                        runStep(pStep.getName());
                    }
            
                    SEED_TABLES.clear();
                    SEED_TABLES.add(
                        new AAHSeedTable( AAHTablenameConstants.FEED,
                        PATH_TO_TEST_RESOURCES,
                        "SeedData-Day3.xlsx"
                        ));
                    
                    SEED_TABLES.add(
                        new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
                        PATH_TO_TEST_RESOURCES,
                        "SeedData-Day3.xlsx"));
            
                    SEED_TABLES.add(
                        new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
                        PATH_TO_TEST_RESOURCES,
                        "SeedData-Day3.xlsx"));
                        setupTest();
                        for (AAHStep pStep : steps) {
                            runStep(pStep.getName());
                        }
                        compareResults();
                        cleardown ();
                    }

//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( "testDayOnDayProcessing" );
//         final Path PATH_TO_SEED_DATA_DAY1   = PATH_TO_TEST_RESOURCES.resolve ( "SeedData-Day1.xlsx" );
//         final Path PATH_TO_SEED_DATA_DAY2   = PATH_TO_TEST_RESOURCES.resolve ( "SeedData-Day2.xlsx" );
//         final Path PATH_TO_SEED_DATA_DAY3   = PATH_TO_TEST_RESOURCES.resolve ( "SeedData-Day3.xlsx" );
//         final Path PATH_TO_EXPECTED_RESULTS = PATH_TO_TEST_RESOURCES.resolve ( "ExpectedResults.xlsx" );

//         if ( ! Files.exists ( PATH_TO_SEED_DATA_DAY1 ) )   { LOG.debug ( "'" + PATH_TO_SEED_DATA_DAY1.toString ()   + "' does not exist." ); assert ( false ); };
//         if ( ! Files.exists ( PATH_TO_SEED_DATA_DAY2 ) )   { LOG.debug ( "'" + PATH_TO_SEED_DATA_DAY2.toString ()   + "' does not exist." ); assert ( false ); };
//         if ( ! Files.exists ( PATH_TO_SEED_DATA_DAY3 ) )   { LOG.debug ( "'" + PATH_TO_SEED_DATA_DAY3.toString ()   + "' does not exist." ); assert ( false ); };
//         if ( ! Files.exists ( PATH_TO_EXPECTED_RESULTS ) ) { LOG.debug ( "'" + PATH_TO_EXPECTED_RESULTS.toString () + "' does not exist." ); assert ( false ); };

//         final AAHTablenameConstants [] TABLES_TO_SEED          = {
//                                                                      AAHTablenameConstants.FEED
//                                                                  ,   AAHTablenameConstants.FEED_RECORD_COUNT
//                                                                  ,   AAHTablenameConstants.TAX_JURISDICTION
//                                                                  };
//         final AAHTablenameConstants [] EXPECTED_RESULTS_TABLES = {
//                                                                      AAHTablenameConstants.ER_BROKEN_FEED
//                                                                  ,   AAHTablenameConstants.ER_SUPERSEDED_FEED
//                                                                  ,   AAHTablenameConstants.ER_FEED_RECORD_COUNT
//                                                                  ,   AAHTablenameConstants.ER_TAX_JURISDICTION
//                                                                  ,   AAHTablenameConstants.ER_HOPPER_TAX_JURISDICTION
//                                                                  ,   AAHTablenameConstants.ER_FR_TAX_JURISDICTION
//                                                                  };

//         LOG.debug ( "Start cleardown" );

//         cleardown ();

//         LOG.debug ( "Completed cleardown" );

//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );

//         LOG.debug ( "Set the business date" );

//         for ( AAHTablenameConstants t : TABLES_TO_SEED )
//         {
//             XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_SEED_DATA_DAY1 , t.getTableName () , TOKEN_OPS );
//         }

//         Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.StandardiseTaxJurisdiction ) );

//         LOG.debug ( "Standardised tax_jurisdiction data" );

//         Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.DSRTaxJurisdiction ) );

//         for ( AAHTablenameConstants t : TABLES_TO_SEED )
//         {
//             XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_SEED_DATA_DAY2 , t.getTableName () , TOKEN_OPS );
//         }

//         Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.StandardiseTaxJurisdiction ) );

//         LOG.debug ( "Standardised tax_jurisdiction data" );

//         Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.DSRTaxJurisdiction ) );

//         for ( AAHTablenameConstants t : TABLES_TO_SEED )
//         {
//             XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_SEED_DATA_DAY3 , t.getTableName () , TOKEN_OPS );
//         }

//         Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.StandardiseTaxJurisdiction ) );

//         LOG.debug ( "Standardised tax_jurisdiction data" );

//         Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.DSRTaxJurisdiction ) );

//         LOG.debug ( "Processed tax_jurisdiction data through to AAH core" );

//         LOG.debug ( "*** *** Start loading expected results" );

//         for ( AAHTablenameConstants t : EXPECTED_RESULTS_TABLES )
//         {
//             XL_OPS.createDatabaseTableFromExcelTab ( t.getTableOwner () , PATH_TO_EXPECTED_RESULTS , t.getTableName () );

//             XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_EXPECTED_RESULTS , t.getTableName () , TOKEN_OPS );

//             Assert.assertEquals
//             (
//                 0
//             ,   DATA_COMP_OPS.countMinusQueryResults
//                 (
//                     t.getActualResultsSQL   ().getPathToResource ()
//                 ,   t.getExpectedResultsSQL ().getPathToResource ()
//                 ,   new String [] {}
//                 ,   TOKEN_OPS
//                 )
//             );
//         }
//     }

}