package com.aptitudesoftware.test.quality.sql;

import java.io.BufferedReader;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.Files;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.util.regex.Matcher;
import java.util.Map;
import org.apache.log4j.Logger;

public class SQLFileSetQualityChecker extends SimpleFileVisitor <Path>
{
    private static final Logger LOG = Logger.getLogger ( SQLFileSetQualityChecker.class );

    private Map <String, String> PATH_TO_DB_NAME_MAPPINGS = null;
    private Path                 PATH_TO_ROOT_FOLDER      = null;
    private SQLCodePattern       TABLE_PATTERN            = null;
    private SQLCodePattern       VIEW_PATTERN             = null;
    private SQLCodePattern       DATA_PATTERN             = null;
    private SQLCodePattern       PROCEDURE_PATTERN        = null;
    private SQLCodePattern       RI_PATTERN               = null;
    private SQLCodePattern       INDEX_PATTERN            = null;
    private SQLCodePattern       GRANTS_PATTERN           = null;
    private SQLCodePattern       PACKAGES_PATTERN         = null;
	private SQLCodePattern       SEQUENCES_PATTERN        = null;
	private SQLCodePattern       FUNCTION_PATTERN         = null;
    private boolean              foundProblem             = false;

    public SQLFileSetQualityChecker ( final Path pPathToRootFolder , final SQLCodePattern pTablePattern , final SQLCodePattern pViewPattern , final SQLCodePattern pDataPattern , final SQLCodePattern pProcedurePattern , final SQLCodePattern pRIPattern , final SQLCodePattern pIndexPattern , final SQLCodePattern pGrantsPattern , final SQLCodePattern pPackagesPattern , final SQLCodePattern pSequencesPattern, final Map <String, String> pPathToDBNameMappings , final SQLCodePattern pFunctionPattern) throws Exception
    {
        PATH_TO_ROOT_FOLDER      = pPathToRootFolder;
        TABLE_PATTERN            = pTablePattern;
        VIEW_PATTERN             = pViewPattern;
        DATA_PATTERN             = pDataPattern;
        PROCEDURE_PATTERN        = pProcedurePattern;
        RI_PATTERN               = pRIPattern;
        INDEX_PATTERN            = pIndexPattern;
        GRANTS_PATTERN           = pGrantsPattern;
        PACKAGES_PATTERN         = pPackagesPattern;
		SEQUENCES_PATTERN        = pSequencesPattern;
        PATH_TO_DB_NAME_MAPPINGS = pPathToDBNameMappings;
		FUNCTION_PATTERN         = pFunctionPattern;

        Files.walkFileTree
        (
            pPathToRootFolder
        ,   this
        );
    }

