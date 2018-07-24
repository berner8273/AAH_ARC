package com.aptitudesoftware.batch;

import java.math.BigDecimal;

import org.apache.log4j.Logger;

import uk.co.microgen.aptitude.bus.response.ServiceCallResponseWrapper;
import uk.co.microgen.aptitude.data.dataobject.DataObject;
import uk.co.microgen.aptitude.data.dataobject.DataObjectMessage;
import uk.co.microgen.aptitude.data.dataobject.DataSegmentValues;
import uk.co.microgen.aptitude.data.NumericAttributeValue;
import uk.co.microgen.aptitude.data.StringAttributeValue;
import uk.co.microgen.aptitude.exceptions.MalformedXMLException;
import com.aptitudesoftware.batch.CallAptitude;

public class StartStep
{
    private static final Logger LOGGER = Logger.getLogger ( StartStep.class );

    /** */
    public static void main ( String args [] ) throws Exception , MalformedXMLException
    {
        final String APTITUDE_BUS_HOST         = args [ 0 ];
        final int    APTITUDE_BUS_PORT         = Integer.parseInt ( args [ 1 ] );
        final String TRIGGERING_PROJECT_FOLDER = args [ 2 ];
        final String TRIGGERING_PROJECT        = args [ 3 ];
        final String TRIGGERING_SERVICE        = args [ 4 ];
        final String TRIGGERED_STEP            = args [ 5 ];

              int returnCode = 0;

        LOGGER.debug ( "Aptitude bus host = '"           + APTITUDE_BUS_HOST         + "'" );
        LOGGER.debug ( "Aptitude bus port = '"           + APTITUDE_BUS_PORT         + "'" );
        LOGGER.debug ( "Triggering project's folder = '" + TRIGGERING_PROJECT_FOLDER + "'" );
        LOGGER.debug ( "Triggering project's name = '"   + TRIGGERING_PROJECT        + "'" );
        LOGGER.debug ( "Triggering service name = '"     + TRIGGERING_SERVICE        + "'" );
        LOGGER.debug ( "Triggered  step = '"             + TRIGGERED_STEP            + "'" );

        try
        {
            final DataObject        TRIGGERING_DATA_OBJECT         = CallAptitude.getTriggeringDataObject        ( StartStep.class.getResourceAsStream ( "trigger.xml" ) );
            final DataObjectMessage TRIGGERING_DATA_OBJECT_MESSAGE = CallAptitude.getTriggeringDataObjectMessage ( TRIGGERING_DATA_OBJECT );
            final DataSegmentValues TRIGGERING_OBJECT_MESSAGE_ROOT = TRIGGERING_DATA_OBJECT_MESSAGE.createRootSegment ();

            TRIGGERING_OBJECT_MESSAGE_ROOT.setValue ( "step_cd"     , new StringAttributeValue  ( TRIGGERED_STEP ) );
            TRIGGERING_OBJECT_MESSAGE_ROOT.setValue ( "return_code" , new NumericAttributeValue ( BigDecimal.ZERO ) );

            ServiceCallResponseWrapper response = CallAptitude.startBusinessProcess
                                                  (
                                                      TRIGGERING_PROJECT_FOLDER
                                                  ,   TRIGGERING_PROJECT
                                                  ,   APTITUDE_BUS_HOST
                                                  ,   APTITUDE_BUS_PORT
                                                  ,   TRIGGERING_SERVICE
                                                  ,   TRIGGERING_DATA_OBJECT_MESSAGE
                                                  ,   TRIGGERING_DATA_OBJECT
                                                  );

            returnCode = new Integer ( response.getMessage().getRoot().get ( 0 ).getValue ( "return_code" ).toString() );

            LOGGER.debug ( "The data object '" + response.getMessage().getRoot() + "' was returned." );

            if ( returnCode != 0 )
            {
                throw new Exception ( "Non zero return code" );
            }
        }
        catch ( MalformedXMLException mxe )
        {
            LOGGER.debug ( mxe );

            System.exit ( -1 );
        }
        catch ( Exception e )
        {
            LOGGER.debug ( e );

            System.exit ( -2 );
        }
    }
}