package com.aptitudesoftware.test.aah.tests.legalentity;

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

public class TestLegalEntityStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestLegalEntityStandardisation.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

    public void cleardown () throws Exception
	{		
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_CONTRACT_PARTY, "CPA_CON_CONTRACT_ID <> 1");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INT_PROC_ENTITY_LOOKUP, "IPEL_LOOKUP_KEY NOT IN ('NVS','DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ENTITY_SCHEMA);        
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY not in ('1','NVS')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.LEGAL_ENTITY_LINK);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS_LOOKUP);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_TYPE, "PLT_PL_PARTY_LEGAL_ID <> '1'");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK_LOOKUP, "BOL_LOOKUP_KEY != 'DEFAULT'");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK, "BO_BOOK_CLICODE != 'DEFAULT'");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.SLR_BM_ENTITY_PROCESSING_SET);                
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
            "SeedData.xlsx"
            ));
     
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY,
            AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.LEGAL_ENTITY_ER,
            AAHResourceConstants.LEGAL_ENTITY_AR));
 	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY_LINK,
            AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.LEGAL_ENTITY_LINK_ER,
            AAHResourceConstants.LEGAL_ENTITY_LINK_AR));


        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_PARTY_BUSINESS,
            AAHTablenameConstants.FR_PARTY_BUSINESS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_PARTY_BUSINESS_ER,
            AAHResourceConstants.FR_STAN_RAW_PARTY_BUSINESS_AR,
            "PBU_PARTY_BUS_CLIENT_CODE not in ('DEFAULT')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_PARTY_BUSINESS,
            AAHTablenameConstants.FR_PARTY_BUSINESS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_PARTY_BUSINESS_ER,
            AAHResourceConstants.FR_PARTY_BUSINESS_AR,
            "PBU_PARTY_BUS_CLIENT_CODE not in ('DEFAULT')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_INT_ENTITY,
            AAHTablenameConstants.FR_STAN_RAW_INT_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_INT_ENTITY_ER,
            AAHResourceConstants.FR_STAN_RAW_INT_ENTITY_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_FR_INTERNAL_PROC_ENTITY,
                AAHTablenameConstants.FR_INTERNAL_PROC_ENTITY,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.FR_INTERNAL_PROC_ENTITY_ER,
                AAHResourceConstants.FR_INTERNAL_PROC_ENTITY_AR,
                "IPE_ENTITY_CLIENT_CODE  not in ('NVS' , 'DEFAULT')"));       

                ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_FR_ORG_NODE_STRUCTURE,
                    AAHTablenameConstants.FR_ORG_NODE_STRUCTURE,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.FR_ORG_NODE_STRUCTURE_ER,
                    AAHResourceConstants.FR_ORG_NODE_STRUCTURE_AR,
                    "ONS_ON_CHILD_ORG_NODE_ID != 1"));

                ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_FR_ORG_NETWORK,
                    AAHTablenameConstants.FR_ORG_NETWORK,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.FR_ORG_NETWORK_ER,
                    AAHResourceConstants.FR_ORG_NETWORK_AR,
                    "ON_ORG_NODE_CLIENT_CODE not in ('DEFAULT')"));
               

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_PARTY_LEGAL,
                AAHTablenameConstants.FR_PARTY_LEGAL,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.FR_STAN_RAW_PARTY_LEGAL_ER,
                AAHResourceConstants.FR_STAN_RAW_PARTY_LEGAL_AR,
                "PL_PARTY_LEGAL_CLICODE    not in ('1','NVS')"));
    
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_FR_PARTY_LEGAL,
                AAHTablenameConstants.FR_PARTY_LEGAL,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.FR_PARTY_LEGAL_ER,
                AAHResourceConstants.FR_PARTY_LEGAL_AR,
                "PL_PARTY_LEGAL_CLICODE    not in ('1','NVS')"));
                

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_ORG_HIER_NODE,
            AAHTablenameConstants.FR_STAN_RAW_ORG_HIER_NODE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_ORG_HIER_NODE_ER,
            AAHResourceConstants.FR_STAN_RAW_ORG_HIER_NODE_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_ORG_HIER_STRUC,
            AAHTablenameConstants.FR_STAN_RAW_ORG_HIER_STRUC,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_ORG_HIER_STRUC_ER,
            AAHResourceConstants.FR_STAN_RAW_ORG_HIER_STRUC_AR));


        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_LEGAL_ENTITY_ALIAS,
            AAHTablenameConstants.HOPPER_LEGAL_ENTITY_ALIAS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_LEGAL_ENTITY_ALIAS_ER,
            AAHResourceConstants.HOPPER_LEGAL_ENTITY_ALIAS_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_LOOKUP_LEA,
            AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEA_ER,
            AAHResourceConstants.FR_GENERAL_LOOKUP_LEA_AR,
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_LPG_CONFIG,
            AAHTablenameConstants.FR_LPG_CONFIG,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_LPG_CONFIG_ER,
            AAHResourceConstants.FR_LPG_CONFIG_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITIES,
            AAHTablenameConstants.SLR_ENTITIES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_ENTITIES_ER,
            AAHResourceConstants.SLR_ENTITIES_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DEFINITIONS,
            AAHTablenameConstants.SLR_EBA_DEFINITIONS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_EBA_DEFINITIONS_ER,
            AAHResourceConstants.SLR_EBA_DEFINITIONS_AR));
         
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DEFINITIONS,
            AAHTablenameConstants.SLR_FAK_DEFINITIONS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_FAK_DEFINITIONS_ER,
            AAHResourceConstants.SLR_FAK_DEFINITIONS_AR));                        

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITY_GRACE_DAYS,
            AAHTablenameConstants.SLR_ENTITY_GRACE_DAYS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_ENTITY_GRACE_DAYS_ER,
            AAHResourceConstants.SLR_ENTITY_GRACE_DAYS_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITY_PROC_GROUP,
            AAHTablenameConstants.SLR_ENTITY_PROC_GROUP,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.SLR_ENTITY_PROC_GROUP_ER,
            AAHResourceConstants.SLR_ENTITY_PROC_GROUP_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_ELIMINATION_LEGAL_ENTITY,
            AAHTablenameConstants.ELIMINATION_LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.ELIMINATION_LEGAL_ENTITY_ER,
            AAHResourceConstants.ELIMINATION_LEGAL_ENTITY_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_VIE_LEGAL_ENTITY,
            AAHTablenameConstants.VIE_LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.VIE_LEGAL_ENTITY_ER,
            AAHResourceConstants.VIE_LEGAL_ENTITY_AR));

         
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        runBasicTest(steps);
        cleardown ();
    }

