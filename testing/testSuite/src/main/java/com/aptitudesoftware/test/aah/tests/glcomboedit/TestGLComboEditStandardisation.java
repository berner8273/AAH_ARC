package com.aptitudesoftware.test.aah.tests.glcomboedit;

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

    public void cleardown () throws Exception
    {		
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_STAN_RAW_FX_RATE);	
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_FX_RATE);	
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_RATE_TYPE_LOOKUP,"RTYL_LOOKUP_KEY not in ( '1','SPOT','FORWARD','MAVG')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_RATE_TYPE,"RTY_RATE_TYPE_ID not in ( '1','SPOT','FORWARD','MAVG')");    
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_TRADE, "T_FDR_TRAN_NO NOT IN ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_CONTRACT_PARTY, "CPA_CON_CONTRACT_ID != 1");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK_LOOKUP, "BOL_LOOKUP_KEY != 'DEFAULT'");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_BOOK, "BO_BOOK_CLICODE != 'DEFAULT'");        
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INSTR_INSURE_EXTEND);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INT_PROC_ENTITY_LOOKUP, "IPEL_LOOKUP_KEY NOT IN ('NVS','DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_INTERNAL_PROC_ENTITY, "IPE_ENTITY_CLIENT_CODE not in ('NVS' , 'DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ENTITY_SCHEMA);     
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NODE_STRUCTURE, "ONS_ON_CHILD_ORG_NODE_ID  != 1");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_ORG_NETWORK, "ON_ORG_NODE_CLIENT_CODE not in ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_LOOKUP, "PLL_LOOKUP_KEY not in ('1','NVS')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.LEGAL_ENTITY_LINK);
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS_LOOKUP,"PBL_SIL_SYS_INST_CLICODE not in ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_BUSINESS,"PBU_PARTY_BUS_CLIENT_CODE not in ('DEFAULT')");
        AAHCleardownOperations.clearTable(AAHTablenameConstants.FR_PARTY_LEGAL_TYPE, "PLT_PL_PARTY_LEGAL_ID <> '1'");
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
            "SeedData.xlsx",
            "PL_PARTY_LEGAL_CLICODE not in ('1','NVS')"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

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
            AAHTablenameConstants.FR_STAN_RAW_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR,
            "SRGC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_CODES_GCE,
            AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_CODES_GCE_ER,
            AAHResourceConstants.FR_GENERAL_CODES_GCE_AR,
            "GC_GCT_CODE_TYPE_ID NOT IN ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));

      	cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9,8 ) , 1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        steps.add(AAHStep.StandardiseGLComboEdit);
        steps.add(AAHStep.DSRGLComboEdit);
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
                "SeedData.xlsx",
                "PL_PARTY_LEGAL_CLICODE not in ('1','NVS')"));
                
            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
                PATH_TO_TEST_RESOURCES,
                "SeedData.xlsx",
                "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));
    
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
                AAHTablenameConstants.FR_STAN_RAW_GENERAL_CODES,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
                AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR,
                "SRGC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));
    
            ER_TABLES.add(
                new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_CODES_GCE,
                AAHTablenameConstants.FR_GENERAL_CODES,
                PATH_TO_TEST_RESOURCES,
                "ExpectedResults.xlsx",
                AAHResourceConstants.FR_GENERAL_CODES_GCE_ER,
                AAHResourceConstants.FR_GENERAL_CODES_GCE_AR,
                "GC_GCT_CODE_TYPE_ID NOT IN ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));
            
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
        steps.add(AAHStep.StandardiseGLComboEdit);
        steps.add(AAHStep.DSRGLComboEdit);
        steps.add(AAHStep.StandardiseFXRates);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.StandardiseDepartments);
        steps.add(AAHStep.DSRDepartments);
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
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseTaxJurisdiction);
        steps.add(AAHStep.DSRTaxJurisdiction);                
        steps.add(AAHStep.StandardiseGLChartfields);
        steps.add(AAHStep.DSRGLChartfields);
        steps.add(AAHStep.StandardiseInsurancePolicies);
        steps.add(AAHStep.DSRInsurancePolicies);
        steps.add(AAHStep.DSRFXRates);
        steps.add(AAHStep.DSRPolicyTaxJurisdictions);
        steps.add(AAHStep.StandardiseJournalLine);
        steps.add(AAHStep.DSRJournalLine);
        steps.add(AAHStep.SLRUpdateDaysPeriods);
        steps.add(AAHStep.SLRAccounts);
        steps.add(AAHStep.SLRFXRates);
        steps.add(AAHStep.SLRUpdateCurrencies);
        steps.add(AAHStep.SLRUpdateFakSeg3);
        steps.add(AAHStep.SLRUpdateFakSeg4);
        steps.add(AAHStep.SLRUpdateFakSeg5);
        steps.add(AAHStep.SLRUpdateFakSeg6);
        steps.add(AAHStep.SLRUpdateFakSeg7);
        steps.add(AAHStep.SLRUpdateFakSeg8);
        steps.add(AAHStep.SLRpUpdateJLU);
        steps.add(AAHStep.SLRpProcess);                
        
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
            "SeedData.xlsx",
            "PL_PARTY_LEGAL_CLICODE not in ('1','NVS')"));
            
        SEED_TABLES.add(
            new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
            PATH_TO_TEST_RESOURCES,
            "SeedData.xlsx",
            "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

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
            AAHTablenameConstants.FR_STAN_RAW_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
            AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR,
            "SRGC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_CODES_GCE,
            AAHTablenameConstants.FR_GENERAL_CODES,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.FR_GENERAL_CODES_GCE_ER,
            AAHResourceConstants.FR_GENERAL_CODES_GCE_AR,
            "GC_GCT_CODE_TYPE_ID NOT IN ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));
    	
       	cleardown ();
        AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9,8 ),1 );
        ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

        //list steps to run here
        steps.add(AAHStep.StandardiseGLAccounts);
        steps.add(AAHStep.DSRGLAccounts);
        steps.add(AAHStep.StandardiseLedgers);
        steps.add(AAHStep.DSRLedgers);
        steps.add(AAHStep.StandardiseGLComboEdit);
        steps.add(AAHStep.DSRGLComboEdit);
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
    "SeedData.xlsx",
    "PL_PARTY_LEGAL_CLICODE not in ('1','NVS')"));
    
