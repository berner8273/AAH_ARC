DECLARE
  v_column_exists number := 0;  
BEGIN
    Select count(*) into v_column_exists
    from all_tab_cols
    where lower(table_name) = 'bak_slr_jrnl_headers'
      and upper(column_name) = 'JH_JRNL_ID_NEW'
      and owner = 'SLR';

  if (v_column_exists = 0) then
      execute immediate 'alter table slr.bak_slr_jrnl_headers add (JH_JRNL_ID_NEW CHAR(32 BYTE))';
  end if;
end;
/

DECLARE
  v_mapping_exists number := 0;  
BEGIN
    Select count(*) into v_mapping_exists
    from slr.bak_slr_jrnl_headers
    where  JH_JRNL_ID_NEW IS NULL

  if (v_mapping_exists > 0) then
      execute immediate '
        update slr.bak_slr_jrnl_headers bak
            set (JH_JRNL_ID_NEW) = 
                (
                    select JH_JRNL_ID
                    from slr.slr_jrnl_headers n
                    where
                            bak.JH_JRNL_TYPE					=  n.JH_JRNL_TYPE				
                        and bak.JH_JRNL_DATE					=  n.JH_JRNL_DATE				
                        and bak.JH_JRNL_ENTITY					=  n.JH_JRNL_ENTITY				
                        and bak.JH_JRNL_EPG_ID					=  n.JH_JRNL_EPG_ID				
                        and bak.JH_JRNL_STATUS					=  n.JH_JRNL_STATUS				
                        and bak.JH_JRNL_STATUS_TEXT				=  n.JH_JRNL_STATUS_TEXT			
                        and bak.JH_JRNL_PROCESS_ID				=  n.JH_JRNL_PROCESS_ID			
                        and bak.JH_JRNL_DESCRIPTION				=  n.JH_JRNL_DESCRIPTION			
                        and bak.JH_JRNL_SOURCE					=  n.JH_JRNL_SOURCE				
                        and bak.JH_JRNL_SOURCE_JRNL_ID			=  n.JH_JRNL_SOURCE_JRNL_ID		
                        and bak.JH_JRNL_PREF_STATIC_SRC			=  n.JH_JRNL_PREF_STATIC_SRC		
                        and bak.JH_JRNL_REF_ID					=  n.JH_JRNL_REF_ID				
                        and bak.JH_JRNL_REV_DATE				=  n.JH_JRNL_REV_DATE			
                        and bak.JH_JRNL_AUTHORISED_BY			=  n.JH_JRNL_AUTHORISED_BY		
                        and bak.JH_JRNL_AUTHORISED_ON			=  n.JH_JRNL_AUTHORISED_ON		
                        and bak.JH_JRNL_VALIDATED_BY			=  n.JH_JRNL_VALIDATED_BY		
                        and bak.JH_JRNL_VALIDATED_ON			=  n.JH_JRNL_VALIDATED_ON		
                        and bak.JH_JRNL_POSTED_BY				=  n.JH_JRNL_POSTED_BY			
                        and bak.JH_JRNL_POSTED_ON				=  n.JH_JRNL_POSTED_ON			
                        and bak.JH_JRNL_TOTAL_HASH_DEBIT		=  n.JH_JRNL_TOTAL_HASH_DEBIT	
                        and bak.JH_JRNL_TOTAL_HASH_CREDIT		=  n.JH_JRNL_TOTAL_HASH_CREDIT	
                        and bak.JH_JRNL_TOTAL_LINES				=  n.JH_JRNL_TOTAL_LINES			
                        and bak.JH_CREATED_BY					=  n.JH_CREATED_BY				
                        and bak.JH_CREATED_ON					=  n.JH_CREATED_ON				
                        and bak.JH_AMENDED_BY					=  n.JH_AMENDED_BY				
                        and bak.JH_AMENDED_ON					=  n.JH_AMENDED_ON				
                        and bak.JH_BUS_POSTING_DATE				=  n.JH_BUS_POSTING_DATE			
                        and bak.JH_JRNL_INTERNAL_PERIOD_FLAG	=  n.JH_JRNL_INTERNAL_PERIOD_FLAG
                        and bak.JH_JRNL_ENT_RATE_SET			=  n.JH_JRNL_ENT_RATE_SET		
                        and bak.JH_JRNL_TRANSLATION_DATE		=  n.JH_JRNL_TRANSLATION_DATE                

                )      

      ';
  end if;
