package com.project.artconnect.persistence;

import com.project.artconnect.config.DatabaseConfig;
import com.project.artconnect.dao.ExhibitionDao;
import com.project.artconnect.model.Exhibition;
import com.project.artconnect.model.Gallery;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcExhibitionDao implements ExhibitionDao {

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DatabaseConfig.URL, DatabaseConfig.USER, DatabaseConfig.PASSWORD);
    }

    @Override
    public List<Exhibition> findAll() {
        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT e.*, g.name AS gallery_name, g.address AS gallery_address, g.rating AS gallery_rating " +
                "FROM exhibition e JOIN gallery g ON e.gallery_id = g.id";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                exhibitions.add(mapExhibition(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return exhibitions;
    }

    @Override
    public void save(Exhibition exhibition) {
        String sql = "INSERT INTO exhibition (title, start_date, end_date, description, curator_name, theme, gallery_id) " +
                "SELECT ?, ?, ?, ?, ?, ?, id FROM gallery WHERE name = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, exhibition.getTitle());
            ps.setDate(2, exhibition.getStartDate() != null ? Date.valueOf(exhibition.getStartDate()) : null);
            ps.setDate(3, exhibition.getEndDate() != null ? Date.valueOf(exhibition.getEndDate()) : null);
            ps.setString(4, exhibition.getDescription());
            ps.setString(5, exhibition.getCuratorName());
            ps.setString(6, exhibition.getTheme());
            ps.setString(7, exhibition.getGallery() != null ? exhibition.getGallery().getName() : null);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Exhibition exhibition) {
        String sql = "UPDATE exhibition SET start_date = ?, end_date = ?, description = ?, curator_name = ?, theme = ? WHERE title = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, exhibition.getStartDate() != null ? Date.valueOf(exhibition.getStartDate()) : null);
            ps.setDate(2, exhibition.getEndDate() != null ? Date.valueOf(exhibition.getEndDate()) : null);
            ps.setString(3, exhibition.getDescription());
            ps.setString(4, exhibition.getCuratorName());
            ps.setString(5, exhibition.getTheme());
            ps.setString(6, exhibition.getTitle());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String title) {
        String sql = "DELETE FROM exhibition WHERE title = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private Exhibition mapExhibition(ResultSet rs) throws SQLException {
        Exhibition e = new Exhibition();
        e.setTitle(rs.getString("title"));
        Date start = rs.getDate("start_date");
        if (start != null) e.setStartDate(start.toLocalDate());
        Date end = rs.getDate("end_date");
        if (end != null) e.setEndDate(end.toLocalDate());
        e.setDescription(rs.getString("description"));
        e.setCuratorName(rs.getString("curator_name"));
        e.setTheme(rs.getString("theme"));
        Gallery g = new Gallery();
        g.setName(rs.getString("gallery_name"));
        g.setAddress(rs.getString("gallery_address"));
        g.setRating(rs.getDouble("gallery_rating"));
        e.setGallery(g);
        return e;
    }
}