    @Override
    public FileVisitResult visitFile ( Path pFile , BasicFileAttributes attrs )
    {
        if ( ! pFile.getParent ().equals ( PATH_TO_ROOT_FOLDER ) )
        {
            LOG.debug ( "Check file : '" + pFile.toString () + "' for quality" );

            final Path RELATIVE_PATH_TO_FILE = PATH_TO_ROOT_FOLDER.relativize ( pFile );

            LOG.debug ( "RELATIVE_PATH_TO_FILE : '" + RELATIVE_PATH_TO_FILE + "'" );

            final String OBJECT_TYPE_BY_PATH = RELATIVE_PATH_TO_FILE.getName ( 0 ).toString ();

            LOG.debug ( "OBJECT_TYPE_BY_PATH : '" + OBJECT_TYPE_BY_PATH + "'" );

            final String DB_NAME_BY_PATH = ( OBJECT_TYPE_BY_PATH.equals ( "grants" ) ? RELATIVE_PATH_TO_FILE.getName ( 2 ).toString () : RELATIVE_PATH_TO_FILE.getName ( 1 ).toString () );

            LOG.debug ( "DB_NAME_BY_PATH : '" + DB_NAME_BY_PATH + "'" );

            final String OBJECT_NAME_BY_PATH = pFile.getFileName ().toString ().replace ( ".sql", "" ).replace ( ".hdr" , "" ).replace ( ".bdy" , "" );

            SQLCodePattern sqlCodePattern = null;

            if      ( OBJECT_TYPE_BY_PATH.equals ( "tables" ) )
            {
                sqlCodePattern = TABLE_PATTERN;
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "views" ) )
            {
                sqlCodePattern = VIEW_PATTERN;
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "data" ) )
            {
                sqlCodePattern = DATA_PATTERN;
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "procedures" ) )
            {
                sqlCodePattern = PROCEDURE_PATTERN;
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "ri_constraints" ) )
            {
                sqlCodePattern = RI_PATTERN;
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "indices" ) )
            {
                sqlCodePattern = INDEX_PATTERN;
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "grants" ) )
            {
                sqlCodePattern = GRANTS_PATTERN;
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "packages" ) )
            {
                sqlCodePattern = PACKAGES_PATTERN;
            }
			else if ( OBJECT_TYPE_BY_PATH.equals ( "sequences" ) )
            {
                sqlCodePattern = SEQUENCES_PATTERN;
            }
			else if ( OBJECT_TYPE_BY_PATH.equals ( "functions" ) )
            {
                sqlCodePattern = FUNCTION_PATTERN;
            }

            LOG.debug ( "SQLCodePattern = " + sqlCodePattern.toString () );

            String  ln                            = "";
            String  objectDbName                  = "";
            String  objectName                    = "";
            String  lastTextInFile                = "";
            int     countObjectSchemaDeclarations = 0;
            int     countObjectDeclarations       = 0;
            // boolean fileEndsWithCommit            = false;
            Matcher m                             = null;
            int     lnNum                         = 0;

            try ( BufferedReader br = Files.newBufferedReader ( pFile ) )
            {
                while ( ( ln = br.readLine () ) != null )
                {
                    lnNum++;

                    if ( ! ln.trim ().equals ( "" ) )
                    {
                        lastTextInFile = ln;
                    }

                    LOG.debug ( "Check for the object's DB name in the DDL declaration." );

                    if ( ( m = sqlCodePattern.getDbNamePattern ().matcher ( ln ) ).find () )
                    {
                        final String tmp = m.group ();

                        LOG.debug ( "DB name '" + tmp + "' found on line '" + lnNum + "' of file '" + pFile.toString () + "'" );

                        if ( ( ! tmp.equals ( objectDbName ) ) && countObjectSchemaDeclarations == 1 )
                        {
                            LOG.error ( "The file '" + pFile.toString () + "' contains references to both of the following DB names: '" + tmp + "' and '" + objectDbName + "'. See line '" + lnNum + "'"  );

                            foundProblem = true;
                        }

                        objectDbName = tmp;

                        LOG.debug ( "The object database name '" + objectDbName + "' was found in the file '" + pFile.toString () + "'" );

                        countObjectSchemaDeclarations++;
                    }

                    LOG.debug ( "Check for the object's name in the DDL declaration." );

                    if ( ( m = sqlCodePattern.getObjectNamePattern ().matcher ( ln ) ).find () )
                    {
                        objectName = m.group ();

                        LOG.debug ( "Object name '" + objectName + "' was found on line '" + lnNum + "' of file '" + pFile.toString () + "'" );

                        countObjectDeclarations++;
                    }
                }
            }
            catch ( Exception e )
            {
                foundProblem = true;

                LOG.error ( "The following exception has occurred whilst processing line '" + lnNum + "' of the file '" + pFile.toString () + "' : " + e );
            }

            if ( ( ! sqlCodePattern.getFileCanContainMultipleStatements () ) && ( countObjectSchemaDeclarations > 1 || countObjectDeclarations > 1 ) )
            {
                LOG.error ( "The file '" + pFile + "' is not permitted to contain multiple DDL/DML statements and it was found to contain '" + countObjectSchemaDeclarations + "'" );

                foundProblem = true;
            }

            if ( sqlCodePattern.getFileMustEndWithCommit () && ( ! lastTextInFile.trim ().equals ( "commit;" ) ) )
            {
                LOG.error ( "The file '" + pFile + "' was expected to end with a 'commit;' statement - it does not." );

                foundProblem = true;
            }

            if ( ! OBJECT_NAME_BY_PATH.toUpperCase ().equals ( objectName.toUpperCase () ) )
            {
                LOG.error ( "The file '" + pFile + "' was expected to define an object called '" + OBJECT_NAME_BY_PATH + "', the object declared in the file is called '" + objectName + "'." );

                foundProblem = true;
            }

            if ( ! ( PATH_TO_DB_NAME_MAPPINGS.get ( DB_NAME_BY_PATH ).equals ( objectDbName ) ) )
            {
                LOG.error ( "The DB owner of the object declared in '" + pFile.toString () + "' was expected to be '" + PATH_TO_DB_NAME_MAPPINGS.get ( DB_NAME_BY_PATH ) + "', but the DB owner '" + objectDbName + "' was found." );

                foundProblem = true;
            }
        }

        return FileVisitResult.CONTINUE;
    }

    public boolean getResult ()
    {
        return foundProblem;
    }
}