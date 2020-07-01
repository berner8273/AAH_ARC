package com.aptitudesoftware.test.quality.sql.oracle.deployment;

import com.aptitudesoftware.test.quality.sql.DatabaseConnectorFactory;
import com.aptitudesoftware.test.quality.sql.ICodeDeploymentChecker;
import com.aptitudesoftware.test.quality.sql.SQLCodePattern;
import java.io.BufferedReader;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.Map;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.apache.log4j.Logger;

public class OracleCodeDeploymentChecker extends SimpleFileVisitor <Path> implements ICodeDeploymentChecker
{
    private static final   Logger               LOG                      = Logger.getLogger ( OracleCodeDeploymentChecker.class );
    // private                Map <String, String> PATH_TO_DB_NAME_MAPPINGS = null;
    private                Path                 PATH_TO_ROOT_FOLDER      = null;
    private        final   SQLCodePattern       TABLE_PATTERN            = SQLCodePattern.ORACLE_CREATE_TABLE;
    private        final   SQLCodePattern       VIEW_PATTERN             = SQLCodePattern.ORACLE_CREATE_VIEW;
    private        final   SQLCodePattern       PROCEDURE_PATTERN        = SQLCodePattern.ORACLE_CREATE_PROCEDURE;
	private        final   SQLCodePattern       FUNCTION_PATTERN         = SQLCodePattern.ORACLE_CREATE_FUNCTION;
    // private        final   SQLCodePattern       RI_PATTERN               = SQLCodePattern.ORACLE_CREATE_RI;

    private boolean foundProblem = false;

    private final Set <OracleCodeDeploymentChecker.ObjectDetails> OBJECTS = new HashSet <OracleCodeDeploymentChecker.ObjectDetails> ();

    private static class ObjectDetails
    {
        private String dbName;
        private String objectName;
        private String objectType;

        public ObjectDetails ( final String pDbName , final String pObjectName , final String pObjectType )
        {
            dbName     = pDbName.toLowerCase ();
            objectName = pObjectName.toLowerCase ();
            objectType = pObjectType.toLowerCase ();
        }

        public String getDbName ()
        {
            return dbName;
        }

        public String getObjectName ()
        {
            return objectName;
        }

        public String getObjectType ()
        {
            return objectType;
        }

        @Override
        public boolean equals ( final Object pObjectDetails )
        {
            boolean isEqual = false;

            if ( pObjectDetails instanceof OracleCodeDeploymentChecker.ObjectDetails )
            {
                final OracleCodeDeploymentChecker.ObjectDetails temp = ( OracleCodeDeploymentChecker.ObjectDetails ) pObjectDetails;

                if ( getDbName ().equals ( temp.getDbName () ) && getObjectName ().equals ( temp.getObjectName () ) && objectType.equals ( temp.getObjectType () ) )
                {
                    isEqual = true;
                }
            }

            return isEqual;
        }

        @Override
        public int hashCode ()
        {
            return new HashCodeBuilder ( 21 , 13 ).append ( getDbName() ).append ( getObjectName() ).toHashCode();
        }

        @Override
        public String toString ()
        {
            return "[" + objectType + "] " + dbName + "." + objectName;
        }
    }

    public OracleCodeDeploymentChecker ( final Path pPathToRootFolder , final Map <String, String> pPathToDBNameMappings ) throws Exception
    {
        PATH_TO_ROOT_FOLDER      = pPathToRootFolder;
        // PATH_TO_DB_NAME_MAPPINGS = pPathToDBNameMappings;

        Files.walkFileTree
        (
            pPathToRootFolder
        ,   this
        );

        reconcile ();
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

            SQLCodePattern sqlCodePattern = null;

            String oracleDictionaryObjectType = "";

            if      ( OBJECT_TYPE_BY_PATH.equals ( "tables" ) )
            {
                sqlCodePattern             = TABLE_PATTERN;
                oracleDictionaryObjectType = "table";
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "views" ) )
            {
                sqlCodePattern             = VIEW_PATTERN;
                oracleDictionaryObjectType = "view";
            }
            else if ( OBJECT_TYPE_BY_PATH.equals ( "procedures" ) )
            {
                sqlCodePattern             = PROCEDURE_PATTERN;
                oracleDictionaryObjectType = "procedure";
            }
			else if ( OBJECT_TYPE_BY_PATH.equals ( "functions" ) )
            {
                sqlCodePattern             = FUNCTION_PATTERN;
                oracleDictionaryObjectType = "function";
            }
            else
            {
                //Don't check whether objects of these types were deployed
                sqlCodePattern = null;
            }

