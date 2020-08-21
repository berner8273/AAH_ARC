// package com.aptitudesoftware.test.aah.tests.InsurancePolicy;

// import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
// import com.aptitudesoftware.test.aah.AAHCleardownOperations;
// import com.aptitudesoftware.test.aah.AAHExpectedResult;
// import com.aptitudesoftware.test.aah.AAHResourceConstants;
// import com.aptitudesoftware.test.aah.AAHResources;
// import com.aptitudesoftware.test.aah.AAHSeedTable;
// import com.aptitudesoftware.test.aah.AAHStep;
// import com.aptitudesoftware.test.aah.AAHTablenameConstants;
// import com.aptitudesoftware.test.aah.AAHTest;
// import java.nio.file.Path;
// import java.time.LocalDate;
// import java.util.ArrayList;

// import org.apache.log4j.Logger;
// import org.testng.annotations.Test;

// public class TestInsurancePolicyStandardisation extends AAHTest
// {
//     private static final Logger LOG = Logger.getLogger ( TestInsuracePolicyStandardisation.class );

//     private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

//     @Test
//     public void testSingleValidFeed () throws Exception
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
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
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
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
//             AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_ER,
//             AAHResourceConstants.INSURANCE_POLICY_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
//             AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_ER,
//             AAHResourceConstants.CESSION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
//             AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_LINK_ER,
//             AAHResourceConstants.CESSION_LINK_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
//             AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
//             AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
//             AAHTablenameConstants.HOPPER_INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
//             AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
//             AAHTablenameConstants.FR_RATE_TYPE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_RATE_TYPE_ER,
//             AAHResourceConstants.FR_RATE_TYPE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
//             AAHTablenameConstants.FR_INSTRUMENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTRUMENT_ER,
//             AAHResourceConstants.FR_INSTRUMENT_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
//             AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
//             AAHTablenameConstants.FR_TRADE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_TRADE_ER,
//             AAHResourceConstants.FR_TRADE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
//             AAHTablenameConstants.FR_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_FX_RATE_ER,
//             AAHResourceConstants.FR_FX_RATE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
//             AAHTablenameConstants.FR_POLICY_TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
//             AAHTablenameConstants.FR_LOG,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_LOG,
//             AAHResourceConstants.FR_LOG));
            
//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 2 ));
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processInsurancePolicies);
//         runBasicTest(steps);
//         cleardown ();
//     }

//     @Test
//     public void testValidations () throws Exception
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
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
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
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
//             AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_ER,
//             AAHResourceConstants.INSURANCE_POLICY_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
//             AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_ER,
//             AAHResourceConstants.CESSION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
//             AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_LINK_ER,
//             AAHResourceConstants.CESSION_LINK_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
//             AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
//             AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
//             AAHTablenameConstants.HOPPER_INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
//             AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
//             AAHTablenameConstants.FR_RATE_TYPE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_RATE_TYPE_ER,
//             AAHResourceConstants.FR_RATE_TYPE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
//             AAHTablenameConstants.FR_INSTRUMENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTRUMENT_ER,
//             AAHResourceConstants.FR_INSTRUMENT_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
//             AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
//             AAHTablenameConstants.FR_TRADE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_TRADE_ER,
//             AAHResourceConstants.FR_TRADE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
//             AAHTablenameConstants.FR_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_FX_RATE_ER,
//             AAHResourceConstants.FR_FX_RATE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
//             AAHTablenameConstants.FR_POLICY_TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
//             AAHTablenameConstants.FR_LOG,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_LOG,
//             AAHResourceConstants.FR_LOG));
            
//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ));
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processInsurancePolicies);
//         runBasicTest(steps);
//         cleardown ();
//     }

//     @Test
//     public void testDoubleExecution () throws Exception
//     {
    	
