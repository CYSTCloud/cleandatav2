# Projet ETL - Analyse des Pandémies

## Description du Projet
Ce projet s'inscrit dans le cadre de la certification Développeur en Intelligence Artificielle et Data Science (RNCP 36581). Il consiste en la mise en place d'une solution ETL (Extract, Transform, Load) pour l'analyse des données de pandémies mondiales (COVID-19 et Monkeypox).

## Objectifs
- Collecter les données de différentes sources (COVID-19 et Monkeypox)
- Nettoyer, agréger, normaliser et supprimer les doublons
- Charger les données dans une base de données relationnelle
- Permettre la visualisation et l'analyse des données

## Structure du Projet
Le projet est organisé en trois parties principales, suivant le processus ETL :

### 1. Extraction (Partie-01-Extraction)
- **Extraction.ipynb** : Notebook pour l'extraction des données brutes
- **Donnees Brutes/** : Dossier contenant les fichiers de données sources
  - `covid_19_clean_complete.csv`
  - `owid-monkeypox-data.csv`
  - `worldometer_coronavirus_daily_data.csv`

### 2. Transformation (Partie-02-Transformation)
- **Transformation_v3.ipynb** : Notebook pour le nettoyage et la transformation des données
- **Transformation_v4.ipynb** : Version améliorée du notebook de transformation
- **generate_clean_data.py** : Script Python pour générer les fichiers CSV nettoyés

### 3. Chargement (Partie-03-Chargement)
- **Chargement_v2.ipynb** : Notebook pour le chargement des données dans la base de données
- **donnees_nettoyees/** : Dossier contenant les fichiers CSV transformés prêts à être chargés
  - `localisations_clean.csv`
  - `pandemies_clean.csv`
  - `cas_confirmes_clean.csv`
  - `deces_clean.csv`
  - `guerisons_clean.csv`

## Schéma de la Base de Données
La base de données `epiviz` est structurée selon le modèle suivant :
- **calendrier** : Table des dates
- **localisation** : Table des pays et continents
- **pandemie** : Table des types de pandémies
- **data** : Table principale contenant les données de cas avec des clés étrangères vers les autres tables

## Compétences Évaluées
- Définir les sources et les outils nécessaires pour la collecte des données
- Identifier les méthodes de modélisation des informations à partir de sources hétérogènes
- Paramétrer les outils pour l'importation automatisée des données
- Analyser, nettoyer et assurer la qualité des données
- Construire la structure de stockage des données (modèle de données)
- Représenter graphiquement les relations entre les données
- Explorer les données et les analyser dans les structures de stockage

## Installation et Utilisation
1. Cloner le dépôt
2. Installer les dépendances requises
3. Exécuter les notebooks dans l'ordre :
   - `Extraction.ipynb`
   - `Transformation_v3.ipynb` ou `Transformation_v4.ipynb`
   - `Chargement_v2.ipynb`

## Paramètres de Connexion à la Base de Données
- **Nom de la base de données** : epiviz
- **Utilisateur** : root
- **Mot de passe** : (aucun)
- **Hôte** : localhost
- **Port** : 3306

## Auteur
Projet réalisé dans le cadre de la certification Développeur en Intelligence Artificielle et Data Science (RNCP 36581) à l'EPSI.

## Date
Mars 2025
