package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.ITablename;

public enum AAHTablenameConstants implements ITablename
{
    /* STN - actual tables/views */
        ACCOUNTING_BASIS_LEDGER        ( AAHEnvironmentConstants.AAH_STN_DB           , "ACCOUNTING_BASIS_LEDGER" )
    ,   BROKEN_FEED                    ( AAHEnvironmentConstants.AAH_STN_DB           , "BROKEN_FEED"                    )
    ,   CESSION                        ( AAHEnvironmentConstants.AAH_STN_DB           , "CESSION"                        )
    ,   CESSION_EVENT                  ( AAHEnvironmentConstants.AAH_STN_DB           , "CESSION_EVENT"                  )
    ,   CESSION_LINK                   ( AAHEnvironmentConstants.AAH_STN_DB           , "CESSION_LINK"                   )
    ,   CODE_MODULE                    ( AAHEnvironmentConstants.AAH_STN_DB           , "CODE_MODULE"                    )
    ,   CODE_MODULE_TYPE               ( AAHEnvironmentConstants.AAH_STN_DB           , "CODE_MODULE_TYPE"               )
    ,   DB_TABLE                       ( AAHEnvironmentConstants.AAH_STN_DB           , "DB_TABLE"                       )
    ,   DB_TAB_COLUMN                  ( AAHEnvironmentConstants.AAH_STN_DB           , "DB_TAB_COLUMN"                  )
    ,   DEPARTMENT                     ( AAHEnvironmentConstants.AAH_STN_DB           , "DEPARTMENT"                     )
    ,   ELIMINATION_LEGAL_ENTITY       ( AAHEnvironmentConstants.AAH_STN_DB           , "ELIMINATION_LEGAL_ENTITY"       )    
    ,   EVENT_HIERARCHY                ( AAHEnvironmentConstants.AAH_STN_DB           , "EVENT_HIERARCHY"                )
    ,   EVENT_TYPE                     ( AAHEnvironmentConstants.AAH_STN_DB           , "EVENT_TYPE"                     )
    ,   EXECUTION_FOLDER               ( AAHEnvironmentConstants.AAH_STN_DB           , "EXECUTION_FOLDER"               )
    ,   FEED                           ( AAHEnvironmentConstants.AAH_STN_DB           , "FEED"                           )
    ,   FEED_RECORD_COUNT              ( AAHEnvironmentConstants.AAH_STN_DB           , "FEED_RECORD_COUNT"              )
    ,   FEED_TYPE                      ( AAHEnvironmentConstants.AAH_STN_DB           , "FEED_TYPE"                      )
    ,   FEED_TYPE_PAYLOAD              ( AAHEnvironmentConstants.AAH_STN_DB           , "FEED_TYPE_PAYLOAD"              )
    ,   FX_RATE                        ( AAHEnvironmentConstants.AAH_STN_DB           , "FX_RATE"                        )
    ,   FX_RATE_TYPE                   ( AAHEnvironmentConstants.AAH_STN_DB           , "FX_RATE_TYPE"                   )
    ,   GL_ACCOUNT                     ( AAHEnvironmentConstants.AAH_STN_DB           , "GL_ACCOUNT"                     )
    ,   GL_CHARTFIELD                  ( AAHEnvironmentConstants.AAH_STN_DB           , "GL_CHARTFIELD"                  )
    ,   GL_CHARTFIELD_TYPE             ( AAHEnvironmentConstants.AAH_STN_DB           , "GL_CHARTFIELD_TYPE"             )
    ,   GL_COMBO_EDIT_ASSIGNMENT       ( AAHEnvironmentConstants.AAH_STN_DB           , "GL_COMBO_EDIT_ASSIGNMENT"       )
    ,   GL_COMBO_EDIT_PROCESS          ( AAHEnvironmentConstants.AAH_STN_DB           , "GL_COMBO_EDIT_PROCESS"          )
    ,   GL_COMBO_EDIT_RULE             ( AAHEnvironmentConstants.AAH_STN_DB           , "GL_COMBO_EDIT_RULE"             )
    ,   HOPPER_ACCOUNTING_BASIS        ( AAHEnvironmentConstants.AAH_STN_DB           , "HOPPER_ACCOUNTING_BASIS"        )    
    ,   HOPPER_CESSION_EVENT           ( AAHEnvironmentConstants.AAH_STN_DB           , "HOPPER_CESSION_EVENT"           )            
    ,   HOPPER_JOURNAL_LINE            ( AAHEnvironmentConstants.AAH_STN_DB           , "HOPPER_JOURNAL_LINE"            )        
    ,   HOPPER_LEGAL_ENTITY_LEDGER     ( AAHEnvironmentConstants.AAH_STN_DB           , "HOPPER_LEGAL_ENTITY_LEDGER"     )        
    ,   HOPPER_LEGAL_ENTITY_ALIAS      ( AAHEnvironmentConstants.AAH_STN_DB           , "HOPPER_LEGAL_ENTITY_ALIAS"      )        
    ,   IDENTIFIED_FEED                ( AAHEnvironmentConstants.AAH_STN_DB           , "IDENTIFIED_FEED"                )
    ,   IDENTIFIED_RECORD              ( AAHEnvironmentConstants.AAH_STN_DB           , "IDENTIFIED_RECORD"              )
    ,   INSURANCE_POLICY               ( AAHEnvironmentConstants.AAH_STN_DB           , "INSURANCE_POLICY"               )
    ,   INSURANCE_POLICY_FX_RATE       ( AAHEnvironmentConstants.AAH_STN_DB           , "INSURANCE_POLICY_FX_RATE"       )
    ,   INSURANCE_POLICY_TAX_JURISD    ( AAHEnvironmentConstants.AAH_STN_DB           , "INSURANCE_POLICY_TAX_JURISD"    )
    ,   LEDGER                         ( AAHEnvironmentConstants.AAH_STN_DB           , "LEDGER"                         )
    ,   JOURNAL_LINE                   ( AAHEnvironmentConstants.AAH_STN_DB           , "JOURNAL_LINE"                   )
    ,   LEGAL_ENTITY                   ( AAHEnvironmentConstants.AAH_STN_DB           , "LEGAL_ENTITY"                   )
    ,   LEGAL_ENTITY_LEDGER            ( AAHEnvironmentConstants.AAH_STN_DB           , "LEGAL_ENTITY_LEDGER"            )
    ,   LEGAL_ENTITY_LINK              ( AAHEnvironmentConstants.AAH_STN_DB           , "LEGAL_ENTITY_LINK"              )
    ,   PARAM_SET                      ( AAHEnvironmentConstants.AAH_STN_DB           , "PARAM_SET"                      )
    ,   PARAM_SET_ITEM                 ( AAHEnvironmentConstants.AAH_STN_DB           , "PARAM_SET_ITEM"                 )
    ,   PROCESS                        ( AAHEnvironmentConstants.AAH_STN_DB           , "PROCESS"                        )
    ,   PROCESS_CODE_MODULE            ( AAHEnvironmentConstants.AAH_STN_DB           , "PROCESS_CODE_MODULE"            )
    ,   PROCESS_TYPE                   ( AAHEnvironmentConstants.AAH_STN_DB           , "PROCESS_TYPE"                   )
    ,   PROJECT                        ( AAHEnvironmentConstants.AAH_STN_DB           , "PROJECT"                        )
    ,   PROJECT_TYPE                   ( AAHEnvironmentConstants.AAH_STN_DB           , "PROJECT_TYPE"                   )
    ,   STANDARDISATION_LOG            ( AAHEnvironmentConstants.AAH_STN_DB           , "STANDARDISATION_LOG"            )
    ,   STEP                           ( AAHEnvironmentConstants.AAH_STN_DB           , "STEP"                           )
    ,   STEP_RUN                       ( AAHEnvironmentConstants.AAH_STN_DB           , "STEP_RUN"                       )
    ,   STEP_RUN_PARAM                 ( AAHEnvironmentConstants.AAH_STN_DB           , "STEP_RUN_PARAM"                 )
    ,   STEP_RUN_STATE                 ( AAHEnvironmentConstants.AAH_STN_DB           , "STEP_RUN_STATE"                 )
    ,   STEP_RUN_STATUS                ( AAHEnvironmentConstants.AAH_STN_DB           , "STEP_RUN_STATUS"                )
    ,   SUPERSEDED_FEED                ( AAHEnvironmentConstants.AAH_STN_DB           , "SUPERSEDED_FEED"                )
    ,   SUPERSESSION_METHOD            ( AAHEnvironmentConstants.AAH_STN_DB           , "SUPERSESSION_METHOD"            )
    ,   TAX_JURISDICTION               ( AAHEnvironmentConstants.AAH_STN_DB           , "TAX_JURISDICTION"               )
    ,   USER_DETAIL                    ( AAHEnvironmentConstants.AAH_STN_DB           , "USER_DETAIL"                    )
    ,   USER_GROUP                     ( AAHEnvironmentConstants.AAH_STN_DB           , "USER_GROUP"                     )
    ,   VALIDATION                     ( AAHEnvironmentConstants.AAH_STN_DB           , "VALIDATION"                     )
    ,   VALIDATION_COLUMN              ( AAHEnvironmentConstants.AAH_STN_DB           , "VALIDATION_COLUMN"              )
    ,   VALIDATION_LEVEL               ( AAHEnvironmentConstants.AAH_STN_DB           , "VALIDATION_LEVEL"               )
    ,   VALIDATION_TYPE                ( AAHEnvironmentConstants.AAH_STN_DB           , "VALIDATION_TYPE"                )
    ,   VIE_LEGAL_ENTITY               ( AAHEnvironmentConstants.AAH_STN_DB           , "VIE_LEGAL_ENTITY"               )    
    