//     @Test
//     public void testValidations () throws Exception
//     {
    	
//       //edit this line
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
//             new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY,
//             AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.LEGAL_ENTITY_ER,
//             AAHResourceConstants.LEGAL_ENTITY_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY_LINK,
//             AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.LEGAL_ENTITY_LINK_ER,
//             AAHResourceConstants.LEGAL_ENTITY_LINK_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_PARTY_LEGAL,
//             AAHTablenameConstants.FR_STAN_RAW_PARTY_LEGAL,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_PARTY_LEGAL_ER,
//             AAHResourceConstants.FR_STAN_RAW_PARTY_LEGAL_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_ORG_HIER_STRUC,
//             AAHTablenameConstants.FR_STAN_RAW_ORG_HIER_STRUC,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_ORG_HIER_STRUC_ER,
//             AAHResourceConstants.FR_STAN_RAW_ORG_HIER_STRUC_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_LEGAL_ENTITY_ALIAS,
//             AAHTablenameConstants.HOPPER_LEGAL_ENTITY_ALIAS,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_LEGAL_ENTITY_ALIAS_ER,
//             AAHResourceConstants.HOPPER_LEGAL_ENTITY_ALIAS_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
//             AAHTablenameConstants.FR_LOG,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_LOG_ER,
//             AAHResourceConstants.FR_LOG_AR));

