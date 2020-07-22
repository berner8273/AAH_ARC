package com.aptitudesoftware.test.aah.tests.GLChartfield;

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
    private static final Logger LOG = Logger.getLogger ( TestGLChartfieldStandardisation.class );

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
            new AAHSeedTable( AAHTablenameConstants.GL_CHARTFIELD,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_CHARTFIELD,
            AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_CHARTFIELD_ER,
            AAHResourceConstants.GL_CHARTFIELD_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_GL_CHARTFIELD,
            AAHTablenameConstants.HOPPER_GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_CHARTFIELD_ER,
            AAHResourceConstants.HOPPER_GL_CHARTFIELD_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GL_CHARTFIELD,
            AAHTablenameConstants.FR_GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GL_CHARTFIELD_ER,
            AAHResourceConstants.FR_GL_CHARTFIELD_AR));

    	
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 ,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLChartfields);
        steps.add(AAHStep.DSRGLChartfields);
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
            new AAHSeedTable( AAHTablenameConstants.GL_CHARTFIELD,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_CHARTFIELD,
            AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_CHARTFIELD_ER,
            AAHResourceConstants.GL_CHARTFIELD_AR));

    	
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 ,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLChartfields);
        steps.add(AAHStep.StandardiseGLChartfields);
        runBasicTest(steps);
        cleardown ();
    }

    @Test
    public void testDayOnDayProcessing () throws Exception
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
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
       
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
    	
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
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_CHARTFIELD,
            AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_CHARTFIELD_ER,
            AAHResourceConstants.GL_CHARTFIELD_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_GL_CHARTFIELD,
            AAHTablenameConstants.HOPPER_GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_CHARTFIELD_ER,
            AAHResourceConstants.HOPPER_GL_CHARTFIELD_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GL_CHARTFIELD,
            AAHTablenameConstants.FR_GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GL_CHARTFIELD_ER,
            AAHResourceConstants.FR_GL_CHARTFIELD_AR));
    	
        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9 ,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLChartfields);
        steps.add(AAHStep.DSRGLChartfields);
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }
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
            new AAHSeedTable( AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"));
  	
        cleardown ();
        setupTest();
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLChartfields);
        steps.add(AAHStep.DSRGLChartfields);
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }
        compareResults();
        cleardown ();
}    	
}
