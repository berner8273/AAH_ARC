package com.aptitudesoftware.test.quality.sql.oracle.code;

import com.aptitudesoftware.test.quality.sql.SQLCodePattern;
import com.aptitudesoftware.test.quality.sql.ISQLCodeQualityChecker;
import com.aptitudesoftware.test.quality.sql.SQLBadEOLFileChecker;
import com.aptitudesoftware.test.quality.sql.SQLBadFileNameChecker;
import com.aptitudesoftware.test.quality.sql.SQLFileExtensionChecker;
import com.aptitudesoftware.test.quality.sql.SQLEmptyFileChecker;
import com.aptitudesoftware.test.quality.sql.SQLFileSetQualityChecker;
import com.aptitudesoftware.test.quality.sql.SQLInstallFileChecker;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.regex.Pattern;
import java.util.Map;
import org.apache.log4j.Logger;

public class OracleCodeQualityChecker implements ISQLCodeQualityChecker
{
    private static final Logger LOG = Logger.getLogger ( OracleCodeQualityChecker.class );

    /*
     * Check that files with the file extension pFileExtension in directory pPathToRootFolder and all of its children do not contain \r EOL characters.
     */
    public boolean hasBadEOLCharacters ( final Path pPathToRootFolder ) throws Exception
    {
        if ( ! Files.isDirectory ( pPathToRootFolder ) ) { LOG.error ( "The path '" + pPathToRootFolder + "' does not represent a directory" ); assert ( false ); };

        return new SQLBadEOLFileChecker ( pPathToRootFolder ).getResult ();
    }

    /*
     * Check that files with the file extension pFileExtension in directory pPathToRootFolder and all of its children are named in lowercase.
     */
    public boolean hasBadFileNames ( final Path pPathToRootFolder ) throws Exception
    {
        if ( ! Files.isDirectory ( pPathToRootFolder ) ) { LOG.error ( "The path '" + pPathToRootFolder + "' does not represent a directory" ); assert ( false ); };

        return new SQLBadFileNameChecker ( pPathToRootFolder ).getResult ();
    }

    /*
     * Check that files with the file extension pFileExtension in directory pPathToRootFolder and all of its children are not empty.
     */
    public boolean areFilesEmpty ( final Path pPathToRootFolder ) throws Exception
    {
        if ( ! Files.isDirectory ( pPathToRootFolder ) ) { LOG.error ( "The path '" + pPathToRootFolder + "' does not represent a directory" ); assert ( false ); };

        return new SQLEmptyFileChecker ( pPathToRootFolder ).getResult ();
    }

    /*
     * Check that files have the expected file extension
     */
    public boolean hasBadFileExtensions ( final Path pPathToRootFolder ) throws Exception
    {
        if ( ! Files.isDirectory ( pPathToRootFolder ) ) { LOG.error ( "The path '" + pPathToRootFolder + "' does not represent a directory" ); assert ( false ); };

        return new SQLFileExtensionChecker ( pPathToRootFolder ).getResult ();
    }

    /*
     * (1) Check that files referred to by the file pPathToInstallFile exist.
     * (2) Check that all files in codebase ar referred to by the file pPathToInstallFile.
     * (3) Check that no duplicate entries exist in the file pPathToInstallFile.
     */
    public boolean checkInstallScriptQuality ( final Path pPathToInstallFile ) throws Exception
    {
        if ( ! Files.isRegularFile ( pPathToInstallFile ) )                             { LOG.error ( "The file '" + pPathToInstallFile + "' does not exist" );              assert ( false ); };
        if ( ! pPathToInstallFile.getFileName ().toString ().equals ( "install.sql" ) ) { LOG.error ( "The file '" + pPathToInstallFile + "' is not called 'install.sql'" ); assert ( false ); };
       
        return new SQLInstallFileChecker ( Pattern.compile ( "@@" ) , pPathToInstallFile ).getResult ();
    }

    /*
     * Check that files with the file extension pFileExtension in directory pPathToRootFolder and all of its children meet the patterns specified in pCodePattern.
     */
    public boolean checkFileSetQuality ( final Path pPathToRootFolder , final Map <String, String> pPathToDBNameMappings ) throws Exception
    {
        return new SQLFileSetQualityChecker ( pPathToRootFolder , SQLCodePattern.ORACLE_CREATE_TABLE , SQLCodePattern.ORACLE_CREATE_VIEW , SQLCodePattern.ORACLE_INSERT_DATA , SQLCodePattern.ORACLE_CREATE_PROCEDURE , SQLCodePattern.ORACLE_CREATE_RI , SQLCodePattern.ORACLE_CREATE_INDEX , SQLCodePattern.ORACLE_GRANT , SQLCodePattern.ORACLE_PACKAGE , SQLCodePattern.ORACLE_SEQUENCE , pPathToDBNameMappings , SQLCodePattern.ORACLE_CREATE_FUNCTION).getResult ();
    }
}