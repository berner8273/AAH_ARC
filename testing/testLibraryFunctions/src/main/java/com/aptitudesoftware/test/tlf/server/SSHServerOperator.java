package com.aptitudesoftware.test.tlf.server;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;
import org.apache.log4j.Logger;

public class SSHServerOperator implements IServerOperator
{
    private static final Logger LOG = Logger.getLogger ( SSHServerOperator.class );

    private String serverName          = "";
    private String userName            = "";
    private String password            = "";
    private Path   pathToKey           = null;
    private boolean usePasswordLessSSH = false;

    public SSHServerOperator ( final String pServerName , final String pUserName , final String pPassword )
    {
        serverName = pServerName;

        LOG.debug ( "serverName has been set to '" + pServerName + "'" );

        userName = pUserName;

        LOG.debug ( "userName has been set to '" + pUserName + "'" );

        password = pPassword;
    }

    public SSHServerOperator ( final String pServerName , final String pUserName , final Path pPathToKey )
    {
        serverName = pServerName;

        LOG.debug ( "serverName has been set to '" + pServerName + "'" );

        userName = pUserName;

        LOG.debug ( "userName has been set to '" + pUserName + "'" );

        LOG.debug ( "The path to the key is claimed to be : " + pPathToKey );
        
        assert ( Files.exists ( pPathToKey ) && Files.isRegularFile ( pPathToKey ) );

        LOG.debug ( "The path to the key points to a real file" );

        pathToKey = pPathToKey;

        usePasswordLessSSH = true;
    }

    private int checkAck ( InputStream in ) throws Exception
    {
        int b = in.read ();
        // b may be 0 for success,
        //          1 for error,
        //          2 for fatal error,
        //          -1
        if ( b == 0 )
        {
            return b;
        }

        if ( b == -1 )
        {
            return b;
        }

        if ( b == 1 || b == 2 )
        {
            StringBuffer sb = new StringBuffer();
            int c;

            do
            {
                c=in.read ();
                sb.append ( (char) c );
            }
            while ( c != '\n' );

            if ( b == 1 )
            { // error
                LOG.debug ( sb.toString () );
            }

            if ( b == 2 )
            { // fatal error
                LOG.debug ( sb.toString () );
            }
        }
        return b;
    }

    public void executeCommand ( final String pCommand ) throws Exception
    {
        LOG.debug ( "The command '" + pCommand + "' will be executed on the server '" + serverName + "'" );

        Session session = null;

        Channel channel = null;

        ChannelExec channelExec = null;

        BufferedReader reader = null;

        try
        {
            final JSch JSCH = new JSch ();

            LOG.debug ( "Created JSch object" );

            session = JSCH.getSession ( userName , serverName , 22 );

            LOG.debug ( "Defined session - username = '" + userName + "', server name = '" + serverName + "'" );

            if ( usePasswordLessSSH )
            {
                LOG.debug ( "Setting key for password-less SSH ..." );

                JSCH.addIdentity ( pathToKey.toString () );
                
                LOG.debug ( "Key for password-less SSH set" );
            }
            else
            {
                LOG.debug ( "Setting password ..." );
                
                session.setPassword ( password );
                
                LOG.debug ( "Password set" );
            }

            final Properties CONFIG = new Properties ();

            LOG.debug ( "Created configuration properties" );

            CONFIG.put ( "StrictHostKeyChecking" , "no" );

            LOG.debug ( "Set StrictHostKeyChecking to 'no'" );

            session.setConfig ( CONFIG );

            LOG.debug ( "Configured session with configuration properties" );

            session.connect ();

            LOG.debug ( "Connected to remote host" );

            channel = session.openChannel ( "exec" );

            channelExec = ( ChannelExec ) channel;

            LOG.debug ( "Opened a channel to execute a command" );

            channelExec.setCommand ( pCommand );

            LOG.debug ( "Set the command to be executed = '" + pCommand + "'" );

            channelExec.setErrStream ( System.err );

            LOG.debug ( "Error stream has been set" );

            channel.connect ();

            LOG.debug ( "Command executed. Reading output ... " );

            reader = new BufferedReader ( new InputStreamReader ( channel.getInputStream () ) );

            String line;

            int i = 1;

            while ( ( line = reader.readLine () ) != null )
            {
                LOG.debug ( "Output line " + i + " : " + line );

                i++;
            }

            final int RETURN_CODE = channelExec.getExitStatus ();

            LOG.debug ( "The return code was '" + RETURN_CODE + "'" );

            if ( RETURN_CODE != 0 )
            {
                LOG.debug ( "The remote command ended with a failure" );

                throw new Exception ( "The attempt to issue the remote command '" + pCommand + "' failed" );
            };
        }
        catch ( Exception e )
        {
            LOG.error ( "The following exception was raised whilst executing a command on a remote server: '" + e + "'" );

            if ( reader != null )
            {
                reader.close ();
            }

            throw e;
        }
        finally
        {
            if ( channelExec != null )
            {
                LOG.debug ( "Disconnecting JSCH channelExec" );

                channelExec.disconnect ();
            }

            if ( channel != null )
            {
                LOG.debug ( "Disconnecting JSCH channel" );

                channel.disconnect ();
            }

            if ( session != null )
            {
                LOG.debug ( "Disconnecting JSCH session" );

                session.disconnect ();
            }
        }
    }

