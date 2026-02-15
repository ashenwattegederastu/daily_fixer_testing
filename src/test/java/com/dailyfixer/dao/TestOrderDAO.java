package com.dailyfixer.dao;

import com.dailyfixer.util.TestDBConnection;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Test subclass of OrderDAO to inject H2 connection.
 */
public class TestOrderDAO extends OrderDAO {

    @Override
    protected Connection getConnection() throws SQLException, ClassNotFoundException {
        return TestDBConnection.getConnection();
    }
}
