DECLARE
    i INTEGER;
    j INTEGER;
    x INTEGER;    
BEGIN
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'BAK_XPK_GLINT_JOURNAL_LINE';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX XPK_GLINT_JOURNAL_LINE RENAME TO BAK_XPK_GLINT_JOURNAL_LINE';
    END IF;

    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'BAK_IDX_AG_GLINT_JE_LINE01';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX IDX_AG_GLINT_JE_LINE01 RENAME TO BAK_IDX_AG_GLINT_JE_LINE01';
    END IF;

    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'BAK_XIF1GL_INTERFACE_JOURNAL_LINE';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX XIF1GL_INTERFACE_JOURNAL_LINE RENAME TO BAK_XIF1GL_INTERFACE_JOURNAL_LINE';
    END IF;

    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = 'BAK_GLINT_J_JL';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_LINE RENAME CONSTRAINT GLINT_J_JL TO BAK_GLINT_J_JL';
    END IF;

    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = 'BAK_XPK_GLINT_JOURNAL_LINE;';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_LINE RENAME CONSTRAINT XPK_GLINT_JOURNAL_LINE TO BAK_XPK_GLINT_JOURNAL_LINE';
    END IF;

    select COUNT(*) into i from tab where tname = 'BAK_RR_GLINT_JOURNAL_LINE';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_LINE RENAME TO BAK_RR_GLINT_JOURNAL_LINE';
    END IF;

END;
/