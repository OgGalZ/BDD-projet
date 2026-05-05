package com.project.artconnect.persistence;

import com.project.artconnect.config.DatabaseConfig;
import com.project.artconnect.dao.ArtworkDao;
import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Artwork;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcArtworkDao implements ArtworkDao {

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DatabaseConfig.URL, DatabaseConfig.USER, DatabaseConfig.PASSWORD);
    }

    @Override
    public List<Artwork> findAll() {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT aw.*, ar.name AS artist_name FROM artwork aw JOIN artist ar ON aw.artist_id = ar.id";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                artworks.add(mapArtwork(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artworks;
    }

    @Override
    public void save(Artwork artwork) {
        String sql = "INSERT INTO artwork (title, creation_year, type, medium, dimensions, description, price, status, artist_id) " +
                "SELECT ?, ?, ?, ?, ?, ?, ?, ?, id FROM artist WHERE name = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, artwork.getTitle());
            ps.setObject(2, artwork.getCreationYear());
            ps.setString(3, artwork.getType());
            ps.setString(4, artwork.getMedium());
            ps.setString(5, artwork.getDimensions());
            ps.setString(6, artwork.getDescription());
            ps.setDouble(7, artwork.getPrice());
            ps.setString(8, artwork.getStatus() != null ? artwork.getStatus().name() : "FOR_SALE");
            ps.setString(9, artwork.getArtist() != null ? artwork.getArtist().getName() : null);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Artwork artwork) {
        String sql = "UPDATE artwork SET creation_year = ?, type = ?, medium = ?, dimensions = ?, description = ?, price = ?, status = ? WHERE title = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, artwork.getCreationYear());
            ps.setString(2, artwork.getType());
            ps.setString(3, artwork.getMedium());
            ps.setString(4, artwork.getDimensions());
            ps.setString(5, artwork.getDescription());
            ps.setDouble(6, artwork.getPrice());
            ps.setString(7, artwork.getStatus() != null ? artwork.getStatus().name() : "FOR_SALE");
            ps.setString(8, artwork.getTitle());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String title) {
        String sql = "DELETE FROM artwork WHERE title = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Artwork> findByArtistName(String artistName) {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT aw.*, ar.name AS artist_name FROM artwork aw JOIN artist ar ON aw.artist_id = ar.id WHERE ar.name = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, artistName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    artworks.add(mapArtwork(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artworks;
    }

    private Artwork mapArtwork(ResultSet rs) throws SQLException {
        Artwork a = new Artwork();
        a.setTitle(rs.getString("title"));
        a.setCreationYear(rs.getObject("creation_year", Integer.class));
        a.setType(rs.getString("type"));
        a.setMedium(rs.getString("medium"));
        a.setDimensions(rs.getString("dimensions"));
        a.setDescription(rs.getString("description"));
        a.setPrice(rs.getDouble("price"));
        String status = rs.getString("status");
        if (status != null) a.setStatus(Artwork.Status.valueOf(status));
        Artist artist = new Artist();
        artist.setName(rs.getString("artist_name"));
        a.setArtist(artist);
        return a;
    }
}