    /* STN - expected result tables */
    ,   ER_ACCOUNTING_BASIS_LEDGER     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME           , "ER_ACCOUNTING_BASIS_LEDGER" )
    ,   ER_BROKEN_FEED                 ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME           , "ER_BROKEN_FEED" )
    ,   ER_CESSION                     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME           , "ER_CESSION" )
    ,   ER_CESSION_EVENT               ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME           , "ER_CESSION_EVENT" )
    ,   ER_CESSION_LINK                ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME           , "ER_CESSION_LINK"  )
    ,   ER_DEPARTMENT                  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME           , "ER_DEPARTMENT"    )
    ,   ER_ELIMINATION_LEGAL_ENTITY    ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_ELIMINATION_LEGAL_ENTITY")
    ,   ER_EVENT_HIERARCHY             ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_EVENT_HIERARCHY"         )
    ,   ER_EVENT_TYPE                  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_EVENT_TYPE"              )
    ,   ER_FEED                        ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FEED"                    )
    ,   ER_FEED_RECORD_COUNT           ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FEED_RECORD_COUNT"       )
    ,   ER_FX_RATE                     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FX_RATE"                 )
    ,   ER_GL_ACCOUNT                  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_GL_ACCOUNT"              )
    ,   ER_GL_CHARTFIELD               ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_GL_CHARTFIELD"           )
    ,   ER_GL_COMBO_EDIT_ASSIGNMENT    ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_GL_COMBO_EDIT_ASSIGNMENT")
    ,   ER_GL_COMBO_EDIT_PROCESS       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_GL_COMBO_EDIT_PROCESS"   )
    ,   ER_GL_COMBO_EDIT_RULE          ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_GL_COMBO_EDIT_RULE"      )
    ,   ER_TAX_JURISDICTION            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_TAX_JURISDICTION"        )
    ,   ER_HOPPER_ACCOUNTING_BASIS     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_ACCOUNTING_BASIS" )
    ,   ER_HOPPER_EVENT_CATEGORY       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_EVENT_CATEGORY"   )
    ,   ER_HOPPER_EVENT_CLASS          ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_EVENT_CLASS"      )
    ,   ER_HOPPER_EVENT_HIERARCHY      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_EVENT_HIERARCHY"  )
    ,   ER_HOPPER_EVENT_GROUP          ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_EVENT_GROUP"      )
    ,   ER_HOPPER_EVENT_SUBGROUP       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_EVENT_SUBGROUP"   )
    ,   ER_HOPPER_GL_CHARTFIELD        ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_GL_CHARTFIELD"    )
    ,   ER_HOPPER_CESSION_EVENT        ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_CESSION_EVENT"    )
    ,   ER_HOPPER_GL_COMBO_EDIT_GC     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_GL_COMBO_EDIT_GC" )
    ,   ER_HOPPER_GL_COMBO_EDIT_GL     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_GL_COMBO_EDIT_GL" )
    ,   ER_HOPPER_INSURANCE_POLICY     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_INSURANCE_POLICY" )
    ,   ER_HOPPER_LEGAL_ENTITY_ALIAS   ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_LEGAL_ENTITY_ALIAS")
    ,   ER_HOPPER_LEGAL_ENTITY_LEDGER  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_LEGAL_ENTITY_LEDGER")
    ,   ER_HOPPER_TAX_JURISDICTION     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_TAX_JURISDICTION"    )
    ,   ER_HOPPER_JOURNAL_LINE         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_HOPPER_JOURNAL_LINE"        )
    ,   ER_JOURNAL_LINE                ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_JOURNAL_LINE"               )
    ,   ER_INSURANCE_POLICY            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_INSURANCE_POLICY"           )
    ,   ER_INSURANCE_POLICY_FX_RATE    ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_INSURANCE_POLICY_FX_RATE"   )
    ,   ER_INSURANCE_POLICY_TAX_JURISD ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_INSURANCE_POLICY_TAX_JURISD")
    ,   ER_LEDGER                      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_LEDGER"                     )
    ,   ER_LEGAL_ENTITY                ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_LEGAL_ENTITY"               )
    ,   ER_LEGAL_ENTITY_LEDGER         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_LEGAL_ENTITY_LEDGER"        )
    ,   ER_LEGAL_ENTITY_LINK           ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_LEGAL_ENTITY_LINK"          )
    ,   ER_STEP_RUN                    ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_STEP_RUN"                   )
    ,   ER_STEP_RUN_PARAM              ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_STEP_RUN_PARAM"             )
    ,   ER_STEP_RUN_STATE              ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_STEP_RUN_STATE"             )
    ,   ER_SUPERSEDED_FEED             ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SUPERSEDED_FEED"            )
    ,   ER_USER_DETAIL                 ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_USER_DETAIL"                )
    ,   ER_USER_GROUP                  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_USER_GROUP"                 )
    ,   ER_VIE_LEGAL_ENTITY            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_VIE_LEGAL_ENTITY"           )
    /* FDR - actual tables */
    ,   FR_ACCOUNT_LOOKUP              ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_ACCOUNT_LOOKUP"              )
    ,   FR_ACCOUNTING_EVENT_IMP        ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_ACCOUNTING_EVENT_IMP"        )    
    ,   FR_CONTRACT_PARTY              ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_CONTRACT_PARTY"              )    
    ,   FR_ENTITY_SCHEMA               ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_ENTITY_SCHEMA"               )    
    ,   FR_GENERAL_CODES               ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_GENERAL_CODES"               )
    ,   FR_GENERAL_LOOKUP              ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_GENERAL_LOOKUP"              )
    ,   FR_POSTING_DRIVER              ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_POSTING_DRIVER"              )
    ,   FR_LOG                         ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_LOG"                         )
    ,   FR_LOG_TEXT                    ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_LOG_TEXT"                    )    
    ,   FR_FX_RATE                     ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_FX_RATE"                     )
    ,   FR_RATE_TYPE                   ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_RATE_TYPE"                   )
    ,   FR_RATE_TYPE_LOOKUP            ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_RATE_TYPE_LOOKUP"             )    
    ,   FR_GENERAL_LOOKUP_LEDG         ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_GENERAL_LOOKUP_LEDG"         )    
    ,   FR_GL_ACCOUNT                  ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_GL_ACCOUNT"                  )
    ,   FR_GL_ACCOUNT_AUD              ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_GL_ACCOUNT_AUD"              )
    ,   FR_GL_ACCOUNT_LOOKUP           ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_GL_ACCOUNT_LOOKUP"           )
    ,   FR_GLOBAL_PARAMETER            ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_GLOBAL_PARAMETER"            )
    ,   FR_LPG_CONFIG                  ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_LPG_CONFIG"                  )    
    ,   FR_PARTY_LEGAL                 ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_PARTY_LEGAL"                 )
    ,   FR_PARTY_LEGAL_LOOKUP          ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_PARTY_LEGAL_LOOKUP"          )    
    ,   FR_PARTY_LEGAL_TYPE            ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_PARTY_LEGAL_TYPE"            )        
    ,   FR_PARTY_BUSINESS              ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_PARTY_BUSINESS"              )
    ,   FR_PARTY_BUSINESS_LOOKUP       ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_PARTY_BUSINESS_LOOKUP"       )
    ,   FR_POSTING_SCHEMA              ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_POSTING_SCHEMA"              )    
    ,   FR_BOOK                        ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_BOOK"                        )
    ,   FR_BOOK_LOOKUP                 ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_BOOK_LOOKUP"                 )    
    ,   FR_INSTR_INSURE_EXTEND         ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_INSTR_INSURE_EXTEND"         )
    ,   FR_TRADE                       ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_TRADE"                       )
    ,   FR_INSTRUMENT_LOOKUP           ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_INSTRUMENT_LOOKUP"           )
    ,   FR_INSTRUMENT                  ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_INSTRUMENT"                  )
    ,   FR_EVENT_GROUP_PERIOD          ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_EVENT_GROUP_PERIOD"          )
    ,   FR_STAN_RAW_GL_ACCOUNT         ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_GL_ACCOUNT"         )
    ,   FR_STAN_RAW_FX_RATE            ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_FX_RATE"            )
    ,   FR_STAN_RAW_BOOK               ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_BOOK"               )
    ,   FR_STAN_RAW_GENERAL_CODES      ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_GENERAL_CODES"      )
    ,   FR_STAN_RAW_INT_ENTITY         ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_INT_ENTITY"         )    
    ,   FR_INTERNAL_PROC_ENTITY        ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_INTERNAL_PROC_ENTITY"        )
    ,   FR_INT_PROC_ENTITY_LOOKUP      ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_INT_PROC_ENTITY_LOOKUP"      )    
    ,   FR_STAN_RAW_INSURANCE_POLICY   ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_INSURANCE_POLICY"   )    
    ,   FR_STAN_RAW_ORG_HIER_NODE      ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_ORG_HIER_NODE"      )
    ,   FR_STAN_RAW_ORG_HIER_STRUC     ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_STAN_RAW_ORG_HIER_STRUC"     )    
    ,   FR_ORG_NETWORK                 ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_ORG_NETWORK"                 )    
    ,   FR_ORG_NODE_STRUCTURE          ( AAHEnvironmentConstants.AAH_FDR_DB           , "FR_ORG_NODE_STRUCTURE"          )    

    
    /* FDR - expected result tables */
    ,   ER_FR_BOOK                     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_BOOK"                   )
    ,   ER_FR_RATE_TYPE                ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_RATE_TYPE"              )
    ,   ER_FR_EVENT_GROUP_PERIOD       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_EVENT_GROUP_PERIOD"     )
    ,   ER_FR_FX_RATE                  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_FX_RATE"                )
    ,   ER_FR_GL_ACCOUNT               ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GL_ACCOUNT"             )
    ,   ER_FR_INSTR_INSURE_EXTEND      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_INSTR_INSURE_EXTEND"    )
    ,   ER_FR_INSTRUMENT               ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_INSTRUMENT"             )
    ,   ER_FR_INTERNAL_PROC_ENTITY     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_INTERNAL_PROC_ENTITY"   )
    ,   ER_FR_LOG                      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_LOG"                    )
    ,   ER_FR_LPG_CONFIG               ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_LPG_CONFIG"             )
    ,   ER_FR_ORG_NETWORK              ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_ORG_NETWORK"            )
    ,   ER_FR_ORG_NODE_STRUCTURE       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_ORG_NODE_STRUCTURE"     )
    ,   ER_FR_PARTY_BUSINESS           ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_PARTY_BUSINESS"         )
    ,   ER_FR_PARTY_LEGAL              ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_PARTY_LEGAL"            )
    ,   ER_FR_POSTING_SCHEMA           ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_POSTING_SCHEMA"         )
    ,   ER_FR_STAN_RAW_ADJUSTMENT      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_ADJUSTMENT"    )    
    ,   ER_FR_STAN_RAW_BOOK            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_BOOK"          )
    ,   ER_FR_STAN_RAW_FX_RATE         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_FX_RATE"       )
    ,   ER_FR_STAN_RAW_GL_ACCOUNT      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_GL_ACCOUNT"    )
    ,   ER_FR_STAN_RAW_INT_ENTITY      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_INT_ENTITY"    )
    ,   ER_FR_STAN_RAW_ORG_HIER_NODE   ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_ORG_HIER_NODE" )
    ,   ER_FR_STAN_RAW_ORG_HIER_STRUC  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_ORG_HIER_STRUC")
    ,   ER_FR_STAN_RAW_PARTY_BUSINESS  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_PARTY_BUSINESS")
    ,   ER_FR_STAN_RAW_PARTY_LEGAL     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_STAN_RAW_PARTY_LEGAL"   )
    ,   ER_FR_TRADE                    ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_TRADE"                  )
    ,   ER_FR_GENERAL_CODES            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GENERAL_CODES"          )
    ,   ER_FR_GL_CHARTFIELD            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GL_CHARTFIELD"          )
    ,   ER_FR_TAX_JURISDICTION         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_TAX_JURISDICTION"       )
    ,   ER_FR_JOURNAL_LINE             ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_JOURNAL_LINE"           )
    ,   ER_FR_GENERAL_CODES_GCE        ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GENERAL_CODES_GCE"      )
    ,   ER_FR_GENERAL_LOOKUP_GCE       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GENERAL_LOOKUP_GCE"     )
    ,   ER_FR_GENERAL_LOOKUP_LEA       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GENERAL_LOOKUP_LEA"     )
    ,   ER_FR_GENERAL_LOOKUP_LEDG      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GENERAL_LOOKUP_LEDG"    )
    ,   ER_FR_GENERAL_LOOKUP_EH        ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GENERAL_LOOKUP_EH"      )
    ,   ER_FR_GLOBAL_PARAMETER         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_GLOBAL_PARAMETER"       )
    ,   ER_FR_ACC_EVENT_TYPE           ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_ACC_EVENT_TYPE"         )
    ,   ER_FR_ACCOUNTING_EVENT_IMP     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_ACCOUNTING_EVENT_IMP"   )
    ,   ER_FR_POLICY_TAX_JURISDICTION  ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_FR_POLICY_TAX_JURISDICTION")
    ,   ER_IS_USER                     ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_IS_USER"                   )
    ,   ER_IS_GROUPUSER                ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_IS_GROUPUSER"              )
    /* GUI - actual tables */
    ,   T_UI_DEPARTMENTS               ( AAHEnvironmentConstants.AAH_GUI_DB           , "T_UI_DEPARTMENTS"               )
    /* GUI - expected result tables */
    ,   ER_T_UI_USER_DETAILS           ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_T_UI_USER_DETAILS"         )
    ,   ER_T_UI_USER_DEPARTMENTS       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_T_UI_USER_DEPARTMENTS"     )
    ,   ER_T_UI_USER_ROLES             ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_T_UI_USER_ROLES"           )
    ,   ER_T_UI_USER_ENTITIES          ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_T_UI_USER_ENTITIES"        )
    ,   ER_T_UI_DEPARTMENTS            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_T_UI_DEPARTMENTS"          )
    /* SLR - actual tables */
    
    
    ,   SLR_BM_ENTITY_PROCESSING_SET   ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_BM_ENTITY_PROCESSING_SET"  )
    ,   SLR_EBA_BOP_AMOUNTS            ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_EBA_BOP_AMOUNTS"           )
    ,   SLR_EBA_COMBINATIONS           ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_EBA_COMBINATIONS"          )
    ,   SLR_EBA_DEFINITIONS            ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_EBA_DEFINITIONS"           )    
    ,   SLR_EBA_DAILY_BALANCES         ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_EBA_DAILY_BALANCES"        )
    ,   SLR_ENTITY_ACCOUNTS            ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_ENTITY_ACCOUNTS"           )    
    ,   SLR_ENTITIES                   ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_ENTITIES"                  )
    ,   SLR_ENTITY_GRACE_DAYS          ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_ENTITY_GRACE_DAYS"         )    
    ,   SLR_ENTITY_PROC_GROUP          ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_ENTITY_PROC_GROUP"         )
    ,   SLR_ENTITY_PERIODS             ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_ENTITY_PERIODS"            )
    ,   SLR_FAK_DAILY_BALANCES         ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_FAK_DAILY_BALANCES"        )
    ,   SLR_FAK_COMBINATIONS           ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_FAK_COMBINATIONS"          )
    ,   SLR_FAK_DEFINITIONS            ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_FAK_DEFINITIONS"           )    
    ,   SLR_JRNL_LINES                 ( AAHEnvironmentConstants.AAH_SLR_DB            , "SLR_JRNL_LINES"                )
    /* SLR - expected result tables */
    ,   ER_SLR_ENTITIES                ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_ENTITIES"              )
    ,   ER_SLR_EBA_DAILY_BALANCES      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_EBA_DAILY_BALANCES"    )
    ,   ER_SLR_EBA_DEFINITIONS         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_EBA_DEFINITIONS"       )
    ,   ER_SLR_FAK_DAILY_BALANCES      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_FAK_DAILY_BALANCES"    )
    ,   ER_SLR_FAK_DEFINITIONS         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_FAK_DEFINITIONS"       )
    ,   ER_SLR_ENTITY_ACCOUNTS         ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_ENTITY_ACCOUNTS"       )
    ,   ER_SLR_ENTITY_GRACE_DAYS       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_ENTITY_GRACE_DAYS"     )
    ,   ER_SLR_ENTITY_PROC_GROUP       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_ENTITY_PROC_GROUP"     )
    ,   ER_SLR_ENTITY_RATES            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_ENTITY_RATES"          )
    ,   ER_SLR_JRNL_LINES              ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_SLR_JRNL_LINES"            )

