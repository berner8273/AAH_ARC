package com.aptitudesoftware.test.tlf.database;

import java.sql.Connection;

public interface IDatabaseConnector
{
    public Connection getConnection () throws Exception;
}