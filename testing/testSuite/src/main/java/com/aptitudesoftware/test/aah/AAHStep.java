package com.aptitudesoftware.test.aah;

public enum AAHStep
{
        DSREventHierarchy              ( "DSREventHierarchy" )
    ,   DSRCessionEvents               ( "DSRCessionEvents" )
    ,   DSRDepartments                 ( "DSRDepartments" )
    ,   DSRFXRates                     ( "DSRFXRates" )
    ,   DSRGLAccounts                  ( "DSRGLAccounts" )
    ,   DSRGLChartfields               ( "DSRGLChartfields" )
    ,   DSRGLComboEdit                 ( "DSRGLComboEdit" )
    ,   DSRInsurancePolicies           ( "DSRInsurancePolicies" )
    ,   DSRInternalProcessEntities     ( "DSRInternalProcessEntities" )
    ,   DSRLedgers                     ( "DSRLedgers" )
    ,   DSRLegalEntities               ( "DSRLegalEntities" )
    ,   DSRLegalEntityHierarchyData    ( "DSRLegalEntityHierarchyData" )
    ,   DSRLegalEntityHierLinks        ( "DSRLegalEntityHierLinks" )
    ,   DSRLegalEntityHierNodes        ( "DSRLegalEntityHierNodes" )
    ,   DSRLegalEntitySupplementalData ( "DSRLegalEntitySupplementalData" )
    ,   DSRPartyBusiness               ( "DSRPartyBusiness" )
    ,   DSRPolicyTaxJurisdictions      ( "DSRPolicyTaxJurisdictions" )
    ,   DSRTaxJurisdiction             ( "DSRTaxJurisdiction" )
    ,   DSRJournalLine                 ( "DSRJournalLine" )
    ,   FXReval                        ( "FXReval" )	
    ,   GLINTExtract                   ( "GLINTExtract" )
    ,   StandardiseEventHierarchy      ( "StandardiseEventHierarchy" )
    ,   StandardiseCessionEvents       ( "StandardiseCessionEvents" )
    ,   StandardiseDepartments         ( "StandardiseDepartments" )
    ,   StandardiseFXRates             ( "StandardiseFXRates" )
    ,   StandardiseGLAccounts          ( "StandardiseGLAccounts" )
    ,   StandardiseGLChartfields       ( "StandardiseGLChartfields" )
    ,   StandardiseGLComboEdit         ( "StandardiseGLComboEdit" )
    ,   StandardiseInsurancePolicies   ( "StandardiseInsurancePolicies" )
    ,   StandardiseLedgers             ( "StandardiseLedgers" )
    ,   StandardiseLegalEntities       ( "StandardiseLegalEntities" )
    ,   StandardiseLegalEntityLinks    ( "StandardiseLegalEntityLinks" )
    ,   StandardiseTaxJurisdiction     ( "StandardiseTaxJurisdiction" )
    ,   StandardiseJournalLine         ( "StandardiseJournalLine" )
    ,   StandardiseUser                ( "StandardiseUser" )
    ,   SLRUpdateDaysPeriods           ( "SLRUpdateDaysPeriods" )
    ,   SLRAccounts                    ( "SLRAccounts" )
    ,   SLRFXRates                     ( "SLRFXRates" )
    ,   SLRUpdateCurrencies            ( "SLRUpdateCurrencies" )
    ,   SLRUpdateFakSeg3               ( "SLRUpdateFakSeg3" )
    ,   SLRUpdateFakSeg4               ( "SLRUpdateFakSeg4" )
    ,   SLRUpdateFakSeg5               ( "SLRUpdateFakSeg5" )
    ,   SLRUpdateFakSeg6               ( "SLRUpdateFakSeg6" )
    ,   SLRUpdateFakSeg7               ( "SLRUpdateFakSeg7" )
    ,   SLRUpdateFakSeg8               ( "SLRUpdateFakSeg8" )
    ,   SLRpUpdateJLU                  ( "SLRpUpdateJLU" )
    ,   SLRpProcess                    ( "SLRpProcess" )
    ,   RollDates                      ( "RollDates" )
    ,   AutoResubmitTransactions       ("AutoResubmitTransactions")
    ,   CheckResubmittedErrors         ("CheckResubmittedErrors")
    ,   pYECleardown					         ("pYECleardown")
    ;

    private String name;

    AAHStep ( final String pName )
    {
        this.name = pName;
    }

    public String getName ()
    {
        return name;
    }
}