package com.aptitudesoftware.batch;

import java.io.InputStream;
import java.io.IOException;
import java.util.UUID;

import java.util.concurrent.TimeoutException;
import java.util.Locale;

import uk.co.microgen.aptitude.bus.protocol.AptitudeServiceType;
import uk.co.microgen.aptitude.bus.DataFormatRegistry;
import uk.co.microgen.aptitude.bus.ExecutorBusSession;
import uk.co.microgen.aptitude.bus.response.ServiceCallResponseWrapper;
import uk.co.microgen.aptitude.data.dataobject.DataObject;
import uk.co.microgen.aptitude.data.dataobject.DataObjectMessage;
import uk.co.microgen.aptitude.bus.exceptions.BusException;
import uk.co.microgen.aptitude.bus.protocol.exceptions.BusServerException;
import uk.co.microgen.aptitude.exceptions.DataObjectInvalidException;
import uk.co.microgen.aptitude.exceptions.MalformedXMLException;
import uk.co.microgen.aptitude.xml.ExecutionDataObjectFactory;

import org.apache.log4j.Logger;

public class CallAptitude
{
    private static final Logger LOGGER = Logger.getLogger ( CallAptitude.class );

    public static DataObject getTriggeringDataObject ( final InputStream pTriggeringDODefinition ) throws IOException , MalformedXMLException
    {
        return ExecutionDataObjectFactory.readDataDefinition ( pTriggeringDODefinition );
    }

    public static DataObjectMessage getTriggeringDataObjectMessage ( DataObject pTriggeringDataObject )
    {
        return new DataObjectMessage ( pTriggeringDataObject );
    }

    private static ServiceCallResponseWrapper start
    (
        final String              pFolderName
    ,   final String              pProjectName
    ,   final String              pAptitudeBusHost
    ,   final int                 pAptitudeBusPort
    ,   final String              pServiceName
    ,   final DataObjectMessage   pTriggeringDataObjectMessage
    ,   final DataObject          pTriggeringDataObject
    ,   final AptitudeServiceType pAptitudeServiceType
    ,   final String              pInputNodeName
    )
    throws IOException , BusException , DataObjectInvalidException , BusServerException , ClassNotFoundException , TimeoutException , Exception
    {
              int                        returnCode               = 0;
              ExecutorBusSession         session                  = null;
        final String                     sessionId                = UUID.randomUUID().toString();
        final DataFormatRegistry         REGISTRY                 = new DataFormatRegistry();
        final long                       BUS_TIMEOUT              = 36000000;
        final int                        NO_OF_RECONNECT_ATTEMPTS = 3;
        final long                       BUS_RECONNECTION_PERIOD  = 10000;
              ServiceCallResponseWrapper response                 = null;

        try
        {
            LOGGER.debug ( "Adding data object to registry" );
            REGISTRY.add ( pTriggeringDataObject );

            LOGGER.debug ( "Attempting to connect to bus host : '" + pAptitudeBusHost + "'; bus port : '" + pAptitudeBusPort + "'; session id : '" + sessionId + "'; folder name : '" + pFolderName + "'; project name : '" + pProjectName + "'" );
            session = ExecutorBusSession.connect
                      (
                          REGISTRY
                      ,   String.format ( "%s/%s" , pFolderName , pProjectName )
                      ,   sessionId
                      ,   null
                      ,   pAptitudeBusHost
                      ,   pAptitudeBusPort
                      ,   BUS_TIMEOUT
                      ,   NO_OF_RECONNECT_ATTEMPTS
                      ,   BUS_RECONNECTION_PERIOD
                      );

            LOGGER.debug ( "Attempting to invoke project '" + pFolderName + "/" + pProjectName + "'" );
            response = session.callAptitudeService
                       (
                           pProjectName
                       ,   pServiceName
                       ,   pAptitudeServiceType
                       ,   pInputNodeName
                       ,   pTriggeringDataObjectMessage
                       ,   pFolderName
                       ,   pProjectName
                       ,   Locale.getDefault()
                       );

            LOGGER.debug ( "Successfully invoked " + pAptitudeServiceType + " : '" + pFolderName + "/" + pProjectName + "'" );
        }
        catch ( IOException ioe )
        {
            LOGGER.debug ( ioe );
            throw ioe;
        }
        catch ( BusException be )
        {
            LOGGER.debug ( be );
            throw be;
        }
        catch ( DataObjectInvalidException doie )
        {
            LOGGER.debug ( doie );
            throw doie;
        }
        catch ( BusServerException bse )
        {
            LOGGER.debug ( bse );
            throw bse;
        }
        catch ( ClassNotFoundException cnfe )
        {
            LOGGER.debug ( cnfe );
            throw cnfe;
        }
        catch ( TimeoutException toe )
        {
            LOGGER.debug ( toe );
            throw toe;
        }
        catch ( Exception e )
        {
            LOGGER.debug ( e );
            throw e;
        }
        finally
        {
            if ( session != null )
            {
                LOGGER.debug ( "Attempting to disconnect from bus" );

                session.disconnect();

                LOGGER.debug ( "Successfully disconnected from bus" );
            }
        }

        return response;
    }

    public static ServiceCallResponseWrapper startMicroflow
    (
        final String            pFolderName
    ,   final String            pProjectName
    ,   final String            pAptitudeBusHost
    ,   final int               pAptitudeBusPort
    ,   final String            pMicroflowName
    ,   final DataObjectMessage pTriggeringDataObjectMessage
    ,   final DataObject        pTriggeringDataObject
    )
    throws IOException , BusException , DataObjectInvalidException , BusServerException , ClassNotFoundException , TimeoutException , Exception
    {
        return start
               (
                   pFolderName
               ,   pProjectName
               ,   pAptitudeBusHost
               ,   pAptitudeBusPort
               ,   pMicroflowName
               ,   pTriggeringDataObjectMessage
               ,   pTriggeringDataObject
               ,   AptitudeServiceType.Microflow
               ,   "Source"
               );
    }

    public static ServiceCallResponseWrapper startBusinessProcess
    (
        final String            pFolderName
    ,   final String            pProjectName
    ,   final String            pAptitudeBusHost
    ,   final int               pAptitudeBusPort
    ,   final String            pBPDName
    ,   final DataObjectMessage pTriggeringDataObjectMessage
    ,   final DataObject        pTriggeringDataObject
    )
    throws IOException , BusException , DataObjectInvalidException , BusServerException , ClassNotFoundException , TimeoutException , Exception
    {
        return start
               (
                   pFolderName
               ,   pProjectName
               ,   pAptitudeBusHost
               ,   pAptitudeBusPort
               ,   pBPDName
               ,   pTriggeringDataObjectMessage
               ,   pTriggeringDataObject
               ,   AptitudeServiceType.BusinessProcessDiagram
               ,   "Event"
               );
    }
}