//         cleardown ();
//         setupTest();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ) );
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
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

// 	      setupTest();
//         steps.add(AAHStep.processLegalEntities);
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         compareResults();
//         cleardown ();
//     }
// }          


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
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
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
            new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY,
            AAHTablenameConstants.LEGAL_ENTITY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.LEGAL_ENTITY_ER,
            AAHResourceConstants.LEGAL_ENTITY_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY_LINK,
            AAHTablenameConstants.LEGAL_ENTITY_LINK,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.LEGAL_ENTITY_LINK_ER,
            AAHResourceConstants.LEGAL_ENTITY_LINK_AR));

        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ) );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseLegalEntities);
        steps.add(AAHStep.DSRLegalEntities);
        steps.add(AAHStep.DSRPartyBusiness);
        steps.add(AAHStep.DSRInternalProcessEntities);
        steps.add(AAHStep.DSRDepartments);
        steps.add(AAHStep.DSRLegalEntityHierNodes);
        steps.add(AAHStep.StandardiseLegalEntityLinks);
        steps.add(AAHStep.DSRLegalEntityHierLinks);
        steps.add(AAHStep.DSRLegalEntitySupplementalData);
        steps.add(AAHStep.DSRLegalEntityHierarchyData);
        steps.add(AAHStep.SLRUpdateDaysPeriods);

        runBasicTest(steps);
        cleardown ();
    }


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
        

//         //Setup arrays here

//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day1.xlsx"
//             //,"FEED_ID = -2"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day1.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day1.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day1.xlsx"));
        
        
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
//             new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY,
//             AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.LEGAL_ENTITY_ER,
//             AAHResourceConstants.LEGAL_ENTITY_AR));
    	
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_LEGAL_ENTITY_LINK,
//             AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.LEGAL_ENTITY_LINK_ER,
//             AAHResourceConstants.LEGAL_ENTITY_LINK_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_PARTY_LEGAL,
//             AAHTablenameConstants.FR_STAN_RAW_PARTY_LEGAL,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_PARTY_LEGAL_ER,
//             AAHResourceConstants.FR_STAN_RAW_PARTY_LEGAL_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_PARTY_LEGAL,
//             AAHTablenameConstants.FR_PARTY_LEGAL,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_PARTY_LEGAL_ER,
//             AAHResourceConstants.FR_PARTY_LEGAL_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_PARTY_BUSINESS,
//             AAHTablenameConstants.FR_STAN_RAW_PARTY_BUSINESS,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_PARTY_BUSINESS_ER,
//             AAHResourceConstants.FR_STAN_RAW_PARTY_BUSINESS_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_PARTY_BUSINESS,
//             AAHTablenameConstants.FR_PARTY_BUSINESS,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_PARTY_BUSINESS_ER,
//             AAHResourceConstants.FR_PARTY_BUSINESS_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_INT_ENTITY,
//             AAHTablenameConstants.FR_STAN_RAW_INT_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_INT_ENTITY_ER,
//             AAHResourceConstants.FR_STAN_RAW_INT_ENTITY_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_INTERNAL_PROC_ENTITY,
//             AAHTablenameConstants.FR_INTERNAL_PROC_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_INTERNAL_PROC_ENTITY_ER,
//             AAHResourceConstants.FR_INTERNAL_PROC_ENTITY_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_ORG_HIER_NODE,
//             AAHTablenameConstants.FR_STAN_RAW_ORG_HIER_NODE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_ORG_HIER_NODE_ER,
//             AAHResourceConstants.FR_STAN_RAW_ORG_HIER_NODE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_ORG_HIER_STRUC,
//             AAHTablenameConstants.FR_STAN_RAW_ORG_HIER_STRUC,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_STAN_RAW_ORG_HIER_STRUC_ER,
//             AAHResourceConstants.FR_STAN_RAW_ORG_HIER_STRUC_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ORG_NETWORK,
//             AAHTablenameConstants.FR_ORG_NETWORK,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ORG_NETWORK_ER,
//             AAHResourceConstants.FR_ORG_NETWORK_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_ORG_NODE_STRUCTURE,
//             AAHTablenameConstants.FR_ORG_NODE_STRUCTURE,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_ORG_NODE_STRUCTURE_ER,
//             AAHResourceConstants.FR_ORG_NODE_STRUCTURE_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_LEGAL_ENTITY_ALIAS,
//             AAHTablenameConstants.HOPPER_LEGAL_ENTITY_ALIAS,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.HOPPER_LEGAL_ENTITY_ALIAS_ER,
//             AAHResourceConstants.HOPPER_LEGAL_ENTITY_ALIAS_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_LOOKUP_LEA,
//             AAHTablenameConstants.FR_GENERAL_LOOKUP_LEA,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_GENERAL_LOOKUP_LEA_ER,
//             AAHResourceConstants.FR_GENERAL_LOOKUP_LEA_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_FR_LPG_CONFIG,
//             AAHTablenameConstants.FR_LPG_CONFIG,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.FR_LPG_CONFIG_ER,
//             AAHResourceConstants.FR_LPG_CONFIG_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITIES,
//             AAHTablenameConstants.SLR_ENTITIES,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_ENTITIES_ER,
//             AAHResourceConstants.SLR_ENTITIES_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_EBA_DEFINITIONS,
//             AAHTablenameConstants.SLR_EBA_DEFINITIONS,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_EBA_DEFINITIONS_ER,
//             AAHResourceConstants.SLR_EBA_DEFINITIONS_AR));
            
