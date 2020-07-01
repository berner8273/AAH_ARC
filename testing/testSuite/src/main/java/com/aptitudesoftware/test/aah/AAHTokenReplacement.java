package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.string.ITokenReplacement;

public class AAHTokenReplacement implements ITokenReplacement
{
    public String replaceTokensInString ( final String pString )
    {
        // if sql embedded within the test suite does not feature hardcoded database names, 
    	// this method can be implemented to modify the sql text at runtime*. e.g:
         return pString.replaceAll ( "@stnUsername@"           , AAHEnvironmentConstants.AAH_STN_DB )
                       .replaceAll ( "@fdrUsername@"           , AAHEnvironmentConstants.AAH_FDR_DB )
                       .replaceAll ( "@slrUsername@"           , AAHEnvironmentConstants.AAH_SLR_DB )
                       .replaceAll ( "@guiUsername@"           , AAHEnvironmentConstants.AAH_GUI_DB )
                       .replaceAll ( "@rdrUsername@"           , AAHEnvironmentConstants.AAH_RDR_DB )
                       .replaceAll ( "@ioUsername@"            , AAHEnvironmentConstants.AAH_IO_DB )
                       .replaceAll ( "@stnDatabase@"           , AAHEnvironmentConstants.AAH_STN_DB )
                       .replaceAll ( "@fdrDatabase@"           , AAHEnvironmentConstants.AAH_FDR_DB )
                       .replaceAll ( "@slrDatabase@"           , AAHEnvironmentConstants.AAH_SLR_DB )
                       .replaceAll ( "@guiDatabase@"           , AAHEnvironmentConstants.AAH_GUI_DB )
                       .replaceAll ( "@rdrDatabase@"           , AAHEnvironmentConstants.AAH_RDR_DB )
                       .replaceAll ( "@ioDatabase@"            , AAHEnvironmentConstants.AAH_IO_DB )
                       .replaceAll ( "@databaseTestSchema@", AAHEnvironmentConstants.DATABASE_TEST_SCHEMA );
         
    }
}
