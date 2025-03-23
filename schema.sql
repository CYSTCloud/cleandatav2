-- Schéma de base de données pour les données de pandémies
-- Basé sur les besoins de l'Organisation Mondiale de la Santé (OMS)

DROP TABLE IF EXISTS `cas_confirmes`;
DROP TABLE IF EXISTS `deces`;
DROP TABLE IF EXISTS `guerisons`;
DROP TABLE IF EXISTS `pandemie`;
DROP TABLE IF EXISTS `localisation`;

-- Table des pandémies
CREATE TABLE `pandemie` (
    `id_pandemie` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(50) NOT NULL,
    `description` TEXT,
    `date_debut` DATE,
    `date_fin` DATE
);

-- Table des localisations
CREATE TABLE `localisation` (
    `id_localisation` INT AUTO_INCREMENT PRIMARY KEY,
    `pays` VARCHAR(100) NOT NULL,
    `region` VARCHAR(100),
    `continent` VARCHAR(50),
    `latitude` DECIMAL(10, 6),
    `longitude` DECIMAL(10, 6),
    `population` BIGINT
);

-- Table des cas confirmés
CREATE TABLE `cas_confirmes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `id_pandemie` INT NOT NULL,
    `id_localisation` INT NOT NULL,
    `date` DATE NOT NULL,
    `cas_cumules` INT NOT NULL,
    `nouveaux_cas` INT NOT NULL,
    FOREIGN KEY (`id_pandemie`) REFERENCES `pandemie`(`id_pandemie`),
    FOREIGN KEY (`id_localisation`) REFERENCES `localisation`(`id_localisation`)
);

-- Table des décès
CREATE TABLE `deces` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `id_pandemie` INT NOT NULL,
    `id_localisation` INT NOT NULL,
    `date` DATE NOT NULL,
    `deces_cumules` INT NOT NULL,
    `nouveaux_deces` INT NOT NULL,
    FOREIGN KEY (`id_pandemie`) REFERENCES `pandemie`(`id_pandemie`),
    FOREIGN KEY (`id_localisation`) REFERENCES `localisation`(`id_localisation`)
);

-- Table des guérisons
CREATE TABLE `guerisons` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `id_pandemie` INT NOT NULL,
    `id_localisation` INT NOT NULL,
    `date` DATE NOT NULL,
    `guerisons_cumulees` INT NOT NULL,
    `nouvelles_guerisons` INT NOT NULL,
    FOREIGN KEY (`id_pandemie`) REFERENCES `pandemie`(`id_pandemie`),
    FOREIGN KEY (`id_localisation`) REFERENCES `localisation`(`id_localisation`)
);

-- Requêtes de vérification après chargement des données
-- SELECT COUNT(*) FROM cas_confirmes;
-- SELECT COUNT(*) FROM deces;
-- SELECT COUNT(*) FROM guerisons;

-- Requêtes d'analyse
-- Top 5 des pays avec le plus de cas confirmés
-- SELECT l.pays, MAX(c.cas_cumules) as total_cas
-- FROM cas_confirmes c
-- JOIN localisation l ON c.id_localisation = l.id_localisation
-- GROUP BY l.pays
-- ORDER BY total_cas DESC
-- LIMIT 5;

-- Top 5 des pays avec le plus de décès
-- SELECT l.pays, MAX(d.deces_cumules) as total_deces
-- FROM deces d
-- JOIN localisation l ON d.id_localisation = l.id_localisation
-- GROUP BY l.pays
-- ORDER BY total_deces DESC
-- LIMIT 5;

-- Top 5 des pays avec le plus de guérisons
-- SELECT l.pays, MAX(g.guerisons_cumulees) as total_guerisons
-- FROM guerisons g
-- JOIN localisation l ON g.id_localisation = l.id_localisation
-- GROUP BY l.pays
-- ORDER BY total_guerisons DESC
-- LIMIT 5;
