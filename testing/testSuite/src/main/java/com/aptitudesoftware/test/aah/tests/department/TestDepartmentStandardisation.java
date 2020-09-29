package com.aptitudesoftware.test.aah.tests.department;

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

public class TestDepartmentStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestDepartmentStandardisation.class );

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
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK_LOOKUP, "BOL_LOOKUP_KEY <> 'DEFAULT'" );                
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
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_DEPARTMENT,
            AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.DEPARTMENT_ER,
            AAHResourceConstants.DEPARTMENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_BOOK,
            AAHTablenameConstants.FR_STAN_RAW_BOOK,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_BOOK_ER,
            AAHResourceConstants.FR_STAN_RAW_BOOK_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_BOOK,
            AAHTablenameConstants.FR_BOOK,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_BOOK_ER,
            AAHResourceConstants.FR_BOOK_AR,
            "BO_BOOK_ID <> '1'"));

        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK_LOOKUP, "BOL_LOOKUP_KEY <> 'DEFAULT'" );                
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 ,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseDepartments);
        steps.add(AAHStep.DSRDepartments);
        runBasicTest(steps);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK_LOOKUP, "BOL_LOOKUP_KEY <> 'DEFAULT'" );                        
        cleardown ();
    }
    	

    @Test
    public void testDoubleExecution () throws Exception
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
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_DEPARTMENT,
            AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.DEPARTMENT_ER,
            AAHResourceConstants.DEPARTMENT_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 ,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseDepartments);
        steps.add(AAHStep.StandardiseDepartments);
        runBasicTest(steps);
        cleardown ();
    }
    	

//     @Test
//     public void testDayOnDayProcessing () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testSingleValidFeed";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();

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
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
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
//             new AAHExpectedResult(AAHTablenameConstants.ER_DEPARTMENT,
//             AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.DEPARTMENT_ER,
//             AAHResourceConstants.DEPARTMENT_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_BOOK,
//             AAHTablenameConstants.FR_STAN_RAW_BOOK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_BOOK_ER,
//             AAHResourceConstants.FR_STAN_RAW_BOOK_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_BOOK,
//             AAHTablenameConstants.FR_BOOK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_BOOK_ER,
//             AAHResourceConstants.FR_BOOK_AR));

//         cleardown ();
//         setupTest();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017, 9 ,8 ) , 1 );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//         //list steps to run here
        
//         steps.add(AAHStep.StandardiseDepartments);
//         steps.add(AAHStep.DSRDepartments);
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
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         cleardown ();
//         setupTest();
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
       
//         steps.add(AAHStep.StandardiseDepartments);
//         steps.add(AAHStep.DSRDepartments);
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         SEED_TABLES.clear();
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
//             new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         cleardown ();
//         setupTest();
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
       
//         steps.add(AAHStep.StandardiseDepartments);
//         steps.add(AAHStep.DSRDepartments);
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
// 				compareResults();
//         cleardown ();
//     }
 }