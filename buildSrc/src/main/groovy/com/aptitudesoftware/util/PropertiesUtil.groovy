package com.aptitudesoftware.util;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

public class PropertiesUtil {
    static Properties getProperties ( final Path pPathToPropertiesFile ) {
        assert ( Files.exists ( pPathToPropertiesFile ) );
        Properties props = new Properties();
        props.load ( Files.newInputStream ( pPathToPropertiesFile ) );
        return props;
    }
}