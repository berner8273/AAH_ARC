package com.aptitudesoftware.test.aah.tests.allstn;

import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
import com.aptitudesoftware.test.aah.AAHCleardownOperations;
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

public class TestAllStandardisation extends AAHTest
{
    private static final Logger LOG = Logger.getLogger ( TestAllStandardisation.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

    public void cleardown () throws Exception
    {	
       AAHCleardownOperations.clearTable(AAHTablenameConstants.BROKEN_FEED);	
        super.cleardown();
    }

    @Test
    public void testSingleValidFeed() throws Exception
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

            SEED_TABLES.add(
                new AAHSeedTable( AAHTablenameConstants.FX_RATE,
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
                        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY,
                        PATH_TO_TEST_RESOURCES,
                        "SeedData.xlsx"));

                    SEED_TABLES.add(
                        new AAHSeedTable( AAHTablenameConstants.LEGAL_ENTITY_LINK,
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
                            new AAHSeedTable( AAHTablenameConstants.FR_INSTRUMENT_LOOKUP,
                            PATH_TO_TEST_RESOURCES,
                            "SeedData.xlsx"));
                                            
                        SEED_TABLES.add(
                            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD,
                            PATH_TO_TEST_RESOURCES,
                            "SeedData.xlsx"));
                    
                        SEED_TABLES.add(
                            new AAHSeedTable( AAHTablenameConstants.INSURANCE_POLICY_FX_RATE,
                            PATH_TO_TEST_RESOURCES,
                            "SeedData.xlsx"
                            ));

                        SEED_TABLES.add(
                            new AAHSeedTable( AAHTablenameConstants.JOURNAL_LINE,
                            PATH_TO_TEST_RESOURCES,
                            "SeedData.xlsx"
                            ));

                        SEED_TABLES.add(
                            new AAHSeedTable( AAHTablenameConstants.SLR_ENTITY_PERIODS,
                            PATH_TO_TEST_RESOURCES,
                            "SeedData.xlsx"
                            ));

                        SEED_TABLES.add(
                            new AAHSeedTable( AAHTablenameConstants.SLR_ENTITY_PROC_GROUP,
                           PATH_TO_TEST_RESOURCES,
                            "SeedData.xlsx"
                            ));

                   cleardown ();
                   AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ) );
                   ArrayList<AAHStep> steps = new ArrayList<AAHStep> ();                   
                   steps.add(AAHStep.StandardiseDepartments);
                   steps.add(AAHStep.DSRDepartments);
                   steps.add(AAHStep.StandardiseFXRates);
                   steps.add(AAHStep.DSRFXRates);
                   steps.add(AAHStep.StandardiseGLAccounts);
                   steps.add(AAHStep.DSRGLAccounts);
                   steps.add(AAHStep.StandardiseGLChartfields);
                   steps.add(AAHStep.DSRGLChartfields);
                   steps.add(AAHStep.StandardiseTaxJurisdiction);
                   steps.add(AAHStep.DSRTaxJurisdiction);
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
                   steps.add(AAHStep.StandardiseLedgers);
                   steps.add(AAHStep.DSRLedgers);
                   steps.add(AAHStep.StandardiseGLComboEdit);
                   steps.add(AAHStep.DSRGLComboEdit);
                   steps.add(AAHStep.StandardiseInsurancePolicies);
                   steps.add(AAHStep.DSRInsurancePolicies);
                   steps.add(AAHStep.DSRFXRates);
                   steps.add(AAHStep.DSRPolicyTaxJurisdictions);
                   steps.add(AAHStep.StandardiseEventHierarchy);
                   steps.add(AAHStep.DSREventHierarchy);
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
                   steps.add(AAHStep.StandardiseJournalLine);
                   steps.add(AAHStep.DSRJournalLine);
                   runBasicTest(steps);
              cleardown ();
              }
            }          