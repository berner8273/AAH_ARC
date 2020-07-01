package com.aptitudesoftware.test.tlf.server;

import java.nio.file.Path;

public interface IServerOperator
{
    public void deleteContentsOfFolder  ( final String pPathToFolder ) throws Exception;

    public void retrieveFileFromServer  ( final String pPathToSourceFileOnServer , final Path pPathToLocalTargetFolder ) throws Exception;

    public void sendFileToServer        ( final String pPathToTargetFolderOnServer , final Path pPathToLocalFile ) throws Exception;

    public void executeCommand          ( final String pCommand ) throws Exception;
}