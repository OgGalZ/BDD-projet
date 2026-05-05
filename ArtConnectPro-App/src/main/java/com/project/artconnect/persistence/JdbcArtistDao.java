package com.project.artconnect.persistence;

import com.project.artconnect.config.DatabaseConfig;
import com.project.artconnect.dao.ArtistDao;
import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Discipline;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcArtistDao implements ArtistDao {

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DatabaseConfig.URL, DatabaseConfig.USER, DatabaseConfig.PASSWORD);
    }

    @Override
    public List<Artist> findAll() {
        List<Artist> artists = new ArrayList<>();
        String sql = "SELECT * FROM artist WHERE is_active = TRUE";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                artists.add(mapArtist(con, rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artists;
    }

    @Override
    public void save(Artist artist) {
        String sql = "INSERT INTO artist (name, bio, birth_year, contact_email, phone, city, website, social_media, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, artist.getName());
            ps.setString(2, artist.getBio());
            ps.setObject(3, artist.getBirthYear());
            ps.setString(4, artist.getContactEmail());
            ps.setString(5, artist.getPhone());
            ps.setString(6, artist.getCity());
            ps.setString(7, artist.getWebsite());
            ps.setString(8, artist.getSocialMedia());
            ps.setBoolean(9, artist.isActive());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Artist artist) {
        String sql = "UPDATE artist SET bio = ?, birth_year = ?, contact_email = ?, phone = ?, city = ?, website = ?, social_media = ?, is_active = ? WHERE name = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, artist.getBio());
            ps.setObject(2, artist.getBirthYear());
            ps.setString(3, artist.getContactEmail());
            ps.setString(4, artist.getPhone());
            ps.setString(5, artist.getCity());
            ps.setString(6, artist.getWebsite());
            ps.setString(7, artist.getSocialMedia());
            ps.setBoolean(8, artist.isActive());
            ps.setString(9, artist.getName());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String artistName) {
        String sql = "DELETE FROM artist WHERE name = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, artistName);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Artist> findByCity(String city) {
        List<Artist> artists = new ArrayList<>();
        String sql = "SELECT * FROM artist WHERE city = ? AND is_active = TRUE";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, city);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    artists.add(mapArtist(con, rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artists;
    }

    private Artist mapArtist(Connection con, ResultSet rs) throws SQLException {
        Artist a = new Artist();
        a.setName(rs.getString("name"));
        a.setBio(rs.getString("bio"));
        a.setBirthYear(rs.getObject("birth_year", Integer.class));
        a.setContactEmail(rs.getString("contact_email"));
        a.setPhone(rs.getString("phone"));
        a.setCity(rs.getString("city"));
        a.setWebsite(rs.getString("website"));
        a.setSocialMedia(rs.getString("social_media"));
        a.setActive(rs.getBoolean("is_active"));
        a.setDisciplines(findDisciplinesByArtistId(con, rs.getInt("id")));
        return a;
    }

    private List<Discipline> findDisciplinesByArtistId(Connection con, int artistId) throws SQLException {
        List<Discipline> disciplines = new ArrayList<>();
        String sql = "SELECT d.name FROM discipline d JOIN artist_discipline ad ON d.id = ad.discipline_id WHERE ad.artist_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, artistId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    disciplines.add(new Discipline(rs.getString("name")));
                }
            }
        }
        return disciplines;
    }
}