-- Schéma de base de données pour la plateforme de données sur les pandémies
-- Structure relationnelle normalisée pour l'OMS

DROP TABLE IF EXISTS `data`;
DROP TABLE IF EXISTS `calendrier`;
DROP TABLE IF EXISTS `localisation`;
DROP TABLE IF EXISTS `pandemie`;

-- Table des dates (calendrier)
CREATE TABLE `calendrier` (
    `id_date` INT AUTO_INCREMENT PRIMARY KEY,
    `date` DATE NOT NULL UNIQUE,
    `jour` INT NOT NULL,
    `mois` INT NOT NULL,
    `annee` INT NOT NULL,
    `trimestre` INT NOT NULL,
    `semaine` INT NOT NULL,
    `jour_semaine` INT NOT NULL,
    `est_weekend` BOOLEAN NOT NULL,
    `est_ferie` BOOLEAN NOT NULL DEFAULT FALSE
);

-- Table des localisations
CREATE TABLE `localisation` (
    `id_localisation` INT AUTO_INCREMENT PRIMARY KEY,
    `pays` VARCHAR(100) NOT NULL,
    `code_pays` VARCHAR(3),
    `region` VARCHAR(100),
    `continent` VARCHAR(50),
    `latitude` DECIMAL(10, 6),
    `longitude` DECIMAL(10, 6),
    `population` BIGINT,
    UNIQUE KEY `idx_pays_region` (`pays`, `region`)
);

-- Table des pandémies
CREATE TABLE `pandemie` (
    `id_pandemie` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(50) NOT NULL UNIQUE,
    `agent_pathogene` VARCHAR(100),
    `description` TEXT,
    `date_debut` DATE,
    `date_fin` DATE
);

-- Table principale des données
CREATE TABLE `data` (
    `id_data` INT AUTO_INCREMENT PRIMARY KEY,
    `id_date` INT NOT NULL,
    `id_localisation` INT NOT NULL,
    `id_pandemie` INT NOT NULL,
    `cas_confirmes` INT NOT NULL DEFAULT 0,
    `nouveaux_cas` INT NOT NULL DEFAULT 0,
    `deces` INT NOT NULL DEFAULT 0,
    `nouveaux_deces` INT NOT NULL DEFAULT 0,
    `guerisons` INT NOT NULL DEFAULT 0,
    `nouvelles_guerisons` INT NOT NULL DEFAULT 0,
    `cas_actifs` INT NOT NULL DEFAULT 0,
    `tests_effectues` INT,
    `hospitalisations` INT,
    `soins_intensifs` INT,
    `taux_incidence` DECIMAL(10, 2),
    `taux_mortalite` DECIMAL(10, 2),
    `taux_guerison` DECIMAL(10, 2),
    `taux_positivite` DECIMAL(10, 2),
    FOREIGN KEY (`id_date`) REFERENCES `calendrier`(`id_date`),
    FOREIGN KEY (`id_localisation`) REFERENCES `localisation`(`id_localisation`),
    FOREIGN KEY (`id_pandemie`) REFERENCES `pandemie`(`id_pandemie`),
    UNIQUE KEY `idx_data_unique` (`id_date`, `id_localisation`, `id_pandemie`)
);

-- Index pour améliorer les performances des requêtes
CREATE INDEX `idx_data_date` ON `data` (`id_date`);
CREATE INDEX `idx_data_localisation` ON `data` (`id_localisation`);
CREATE INDEX `idx_data_pandemie` ON `data` (`id_pandemie`);

-- Exemples de requêtes d'analyse

-- Top 5 des pays avec le plus de cas confirmés pour une pandémie spécifique
-- SELECT l.pays, SUM(d.cas_confirmes) as total_cas
-- FROM data d
-- JOIN localisation l ON d.id_localisation = l.id_localisation
-- JOIN pandemie p ON d.id_pandemie = p.id_pandemie
-- WHERE p.nom = 'COVID-19'
-- GROUP BY l.pays
-- ORDER BY total_cas DESC
-- LIMIT 5;

-- Évolution des cas par mois pour une pandémie spécifique
-- SELECT YEAR(c.date) as annee, MONTH(c.date) as mois, SUM(d.nouveaux_cas) as total_nouveaux_cas
-- FROM data d
-- JOIN calendrier c ON d.id_date = c.id_date
-- JOIN pandemie p ON d.id_pandemie = p.id_pandemie
-- WHERE p.nom = 'COVID-19'
-- GROUP BY YEAR(c.date), MONTH(c.date)
-- ORDER BY annee, mois;

-- Comparaison des taux de mortalité entre différentes pandémies
-- SELECT p.nom as pandemie, l.continent, AVG(d.taux_mortalite) as taux_mortalite_moyen
-- FROM data d
-- JOIN localisation l ON d.id_localisation = l.id_localisation
-- JOIN pandemie p ON d.id_pandemie = p.id_pandemie
-- GROUP BY p.nom, l.continent
-- ORDER BY p.nom, taux_mortalite_moyen DESC;
