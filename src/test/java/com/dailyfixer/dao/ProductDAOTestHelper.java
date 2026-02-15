package com.dailyfixer.dao;

import com.dailyfixer.model.Product;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of ProductDAO that uses H2 in-memory database.
 */
public class ProductDAOTestHelper {

    public void addProduct(Product p) throws Exception {
        String sql = "INSERT INTO products (name, type, quantity, quantity_unit, price, image, store_username, description, store_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getType());
            ps.setInt(3, p.getQuantity());
            ps.setString(4, p.getQuantityUnit());
            ps.setDouble(5, p.getPrice());
            ps.setBytes(6, p.getImage());
            ps.setString(7, p.getStoreUsername());
            ps.setString(8, p.getDescription());
            ps.setInt(9, p.getStoreId());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    p.setProductId(rs.getInt(1));
                }
            }
        }
    }

    public int addProductAndReturnId(Product p) throws Exception {
        addProduct(p);
        return p.getProductId();
    }

    public List<Product> getAllProducts(String storeUsername) throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE store_username=?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, storeUsername);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setName(rs.getString("name"));
                    p.setType(rs.getString("type"));
                    p.setQuantity(rs.getInt("quantity"));
                    p.setQuantityUnit(rs.getString("quantity_unit"));
                    p.setPrice(rs.getDouble("price"));
                    p.setImage(rs.getBytes("image"));
                    p.setDescription(rs.getString("description"));
                    p.setStoreUsername(rs.getString("store_username"));
                    p.setStoreId(rs.getInt("store_id"));
                    list.add(p);
                }
            }
        }
        return list;
    }

    public Product getProductById(int id) throws Exception {
        Product p = null;
        String sql = "SELECT * FROM products WHERE product_id=?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setName(rs.getString("name"));
                    p.setType(rs.getString("type"));
                    p.setQuantity(rs.getInt("quantity"));
                    p.setQuantityUnit(rs.getString("quantity_unit"));
                    p.setPrice(rs.getDouble("price"));
                    p.setImage(rs.getBytes("image"));
                    p.setDescription(rs.getString("description"));
                    p.setStoreUsername(rs.getString("store_username"));
                    p.setStoreId(rs.getInt("store_id"));
                }
            }
        }
        return p;
    }

    public void updateProduct(Product p) throws Exception {
        String sql = "UPDATE products SET name=?, type=?, quantity=?, quantity_unit=?, price=?, image=?, description=? WHERE product_id=?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getType());
            ps.setInt(3, p.getQuantity());
            ps.setString(4, p.getQuantityUnit());
            ps.setDouble(5, p.getPrice());
            ps.setBytes(6, p.getImage());
            ps.setString(7, p.getDescription());
            ps.setInt(8, p.getProductId());
            ps.executeUpdate();
        }
    }

    public void deleteProduct(int id) throws Exception {
        String sql = "DELETE FROM products WHERE product_id=?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
