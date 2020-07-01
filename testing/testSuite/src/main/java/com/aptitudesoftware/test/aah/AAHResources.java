package com.aptitudesoftware.test.aah;

import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.log4j.Logger;

public class AAHResources
{
    private static final Logger LOG = Logger.getLogger ( AAHResources.class );

    public static Path getPathToResource ( final String pPathToResource )
    {
        LOG.debug ( "Obtaining a path to the resource '" + pPathToResource + "'" );

        Path p = null;

        try
        {
            LOG.debug ( "Building a full path to the resource '" + pPathToResource + "'" );
            
            URL url = AAHResources.class.getClassLoader ().getResource ( pPathToResource );
            
            p = (url == null) ? null : Paths.get( url.toURI () );

            LOG.debug ( "The full path to the resoutce 'p' = " + p.toString () );

            if ( p == null || ! Files.exists ( p ) ) { LOG.debug ( "'" + p.toString () + "' does not exist. Exiting ... " ); assert ( false ); }
        }
        catch ( URISyntaxException use )
        {
            LOG.debug ( "URISyntaxException + '" + use + "'" );

            assert ( false );
        }
        catch ( Exception e )
        {
            LOG.debug ( "An unexpected exception occurred when obtaining a path to the resource " + pPathToResource + " : " + e );
            
            assert ( false );
        }

        return p;
    }
}