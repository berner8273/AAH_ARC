package com.aptitudesoftware.util;

import java.nio.file.Files;
import java.nio.file.Path;

public class LogUtil {
    static Path getPathToLogFolder ( final Path pPathToRootDir ) {
        return pPathToRootDir.resolve ( 'log' );
    }

    static Path getPathToCurrentLogFolder ( final Path pPathToRootDir ) {
        return LogUtil.getPathToLogFolder ( pPathToRootDir ).resolve ( 'current' );
    }

    static Path getPathToLogFolder ( final Path pPathToRootDir , final Path pPathToProjectDir ) {
        return LogUtil.getPathToCurrentLogFolder ( pPathToRootDir ).resolve ( pPathToRootDir.relativize ( pPathToProjectDir ) );
    }
}