SEED_TABLES.add(
    new AAHSeedTable( AAHTablenameConstants.FR_GENERAL_LOOKUP,
    PATH_TO_TEST_RESOURCES,
    "SeedData.xlsx",
    "LK_LKT_LOOKUP_TYPE_CODE IN ('ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET')"));

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
    AAHTablenameConstants.FR_STAN_RAW_GENERAL_CODES,
    PATH_TO_TEST_RESOURCES,
    "ExpectedResults.xlsx",
    AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_ER,
    AAHResourceConstants.HOPPER_GL_COMBO_EDIT_GC_AR,
    "SRGC_GCT_CODE_TYPE_ID LIKE 'COMBO%'"));

ER_TABLES.add(
    new AAHExpectedResult(AAHTablenameConstants.ER_FR_GENERAL_CODES_GCE,
    AAHTablenameConstants.FR_GENERAL_CODES,
    PATH_TO_TEST_RESOURCES,
    "ExpectedResults.xlsx",
    AAHResourceConstants.FR_GENERAL_CODES_GCE_ER,
    AAHResourceConstants.FR_GENERAL_CODES_GCE_AR,
    "GC_GCT_CODE_TYPE_ID NOT IN ('GL_CHARTFIELD','TAX_JURISDICTION','POLICY_TAX','JOURNAL_LINE') AND GC_GCT_CODE_TYPE_ID NOT LIKE 'COMBO%'"));

   cleardown ();
AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 9,8 ),1 );
ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();

//list steps to run here
steps.add(AAHStep.StandardiseGLAccounts);
steps.add(AAHStep.DSRGLAccounts);
steps.add(AAHStep.StandardiseLedgers);
steps.add(AAHStep.DSRLedgers);
steps.add(AAHStep.StandardiseGLComboEdit);
steps.add(AAHStep.DSRGLComboEdit);
steps.add(AAHStep.StandardiseGLComboEdit);
steps.add(AAHStep.DSRGLComboEdit);
runBasicTest(steps);
cleardown ();  }
    }