    public void deleteContentsOfFolder ( final String pPathToFolder ) throws Exception
    {
        executeCommand ( "rm -rf " + pPathToFolder.trim ().replaceAll ( "/$" , "/*" ) );
    }

    public void retrieveFileFromServer  ( final String pPathToSourceFileOnServer , final Path pPathToLocalTargetFolder ) throws Exception
    {
        LOG.debug ( "The file '" + pPathToSourceFileOnServer + "' will be retrieved from '" + serverName + "' and placed on this machine at '" + pPathToLocalTargetFolder.toString () + "'" );

        if ( ! Files.exists ( pPathToLocalTargetFolder ) )
        {
            LOG.error ( "'" + pPathToLocalTargetFolder + "' does not exist" );

            assert ( false );
        }

        if ( ! Files.isDirectory ( pPathToLocalTargetFolder ) )
        {
            LOG.error ( "'" + pPathToLocalTargetFolder + "' is not a directory" );

            assert ( false );
        }

        if ( ! Files.isWritable ( pPathToLocalTargetFolder ) )
        {
            LOG.error ( "'" + pPathToLocalTargetFolder + "' is not writable" );

            assert ( false );
        }

        Session session = null;

        Channel channel = null;

        ChannelExec channelExec = null;

        InputStream in = null;

        OutputStream out = null;

        OutputStream fos = null;

        try
        {
            final JSch JSCH = new JSch ();

            LOG.debug ( "Created JSch object" );

            session = JSCH.getSession ( userName , serverName , 22 );

            LOG.debug ( "Defined session - username = '" + userName + "', server name = '" + serverName + "'" );

            if ( usePasswordLessSSH )
            {
                LOG.debug ( "Setting key for password-less SSH ..." );

                JSCH.addIdentity ( pathToKey.toString () );
                
                LOG.debug ( "Key for password-less SSH set" );
            }
            else
            {
                LOG.debug ( "Setting password ..." );
                
                session.setPassword ( password );
                
                LOG.debug ( "Password set" );
            }

            final Properties CONFIG = new Properties ();

            LOG.debug ( "Created configuration properties" );

            CONFIG.put ( "StrictHostKeyChecking" , "no" );

            LOG.debug ( "Set StrictHostKeyChecking to 'no'" );

            session.setConfig ( CONFIG );

            LOG.debug ( "Configured session with configuration properties" );

            session.connect ();

            LOG.debug ( "Connected to remote host" );

            channel = session.openChannel ( "exec" );

            channelExec = ( ChannelExec ) channel;

            LOG.debug ( "Opened a channel to execute a command" );

            channelExec.setCommand ( "scp -f " + pPathToSourceFileOnServer );

            LOG.debug ( "Set the command" );

            out = channel.getOutputStream ();

            LOG.debug ( "Got the outputstream" );

            in = channel.getInputStream ();

            LOG.debug ( "Got the inputstream" );

            channel.connect ();

            LOG.debug ( "Connected to the channel" );

            byte[] buf = new byte[1024];

            // send '\0'

            buf [ 0 ] = 0;

            out.write ( buf , 0 , 1 );

            out.flush ();

            LOG.debug ( "Sent '\0'" );

            while ( true )
            {
                int c = checkAck ( in );

                LOG.debug ( "Checked the acknowledgement, a value of '" + c + "' was returned");

                if ( c != 'C' )
                {
                    LOG.debug ( "The acknowledgement was not the expected character instead, a value of '" + c + "' was returned");

                    break;
                }

                LOG.debug ( "The acknowledgement was as expected" );

                in.read ( buf , 0 , 5 );

                LOG.debug ( "Read from the inputstream" );

                long filesize = 0L;

                LOG.debug ( "Read the size of the remote file from the inputstream ..." );

                while ( true )
                {
                    if ( in.read ( buf , 0 , 1 ) < 0 )
                    {
                        // error

                        LOG.debug ( "Attempted to read from the inputstream into the buffer, but no data was returned." );

                        break;
                    }

                    if ( buf [ 0 ] == ' ' )
                    {
                        LOG.debug ( "The character read into the buffer was white space" );

                        break;
                    }

                    filesize = filesize * 10L + ( long ) ( buf [ 0 ] - '0' );

                    LOG.debug ( "The size of the remote file is '" + filesize + "'" );
                }

                String file = null;

                LOG.debug ( "Read the name of the remote file from the inputstream ..." );

                for ( int i = 0 ; ; i++ )
                {
                    in.read ( buf , i , 1 );

                    if ( buf [ i ] == ( byte ) 0x0a )
                    {
                        file = new String ( buf , 0 , i );

                        break;
                    }
                }

                LOG.debug ( "file '" + file + "'" );

                // send '\0'

                buf [ 0 ] = 0;

                out.write ( buf , 0 , 1 );

                out.flush ();

                // read a content of lfile

                LOG.debug ( "Attempt to obtain an output stream for the local copy of file ..." );

                fos = Files.newOutputStream ( pPathToLocalTargetFolder.resolve ( file ) );

                LOG.debug ( "Output stream for the local copy of the file obtained" );

                int foo;

                while ( true )
                {
                    if ( buf.length < filesize )
                    {
                        LOG.debug ( "Length of the buffer < filesize ( buf.length = " + buf.length + " ; filesize = " + filesize + ")" );

                        foo = buf.length;
                    }
                    else
                    {
                        LOG.debug ( "foo has been set to the filesize (" + filesize + ")" );

                        foo = ( int ) filesize;
                    }

                    foo = in.read ( buf , 0 , foo );

                    LOG.debug ( "Read from the input stream, foo = " + foo + "" );

                    if ( foo < 0 )
                    {
                        LOG.debug ( "No data was read into the buffer" );

                        break;
                    }

                    LOG.debug ( "Attempting to write the contents of the buffer to the output file" );

                    fos.write ( buf , 0 , foo );

                    LOG.debug ( "The contents of the buffer were written to the output file" );

                    filesize -= foo;

                    LOG.debug ( "Filesize = '" + filesize + "'" );

                    if ( filesize == 0L )
                    {
                        break;
                    }
                }

                fos.close ();

                fos = null;

                if ( checkAck ( in ) != 0 )
                {
                    System.exit ( 1 );
                }

                // send '\0'

                buf [ 0 ] = 0;

                out.write ( buf , 0 , 1 );

                out.flush();
            }
        }
        catch ( Exception e )
        {
            LOG.error ( "The following exception was raised whilst retrieving a remote file: '" + e + "'" );

            if ( fos != null )
            {
                fos.close ();
            }

            throw e;
        }
        finally
        {
            if ( in != null )
            {
                LOG.debug ( "Closing JSCH input stream" );

                in.close ();
            }

            if ( out != null )
            {
                LOG.debug ( "Closing JSCH output stream" );

                out.close ();
            }

            if ( channelExec != null )
            {
                LOG.debug ( "Disconnecting JSCH channelExec" );

                channelExec.disconnect ();
            }

            if ( channel != null )
            {
                LOG.debug ( "Disconnecting JSCH channel" );

                channel.disconnect ();
            }

            if ( session != null )
            {
                LOG.debug ( "Disconnecting JSCH session" );

                session.disconnect ();
            }
        }
    }

