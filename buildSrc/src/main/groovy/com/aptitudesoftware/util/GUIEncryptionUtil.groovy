package com.aptitudesoftware.util;

import uk.co.microgen.tomcat.EncryptedDataSourceFactory;

public class GUIEncryptionUtil {
    static String getGUIEncryptedString ( final String pStringToEncrypt ) {
        return EncryptedDataSourceFactory.encode ( pStringToEncrypt );
    }
}