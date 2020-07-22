package com.aptitudesoftware.test.aah.tests.GLINTExtract;

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

public class TestGLINTExtract extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestGLAccountStandardisation.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

    public void cleardown () throws Exception
/*    
	{
		AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_GL_ACCOUNT_AUD);
		AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_GL_ACCOUNT_LOOKUP, "GAL_INPUT_BY = 'Client Static'");
		super.cleardown();
	}
*/


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
            // (Table, path to seed data, seed data file name, [optional where clause for cleardown])
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            //,"FEED_ID = -2"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            // (Table, path to seed data, seed data file name, [optional where clause for cleardown])
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

       
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_JOURNAL_LINE,
            AAHTablenameConstants.RR_GLINT_JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_JOURNAL_LINE_ER,
            AAHResourceConstants.RR_GLINT_JOURNAL_LINE_AR));
    	

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_JOURNAL,
            AAHTablenameConstants.RR_GLINT_JOURNAL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_JOURNAL_ER,
            AAHResourceConstants.RR_GLINT_JOURNAL_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_BATCH_CONTROL,
            AAHTablenameConstants.RR_GLINT_BATCH_CONTROL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_BATCH_CONTROL_ER,
            AAHResourceConstants.RR_GLINT_BATCH_CONTROL_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_INTERFACE_CONTROL,
            AAHTablenameConstants.RR_GLINT_INTERFACE_CONTROL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_INTERFACE_CONTROL_ER,
            AAHResourceConstants.RR_GLINT_INTERFACE_CONTROL_AR));
            
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 20 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.processFXRates);
        steps.add(AAHStep.processDepartments);
        steps.add(AAHStep.processLegalEntities);
        steps.add(AAHStep.processGLAccounts);
        steps.add(AAHStep.processTaxJurisdictions);
				steps.add(AAHStep.processGLChartfields);
				steps.add(AAHStep.processInsurancePolicies);
				steps.add(AAHStep.processEventHierarchies);
				steps.add(AAHStep.processJournalLines);
				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 1 , 20 ) , 1 );
				steps.add(AAHStep.processSLR);			
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "11" , "PREM_COMM" );
        steps.add(AAHStep.processGLINTExtract);											
        runBasicTest(steps);
        cleardown ();
    }


@Test
    public void testUKGAAP () throws Exception
    {   	
        //edit this line
        final String TEST_NAME              = "testUKGAAP";
        
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
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
       
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_JOURNAL_LINE,
            AAHTablenameConstants.RR_GLINT_JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_JOURNAL_LINE_ER,
            AAHResourceConstants.RR_GLINT_JOURNAL_LINE_AR));
    	

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_JOURNAL,
            AAHTablenameConstants.RR_GLINT_JOURNAL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_JOURNAL_ER,
            AAHResourceConstants.RR_GLINT_JOURNAL_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_BATCH_CONTROL,
            AAHTablenameConstants.RR_GLINT_BATCH_CONTROL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_BATCH_CONTROL_ER,
            AAHResourceConstants.RR_GLINT_BATCH_CONTROL_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_INTERFACE_CONTROL,
            AAHTablenameConstants.RR_GLINT_INTERFACE_CONTROL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_INTERFACE_CONTROL_ER,
            AAHResourceConstants.RR_GLINT_INTERFACE_CONTROL_AR));
            
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 20 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.processFXRates);
        steps.add(AAHStep.processDepartments);
        steps.add(AAHStep.processLegalEntities);
        steps.add(AAHStep.processGLAccounts);
        steps.add(AAHStep.processTaxJurisdictions);
				steps.add(AAHStep.processGLChartfields);
				steps.add(AAHStep.processInsurancePolicies);
				steps.add(AAHStep.processEventHierarchies);
				steps.add(AAHStep.processJournalLines);
				AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 1 , 20 ) , 1 );
				steps.add(AAHStep.processSLR);			
        AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "11" , "PREM_COMM" );
        steps.add(AAHStep.processGLINTExtract);											
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
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_CHARTFIELD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));
       
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_JOURNAL_LINE,
            AAHTablenameConstants.RR_GLINT_JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_JOURNAL_LINE_ER,
            AAHResourceConstants.RR_GLINT_JOURNAL_LINE_AR));   	

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_JOURNAL,
            AAHTablenameConstants.RR_GLINT_JOURNAL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_JOURNAL_ER,
            AAHResourceConstants.RR_GLINT_JOURNAL_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_BATCH_CONTROL,
            AAHTablenameConstants.RR_GLINT_BATCH_CONTROL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_BATCH_CONTROL_ER,
            AAHResourceConstants.RR_GLINT_BATCH_CONTROL_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RR_GLINT_INTERFACE_CONTROL,
            AAHTablenameConstants.RR_GLINT_INTERFACE_CONTROL,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RR_GLINT_INTERFACE_CONTROL_ER,
            AAHResourceConstants.RR_GLINT_INTERFACE_CONTROL_AR));


        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 20 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
            

        //list steps to run here
        steps.add(AAHStep.processFXRates);
        steps.add(AAHStep.processDepartments);
        steps.add(AAHStep.processLegalEntities);
        steps.add(AAHStep.processGLAccounts);
        steps.add(AAHStep.processTaxJurisdictions);
				steps.add(AAHStep.processGLChartfields);
				steps.add(AAHStep.processInsurancePolicies);
				steps.add(AAHStep.processJournalLines);				
				steps.add(AAHStep.processEventHierarchies);
				steps.add(AAHStep.processSLR);							
				AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "11" , "PREM_COMM" );        
        steps.add(AAHStep.processGLINTExtract);											
        runBasicTest(steps);
        cleardown ();
        
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
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day2.xlsx"
            ));

        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 21 ) , 1 );
        AAHEventClassPeriodOperations.setCloseStatus ( "O" , "2017" , "11" , "PREM_COMM" );        
				steps.add(AAHStep.processJournalLines);
				steps.add(AAHStep.processSLR);              
				AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "11" , "PREM_COMM" );        
				steps.add(AAHStep.processGLINTExtract);															
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
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "SeedData-day3.xlsx"
            ));

        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 11 , 22 ) , 1 );
        AAHEventClassPeriodOperations.setCloseStatus ( "O" , "2017" , "11" , "PREM_COMM" );        
				steps.add(AAHStep.processJournalLines);
				steps.add(AAHStep.processSLR);              
				AAHEventClassPeriodOperations.setCloseStatus ( "C" , "2017" , "11" , "PREM_COMM" );        
				steps.add(AAHStep.processGLINTExtract);															
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }
        compareResults();
        cleardown ();
    }
}    
