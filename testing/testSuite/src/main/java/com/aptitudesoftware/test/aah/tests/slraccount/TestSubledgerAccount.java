package com.aptitudesoftware.test.aah.tests.slraccount;

import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
import com.aptitudesoftware.test.aah.AAHCleardownOperations;
// import com.aptitudesoftware.test.aah.AAHExecution;
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


public class TestSubledgerAccount extends AAHTest
{
    private static final Logger LOG = Logger.getLogger (TestSubledgerAccount.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

     public void cleardown () throws Exception
	 {	
      AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_GL_ACCOUNT_LOOKUP, "GAL_GA_LOOKUP_KEY != '1' AND NOT exists ( select null from fdr.fr_gl_account ga where ga.ga_account_code = gal.gal_ga_account_code and ga.ga_input_by = 'AG_SEED' )"));
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
            new AAHSeedTable( AAHTablenameConstants.FR_GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "ga_account_code != '1' and ga_input_by != 'AG_SEED'"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.SLR_ENTITIES,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"));

                ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITY_ACCOUNTS,
                    AAHTablenameConstants.SLR_ENTITY_ACCOUNTS,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.SLR_ENTITY_ACCOUNTS_ER,
                    AAHResourceConstants.SLR_ENTITY_ACCOUNTS_AR));

                    cleardown ();
                    AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 20 ) , 1 );
                    ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
            
                    //list steps to run here
                    steps.add(AAHStep.SLRAccounts);
            
                    runBasicTest(steps);
                    cleardown ();
                }    
            


    // @Test
    // public void testDayOnDayProcessing () throws Exception
    // {
    //     final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( "testDayOnDayProcessing" );
    //     final Path PATH_TO_SEED_DATA_DAY1   = PATH_TO_TEST_RESOURCES.resolve ( "SeedData-Day1.xlsx" );
    //     final Path PATH_TO_SEED_DATA_DAY2   = PATH_TO_TEST_RESOURCES.resolve ( "SeedData-Day2.xlsx" );
    //     final Path PATH_TO_SEED_DATA_DAY3   = PATH_TO_TEST_RESOURCES.resolve ( "SeedData-Day3.xlsx" );
    //     final Path PATH_TO_EXPECTED_RESULTS = PATH_TO_TEST_RESOURCES.resolve ( "ExpectedResults.xlsx" );

    //     if ( ! Files.exists ( PATH_TO_SEED_DATA_DAY1 ) )   { LOG.debug ( "'" + PATH_TO_SEED_DATA_DAY1.toString ()   + "' does not exist." ); assert ( false ); };
    //     if ( ! Files.exists ( PATH_TO_SEED_DATA_DAY2 ) )   { LOG.debug ( "'" + PATH_TO_SEED_DATA_DAY2.toString ()   + "' does not exist." ); assert ( false ); };
    //     if ( ! Files.exists ( PATH_TO_SEED_DATA_DAY3 ) )   { LOG.debug ( "'" + PATH_TO_SEED_DATA_DAY3.toString ()   + "' does not exist." ); assert ( false ); };
    //     if ( ! Files.exists ( PATH_TO_EXPECTED_RESULTS ) ) { LOG.debug ( "'" + PATH_TO_EXPECTED_RESULTS.toString () + "' does not exist." ); assert ( false ); };

    //     final AAHTablenameConstants [] TABLES_TO_SEED          = {
    //                                                                  AAHTablenameConstants.FR_GL_ACCOUNT
    //                                                              ,   AAHTablenameConstants.SLR_ENTITIES
    //                                                              };
    //     final AAHTablenameConstants [] EXPECTED_RESULTS_TABLES = {
    //                                                                  AAHTablenameConstants.ER_SLR_ENTITY_ACCOUNTS
    //                                                              };

    //     LOG.debug ( "Start cleardown" );

    //     cleardown ();

    //     LOG.debug ( "Completed cleardown" );

    //     AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );

    //     LOG.debug ( "Set the business date" );

    //     for ( AAHTablenameConstants t : TABLES_TO_SEED )
    //     {
    //         XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_SEED_DATA_DAY1 , t.getTableName () , TOKEN_OPS );
    //     }

    //     Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.SLRAccounts ) );

    //     LOG.debug ( "Merged account data into SLR entity accounts - Day 1" );

    //     for ( AAHTablenameConstants t : TABLES_TO_SEED )
    //     {
    //         XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_SEED_DATA_DAY2 , t.getTableName () , TOKEN_OPS );
    //     }

    //     Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.SLRAccounts ) );

    //     LOG.debug ( "Merged account data into SLR entity accounts - Day 2" );

    //     for ( AAHTablenameConstants t : TABLES_TO_SEED )
    //     {
    //         XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_SEED_DATA_DAY3 , t.getTableName () , TOKEN_OPS );
    //     }

    //     Assert.assertTrue ( AAHExecution.executeBatchStep ( AAHStep.SLRAccounts ) );

    //     LOG.debug ( "Merged account data into SLR entity accounts - Day 3" );

    //     LOG.debug ( "*** *** Start loading expected results" );

    //     for ( AAHTablenameConstants t : EXPECTED_RESULTS_TABLES )
    //     {
    //         XL_OPS.createDatabaseTableFromExcelTab ( t.getTableOwner () , PATH_TO_EXPECTED_RESULTS , t.getTableName () );

    //         XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_EXPECTED_RESULTS , t.getTableName () , TOKEN_OPS );

    //         Assert.assertEquals
    //         (
    //             0
    //         ,   DATA_COMP_OPS.countMinusQueryResults
    //             (
    //                 t.getActualResultsSQL   ().getPathToResource ()
    //             ,   t.getExpectedResultsSQL ().getPathToResource ()
    //             ,   new String [] {}
    //             ,   TOKEN_OPS
    //             )
    //         );
    //     }
    // }
}