            LOG.debug ( "SQLCodePattern = " + TABLE_PATTERN.toString () );

            if ( sqlCodePattern != null )
            {
                String  ln                = "";
                String  objectDbName      = "";
                String  objectName        = "";
                Matcher m                 = null;
                int     lnNum             = 0;
                boolean foundObjectDbName = false;
                boolean foundObjectName   = false;

                LOG.debug ( "Read the contents of '" + pFile.toString () + "' - oracleDictionaryObjectType = " + oracleDictionaryObjectType );

                try ( BufferedReader br = Files.newBufferedReader ( pFile ) )
                {
                    while ( ( ln = br.readLine () ) != null )
                    {
                        lnNum++;

                        LOG.debug ( "Check for the object's DB name in the DDL declaration." );

                        if ( ( m = sqlCodePattern.getDbNamePattern ().matcher ( ln ) ).find () )
                        {
                            objectDbName = m.group ();

                            foundObjectDbName = true;

                            LOG.debug ( "The object database name '" + objectDbName + "' was found in the file '" + pFile.toString () + "'" );
                        }

                        LOG.debug ( "Check for the object's name in the DDL declaration." );

                        if ( ( m = sqlCodePattern.getObjectNamePattern ().matcher ( ln ) ).find () )
                        {
                            objectName = m.group ();

                            foundObjectName = true;

                            LOG.debug ( "Object name '" + objectName + "' was found on line '" + lnNum + "' of file '" + pFile.toString () + "'" );
                        }

                        if ( foundObjectDbName & foundObjectName )
                        {
                            OracleCodeDeploymentChecker.ObjectDetails o = new OracleCodeDeploymentChecker.ObjectDetails ( objectDbName , objectName , oracleDictionaryObjectType );

                            OBJECTS.add ( o );

                            LOG.debug ( "Object '" + o + "' was found in source code and added to the collection of objects" );

                            break;
                        }
                    }
                }
                catch ( Exception e )
                {
                    foundProblem = true;

                    LOG.error ( "The following exception has occurred whilst processing line '" + lnNum + "' of the file '" + pFile.toString () + "' : " + e );
                }
            }
        }

        return FileVisitResult.CONTINUE;
    }

    public void reconcile () throws Exception
    {
        Connection        conn        = null;
        PreparedStatement objectPStmt = null;
        ResultSet         objectRs    = null;

        try
        {
            conn = DatabaseConnectorFactory.getDatabaseConnector ().getConnection ();

            objectPStmt = conn.prepareStatement
                          (
                                " select "
                              + "        lower ( trim ( a.owner ) )       owner "
                              + "      , lower ( trim ( a.object_name ) ) object_name "
                              + "      , lower ( trim ( a.object_type ) ) object_type "
                              + "   from "
                              + "        dba_objects a "
                              + "  where "
                              + "        upper ( owner ) not in ( 'OLAPSYS' , 'ORDDATA' , 'GSMADMIN_INTERNAL' , 'ORDPLUGINS' , 'DVF' , 'SYS' , 'PUBLIC' , 'OUTLN' , 'ORDSYS' , 'MDSYS' , 'ORACLE_OCM' , 'APEX_040200' , 'SYSTEM' , 'CTXSYS' , 'XDB' , 'WMSYS' , 'SH' , 'DVSYS' ) "
                          );

            objectRs = objectPStmt.executeQuery ();

            while ( objectRs.next () )
            {
                OracleCodeDeploymentChecker.ObjectDetails o = new OracleCodeDeploymentChecker.ObjectDetails ( objectRs.getString ( "owner" ).toLowerCase () , objectRs.getString ( "object_name" ).toLowerCase () , objectRs.getString ( "object_type" ).toLowerCase () );

                LOG.debug ( "Size of object collection : " + OBJECTS.size () );

                OBJECTS.remove ( o );

                LOG.debug ( "Size of object collection after removing " + o + " : " + OBJECTS.size () );

                if ( OBJECTS.isEmpty () )
                {
                    break;
                }
            }

            if ( ! OBJECTS.isEmpty () )
            {
                OBJECTS.forEach ( o -> LOG.error ( "The object '" + o.toString () + "' was not found on the database." ) );

                foundProblem = true;
            }
        }
        catch ( Exception e )
        {
            throw e;
        }
        finally
        {
            objectRs.close ();
            objectPStmt.close ();
            conn.close ();
        }
    }

    public boolean getResult ()
    {
        return foundProblem;
    }
}