    public void sendFileToServer ( final String pPathToTargetFolderOnServer , final Path pPathToLocalFile ) throws Exception
    {
        LOG.debug ( "The file '" + pPathToLocalFile.toString () + "' will be sent to the location '" + pPathToTargetFolderOnServer + "' on the server '" + serverName + "'" );

        if ( ! Files.exists ( pPathToLocalFile ) )
        {
            LOG.error ( "'" + pPathToLocalFile + "' does not exist" );

            assert ( false );
        }

        if ( ! Files.isRegularFile ( pPathToLocalFile ) )
        {
            LOG.error ( "'" + pPathToLocalFile + "' is not a regular file" );

            assert ( false );
        }

        Session session = null;

        Channel channel = null;

        ChannelExec channelExec = null;

        InputStream in = null;

        OutputStream out = null;

        InputStream fis = null;

        try
        {
            final JSch JSCH = new JSch ();

            LOG.debug ( "Created JSch object" );

            session = JSCH.getSession ( userName , serverName , 22 );

            LOG.debug ( "Defined session - username = '" + userName + "', server name = '" + serverName + "'" );

            if ( usePasswordLessSSH )
            {
                LOG.debug ( "Setting key for password-less SSH ..." );

                JSCH.addIdentity ( pathToKey.toString () );
                
                LOG.debug ( "Key for password-less SSH set" );
            }
            else
            {
                LOG.debug ( "Setting password ..." );
                
                session.setPassword ( password );
                
                LOG.debug ( "Password set" );
            }

            final Properties CONFIG = new Properties ();

            LOG.debug ( "Created configuration properties" );

            CONFIG.put ( "StrictHostKeyChecking" , "no" );

            LOG.debug ( "Set StrictHostKeyChecking to 'no'" );

            session.setConfig ( CONFIG );

            LOG.debug ( "Configured session with configuration properties" );

            session.connect ();

            LOG.debug ( "Connected to remote host" );

            channel = session.openChannel ( "exec" );

            channelExec = ( ChannelExec ) channel;

            LOG.debug ( "Opened a channel to execute a command" );

            channelExec.setCommand ( "scp -t " + pPathToTargetFolderOnServer );

            LOG.debug ( "Set the command" );

            out = channel.getOutputStream ();

            LOG.debug ( "Got the outputstream" );

            in = channel.getInputStream ();

            LOG.debug ( "Got the inputstream" );

            channel.connect ();

            LOG.debug ( "Connected to the channel" );

            if ( checkAck ( in ) != 0 )
            {
                System.exit ( 1 );
            }

            LOG.debug ( "Checked the acknowledgement" );

            final long LOCAL_FILE_SIZE = Files.size ( pPathToLocalFile );

            LOG.debug ( "The size of the file to be sent = " + LOCAL_FILE_SIZE );

            String command = "C0644 " + LOCAL_FILE_SIZE + " " + pPathToLocalFile.getFileName ().toString () + "\n";

            out.write ( command.getBytes () );

            out.flush();

            if ( checkAck ( in ) != 0 )
            {
                System.exit(0);
            }

            LOG.debug ( "Command set to : '" + command + "'" );

            // send a content of pPathToLocalFile

            fis = Files.newInputStream ( pPathToLocalFile );

            LOG.debug ( "Got an input stream for the file to be sent" );

            byte [] buf = new byte [ 1024 ];

            LOG.debug ( "Created a byte buffer into which the file can be read" );

            while ( true )
            {
                int len = fis.read ( buf , 0 , buf.length );

                if ( len <= 0 )
                {
                    break;
                }

                out.write ( buf , 0 , len );
            }

            LOG.debug ( "Wrote the file out to the channel's output stream" );

            fis.close ();

            fis = null;

            // send '\0'

            buf [ 0 ] = 0;

            out.write ( buf , 0 , 1 );

            out.flush();

            if ( checkAck ( in ) != 0 )
            {
                System.exit ( 1 );
            }
        }
        catch ( Exception e )
        {
            LOG.error ( "The following exception was raised whilst sending a file to a remote location: '" + e + "'" );

            if ( fis != null )
            {
                fis.close ();
            }

            throw e;
        }
        finally
        {
            if ( in != null )
            {
                LOG.debug ( "Closing JSCH input stream" );

                in.close ();
            }

            if ( out != null )
            {
                LOG.debug ( "Closing JSCH output stream" );

                out.close ();
            }

            if ( channelExec != null )
            {
                LOG.debug ( "Disconnecting JSCH channelExec" );

                channelExec.disconnect ();
            }

            if ( channel != null )
            {
                LOG.debug ( "Disconnecting JSCH channel" );

                channel.disconnect ();
            }

            if ( session != null )
            {
                LOG.debug ( "Disconnecting JSCH session" );

                session.disconnect ();
            }
        }
    }
}