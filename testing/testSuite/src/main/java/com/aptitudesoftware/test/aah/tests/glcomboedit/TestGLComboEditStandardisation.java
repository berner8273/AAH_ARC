package com.aptitudesoftware.test.aah.tests.GLComboEdit;

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

public class TestGLComboEditStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestGLComboEditStandardisation.class );

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
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_PROCESS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_RULE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_ASSIGNMENT,
            AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_ASSIGNMENT_ER,
            AAHResourceConstants.GL_COMBO_EDIT_ASSIGNMENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_RULE,
            AAHTablenameConstants.GL_COMBO_EDIT_RULE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_RULE_ER,
            AAHResourceConstants.GL_COMBO_EDIT_RULE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_PROCESS,
            AAHTablenameConstants.GL_COMBO_EDIT_PROCESS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_PROCESS_ER,
            AAHResourceConstants.GL_COMBO_EDIT_PROCESS_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_GL_COMBO_EDIT_GC,
            AAHTablenameConstants.HOPPER_GL_COMBO_EDIT_GC,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_CODES_GCE,
            AAHTablenameConstants.FR_GENERAL_CODES_GCE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_CODES_GCE_ER,
            AAHResourceConstants.FR_GENERAL_CODES_GCE_AR));

      	cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        steps.add(AAHStep.processGLComboEdit);
        runBasicTest(steps);
        cleardown ();
    }

    @Test
    public void testSingleComboCheckSTN () throws Exception
    {
        //edit this line
        final String TEST_NAME              = "testSingleComboCheckSTN";
        
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
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_PROCESS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_RULE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.DEPARTMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.TAX_JURISDICTION,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
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
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_GL_COMBO_EDIT_GC,
            AAHTablenameConstants.HOPPER_GL_COMBO_EDIT_GC,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_CODES_GCE,
            AAHTablenameConstants.FR_GENERAL_CODES_GCE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_CODES_GCE_ER,
            AAHResourceConstants.FR_GENERAL_CODES_GCE_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_JOURNAL_LINE,
            AAHTablenameConstants.JOURNAL_LINE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.JOURNAL_LINE_ER,
            AAHResourceConstants.JOURNAL_LINE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_JRNL_LINES,
            AAHTablenameConstants.SLR_JRNL_LINES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_JRNL_LINES_ER,
            AAHResourceConstants.SLR_JRNL_LINES_AR));
    	
       	cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2018 , 9,30 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        steps.add(AAHStep.processGLComboEdit);
        
        steps.add(AAHStep.processFXRates);
        steps.add(AAHStep.processDepartments);
        steps.add(AAHStep.processLegalEntities);
        steps.add(AAHStep.processGLAccounts);
        steps.add(AAHStep.processTaxJurisdictions);
        
        
        steps.add(AAHStep.processGLChartfields);
        steps.add(AAHStep.processInsurancePolicies);
        steps.add(AAHStep.processJournalLines);
        steps.add(AAHStep.processSLR);
        
        
        
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
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_PROCESS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_RULE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_ASSIGNMENT,
            AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_ASSIGNMENT_ER,
            AAHResourceConstants.GL_COMBO_EDIT_ASSIGNMENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_RULE,
            AAHTablenameConstants.GL_COMBO_EDIT_RULE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_RULE_ER,
            AAHResourceConstants.GL_COMBO_EDIT_RULE_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_PROCESS,
            AAHTablenameConstants.GL_COMBO_EDIT_PROCESS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_PROCESS_ER,
            AAHResourceConstants.GL_COMBO_EDIT_PROCESS_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_GL_COMBO_EDIT_GC,
            AAHTablenameConstants.HOPPER_GL_COMBO_EDIT_GC,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR));
    	
       	cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9,8 ),1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        steps.add(AAHStep.processGLComboEdit);      
        
        runBasicTest(steps);
        cleardown ();
    }
   	

    @Test
    public void testDoubleExecution () throws Exception
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
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_PROCESS,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_COMBO_EDIT_RULE,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.GL_ACCOUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));
    	
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_PARTY_LEGAL,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"));

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LEDGER,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_ASSIGNMENT,
            AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_ASSIGNMENT_ER,
            AAHResourceConstants.GL_COMBO_EDIT_ASSIGNMENT_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_RULE,
            AAHTablenameConstants.GL_COMBO_EDIT_RULE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_RULE_ER,
            AAHResourceConstants.GL_COMBO_EDIT_RULE_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_GL_COMBO_EDIT_PROCESS,
            AAHTablenameConstants.GL_COMBO_EDIT_PROCESS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.GL_COMBO_EDIT_PROCESS_ER,
            AAHResourceConstants.GL_COMBO_EDIT_PROCESS_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_GL_COMBO_EDIT_GC,
            AAHTablenameConstants.HOPPER_GL_COMBO_EDIT_GC,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR));
    	
       	cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9,8 ),1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        steps.add(AAHStep.processGLComboEdit);      
        steps.add(AAHStep.processGLComboEdit);      
        
        runBasicTest(steps);
        cleardown ();
    }
    	
}