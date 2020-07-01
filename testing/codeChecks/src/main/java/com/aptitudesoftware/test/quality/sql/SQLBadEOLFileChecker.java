package com.aptitudesoftware.test.quality.sql;

import java.io.BufferedReader;
import java.nio.charset.Charset;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.Files;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import org.apache.log4j.Logger;

public class SQLBadEOLFileChecker extends SimpleFileVisitor <Path>
{
    private static final Logger LOG = Logger.getLogger ( SQLBadEOLFileChecker.class );

    private boolean           foundBadEOL = false;
    private final PathMatcher MATCHER     = FileSystems.getDefault().getPathMatcher ( "glob:**/*.{sql}" );

    public SQLBadEOLFileChecker ( final Path pPathToRootFolder ) throws Exception
    {
        Files.walkFileTree
        (
            pPathToRootFolder
        ,   this
        );
    }

    @Override
    public FileVisitResult visitFile ( Path pFile , BasicFileAttributes attrs )
    {
        LOG.debug ( "Check file : '" + pFile.toString () + "' for bad EOL characters" );

        if ( MATCHER.matches ( pFile ) )
        {
            LOG.debug ( "File : '" + pFile.toString () + "' is a .sql file" );

            try ( BufferedReader fileReader = Files.newBufferedReader ( pFile , Charset.forName ( "UTF-8" ) ); )
            {
                int     currentChar;
                boolean badEol = false;

                while ( ( currentChar = fileReader.read () ) != -1 )
                {
                    if ( currentChar == '\r' )
                    {
                        currentChar = fileReader.read ();

                        if ( ! ( currentChar == '\n' ) )
                        {
                            foundBadEOL = true;

                            badEol      = true;
                        }
                    }
                }

                if ( badEol )
                {
                    LOG.error ( "File \"" + pFile.toString () + "\" has some \"\\r\" end-of-line characters. Change these to \"\\r\\n\" or just \"\\n\"." );
                }
            }
            catch ( Exception e )
            {
                LOG.error ( "An exception occured whilst checking to see whether the file '" + pFile.toString () + "' contains bad EOL characters : " + e );
            }
        }
        else
        {
            LOG.debug ( "The file '" + pFile.toString () + "' did not match the pattern." );
        }

        return FileVisitResult.CONTINUE;
    }

    public boolean getResult ()
    {
        return foundBadEOL;
    }
}