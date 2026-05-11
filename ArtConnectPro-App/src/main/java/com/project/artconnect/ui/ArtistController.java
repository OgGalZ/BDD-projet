package com.project.artconnect.ui;

import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Discipline;
import com.project.artconnect.service.ArtistService;
import com.project.artconnect.util.ServiceProvider;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.GridPane;
import javafx.geometry.Insets;
import java.util.Optional;

public class ArtistController {
    @FXML private TextField searchField;
    @FXML private ComboBox<Discipline> disciplineFilter;
    @FXML private TableView<Artist> artistTable;
    @FXML private TableColumn<Artist, String> nameColumn;
    @FXML private TableColumn<Artist, String> cityColumn;
    @FXML private TableColumn<Artist, String> emailColumn;
    @FXML private TableColumn<Artist, Integer> yearColumn;

    private final ArtistService artistService = ServiceProvider.getArtistService();

    @FXML
    public void initialize() {
        nameColumn.setCellValueFactory(new PropertyValueFactory<>("name"));
        cityColumn.setCellValueFactory(new PropertyValueFactory<>("city"));
        emailColumn.setCellValueFactory(new PropertyValueFactory<>("contactEmail"));
        yearColumn.setCellValueFactory(new PropertyValueFactory<>("birthYear"));
        disciplineFilter.setItems(FXCollections.observableArrayList(artistService.getAllDisciplines()));
        refreshTable();
    }

    @FXML
    private void handleSearch() {
        String query = searchField.getText();
        Discipline d = disciplineFilter.getValue();
        String dName = (d != null) ? d.getName() : null;
        artistTable.setItems(FXCollections.observableArrayList(artistService.searchArtists(query, dName, null)));
    }

    @FXML
    private void handleReset() {
        searchField.clear();
        disciplineFilter.setValue(null);
        refreshTable();
    }

    @FXML
    private void handleAdd() {
        Dialog<Artist> dialog = createArtistDialog(null);
        Optional<Artist> result = dialog.showAndWait();
        result.ifPresent(artist -> {
            artistService.createArtist(artist);
            refreshTable();
            showAlert("Succès", "Artiste ajouté avec succès !", Alert.AlertType.INFORMATION);
        });
    }

    @FXML
    private void handleEdit() {
        Artist selected = artistTable.getSelectionModel().getSelectedItem();
        if (selected == null) {
            showAlert("Attention", "Veuillez sélectionner un artiste à modifier.", Alert.AlertType.WARNING);
            return;
        }
        Dialog<Artist> dialog = createArtistDialog(selected);
        Optional<Artist> result = dialog.showAndWait();
        result.ifPresent(artist -> {
            artistService.updateArtist(artist);
            refreshTable();
            showAlert("Succès", "Artiste modifié avec succès !", Alert.AlertType.INFORMATION);
        });
    }

    @FXML
    private void handleDelete() {
        Artist selected = artistTable.getSelectionModel().getSelectedItem();
        if (selected == null) {
            showAlert("Attention", "Veuillez sélectionner un artiste à supprimer.", Alert.AlertType.WARNING);
            return;
        }
        Alert confirm = new Alert(Alert.AlertType.CONFIRMATION);
        confirm.setTitle("Confirmation");
        confirm.setHeaderText("Supprimer l'artiste");
        confirm.setContentText("Êtes-vous sûr de vouloir supprimer " + selected.getName() + " ?");
        Optional<ButtonType> result = confirm.showAndWait();
        if (result.isPresent() && result.get() == ButtonType.OK) {
            artistService.deleteArtist(selected.getName());
            refreshTable();
            showAlert("Succès", "Artiste supprimé avec succès !", Alert.AlertType.INFORMATION);
        }
    }

    private Dialog<Artist> createArtistDialog(Artist existing) {
        Dialog<Artist> dialog = new Dialog<>();
        dialog.setTitle(existing == null ? "Ajouter un artiste" : "Modifier l'artiste");
        dialog.setHeaderText(existing == null ? "Nouvel artiste" : "Modifier : " + existing.getName());

        ButtonType saveButton = new ButtonType("Enregistrer", ButtonBar.ButtonData.OK_DONE);
        dialog.getDialogPane().getButtonTypes().addAll(saveButton, ButtonType.CANCEL);

        GridPane grid = new GridPane();
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(20, 150, 10, 10));

        TextField nameField = new TextField(existing != null ? existing.getName() : "");
        TextField cityField = new TextField(existing != null ? existing.getCity() : "");
        TextField emailField = new TextField(existing != null && existing.getContactEmail() != null ? existing.getContactEmail() : "");
        TextField bioField = new TextField(existing != null && existing.getBio() != null ? existing.getBio() : "");
        TextField yearField = new TextField(existing != null && existing.getBirthYear() != null ? existing.getBirthYear().toString() : "");

        grid.add(new Label("Nom :"), 0, 0);
        grid.add(nameField, 1, 0);
        grid.add(new Label("Ville :"), 0, 1);
        grid.add(cityField, 1, 1);
        grid.add(new Label("Email :"), 0, 2);
        grid.add(emailField, 1, 2);
        grid.add(new Label("Bio :"), 0, 3);
        grid.add(bioField, 1, 3);
        grid.add(new Label("Année naissance :"), 0, 4);
        grid.add(yearField, 1, 4);

        dialog.getDialogPane().setContent(grid);

        dialog.setResultConverter(buttonType -> {
            if (buttonType == saveButton) {
                Artist artist = existing != null ? existing : new Artist();
                artist.setName(nameField.getText());
                artist.setCity(cityField.getText());
                artist.setContactEmail(emailField.getText());
                artist.setBio(bioField.getText());
                artist.setActive(true);
                try {
                    artist.setBirthYear(Integer.parseInt(yearField.getText()));
                } catch (NumberFormatException e) {
                    artist.setBirthYear(null);
                }
                return artist;
            }
            return null;
        });
        return dialog;
    }

    private void showAlert(String title, String message, Alert.AlertType type) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }

    private void refreshTable() {
        artistTable.setItems(FXCollections.observableArrayList(artistService.getAllArtists()));
    }
}