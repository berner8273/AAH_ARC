package com.aptitudesoftware.test.aah.tests.insurancepolicy;

import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
import com.aptitudesoftware.test.aah.AAHCleardownOperations;
import com.aptitudesoftware.test.aah.AAHExpectedResult;
import com.aptitudesoftware.test.aah.AAHResourceConstants;
import com.aptitudesoftware.test.aah.AAHResources;
import com.aptitudesoftware.test.aah.AAHSeedTable;
import com.aptitudesoftware.test.aah.AAHStep;
import com.aptitudesoftware.test.aah.AAHTablenameConstants;
import com.aptitudesoftware.test.aah.AAHTest;
// import com.aptitudesoftware.test.aah.AAHExecution;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.ArrayList;

import org.apache.log4j.Logger;
import org.testng.annotations.Test;

public class TestInsurancePolicyStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestInsurancePolicyStandardisation.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

    public void cleardown () throws Exception
	{		
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_RATE_TYPE_LOOKUP,"RTYL_LOOKUP_KEY not in ( '1','SPOT','FORWARD','MAVG')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_LOG_TEXT);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.LEGAL_ENTITY_LINK);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_TRADE, "T_FDR_TRAN_NO NOT IN ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK_LOOKUP, "BOL_LOOKUP_KEY NOT IN ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK, "BO_BOOK_CLICODE NOT IN ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INSTR_INSURE_EXTEND);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INT_PROC_ENTITY_LOOKUP, "IPEL_LOOKUP_KEY NOT IN ('NVS','DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INTERNAL_PROC_ENTITY, "IPE_ENTITY_CLIENT_CODE not in ('NVS' , 'DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ENTITY_SCHEMA);     
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS_LOOKUP,"PBL_SIL_SYS_INST_CLICODE not in ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS,"PBU_PARTY_BUS_CLIENT_CODE not in ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_TYPE, "PLT_PL_PARTY_LEGAL_ID <> '1'");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.SLR_BM_ENTITY_PROCESSING_SET);                
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NODE_STRUCTURE, "ONS_ON_CHILD_ORG_NODE_ID  != 1");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NETWORK, "ON_ORG_NODE_CLIENT_CODE not in ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP,"PLL_LOOKUP_KEY not in ( '1','NVS')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_TYPE,"PLT_PL_PARTY_LEGAL_ID !='1'");   
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL,"PL_PARTY_LEGAL_CLICODE not in ( '1','NVS')");                
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_LPG_CONFIG);                
        AAHCleardownOperations.clearTable(AAHTablenameConstants.SLR_ENTITIES);                
        AAHCleardownOperations.clearTable(AAHTablenameConstants.SLR_ENTITY_PERIODS);                
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
                "SeedData.xlsx"));
    
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData.xlsx"
                    ));
                   
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"));   
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"
                ));
    

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
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "GC_GCT_CODE_TYPE_ID in ('GL_CHARTFIELD','POLICY_TAX','JOURNAL_LINE','TAX_JURISDICTION') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));
        
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
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
                AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_LINK_ER,
                AAHResourceConstants.CESSION_LINK_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
                AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_ER,
                AAHResourceConstants.CESSION_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
                AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
                AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
    
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
            AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.INSURANCE_POLICY_ER,
            AAHResourceConstants.INSURANCE_POLICY_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
                AAHTablenameConstants.FR_STAN_RAW_INSURANCE_POLICY,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));
                
                ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
                    AAHTablenameConstants.FR_FX_RATE,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.FR_FX_RATE_ER,
                    AAHResourceConstants.FR_FX_RATE_AR));                    
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
            AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
            AAHTablenameConstants.FR_RATE_TYPE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_RATE_TYPE_ER,
            AAHResourceConstants.FR_RATE_TYPE_AR,
            "RTY_RATE_TYPE_ID not in ('1','SPOT','FORWARD','MAVG')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
            AAHTablenameConstants.FR_INSTRUMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTRUMENT_ER,
            AAHResourceConstants.FR_INSTRUMENT_AR,
            "I_INSTRUMENT_ID not in ('1','INSURANCE_POLICY')"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
            AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
            AAHTablenameConstants.FR_TRADE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_TRADE_ER,
            AAHResourceConstants.FR_TRADE_AR,
            "T_FDR_TRAN_NO not in ( 'DEFAULT' )"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
            AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
            AAHResourceConstants.FR_GENERAL_CODES_POLTJ_AR,
            "GC_GCT_CODE_TYPE_ID ='POLICY_TAX'"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
            AAHTablenameConstants.FR_LOG,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_LOG_ER,
            AAHResourceConstants.FR_LOG_AR));
            
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ));
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

        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        runBasicTest(steps);
        cleardown ();
    }

    @Test
    public void testValidations () throws Exception
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
                    new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData.xlsx"
                    ));
                   
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"));   
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"
                ));
    

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
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "GC_GCT_CODE_TYPE_ID not in ('GL_CHARTFIELD','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));
        
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
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
                AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_LINK_ER,
                AAHResourceConstants.CESSION_LINK_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
                AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_ER,
                AAHResourceConstants.CESSION_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
                AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
                AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
    
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
            AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.INSURANCE_POLICY_ER,
            AAHResourceConstants.INSURANCE_POLICY_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
                AAHTablenameConstants.FR_STAN_RAW_INSURANCE_POLICY,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));
                
                ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
                    AAHTablenameConstants.FR_FX_RATE,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.FR_FX_RATE_ER,
                    AAHResourceConstants.FR_FX_RATE_AR));                    
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
            AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
            AAHTablenameConstants.FR_RATE_TYPE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_RATE_TYPE_ER,
            AAHResourceConstants.FR_RATE_TYPE_AR,
            "RTY_RATE_TYPE_ID not in ('1','SPOT','FORWARD','MAVG')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
            AAHTablenameConstants.FR_INSTRUMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTRUMENT_ER,
            AAHResourceConstants.FR_INSTRUMENT_AR,
            "I_INSTRUMENT_ID not in ('1','INSURANCE_POLICY')"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
            AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
            AAHTablenameConstants.FR_TRADE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_TRADE_ER,
            AAHResourceConstants.FR_TRADE_AR,
            "T_FDR_TRAN_NO not in ( 'DEFAULT' )"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
            AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
            AAHResourceConstants.FR_GENERAL_CODES_POLTJ_AR,
            "GC_GCT_CODE_TYPE_ID ='POLICY_TAX'"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
            AAHTablenameConstants.FR_LOG,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_LOG_ER,
            AAHResourceConstants.FR_LOG_AR));
            
        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ));
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

        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
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
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"));
    
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData.xlsx"
                    ));
                   
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"));   
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx"
                ));
    

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
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "GC_GCT_CODE_TYPE_ID not in ('GL_CHARTFIELD','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));
        
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
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
                AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_LINK_ER,
                AAHResourceConstants.CESSION_LINK_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
                AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_ER,
                AAHResourceConstants.CESSION_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
                AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
                AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
    
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
            AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.INSURANCE_POLICY_ER,
            AAHResourceConstants.INSURANCE_POLICY_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
                AAHTablenameConstants.FR_STAN_RAW_INSURANCE_POLICY,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));
                
                ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
                    AAHTablenameConstants.FR_FX_RATE,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.FR_FX_RATE_ER,
                    AAHResourceConstants.FR_FX_RATE_AR));                    
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
            AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
            AAHTablenameConstants.FR_RATE_TYPE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_RATE_TYPE_ER,
            AAHResourceConstants.FR_RATE_TYPE_AR,
            "RTY_RATE_TYPE_ID not in ('1','SPOT','FORWARD','MAVG')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
            AAHTablenameConstants.FR_INSTRUMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTRUMENT_ER,
            AAHResourceConstants.FR_INSTRUMENT_AR,
            "I_INSTRUMENT_ID not in ('1','INSURANCE_POLICY')"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
            AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
            AAHTablenameConstants.FR_TRADE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_TRADE_ER,
            AAHResourceConstants.FR_TRADE_AR,
            "T_FDR_TRAN_NO not in ( 'DEFAULT' )"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
            AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
            AAHResourceConstants.FR_GENERAL_CODES_POLTJ_AR,
            "GC_GCT_CODE_TYPE_ID ='POLICY_TAX'"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
            AAHTablenameConstants.FR_LOG,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_LOG_ER,
            AAHResourceConstants.FR_LOG_AR));
            
        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ));
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

        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);

        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }
        compareResults();
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
            "SeedData-Day1.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day1.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day1.xlsx"));
    
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-Day1.xlsx"
                    ));
                   
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day1.xlsx"));   
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day1.xlsx"
                ));
    
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day1.xlsx"
                ));
            
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day1.xlsx"));
       
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day1.xlsx",
            "GC_GCT_CODE_TYPE_ID not in ('GL_CHARTFIELD','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));
        
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
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION_LINK,
                AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_LINK_ER,
                AAHResourceConstants.CESSION_LINK_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_CESSION,
                AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.CESSION_ER,
                AAHResourceConstants.CESSION_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_FX_RATE,
                AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_ER,
                AAHResourceConstants.INSURANCE_POLICY_FX_RATE_AR));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY_TAX_JURISD,
                AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_ER,
                AAHResourceConstants.INSURANCE_POLICY_TAX_JURISD_AR));
    
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_INSURANCE_POLICY,
            AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.INSURANCE_POLICY_ER,
            AAHResourceConstants.INSURANCE_POLICY_AR));

            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_HOPPER_INSURANCE_POLICY,
                AAHTablenameConstants.FR_STAN_RAW_INSURANCE_POLICY,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_ER,
                AAHResourceConstants.HOPPER_INSURANCE_POLICY_AR));
                
                ER_TABLES.add(
                    new AAHExpectedResult(AAHTablenameConstants.ER_FR_FX_RATE,
                    AAHTablenameConstants.FR_FX_RATE,
                    PATH_TO_TEST_RESOURCES,
                    "ExpectedResults.xlsx",
                    AAHResourceConstants.FR_FX_RATE_ER,
                    AAHResourceConstants.FR_FX_RATE_AR));                    
        
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_STAN_RAW_FX_RATE,
            AAHTablenameConstants.FR_STAN_RAW_FX_RATE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_ER,
            AAHResourceConstants.FR_STAN_RAW_FX_RATE_AR));
    	
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_RATE_TYPE,
            AAHTablenameConstants.FR_RATE_TYPE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_RATE_TYPE_ER,
            AAHResourceConstants.FR_RATE_TYPE_AR,
            "RTY_RATE_TYPE_ID not in ('1','SPOT','FORWARD','MAVG')"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTRUMENT,
            AAHTablenameConstants.FR_INSTRUMENT,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTRUMENT_ER,
            AAHResourceConstants.FR_INSTRUMENT_AR,
            "I_INSTRUMENT_ID not in ('1','INSURANCE_POLICY')"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_INSTR_INSURE_EXTEND,
            AAHTablenameConstants.FR_INSTR_INSURE_EXTEND,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_ER,
            AAHResourceConstants.FR_INSTR_INSURE_EXTEND_AR));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_TRADE,
            AAHTablenameConstants.FR_TRADE,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_TRADE_ER,
            AAHResourceConstants.FR_TRADE_AR,
            "T_FDR_TRAN_NO not in ( 'DEFAULT' )"));
            
        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_POLICY_TAX_JURISDICTION,
            AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_POLICY_TAX_JURISDICTION_ER,
            AAHResourceConstants.FR_GENERAL_CODES_POLTJ_AR,
            "GC_GCT_CODE_TYPE_ID ='POLICY_TAX'"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_LOG,
            AAHTablenameConstants.FR_LOG,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_LOG_ER,
            AAHResourceConstants.FR_LOG_AR));

        cleardown ();
        setupTest();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 ,1 ));
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
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
			
        for (AAHStep pStep : steps) {
        	runStep(pStep.getName());
        }
        SEED_TABLES.clear();

        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day2.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day2.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day2.xlsx"));
    
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-Day2.xlsx"
                    ));
                   
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day2.xlsx"));   
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day2.xlsx"
                ));
    
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day2.xlsx"
                ));
            
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day2.xlsx"));
       
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day2.xlsx",
            "GC_GCT_CODE_TYPE_ID not in ('GL_CHARTFIELD','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));

            setupTest();
            for (AAHStep pStep : steps) {
                runStep(pStep.getName());
            }
        
        SEED_TABLES.clear();
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day3.xlsx"
            ));
        
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FEED_RECORD_COUNT,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day3.xlsx"));

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day3.xlsx"));
    
                SEED_TABLES.add(
                    new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
                    PATH_TO_TEST_RESOURCES,
                    "SeedData-Day3.xlsx"
                    ));
                   
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day3.xlsx"));   
        
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day3.xlsx"
                ));
    
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day3.xlsx"
                ));
            
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                PATH_TO_TEST_RESOURCES,
                "SeedData-Day3.xlsx"));
       
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "SeedData-Day3.xlsx",
            "GC_GCT_CODE_TYPE_ID not in ('GL_CHARTFIELD','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));

            setupTest();
            for (AAHStep pStep : steps) {
                runStep(pStep.getName());
            }
    
            compareResults();
            cleardown ();

    }        
        
        
    @Test
    public void testProcessOnly () throws Exception
    {
        //edit this line
        final String TEST_NAME              = "testProcessOnly";
        
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
            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx"
            ));
           
    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"));   

    SEED_TABLES.add(
        new AAHSeedTable( AAHTablenameConstants.CESSION_LINK,
        PATH_TO_TEST_RESOURCES,
        "SeedData.xlsx"
        ));


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
    new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_CODES,
    PATH_TO_TEST_RESOURCES,
    "SeedData.xlsx",
    "GC_GCT_CODE_TYPE_ID not in ('GL_CHARTFIELD','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));


        cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 ,1 ));
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

        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
      runBasicTest(steps);
        cleardown ();
    }

 }