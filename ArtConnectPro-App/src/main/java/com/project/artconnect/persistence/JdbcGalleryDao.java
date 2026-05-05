package com.project.artconnect.persistence;

import com.project.artconnect.config.DatabaseConfig;
import com.project.artconnect.dao.GalleryDao;
import com.project.artconnect.model.Exhibition;
import com.project.artconnect.model.Gallery;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcGalleryDao implements GalleryDao {

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DatabaseConfig.URL, DatabaseConfig.USER, DatabaseConfig.PASSWORD);
    }

    @Override
    public Optional<Gallery> findById(Long id) {
        String sql = "SELECT * FROM gallery WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapGallery(con, rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public List<Gallery> findAll() {
        List<Gallery> galleries = new ArrayList<>();
        String sql = "SELECT * FROM gallery";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                galleries.add(mapGallery(con, rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return galleries;
    }

    private Gallery mapGallery(Connection con, ResultSet rs) throws SQLException {
        Gallery g = new Gallery();
        int id = rs.getInt("id");
        g.setName(rs.getString("name"));
        g.setAddress(rs.getString("address"));
        g.setOwnerName(rs.getString("owner_name"));
        g.setOpeningHours(rs.getString("opening_hours"));
        g.setContactPhone(rs.getString("contact_phone"));
        g.setRating(rs.getDouble("rating"));
        g.setWebsite(rs.getString("website"));
        g.setExhibitions(findExhibitionsByGalleryId(con, id));
        return g;
    }

    private List<Exhibition> findExhibitionsByGalleryId(Connection con, int galleryId) throws SQLException {
        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT * FROM exhibition WHERE gallery_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, galleryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Exhibition e = new Exhibition();
                    e.setTitle(rs.getString("title"));
                    e.setStartDate(rs.getDate("start_date").toLocalDate());
                    Date end = rs.getDate("end_date");
                    if (end != null) e.setEndDate(end.toLocalDate());
                    e.setDescription(rs.getString("description"));
                    e.setCuratorName(rs.getString("curator_name"));
                    e.setTheme(rs.getString("theme"));
                    exhibitions.add(e);
                }
            }
        }
        return exhibitions;
    }
}