//         //edit this line
//         final String TEST_NAME              = "testDoubleExecution";
        
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
//         LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
//         LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
//         LOG.info( "Reseting environment");
//         ER_TABLES.clear();
//         SEED_TABLES.clear();

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData.xlsx"
//             ));
        
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
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
//             AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_ER,
//             AAHResourceConstants.INSURANCE_POLICY_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
//             AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_ER,
//             AAHResourceConstants.CESSION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
//             AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_LINK_ER,
//             AAHResourceConstants.CESSION_LINK_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
//             AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
//             AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
//             AAHTablenameConstants.HOPPER_INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
//             AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
//             AAHTablenameConstants.FR_RATE_TYPE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_RATE_TYPE_ER,
//             AAHResourceConstants.FR_RATE_TYPE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
//             AAHTablenameConstants.FR_INSTRUMENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTRUMENT_ER,
//             AAHResourceConstants.FR_INSTRUMENT_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
//             AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
//             AAHTablenameConstants.FR_TRADE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_TRADE_ER,
//             AAHResourceConstants.FR_TRADE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
//             AAHTablenameConstants.FR_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_FX_RATE_ER,
//             AAHResourceConstants.FR_FX_RATE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
//             AAHTablenameConstants.FR_POLICY_TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
//             AAHTablenameConstants.FR_LOG,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_LOG,
//             AAHResourceConstants.FR_LOG));
            
//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ));
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.StandardiseInsurancePolicies);
//         steps.add(AAHStep.processInsurancePolicies);
//         steps.add(AAHStep.DSRInsurancePolicies);
//         runBasicTest(steps);
//         cleardown ();
//     }
    	

//     @Test
//     public void testDayOnDayProcessing () throws Exception
//     {   	
//         //edit this line
//         final String TEST_NAME              = "testDayOnDayProcessing";
        
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
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
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
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
//             AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_ER,
//             AAHResourceConstants.INSURANCE_POLICY_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
//             AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_ER,
//             AAHResourceConstants.CESSION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
//             AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.CESSION_LINK_ER,
//             AAHResourceConstants.CESSION_LINK_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
//             AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
//             AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
//             AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
//             AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
//             AAHTablenameConstants.HOPPER_INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
//             AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
//             AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
//             AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
//             AAHTablenameConstants.FR_RATE_TYPE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_RATE_TYPE_ER,
//             AAHResourceConstants.FR_RATE_TYPE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
//             AAHTablenameConstants.FR_INSTRUMENT,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTRUMENT_ER,
//             AAHResourceConstants.FR_INSTRUMENT_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
//             AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
//             AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
//             AAHTablenameConstants.FR_TRADE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_TRADE_ER,
//             AAHResourceConstants.FR_TRADE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
//             AAHTablenameConstants.FR_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_FX_RATE_ER,
//             AAHResourceConstants.FR_FX_RATE_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
//             AAHTablenameConstants.FR_POLICY_TAX_JURISDICTION,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
//             AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
//             AAHTablenameConstants.FR_LOG,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_LOG,
//             AAHResourceConstants.FR_LOG));

//         cleardown ();
//         setupTest();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 ,1 ));
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
// 				steps.add(AAHStep.processInsurancePolicies);
				
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
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day2.xlsx"
//             ));
              
//         setupTest();
// 				steps.add(AAHStep.processLegalEntities);
// 				steps.add(AAHStep.processInsurancePolicies);              
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
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day3.xlsx"
//             ));

//         setupTest();

// 				steps.add(AAHStep.processLegalEntities);
// 				steps.add(AAHStep.processInsurancePolicies);              
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         compareResults();
//         cleardown ();

//     }        
        
        
//     @Test
//     public void testProcessOnly () throws Exception
//     {
//         //edit this line
//         final String TEST_NAME              = "testProcessOnly";
        
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
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"));

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-day1.xlsx"
//             ));
    	
//         cleardown ();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 ,1 ));
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
//         steps.add(AAHStep.processInsurancePolicies);
//         runBasicTest(steps);
//         cleardown ();
//     }

// }