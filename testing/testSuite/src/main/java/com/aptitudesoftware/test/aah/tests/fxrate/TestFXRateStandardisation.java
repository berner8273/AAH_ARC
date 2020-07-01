package com.aptitudesoftware.test.aah.tests.fxrate;

import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
import com.aptitudesoftware.test.aah.AAHExpectedResult;
import com.aptitudesoftware.test.aah.AAHFXRateOperations;
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

public class TestFXRateStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestFXRateStandardisation.class );

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
        

        //Setup arrays here

        SEED_TABLES.add(
            // (Table, path to seed data, seed data file name, [optional where clause for cleardown])
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            //,"FEED_ID = -2"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
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
            // (Exected Result Table, Actual Table, Path to expected results, expected results file name, Expexted Result Table Select SQL, Actual Table Select SQL, [optional where clause for cleardown of Actual Table])
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
            new AAHExpectedResult(AAHTablenameConstants.ER_FX_RATE,
            AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FX_RATE_ER,
            AAHResourceConstants.FX_RATE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
            AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
            AAHTablenameConstants.FR_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_FX_RATE_ER,
            AAHResourceConstants.FR_FX_RATE_AR));

        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseFXRates);
        steps.add(AAHStep.DSRFXRates);

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ) , 1 );
        AAHFXRateOperations.setNo1To1Days ( 5 );
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
        

        //Setup arrays here

        SEED_TABLES.add(
            // (Table, path to seed data, seed data file name, [optional where clause for cleardown])
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            //,"FEED_ID = -2"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
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
            // (Exected Result Table, Actual Table, Path to expected results, expected results file name, Expexted Result Table Select SQL, Actual Table Select SQL, [optional where clause for cleardown of Actual Table])
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
            new AAHExpectedResult(AAHTablenameConstants.ER_FX_RATE,
            AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FX_RATE_ER,
            AAHResourceConstants.FX_RATE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
            AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
            AAHTablenameConstants.FR_LOG,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_LOG_ER,
            "fr_log.sql",
            "LO_TABLE_IN_ERROR_NAME = 'fx_rate'"));

        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseFXRates);

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ) , 1 );
        AAHFXRateOperations.setNo1To1Days ( 5 );
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
        

        //Setup arrays here

        SEED_TABLES.add(
            // (Table, path to seed data, seed data file name, [optional where clause for cleardown])
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day1.xlsx"
            //,"FEED_ID = -2"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day1.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
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
            // (Exected Result Table, Actual Table, Path to expected results, expected results file name, Expexted Result Table Select SQL, Actual Table Select SQL, [optional where clause for cleardown of Actual Table])
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
            new AAHExpectedResult(AAHTablenameConstants.ER_FX_RATE,
            AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FX_RATE_ER,
            AAHResourceConstants.FX_RATE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
            AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
            AAHTablenameConstants.FR_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_FX_RATE_ER,
            AAHResourceConstants.FR_FX_RATE_AR));

        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.StandardiseFXRates);
        steps.add(AAHStep.DSRFXRates);


        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 , 8 ) , 1 );
        AAHFXRateOperations.setNo1To1Days ( 5 );
        setupTest();
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        SEED_TABLES.clear();
        SEED_TABLES.add(
            // (Table, path to seed data, seed data file name, [optional where clause for cleardown])
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day2.xlsx"
            //,"FEED_ID = -2"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day2.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day2.xlsx"));

        setupTest();
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        SEED_TABLES.clear();
        SEED_TABLES.add(
            // (Table, path to seed data, seed data file name, [optional where clause for cleardown])
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day3.xlsx"
            //,"FEED_ID = -2"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day3.xlsx"));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day3.xlsx"));

        setupTest();
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }

        compareResults();

        cleardown ();
    }
}