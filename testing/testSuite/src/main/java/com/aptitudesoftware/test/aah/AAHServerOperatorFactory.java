package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.server.IServerOperator;
import com.aptitudesoftware.test.tlf.server.SUDOServerOperator;
import com.aptitudesoftware.test.tlf.server.SSHServerOperator;

import java.net.InetAddress;
import java.nio.file.Files;

import org.apache.log4j.Logger;

public class AAHServerOperatorFactory
{
    private static final Logger LOG = Logger.getLogger ( AAHServerOperatorFactory.class );

    public static IServerOperator getServerOperator ()
    {
        IServerOperator serverOperator = null;

        try
        {
            String hostname = "Unknown";

            //InetAddress addr;

            hostname = InetAddress.getLocalHost ().getHostName ();

            LOG.debug ( "The name of the host on which the test is running is : " + hostname );

            if ( hostname.equals ( AAHEnvironmentConstants.APTITUDE_HOST ) )
            {
                LOG.debug ( "Return a SUDOServerOperator" );

                serverOperator = new SUDOServerOperator ( AAHEnvironmentConstants.APTITUDE_TEST_LINUX_USERNAME );
            }
            else
            {
                LOG.debug ( "Return an SSHServerOperator" );
                
                LOG.debug ( "The path to the SSH key is claimed to be : '" + AAHEnvironmentConstants.PATH_TO_SSH_KEY + "'" );

                if ( Files.exists ( AAHEnvironmentConstants.PATH_TO_SSH_KEY ) && Files.isRegularFile ( AAHEnvironmentConstants.PATH_TO_SSH_KEY ) )
                {
                    LOG.debug ( "Return an SSHServerOperator which will use password-less SSH" );

                    serverOperator = new SSHServerOperator ( AAHEnvironmentConstants.APTITUDE_HOST , AAHEnvironmentConstants.APTITUDE_TEST_LINUX_USERNAME , AAHEnvironmentConstants.PATH_TO_SSH_KEY );
                }
                else
                {
                    LOG.debug ( "Return an SSHServerOperator which will use SSH but need passwords" );

                    serverOperator = new SSHServerOperator ( AAHEnvironmentConstants.APTITUDE_HOST , AAHEnvironmentConstants.APTITUDE_TEST_LINUX_USERNAME , AAHEnvironmentConstants.APTITUDE_TEST_LINUX_PASSWORD );
                }
            }
        }
        catch ( Exception e )
        {
            LOG.debug ( "An unexpected exception occurred whilst trying to construct a server operator : " + e );

            System.exit ( 1 );
        }

        return serverOperator;
    }
}