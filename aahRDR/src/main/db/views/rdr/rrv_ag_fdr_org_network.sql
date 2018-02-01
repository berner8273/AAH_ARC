CREATE OR REPLACE FORCE VIEW RDR.RRV_AG_FDR_ORG_NETWORK AS 
SELECT
  ON_ORG_NODE_ID             
  ,ON_SI_SYS_INST_ID          
  ,ON_ORG_NODE_CLIENT_CODE    
  ,ON_IPE_INTERNAL_ENTITY_ID  
  ,ON_ONT_ORG_NODE_TYPE_ID    
  ,ON_PL_PARTY_LEGAL_ID       
  ,ON_BO_BOOK_ID              
  ,ON_ACTIVE                  
  ,ON_INPUT_BY                
  ,ON_AUTH_BY                 
  ,ON_AUTH_STATUS             
  ,ON_INPUT_TIME              
  ,ON_VALID_FROM              
  ,ON_VALID_TO                
  ,ON_DELETE_TIME             
FROM
   FDR.FR_ORG_NETWORK ;
   