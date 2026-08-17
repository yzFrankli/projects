package jrails;

import java.io.File;
import java.lang.reflect.*;
import java.sql.*;
import java.util.*;

public class Model {

    private static final String DB = "sample.db";
    private int id;

    protected static Connection conn() throws SQLException {
        return DriverManager.getConnection("jdbc:sqlite:" + DB);
    }

    /* ───────────────────────────────────────────────
       TABLE CREATION / MIGRATION SUPPORT
       ─────────────────────────────────────────────── */

    private void ensureSelfTable() throws SQLException {
        String table = this.getClass().getSimpleName();

        StringBuilder sb = new StringBuilder("CREATE TABLE IF NOT EXISTS " + table + " (");
        sb.append("id INTEGER PRIMARY KEY");

        for (Field f : this.getClass().getFields()) {
            if (f.isAnnotationPresent(Column.class)) {
                sb.append(", ").append(f.getName()).append(" ");

                String type = f.getType().getSimpleName();
                if (type.equals("String")) sb.append("TEXT");
                else sb.append("INTEGER");
            }
        }

        sb.append(")");

        try (Connection c = conn()) {
            c.createStatement().executeUpdate(sb.toString());
        }
    }


    private static void ensureTable(Class<?> cls) {
        try {
            // Ensure parent table exists
            Object temp = cls.getDeclaredConstructor().newInstance();
            Method ensure = Model.class.getDeclaredMethod("ensureSelfTable");
            ensure.setAccessible(true);
            ensure.invoke(temp);

            // Ensure child tables contain foreign key columns
            for (Field f : cls.getFields()) {
                if (!f.isAnnotationPresent(HasMany.class)) continue;

                if (!(f.getGenericType() instanceof ParameterizedType)) continue;
                ParameterizedType pt = (ParameterizedType) f.getGenericType();
                Class<?> childType = (Class<?>) pt.getActualTypeArguments()[0];

                ensureTable(childType); // recursive ensure

                String parentTable = cls.getSimpleName();
                String childTable = childType.getSimpleName();
                String fk = parentTable + "_id";

                try (Connection c = conn()) {
                    c.createStatement().executeUpdate(
                            "ALTER TABLE " + childTable + " ADD COLUMN " + fk + " INTEGER"
                    );
                } catch (SQLException ignore) {
                    // column already exists
                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }


    /* ───────────────────────────────────────────────
       SERIALIZATION HELPERS
       ─────────────────────────────────────────────── */

    private Object serialize(Object value) {
        if (value instanceof Boolean) return ((Boolean) value) ? 1 : 0;
        return value;
    }

    private static Object convertValue(Class<?> type, Object value) {
        if (type == boolean.class || type == Boolean.class) {
            if (value instanceof Number) return ((Number) value).intValue() != 0;
            return Boolean.parseBoolean(value.toString());
        }
        if (type == int.class || type == Integer.class) {
            if (value instanceof Number) return ((Number) value).intValue();
            return Integer.parseInt(value.toString());
        }
        return value;
    }


    /* ───────────────────────────────────────────────
       SAVE
       ─────────────────────────────────────────────── */

    public void save() {
        Class<?> cls = this.getClass();
        ensureTable(cls);

        try {
            String table = cls.getSimpleName();
            Field[] fields = cls.getFields();

            if (this.id == 0) {
                // INSERT
                int newId;
                try (Connection c = conn();
                     PreparedStatement stmt = c.prepareStatement("SELECT MAX(id) FROM " + table)) {
                    ResultSet rs = stmt.executeQuery();
                    newId = rs.next() ? rs.getInt(1) + 1 : 1;
                }

                this.id = newId;

                StringBuilder cols = new StringBuilder("id,");
                StringBuilder q = new StringBuilder("?,");
                List<Object> values = new ArrayList<>();
                values.add(newId);

                for (Field f : fields) {
                    if (!f.isAnnotationPresent(Column.class)) continue;
                    cols.append(f.getName()).append(",");
                    q.append("?,");
                    f.setAccessible(true);
                    values.add(serialize(f.get(this)));
                }

                cols.setLength(cols.length() - 1);
                q.setLength(q.length() - 1);

                String sql = "INSERT INTO " + table + " (" + cols + ") VALUES (" + q + ")";
                try (Connection c = conn(); PreparedStatement stmt = c.prepareStatement(sql)) {
                    for (int i = 0; i < values.size(); i++) stmt.setObject(i + 1, values.get(i));
                    stmt.executeUpdate();
                }

            } else {
                // UPDATE
                StringBuilder assigns = new StringBuilder();
                List<Object> values = new ArrayList<>();

                for (Field f : fields) {
                    if (!f.isAnnotationPresent(Column.class)) continue;
                    assigns.append(f.getName()).append("=?,");
                    f.setAccessible(true);
                    values.add(serialize(f.get(this)));
                }

                assigns.setLength(assigns.length() - 1);

                String sql = "UPDATE " + table + " SET " + assigns + " WHERE id=?";
                try (Connection c = conn(); PreparedStatement stmt = c.prepareStatement(sql)) {
                    for (int i = 0; i < values.size(); i++) stmt.setObject(i + 1, values.get(i));
                    stmt.setInt(values.size() + 1, this.id);
                    stmt.executeUpdate();
                }
            }

            // Update foreign keys for @HasMany records
            for (Field f : fields) {
                if (!f.isAnnotationPresent(HasMany.class)) continue;

                f.setAccessible(true);
                Object listObj = f.get(this);
                if (!(listObj instanceof List<?> children)) continue;

                Class<?> childType = (Class<?>) ((ParameterizedType) f.getGenericType()).getActualTypeArguments()[0];
                String childTable = childType.getSimpleName();
                String fk = table + "_id";

                // Ensure child's table and its relationships exist before saving
                ensureTable(childType);

                try (Connection c = conn();
                     PreparedStatement stmt = c.prepareStatement("UPDATE " + childTable + " SET " + fk + "=? WHERE id=?")) {

                    for (Object child : children) {
                        
                        // Save child first (assigns id if needed)
                        Method saveMethod = childType.getMethod("save");
                        saveMethod.invoke(child);

                        int childId = (int) childType.getMethod("id").invoke(child);

                        stmt.setInt(1, this.id);
                        stmt.setInt(2, childId);
                        stmt.executeUpdate();
                    }

                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }


    /* ───────────────────────────────────────────────
       FIND
       ─────────────────────────────────────────────── */

    public static <T> T find(Class<T> cls, int id) {
        ensureTable(cls);

        String table = cls.getSimpleName();

        try (Connection conn = conn();
             PreparedStatement stmt = conn.prepareStatement("SELECT * FROM " + table + " WHERE id=?")) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (!rs.next()) return null;

            T instance = cls.getDeclaredConstructor().newInstance();

            // set id field
            Field idField = Model.class.getDeclaredField("id");
            idField.setAccessible(true);
            idField.set(instance, rs.getInt("id"));

            // load simple columns
            for (Field f : cls.getFields()) {
                if (!f.isAnnotationPresent(Column.class)) continue;

                Object val = rs.getObject(f.getName());
                if (val != null) val = convertValue(f.getType(), val);

                f.setAccessible(true);
                f.set(instance, val);
            }

            // load children
            for (Field f : cls.getFields()) {
                if (!f.isAnnotationPresent(HasMany.class)) continue;

                f.setAccessible(true);
                List<Object> children = new ArrayList<>();
                f.set(instance, children);

                ParameterizedType pt = (ParameterizedType) f.getGenericType();
                Class<?> childType = (Class<?>) pt.getActualTypeArguments()[0];
                String fk = table + "_id";
                String childTable = childType.getSimpleName();

                ensureTable(childType);

                try (PreparedStatement stmt2 = conn.prepareStatement(
                        "SELECT id FROM " + childTable + " WHERE " + fk + "=?")) {

                    stmt2.setInt(1, id);
                    ResultSet rs2 = stmt2.executeQuery();

                    while (rs2.next()) {
                        Object child = find(childType, rs2.getInt("id"));
                        if (child != null) children.add(child);
                    }
                }
            }

            return instance;

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }


    /* ───────────────────────────────────────────────
       ALL
       ─────────────────────────────────────────────── */

    public static <T> List<T> all(Class<T> cls) {
        ensureTable(cls);

        List<T> list = new ArrayList<>();
        String table = cls.getSimpleName();

        try (Connection conn = conn();
             PreparedStatement stmt = conn.prepareStatement("SELECT id FROM " + table);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                T obj = find(cls, rs.getInt("id"));
                if (obj != null) list.add(obj);
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        return list;
    }


    /* ───────────────────────────────────────────────
       DESTROY
       ─────────────────────────────────────────────── */

    public void destroy() {
        if (this.id == 0) {
            throw new IllegalStateException("Cannot destroy unsaved model");
        }

        try (Connection c = conn();
             PreparedStatement stmt = c.prepareStatement("DELETE FROM " +
                     this.getClass().getSimpleName() + " WHERE id=?")) {

            stmt.setInt(1, this.id);
            stmt.executeUpdate();
            this.id = 0;

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public int id() {
        return this.id;
    }

    public static void reset() {
        File db = new File(DB);
        if (db.exists()) db.delete();
    }

    public static void sample() {
        // Sample code, slightly modified from https://github.com/xerial/sqlite-jdbc
        // demonstrating sqlite
        // NOTE: Connection and Statement are AutoCloseable.
        // Don't forget to close them both in order to avoid leaks.
        try {
            // create a database connection
            Connection connection = DriverManager.getConnection("jdbc:sqlite:sample.db");
            Statement statement = connection.createStatement();
            statement.setQueryTimeout(5); // set timeout to 5 sec.

            statement.executeUpdate("drop table if exists person");
            statement.executeUpdate("create table person (id integer, name string)");
            statement.executeUpdate("insert into person values(1, 'leo')");
            statement.executeUpdate("insert into person values(2, 'yui')");
            ResultSet rs = statement.executeQuery("select * from person");
            while (rs.next()) {
                // read the result set
                System.out.println("name = " + rs.getString("name"));
                System.out.println("id = " + rs.getInt("id"));
            }
        } catch (SQLException e) {
            // if the error message is "out of memory",
            // it probably means no database file is found
            e.printStackTrace(System.err);
        }
    }
}
