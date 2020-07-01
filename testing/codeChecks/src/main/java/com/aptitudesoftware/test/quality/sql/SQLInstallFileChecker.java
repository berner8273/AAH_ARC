package com.aptitudesoftware.test.quality.sql;

import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.FileVisitResult;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Stream;
import java.util.regex.Pattern;
import org.apache.log4j.Logger;

public class SQLInstallFileChecker extends SimpleFileVisitor <Path>
{
    private static final Logger LOG = Logger.getLogger ( SQLInstallFileChecker.class );

    private final Set <Path> ACTUAL_SQL_FILES     = new HashSet <Path> ();
    private final Set <Path> REFERENCED_SQL_FILES = new HashSet <Path> ();
    private       Path       PATH_TO_ROOT_FOLDER  = null;
    private       boolean    foundProblem         = false;

    public SQLInstallFileChecker ( final Pattern pRegexPattern , final Path pPathToInstallFile ) throws Exception
    {
        if ( ! ( Files.isRegularFile ( pPathToInstallFile ) && pPathToInstallFile.getFileName ().toString ().equals ( "install.sql" ) ) ) { assert ( false ); }

        PATH_TO_ROOT_FOLDER = pPathToInstallFile.getParent ();

        LOG.debug ( "PATH_TO_ROOT_FOLDER = '" + PATH_TO_ROOT_FOLDER.toString () + "'" );

        Files.walkFileTree
        (
            PATH_TO_ROOT_FOLDER
        ,   this
        );

        try ( Stream <String> fileStream = Files.lines ( pPathToInstallFile ) )
        {
            fileStream.filter ( fstr -> pRegexPattern.matcher ( fstr ).lookingAt () ).forEach (
                                                                                                  pstr -> {
                                                                                                              Path p = PATH_TO_ROOT_FOLDER.resolve ( pstr.replaceAll ( pRegexPattern.pattern () , "" ) );
                                                                                                              
                                                                                                              if ( ! REFERENCED_SQL_FILES.contains ( p ) )
                                                                                                              {
                                                                                                                  REFERENCED_SQL_FILES.add ( p );
                                                                                                              }
                                                                                                              else
                                                                                                              {
                                                                                                                  LOG.error ( "'" + pPathToInstallFile.toString () + "' contains duplicate references to '" + p.toString () + "'" );
                                                                                                              
                                                                                                                  foundProblem = true;
                                                                                                              }
                                                                                                          }
                                                                                              );
        }
        catch ( Exception e )
        {
            LOG.error ( "An exception occured whilst checking the quality of the file '" + pPathToInstallFile.toString () + "' : " + e );
        }

        REFERENCED_SQL_FILES.forEach ( p -> LOG.debug ( "REFERENCED_SQL_FILES contains '" + p.toString () + "'" ) );

        ACTUAL_SQL_FILES.forEach ( p -> LOG.debug ( "ACTUAL_SQL_FILES contains '" + p.toString () + "'" ) );

        REFERENCED_SQL_FILES.forEach ( nef -> { if ( ! ACTUAL_SQL_FILES.contains     ( nef ) ){ LOG.error ( "'" + pPathToInstallFile.toString () + "' references the non-existent file " + nef.toString () ); foundProblem = true; } } );

        ACTUAL_SQL_FILES.forEach     ( nef -> { if ( ! REFERENCED_SQL_FILES.contains ( nef ) ){ LOG.error ( "'" + pPathToInstallFile.toString () + "' does not reference the file " + nef.toString () ); foundProblem = true; } } );
    }

    @Override
    public FileVisitResult visitFile ( Path pFile , BasicFileAttributes attrs )
    {
        if ( ! pFile.getParent ().equals ( PATH_TO_ROOT_FOLDER ) )
        {
            ACTUAL_SQL_FILES.add ( pFile );
        }

        return FileVisitResult.CONTINUE;
    }

    public boolean getResult ()
    {
        return foundProblem;
    }
}