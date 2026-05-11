-- =====================================================================
-- SCRIPT COMPLET ARTCONNECT - ÉTAPE 3
-- Supprime et recrée la base de données avec toutes les fonctionnalités
-- Exécutez ce script en une fois (Ctrl+Shift+Enter dans MySQL Workbench)
-- =====================================================================

DROP DATABASE IF EXISTS artconnect;
CREATE DATABASE artconnect;
USE artconnect;

-- ---------------------------------------------------------------------
-- 1. CRÉATION DES TABLES
-- ---------------------------------------------------------------------

CREATE TABLE artist (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    bio TEXT,
    birth_year INT,
    contact_email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(100),
    website VARCHAR(200),
    social_media VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE discipline (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE artist_discipline (
    artist_id INT NOT NULL,
    discipline_id INT NOT NULL,
    PRIMARY KEY (artist_id, discipline_id),
    FOREIGN KEY (artist_id) REFERENCES artist(id) ON DELETE CASCADE,
    FOREIGN KEY (discipline_id) REFERENCES discipline(id) ON DELETE CASCADE
);

CREATE TABLE artwork (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    creation_year INT,
    type VARCHAR(50),
    medium VARCHAR(100),
    dimensions VARCHAR(50),
    description TEXT,
    price DECIMAL(10,2),
    status ENUM('FOR_SALE', 'SOLD', 'EXHIBITED') DEFAULT 'FOR_SALE',
    artist_id INT NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artist(id) ON DELETE CASCADE
);

CREATE TABLE artwork_tag (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE artwork_tag_artwork (
    artwork_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (artwork_id, tag_id),
    FOREIGN KEY (artwork_id) REFERENCES artwork(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES artwork_tag(id) ON DELETE CASCADE
);

CREATE TABLE gallery (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(300),
    owner_name VARCHAR(100),
    opening_hours VARCHAR(100),
    contact_phone VARCHAR(20),
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    website VARCHAR(200)
);

CREATE TABLE exhibition (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    curator_name VARCHAR(100),
    theme VARCHAR(100),
    gallery_id INT NOT NULL,
    FOREIGN KEY (gallery_id) REFERENCES gallery(id) ON DELETE CASCADE
);

CREATE TABLE exhibition_artwork (
    exhibition_id INT NOT NULL,
    artwork_id INT NOT NULL,
    PRIMARY KEY (exhibition_id, artwork_id),
    FOREIGN KEY (exhibition_id) REFERENCES exhibition(id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artwork(id) ON DELETE CASCADE
);

CREATE TABLE workshop (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    date DATETIME NOT NULL,
    duration_minutes INT,
    max_participants INT CHECK (max_participants > 0),
    price DECIMAL(10,2),
    location VARCHAR(200),
    description TEXT,
    level VARCHAR(50),
    instructor_id INT NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES artist(id) ON DELETE CASCADE
);

CREATE TABLE community_member (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    birth_year INT,
    phone VARCHAR(20),
    city VARCHAR(100),
    membership_type VARCHAR(50) DEFAULT 'free'
);

CREATE TABLE member_discipline (
    member_id INT NOT NULL,
    discipline_id INT NOT NULL,
    PRIMARY KEY (member_id, discipline_id),
    FOREIGN KEY (member_id) REFERENCES community_member(id) ON DELETE CASCADE,
    FOREIGN KEY (discipline_id) REFERENCES discipline(id) ON DELETE CASCADE
);

CREATE TABLE booking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_date DATETIME NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    workshop_id INT NOT NULL,
    member_id INT NOT NULL,
    FOREIGN KEY (workshop_id) REFERENCES workshop(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES community_member(id) ON DELETE CASCADE,
    UNIQUE KEY unique_booking (workshop_id, member_id)
);

CREATE TABLE review (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATE NOT NULL,
    artwork_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artwork(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES community_member(id) ON DELETE CASCADE
);

CREATE TABLE artwork_price_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    artwork_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_date DATETIME,
    FOREIGN KEY (artwork_id) REFERENCES artwork(id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 2. INSERTION DES DONNÉES (INCLUANT LES DONNÉES GÉNÉRÉES PAR LLM)
-- ---------------------------------------------------------------------

-- Disciplines
INSERT INTO discipline (name) VALUES 
('Peinture'), ('Sculpture'), ('Photographie'), ('Art Numérique'),
('Céramique'), ('Gravure');

-- Artistes (5 initiaux + 20 supplémentaires = 25)
INSERT INTO artist (name, bio, birth_year, city, is_active) VALUES
-- Artistes de base
('Marc Fontana', 'Spécialiste du clair-obscur.', 1985, 'Lyon', 1),
('Elisa Valade', 'Photographe de rue.', 1992, 'Paris', 1),
('Julien Moss', 'Sculpteur sur métal.', 1978, 'Marseille', 1),
('Sophie Dubois', 'Peintre abstraite.', 1988, 'Bordeaux', 1),
('Lucas Martin', 'Artiste numérique.', 1995, 'Lille', 1),
-- Artistes générés par LLM
('Camille Moreau', 'Peintre paysagiste inspirée par la Bretagne.', 1975, 'Rennes', 1),
('Théo Bernard', 'Sculpteur sur bois autodidacte.', 1982, 'Annecy', 1),
('Louise Fabre', 'Photographe de mode et de portrait.', 1990, 'Nice', 1),
('Gabriel Roux', 'Artiste numérique spécialisé en réalité augmentée.', 1988, 'Toulouse', 1),
('Emma Leroy', 'Céramiste créant des pièces utilitaires poétiques.', 1979, 'Strasbourg', 1),
('Antoine Dumont', 'Graveur sur cuivre traditionnel.', 1965, 'Dijon', 1),
('Chloé Mercier', 'Peintre abstraite aux influences lyriques.', 1993, 'Montpellier', 1),
('Louis Girard', 'Sculpteur monumental en acier.', 1972, 'Nantes', 1),
('Alice Morel', 'Photographe documentaire.', 1985, 'Lille', 1),
('Hugo Renard', 'Artiste numérique génératif.', 1996, 'Grenoble', 1),
('Manon Caron', 'Peintre de marines.', 1980, 'Brest', 1),
('Jules Picard', 'Sculpteur animalier en bronze.', 1968, 'Avignon', 1),
('Clara Lemoine', 'Photographe de nature morte.', 1991, 'Reims', 1),
('Nathan Simon', 'Artiste 3D et VJ.', 1994, 'Metz', 1),
('Inès Lambert', 'Céramiste contemporaine.', 1983, 'Limoges', 1),
('Léa Dupuis', 'Graveuse sur linoléum.', 1977, 'Angers', 1),
('Mathis Perrin', 'Peintre de street art.', 1989, 'Le Havre', 1),
('Zoé Brunet', 'Sculptrice sur verre.', 1974, 'Nancy', 1),
('Tom Maréchal', 'Photographe de paysages urbains.', 1992, 'Saint-Étienne', 1),
('Sarah Blin', 'Artiste numérique interactive.', 1995, 'Tours', 1);

-- Associations artistes-disciplines
INSERT INTO artist_discipline (artist_id, discipline_id) VALUES
(1,1), (2,3), (3,2), (4,1), (5,4),
(6,1), (6,5), (7,2), (8,3), (9,4), (10,5), (10,6), (11,1), (12,2), (13,3),
(14,4), (15,1), (15,5), (16,2), (17,3), (18,4), (19,5), (20,6), (21,1),
(22,2), (23,3), (24,4), (25,5);

-- Œuvres (5 initiales + 22 supplémentaires = 27)
INSERT INTO artwork (title, creation_year, type, price, artist_id, status) VALUES
-- Œuvres de base
('Ombres Urbaines', 2023, 'Tableau', 1200.00, 1, 'FOR_SALE'),
('Reflets d''Acier', 2022, 'Sculpture', 4500.00, 3, 'EXHIBITED'),
('Nuit Blanche', 2024, 'Photo', 350.00, 2, 'FOR_SALE'),
('Couleurs du Sud', 2025, 'Tableau', 950.00, 4, 'FOR_SALE'),
('Éclats Numériques', 2024, 'Digital', 800.00, 5, 'FOR_SALE'),
-- Œuvres générées par LLM
('Marée Basse à Cancale', 2021, 'Tableau', 1800.00, 6, 'FOR_SALE'),
('Forêt de Brocéliande', 2023, 'Tableau', 2200.00, 6, 'EXHIBITED'),
('Danse du Bois', 2020, 'Sculpture', 3500.00, 7, 'FOR_SALE'),
('Élégance Urbaine', 2024, 'Photo', 450.00, 8, 'SOLD'),
('Réalité Augmentée #7', 2025, 'Digital', 1200.00, 9, 'FOR_SALE'),
('Vase Céleste', 2022, 'Céramique', 380.00, 10, 'FOR_SALE'),
('L''Alchimiste', 2019, 'Gravure', 600.00, 11, 'EXHIBITED'),
('Éclats Lyriques', 2024, 'Tableau', 2900.00, 12, 'FOR_SALE'),
('L''Âme de l''Acier', 2018, 'Sculpture', 7800.00, 13, 'EXHIBITED'),
('Les Oubliés de Calais', 2023, 'Photo', 550.00, 14, 'FOR_SALE'),
('Flux Génératif #23', 2026, 'Digital', 950.00, 15, 'FOR_SALE'),
('Coucher de Soleil sur l''Iroise', 2020, 'Tableau', 1600.00, 16, 'SOLD'),
('Le Grand Élan', 2017, 'Sculpture', 6200.00, 17, 'EXHIBITED'),
('Vanitas Contemporaine', 2022, 'Photo', 390.00, 18, 'FOR_SALE'),
('Métamorphose Digitale', 2025, 'Digital', 2000.00, 19, 'FOR_SALE'),
('Bol Océan', 2023, 'Céramique', 220.00, 20, 'FOR_SALE'),
('Le Poids du Monde', 2021, 'Gravure', 480.00, 21, 'EXHIBITED'),
('Fresque Mobile', 2024, 'Tableau', 3100.00, 22, 'FOR_SALE'),
('Transparence', 2019, 'Sculpture', 4100.00, 23, 'EXHIBITED'),
('Noir & Blanc', 2025, 'Photo', 320.00, 24, 'FOR_SALE'),
('Interface Vivante', 2026, 'Digital', 1500.00, 25, 'FOR_SALE'),
('Terre et Feu', 2022, 'Céramique', 280.00, 10, 'SOLD');

-- Galeries (3 initiales + 5 nouvelles = 8)
INSERT INTO gallery (name, address, rating) VALUES
('La Boite à Art', '12 rue des Arts, Lyon', 4.8),
('Galerie Moderne', '45 avenue de France, Paris', 4.5),
('Espace Créatif', '2 boulevard Maritime, Marseille', 4.2),
('Galerie des Lices', '3 place des Lices, Rennes', 4.2),
('Atelier 34', '34 rue de la République, Annecy', 4.7),
('Le Carré d''Art', '12 avenue Jean Médecin, Nice', 4.9),
('Espace Saint-Cyprien', '5 rue du Pont Vieux, Toulouse', 4.3),
('La Chambre Claire', '22 rue de la Krutenau, Strasbourg', 4.6);

-- Expositions (3 initiales + 7 supplémentaires = 10)
INSERT INTO exhibition (title, start_date, end_date, gallery_id) VALUES
('Modernité Lyon', '2026-05-01', '2026-06-01', 1),
('Regards Contemporains', '2026-06-15', '2026-07-30', 2),
('Sculptures en Lumière', '2026-09-10', '2026-10-20', 3),
('Horizons Bretons', '2026-04-01', '2026-05-15', 4),
('Art et Nature', '2026-06-01', '2026-07-10', 5),
('Regards Méditerranéens', '2026-05-20', '2026-06-30', 6),
('Numérique & Sens', '2026-07-01', '2026-08-20', 7),
('Terres d''Alsace', '2026-09-01', '2026-10-15', 8),
('Biennale de Sculpture', '2026-05-10', '2026-09-10', 1),
('Photo Documentaire', '2026-06-15', '2026-08-01', 2);

-- Association œuvres-expositions
INSERT INTO exhibition_artwork (exhibition_id, artwork_id) VALUES
(1,1), (1,2), (2,3), (2,4), (3,5),
(4,6), (4,8), (5,10), (5,11), (6,12),
(7,13), (7,14), (8,15), (9,16), (10,17),
(4,18), (5,19), (6,20), (7,21), (8,22),
(9,23), (10,24), (4,25), (5,26);

-- Ateliers (3 initiaux + 5 supplémentaires = 8)
INSERT INTO workshop (title, date, duration_minutes, max_participants, price, location, level, instructor_id) VALUES
('Initiation Photo', '2026-05-15 14:00:00', 120, 10, 50.00, 'La Boite à Art, Lyon', 'Débutant', 2),
('Peinture Abstraite', '2026-06-10 10:00:00', 180, 8, 60.00, 'Galerie Moderne, Paris', 'Intermédiaire', 1),
('Sculpture Métal', '2026-07-05 09:30:00', 240, 6, 75.00, 'Espace Créatif, Marseille', 'Avancé', 3),
('Découverte de la Céramique', '2026-06-05 14:00:00', 180, 8, 65.00, 'Atelier Terre & Feu, Strasbourg', 'Débutant', 10),
('Gravure sur Cuivre', '2026-07-12 10:00:00', 240, 6, 90.00, 'La Chambre Claire, Strasbourg', 'Intermédiaire', 11),
('Peinture Abstraite (Rennes)', '2026-08-20 09:30:00', 120, 12, 45.00, 'Galerie des Lices, Rennes', 'Tous niveaux', 12),
('Sculpture Monumentale', '2026-09-15 09:00:00', 360, 5, 150.00, 'Atelier 34, Annecy', 'Avancé', 13),
('Photographie de Rue', '2026-10-10 15:00:00', 150, 10, 40.00, 'Le Carré d''Art, Nice', 'Débutant', 8);

-- Membres (4 initiaux + 10 supplémentaires = 14)
INSERT INTO community_member (name, email, city, membership_type) VALUES
('Jean Dupont', 'jean.dupont@email.com', 'Lyon', 'premium'),
('Marie Loire', 'm.loire@email.com', 'Paris', 'free'),
('Paul Bernard', 'paul.bernard@email.com', 'Marseille', 'premium'),
('Alice Martin', 'alice.martin@email.com', 'Lille', 'free'),
('Lucie Fontaine', 'lucie.fontaine@email.com', 'Rennes', 'premium'),
('Mathieu Legrand', 'm.legrand@email.com', 'Annecy', 'free'),
('Julie Moreau', 'julie.m@email.com', 'Nice', 'premium'),
('Thomas Petit', 'thomas.p@email.com', 'Toulouse', 'free'),
('Camille Roussel', 'camille.r@email.com', 'Strasbourg', 'premium'),
('Nicolas Durand', 'n.durand@email.com', 'Nantes', 'free'),
('Elodie Simon', 'elodie.s@email.com', 'Montpellier', 'premium'),
('Quentin Leroy', 'q.leroy@email.com', 'Lille', 'free'),
('Aurélie Blanc', 'aurelie.b@email.com', 'Grenoble', 'premium'),
('Sébastien Klein', 's.klein@email.com', 'Brest', 'free');

-- Réservations (3 initiales + 10 supplémentaires = 13)
INSERT INTO booking (booking_date, payment_status, workshop_id, member_id) VALUES
(NOW(), 'PAID', 1, 1),
(NOW(), 'PENDING', 2, 2),
(NOW(), 'PAID', 3, 3),
(NOW(), 'PAID', 4, 5),
(NOW(), 'PAID', 4, 6),
(NOW(), 'PENDING', 5, 7),
(NOW(), 'PAID', 5, 8),
(NOW(), 'PAID', 6, 9),
(NOW(), 'PENDING', 7, 10),
(NOW(), 'PAID', 8, 11),
(NOW(), 'PAID', 4, 12),
(NOW(), 'PAID', 5, 13),
(NOW(), 'PENDING', 6, 14);

-- Critiques (3 initiales + 15 supplémentaires = 18)
INSERT INTO review (rating, comment, review_date, artwork_id, reviewer_id) VALUES
(5, 'Magnifique tableau, très expressif !', CURDATE(), 1, 1),
(4, 'Belle composition, couleurs vibrantes.', CURDATE(), 4, 2),
(5, 'Sculpture impressionnante, un vrai travail d''orfèvre.', CURDATE(), 2, 3),
(5, 'Une toile qui capture magnifiquement la lumière bretonne.', '2026-04-10', 6, 5),
(4, 'Sculpture très originale, le bois est vivant.', '2026-04-12', 8, 6),
(5, 'Photo d''une grande sensibilité, bravo !', '2026-04-15', 9, 7),
(3, 'Intéressant mais un peu cher pour une œuvre numérique.', '2026-04-18', 10, 8),
(5, 'Ce vase est une pure merveille, je l''ai acheté immédiatement.', '2026-04-20', 11, 9),
(4, 'Gravure de grande qualité, édition limitée.', '2026-04-22', 12, 10),
(5, 'Abstraction puissante, couleurs éclatantes.', '2026-04-25', 13, 11),
(4, 'Sculpture impressionnante par sa taille et sa maîtrise.', '2026-04-28', 14, 12),
(5, 'Un témoignage photographique poignant.', '2026-05-02', 15, 13),
(4, 'Art génératif hypnotique, très belle pièce.', '2026-05-05', 16, 14),
(5, 'Peinture classique mais exécutée avec brio.', '2026-05-08', 17, 5),
(3, 'Sculpture correcte mais manque de finition.', '2026-05-10', 18, 6),
(5, 'Composition photographique parfaite.', '2026-05-12', 19, 7),
(4, 'Œuvre digitale innovante, bel avenir pour cet artiste.', '2026-05-15', 20, 8),
(5, 'Bol utilitaire et esthétique, je recommande.', '2026-05-18', 21, 9);

-- ---------------------------------------------------------------------
-- 3. VUES (3)
-- ---------------------------------------------------------------------

CREATE VIEW v_artwork_catalog AS
SELECT a.id, a.title, a.price, a.status, ar.name AS artist_name
FROM artwork a JOIN artist ar ON a.artist_id = ar.id;

CREATE VIEW v_workshop_availability AS
SELECT w.id, w.title, w.date, w.max_participants,
       w.max_participants - COUNT(b.id) AS places_restantes
FROM workshop w LEFT JOIN booking b ON w.id = b.workshop_id
GROUP BY w.id;

CREATE VIEW v_artist_disciplines AS
SELECT a.id, a.name, a.city,
       GROUP_CONCAT(d.name SEPARATOR ', ') AS disciplines
FROM artist a
LEFT JOIN artist_discipline ad ON a.id = ad.artist_id
LEFT JOIN discipline d ON ad.discipline_id = d.id
GROUP BY a.id;

-- ---------------------------------------------------------------------
-- 4. INDEX (3)
-- ---------------------------------------------------------------------

CREATE INDEX idx_artwork_price ON artwork(price);
CREATE INDEX idx_workshop_date ON workshop(date);
CREATE INDEX idx_member_email ON community_member(email);

-- ---------------------------------------------------------------------
-- 5. TRIGGERS (3)
-- ---------------------------------------------------------------------

DELIMITER //
CREATE TRIGGER trg_check_exhibition_dates
BEFORE INSERT ON exhibition
FOR EACH ROW
BEGIN
    IF NEW.end_date IS NOT NULL AND NEW.end_date <= NEW.start_date THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erreur : La date de fin doit être postérieure à la date de début.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_booking_capacity
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE nb_inscrits INT;
    DECLARE capacite_max INT;
    SELECT COUNT(*) INTO nb_inscrits FROM booking WHERE workshop_id = NEW.workshop_id;
    SELECT max_participants INTO capacite_max FROM workshop WHERE id = NEW.workshop_id;
    IF nb_inscrits >= capacite_max THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Atelier complet, réservation impossible.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_artwork_price_audit
AFTER UPDATE ON artwork
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO artwork_price_audit (artwork_id, old_price, new_price, change_date)
        VALUES (NEW.id, OLD.price, NEW.price, NOW());
    END IF;
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- 6. PROGRAMMES STOCKÉS (3 : 1 fonction + 2 procédures)
-- ---------------------------------------------------------------------

DELIMITER //
CREATE FUNCTION fn_places_restantes(p_workshop_id INT) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE capacite INT;
    DECLARE inscrits INT;
    SELECT max_participants INTO capacite FROM workshop WHERE id = p_workshop_id;
    SELECT COUNT(*) INTO inscrits FROM booking WHERE workshop_id = p_workshop_id;
    RETURN capacite - inscrits;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_inscrire_atelier(IN p_member_id INT, IN p_workshop_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    INSERT INTO booking (booking_date, payment_status, workshop_id, member_id)
    VALUES (NOW(), 'PENDING', p_workshop_id, p_member_id);
    UPDATE booking SET payment_status = 'PAID' 
    WHERE workshop_id = p_workshop_id AND member_id = p_member_id;
    COMMIT;
    SELECT CONCAT('Inscription réussie du membre ', p_member_id, ' à l''atelier ', p_workshop_id) AS message;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_ajouter_oeuvre_expo(
    IN p_title VARCHAR(200),
    IN p_artist_id INT,
    IN p_exhibition_id INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    DECLARE new_artwork_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    INSERT INTO artwork (title, artist_id, price, status) 
    VALUES (p_title, p_artist_id, p_price, 'EXHIBITED');
    SET new_artwork_id = LAST_INSERT_ID();
    INSERT INTO exhibition_artwork (exhibition_id, artwork_id) 
    VALUES (p_exhibition_id, new_artwork_id);
    COMMIT;
    SELECT CONCAT('Œuvre "', p_title, '" créée et ajoutée à l''exposition ', p_exhibition_id) AS message;
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- 7. SCÉNARIO TRANSACTIONNEL (TEST)
-- ---------------------------------------------------------------------
-- Exécutez le bloc suivant pour tester une transaction complexe.
-- (Décommentez et exécutez dans une nouvelle fenêtre de requête)

/*
START TRANSACTION;

-- Créer une nouvelle exposition
INSERT INTO exhibition (title, start_date, end_date, gallery_id, description) 
VALUES ('Nouveaux Talents', '2026-11-01', '2026-11-15', 1, 
        'Exposition collective des artistes émergents');
SET @new_expo_id = LAST_INSERT_ID();

-- Ajouter deux œuvres à cette exposition
INSERT INTO exhibition_artwork (exhibition_id, artwork_id) 
VALUES (@new_expo_id, 1), (@new_expo_id, 4);

-- Mettre à jour le statut des œuvres
UPDATE artwork SET status = 'EXHIBITED' 
WHERE id IN (1, 4) AND status = 'FOR_SALE';

-- Augmenter le prix de 5% pour ces œuvres
UPDATE artwork SET price = price * 1.05 WHERE id IN (1, 4);

-- Vérification manuelle : si tout est OK, COMMIT ; sinon ROLLBACK
COMMIT;
SELECT 'Transaction réussie : exposition créée, œuvres ajoutées et prix mis à jour.' AS message;
*/

-- -----------------artist----------------------------------------------------
-- FIN DU SCRIPT
-- ---------------------------------------------------------------------
SELECT '=== Base de données ARTCONNECT créée avec succès ===' AS '';
SELECT COUNT(*) AS 'Nombre d''artistes' FROM artist;
SELECT COUNT(*) AS 'Nombre d''œuvres' FROM artwork;
SELECT COUNT(*) AS 'Nombre de membres' FROM community_member;
START TRANSACTION;