end;
/


MERGE INTO slr.bak_slr_jrnl_headers bak
USING
(
-- For more complicated queries you can use WITH clause here
SELECT JH_JRNL_ID FROM slr.slr_jrnl_headers
)n
ON(
                    bak.JH_JRNL_TYPE					=  n.JH_JRNL_TYPE				
                and bak.JH_JRNL_DATE					=  n.JH_JRNL_DATE				
                and bak.JH_JRNL_ENTITY					=  n.JH_JRNL_ENTITY				
                and bak.JH_JRNL_EPG_ID					=  n.JH_JRNL_EPG_ID				
                and bak.JH_JRNL_STATUS					=  n.JH_JRNL_STATUS				
                and bak.JH_JRNL_STATUS_TEXT				=  n.JH_JRNL_STATUS_TEXT			
                and bak.JH_JRNL_PROCESS_ID				=  n.JH_JRNL_PROCESS_ID			
                and bak.JH_JRNL_DESCRIPTION				=  n.JH_JRNL_DESCRIPTION			
                and bak.JH_JRNL_SOURCE					=  n.JH_JRNL_SOURCE				
                and bak.JH_JRNL_SOURCE_JRNL_ID			=  n.JH_JRNL_SOURCE_JRNL_ID		
                and bak.JH_JRNL_PREF_STATIC_SRC			=  n.JH_JRNL_PREF_STATIC_SRC		
                and bak.JH_JRNL_REF_ID					=  n.JH_JRNL_REF_ID				
                and bak.JH_JRNL_REV_DATE				=  n.JH_JRNL_REV_DATE			
                and bak.JH_JRNL_AUTHORISED_BY			=  n.JH_JRNL_AUTHORISED_BY		
                and bak.JH_JRNL_AUTHORISED_ON			=  n.JH_JRNL_AUTHORISED_ON		
                and bak.JH_JRNL_VALIDATED_BY			=  n.JH_JRNL_VALIDATED_BY		
                and bak.JH_JRNL_VALIDATED_ON			=  n.JH_JRNL_VALIDATED_ON		
                and bak.JH_JRNL_POSTED_BY				=  n.JH_JRNL_POSTED_BY			
                and bak.JH_JRNL_POSTED_ON				=  n.JH_JRNL_POSTED_ON			
                and bak.JH_JRNL_TOTAL_HASH_DEBIT		=  n.JH_JRNL_TOTAL_HASH_DEBIT	
                and bak.JH_JRNL_TOTAL_HASH_CREDIT		=  n.JH_JRNL_TOTAL_HASH_CREDIT	
                and bak.JH_JRNL_TOTAL_LINES				=  n.JH_JRNL_TOTAL_LINES			
                and bak.JH_CREATED_BY					=  n.JH_CREATED_BY				
                and bak.JH_CREATED_ON					=  n.JH_CREATED_ON				
                and bak.JH_AMENDED_BY					=  n.JH_AMENDED_BY				
                and bak.JH_AMENDED_ON					=  n.JH_AMENDED_ON				
                and bak.JH_BUS_POSTING_DATE				=  n.JH_BUS_POSTING_DATE			
                and bak.JH_JRNL_INTERNAL_PERIOD_FLAG	=  n.JH_JRNL_INTERNAL_PERIOD_FLAG
                and bak.JH_JRNL_ENT_RATE_SET			=  n.JH_JRNL_ENT_RATE_SET		
                and bak.JH_JRNL_TRANSLATION_DATE		=  n.JH_JRNL_TRANSLATION_DATE   




)
WHEN MATCHED THEN UPDATE SET
bak.JH_JRNL_ID_NEW = n.JH_JRNL_ID;