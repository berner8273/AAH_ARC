package com.aptitudesoftware.test.quality.sql;

import java.util.regex.Pattern;

public enum SQLCodePattern
{
        ORACLE_CREATE_TABLE       ( "(?<=(create (global temporary )?table ))[a-z0-9_]*(?=\\.)"                     , "(?<=(create (global temporary )?table [a-z0-9_]{1,128}\\.))[a-z0-9_]*"                      , false , false )
    ,   TERADATA_CREATE_TABLE     ( "(?<=(create (global temporary )?table ))[a-z0-9_]*(?=\\.)"                     , "(?<=(create (global temporary )?table [a-z0-9_]{1,128}\\.))[a-z0-9_]*"                      , true  , false )
    ,   ORACLE_CREATE_VIEW        ( "(?<=(create or replace view ))[a-z0-9_]*(?=\\.)"                               , "(?<=(create or replace view [a-z0-9_]{1,128}\\.))[a-z0-9_]*"                                , false , false )
    ,   TERADATA_CREATE_VIEW      ( "(?<=(replace view ))[a-z0-9_]*(?=\\.)"                                         , "(?<=(replace view [a-z0-9_]{1,128}\\.))[a-z0-9_]*"                                          , true  , true )
    ,   ORACLE_INSERT_DATA        ( "(?<=(insert into|update|delete from) )[a-z0-9_]*(?=\\.)"                       , "(?<=(insert into|update|delete from) [a-z0-9_]{1,30}\\.)[a-z0-9_]*"                         , true  , true )
    ,   TERADATA_INSERT_DATA      ( "(?<=(insert into|update|delete from) )[a-z0-9_]*(?=\\.)"                       , "(?<=(insert into|update|delete from) [a-z0-9_]{1,30}\\.)[a-z0-9_]*"                         , true  , true )
    ,   ORACLE_CREATE_PROCEDURE   ( "(?<=(create or replace procedure ))[a-z0-9_]*(?=\\.)"                          , "(?<=(create or replace procedure [a-z0-9_]{1,128}\\.))[a-z0-9_]*"                           , false , false )
    ,   TERADATA_CREATE_PROCEDURE ( "(?<=(replace procedure ))[a-z0-9_]*(?=\\.)"                                    , "(?<=(replace procedure [a-z0-9_]{1,128}\\.))[a-z0-9_]*"                                     , false , false )
    ,   ORACLE_CREATE_RI          ( "(?<=alter table )[a-z0-9_]*(?=\\.[a-z0-9_]* add constraint)"                   , "(?<=alter table [a-z0-9_]{1,30}\\.)[a-z0-9_]*(?= add constraint)"                           , false , true )
    ,   TERADATA_CREATE_RI        ( "(?<=alter table )[a-z0-9_]*(?=\\.[a-z0-9_]* add constraint)"                   , "(?<=alter table [a-z0-9_]{1,30}\\.)[a-z0-9_]*(?= add constraint)"                           , true  , true )
    ,   ORACLE_CREATE_INDEX       ( "(?<=create (unique |bitmap )?index [a-z0-9_]{1,128} on )[a-z0-9_]*(?=\\.)"     , "(?<=create (unique |bitmap )?index [a-z0-9_]{1,128} on [a-z0-9_]{1,128}\\.)[a-z0-9_]*"      , false , true )
    ,   TERADATA_CREATE_INDEX     ( "(?<=create (unique )?index [a-z0-9_]{1,128} on )[a-z0-9_]*(?=\\.)"             , "(?<=create (unique )?index [a-z0-9_]{1,128} on [a-z0-9_]{1,128}\\.)[a-z0-9_]*"              , false , true )
    ,   ORACLE_GRANT              ( "(?<=grant (select|insert|delete|update|execute) on )[a-z0-9_]*(?=\\.)"         , "(?<=grant (select|insert|delete|update|execute) on [a-z0-9_]{1,128}\\.)[a-z0-9_]*"          , false , true )
    ,   TERADATA_GRANT            ( "(?<=grant (select|insert|delete|update) on )[a-z0-9_]*(?=\\.)"                 , "(?<=grant (select|insert|delete|update) on [a-z0-9_]{1,128}\\.)[a-z0-9_]*"                  , false , true )
    ,   ORACLE_PACKAGE            ( "(?<=create or replace package (body )?)[a-z0-9_]*(?=\\.)"                      , "(?<=create or replace package (body )?[a-z0-9_]{1,128}\\.)[a-z0-9_]*"                       , false , false )
    , 	ORACLE_SEQUENCE           ( "(?<=create sequence )[a-z0-9_]*(?=\\.)"                                        , "(?<=create sequence [a-z0-9_]{1,128}\\.)[a-z0-9_]*"                                         , false , false )
    ,   ORACLE_CREATE_FUNCTION    ( "(?<=(create or replace function ))[a-z0-9_]*(?=\\.)"                           , "(?<=(create or replace function [a-z0-9_]{1,128}\\.))[a-z0-9_]*"                            , false , false )		
	
	;

    private Pattern dbNamePattern                    = null;
    private Pattern objectNamePattern                = null;
    private boolean fileMustEndWithCommit            = false;
    private boolean fileCanContainMultipleStatements = false;


    private SQLCodePattern ( final String pDbNameRegex , final String pObjectNameRegex , final boolean pFileMustEndWithCommit , final boolean pFileCanContainMultipleStatements )
    {
        dbNamePattern                    = Pattern.compile ( pDbNameRegex     , Pattern.CASE_INSENSITIVE );
        objectNamePattern                = Pattern.compile ( pObjectNameRegex , Pattern.CASE_INSENSITIVE );
        fileMustEndWithCommit            = pFileMustEndWithCommit;
        fileCanContainMultipleStatements = pFileCanContainMultipleStatements;
    }

    public Pattern getDbNamePattern ()
    {
        return dbNamePattern;
    }

    public Pattern getObjectNamePattern ()
    {
        return objectNamePattern;
    }

    public boolean getFileMustEndWithCommit ()
    {
        return fileMustEndWithCommit;
    }

    public boolean getFileCanContainMultipleStatements ()
    {
        return fileCanContainMultipleStatements;
    }
}