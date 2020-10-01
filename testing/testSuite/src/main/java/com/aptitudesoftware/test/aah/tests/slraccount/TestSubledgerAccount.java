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
      AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_GL_ACCOUNT_LOOKUP, "GAL_GA_LOOKUP_KEY != '1' AND NOT exists ( SELECT NULL FROM FDR.FR_GL_ACCOUNT GA WHERE GA.GA_ACCOUNT_CODE = GAL_GA_ACCOUNT_CODE AND GA.GA_INPUT_BY = 'AG_SEED' )");
      AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_GL_ACCOUNT, "GA_ACCOUNT_CODE != '1' AND GA_INPUT_BY != 'AG_SEED'");
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
            new AAHSeedTable( AAHTablenameConstants.FR_GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day1.xlsx",
            "ga_account_code != '1' and ga_input_by != 'AG_SEED'"));

         SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.SLR_ENTITIES,
             PATH_TO_TEST_RESOURCES,
             "SeedData-Day1.xlsx"));

         ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITY_ACCOUNTS,
                    AAHTablenameConstants.SLR_ENTITY_ACCOUNTS,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.SLR_ENTITY_ACCOUNTS_ER,
                    AAHResourceConstants.SLR_ENTITY_ACCOUNTS_AR));
        cleardown ();

       AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );
       ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

       //list steps to run here
       steps.add(AAHStep.SLRAccounts);
       for (AAHStep pStep : steps) {
        runStep(pStep.getName());
        }
        SEED_TABLES.clear();

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day2.xlsx",
            "ga_account_code != '1' and ga_input_by != 'AG_SEED'"));

       SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.SLR_ENTITIES,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day2.xlsx"));

                steps.add(AAHStep.SLRAccounts);
                setupTest();
                for (AAHStep pStep : steps) {
                    runStep(pStep.getName());
                }

                SEED_TABLES.clear();
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.FR_GL_ACCOUNT,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-Day3.xlsx",
                    "ga_account_code != '1' and ga_input_by != 'AG_SEED'"));
        
                    SEED_TABLES.add(
                        new AAHSeedTable( AAHTablenameConstants.SLR_ENTITIES,
                        PATH_TO_TEST_RESOURCES,
                        "SeedData-Day3.xlsx"));
                        steps.add(AAHStep.SLRAccounts);
                        setupTest();
                        for (AAHStep pStep : steps) {
                            runStep(pStep.getName());
                        }
                
                        compareResults();
                        cleardown ();
            
                }        
           

}