/* RDR - actual result tables */
,   RR_GLINT_JOURNAL_LINE      ( AAHEnvironmentConstants.AAH_RDR_DB , "RR_GLINT_JOURNAL_LINE"    )    
,   RR_GLINT_JOURNAL           ( AAHEnvironmentConstants.AAH_RDR_DB  , "RR_GLINT_JOURNAL"         )    
,   RR_GLINT_BATCH_CONTROL     ( AAHEnvironmentConstants.AAH_RDR_DB  , "RR_GLINT_BATCH_CONTROL"   )    
,   RR_INTERFACE_CONTROL       ( AAHEnvironmentConstants.AAH_RDR_DB  , "RR_INTERFACE_CONTROL"   )  
,   RDR_VIEW_COLUMNS           ( AAHEnvironmentConstants.AAH_RDR_DB  , "RR_INTERFACE_CONTROL"   )  

    /* RDR - expected result tables */
    ,   ER_RR_GLINT_BATCH_CONTROL      ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_RR_GLINT_BATCH_CONTROL"    )
    ,   ER_RR_INTERFACE_CONTROL        ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_RR_INTERFACE_CONTROL"      )
    ,   ER_RR_GLINT_JOURNAL            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_RR_GLINT_JOURNAL"          )
    ,   ER_RR_GLINT_JOURNAL_LINE       ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_RR_GLINT_JOURNAL_LINE"     )
    ,   ER_RDR_VIEW_COLUMNS            ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_RDR_VIEW_COLUMNS"          )
    ;

    private String tableOwner;
	private String tableName;

	AAHTablenameConstants ( final String pTableOwner , final String pTableName )
	{
		tableOwner = pTableOwner;
		tableName  = pTableName;
	}

	public String getTableOwner ()
	{
		return tableOwner;
	}

	public String getTableName ()
	{
		return tableName;
	}

	public String toString ()
	{
		return tableOwner + ".\"" + tableName + "\"";
	}

}