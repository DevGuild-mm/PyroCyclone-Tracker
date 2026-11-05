package util;

import org.junit.jupiter.api.Test;
import java.sql.Connection;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class DbConnectionTest {

    @Test
    public void testOpenConnection() {
        Connection conn = DbConnection.openConnection();
        assertNotNull(conn);
    }
}