//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_FAK_DEFINITIONS,
//             AAHTablenameConstants.SLR_FAK_DEFINITIONS,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_FAK_DEFINITIONS_ER,
//             AAHResourceConstants.SLR_FAK_DEFINITIONS_AR));                        

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITY_GRACE_DAYS,
//             AAHTablenameConstants.SLR_ENTITY_GRACE_DAYS,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_ENTITY_GRACE_DAYS_ER,
//             AAHResourceConstants.SLR_ENTITY_GRACE_DAYS_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_SLR_ENTITY_PROC_GROUP,
//             AAHTablenameConstants.SLR_ENTITY_PROC_GROUP,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.SLR_ENTITY_PROC_GROUP_ER,
//             AAHResourceConstants.SLR_ENTITY_PROC_GROUP_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_ELIMINATION_LEGAL_ENTITY,
//             AAHTablenameConstants.ELIMINATION_LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.ELIMINATION_LEGAL_ENTITY_ER,
//             AAHResourceConstants.ELIMINATION_LEGAL_ENTITY_AR));

//         ER_TABLES.add(
//             new AAHExpectedResult(AAHTablenameConstants.ER_VIE_LEGAL_ENTITY,
//             AAHTablenameConstants.VIE_LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "ExpectedResults.xlsx",
//             AAHResourceConstants.VIE_LEGAL_ENTITY_ER,
//             AAHResourceConstants.VIE_LEGAL_ENTITY_AR));

//         cleardown ();
//         setupTest();
//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ));
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day2.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day2.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day2.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day2.xlsx"));
        
//         setupTest();
//         ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();
//         //list steps to run here
//         steps.add(AAHStep.processLegalEntities);
//         for (AAHStep pStep : steps) {
//         	runStep(pStep.getName());
//         }
//         SEED_TABLES.clear();
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day3.xlsx"
//             ));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day3.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day3.xlsx"));
        
//         SEED_TABLES.add(
//             new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
//             PATH_TO_TEST_RESOURCES,
//             "SeedData-Day3.xlsx"));

//         compareResults();

//         cleardown ();
//     }
 }