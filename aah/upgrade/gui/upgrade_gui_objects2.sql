    DELETE FROM GUI.UI_GENERAL_LOOKUP where UGL_UF_ID in (730,731,4433400);
    DELETE FROM GUI.UI_FIELD where uf_id in (730,731,4433400);

    Insert into GUI.UI_FIELD
    (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
        UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
        UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
        UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
    Values
    (730, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
        'utgl_match_key2', 'Close Year', 'T', 40, 0, 
        'Y', 'N', 'N', 2, 2, 
        1, 'N');
    
    Insert into GUI.UI_FIELD
    (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
        UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
        UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
        UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
    Values
    (731, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
        'utgl_match_key3', 'Close Month', 'T', 40, 0, 
        'Y', 'N', 'N', 2, 2, 
        1, 'N');

    Insert into GUI.UI_FIELD
    (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
        UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
        UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
        UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
    Values
    (4433400, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
        'utgl_match_key2', 'MADJ Balance Column', 'T', 40, 0, 
        'Y', 'N', 'N', 1, 1, 
        1, 'N');

    Insert into GUI.UI_GENERAL_LOOKUP
    (UGL_UF_ID, UGL_LKT_LOOKUP_TYPE_CODE)
    Values
    (730, 'EVENT_CLASS_PERIOD');

    Insert into GUI.UI_GENERAL_LOOKUP
    (UGL_UF_ID, UGL_LKT_LOOKUP_TYPE_CODE)
    Values
    (731, 'EVENT_CLASS_PERIOD');

    Insert into GUI.UI_GENERAL_LOOKUP
    (UGL_UF_ID, UGL_LKT_LOOKUP_TYPE_CODE)
    Values
    (4433400, 'MADJ_BALANCE_COLUMNS');
    
    commit;
