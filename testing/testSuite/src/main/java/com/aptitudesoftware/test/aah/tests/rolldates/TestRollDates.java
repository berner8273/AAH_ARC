package com.aptitudesoftware.test.aah.tests.Rolldates;

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

public class TestRollDates extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestRollDates.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );



    @Test
    public void testWeekendDate () throws Exception
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
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GLOBAL_PARAMETER,
            AAHTablenameConstants.FR_GLOBAL_PARAMETER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GLOBAL_PARAMETER_ER,
            AAHResourceConstants.FR_GLOBAL_PARAMETER_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITIES,
            AAHTablenameConstants.SLR_ENTITIES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_ENTITIES_ER,
            AAHResourceConstants.SLR_ENTITIES_AR));
                     
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 3 ) , 1 ); //Friday
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 4 ) , -1 ); //Saturday
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 5 ) , 2 ); //Sunday
                        
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.processLegalEntities);
        steps.add(AAHStep.RollDates);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        runBasicTest(steps);
        cleardown ();
}

    @Test
    public void testAllIds () throws Exception
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
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GLOBAL_PARAMETER,
            AAHTablenameConstants.FR_GLOBAL_PARAMETER,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GLOBAL_PARAMETER_ER,
            AAHResourceConstants.FR_GLOBAL_PARAMETER_AR));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITIES,
            AAHTablenameConstants.SLR_ENTITIES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_ENTITIES_ER,
            AAHResourceConstants.SLR_ENTITIES_AR));
                     
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 5 ,123 ) , 1 ); 
                        
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
        //list steps to run here
        steps.add(AAHStep.RollDates);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.RollDates);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        runBasicTest(steps);
        cleardown ();
}

}