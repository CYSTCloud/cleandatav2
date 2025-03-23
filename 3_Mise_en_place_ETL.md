# 3. Mise en place d'une solution ETL

Ce notebook présente la mise en place d'une solution ETL (Extract, Transform, Load) pour le traitement des données de pandémies.

## 3.1 Extraction des données

```python
# Importation des bibliothèques nécessaires
import pandas as pd
import json
import os
import glob

# Création du dossier de sortie s'il n'existe pas
os.makedirs('donnees_extraites', exist_ok=True)

# Fonction pour extraire les données CSV
def extraire_csv(chemin_fichier, nom_sortie):
    df = pd.read_csv(chemin_fichier)
    print(f"Extraction de {chemin_fichier}: {df.shape[0]} lignes, {df.shape[1]} colonnes")
    
    # Sauvegarde des données extraites
    df.to_csv(f'donnees_extraites/{nom_sortie}.csv', index=False)
    return df

# Fonction pour extraire les données JSON
def extraire_json(chemin_fichier, nom_sortie):
    with open(chemin_fichier, 'r') as f:
        data = json.load(f)
    
    # Conversion en DataFrame
    df = pd.json_normalize(data)
    print(f"Extraction de {chemin_fichier}: {df.shape[0]} lignes, {df.shape[1]} colonnes")
    
    # Sauvegarde des données extraites
    df.to_csv(f'donnees_extraites/{nom_sortie}.csv', index=False)
    return df

# Extraction des fichiers CSV disponibles
covid_clean = extraire_csv('data/covid_19_clean_complete.csv', 'covid_clean')
monkeypox = extraire_csv('data/owid-monkeypox-data.csv', 'monkeypox')
worldometer = extraire_csv('data/worldometer_coronavirus_daily_data.csv', 'worldometer')

# Affichage des premières lignes pour vérification
covid_clean.head()
```

## 3.2 Transformation des données

```python
# Importation des bibliothèques nécessaires
import pandas as pd
import numpy as np
from datetime import datetime
import os

# Création du dossier de sortie s'il n'existe pas
os.makedirs('donnees_transformees', exist_ok=True)

# Chargement des données extraites
covid_clean = pd.read_csv('donnees_extraites/covid_clean.csv')
monkeypox = pd.read_csv('donnees_extraites/monkeypox.csv')
worldometer = pd.read_csv('donnees_extraites/worldometer.csv')

# Fonction pour nettoyer et transformer les données COVID
def transformer_covid(df):
    # Copie pour éviter de modifier l'original
    df_clean = df.copy()
    
    # Conversion des dates
    df_clean['Date'] = pd.to_datetime(df_clean['Date'])
    
    # Normalisation des noms de pays
    df_clean['Country'] = df_clean['Country/Region']
    
    # Remplissage des valeurs manquantes
    for col in ['Confirmed', 'Deaths', 'Recovered', 'Active']:
        if col in df_clean.columns:
            df_clean[col] = df_clean[col].fillna(0)
    
    # Agrégation par pays et date
    df_agg = df_clean.groupby(['Country', 'Date']).agg({
        'Confirmed': 'sum',
        'Deaths': 'sum',
        'Recovered': 'sum',
        'Active': 'sum'
    }).reset_index()
    
    # Ajout du type de pandémie
    df_agg['Pandemic'] = 'COVID-19'
    
    return df_agg

# Fonction pour transformer les données Monkeypox
def transformer_monkeypox(df):
    # Copie pour éviter de modifier l'original
    df_clean = df.copy()
    
    # Conversion des dates
    df_clean['date'] = pd.to_datetime(df_clean['date'])
    
    # Renommage des colonnes pour cohérence
    df_clean = df_clean.rename(columns={
        'date': 'Date',
        'location': 'Country',
        'total_cases': 'Confirmed',
        'total_deaths': 'Deaths'
    })
    
    # Remplissage des valeurs manquantes
    for col in ['Confirmed', 'Deaths']:
        if col in df_clean.columns:
            df_clean[col] = df_clean[col].fillna(0)
    
    # Ajout des colonnes manquantes
    df_clean['Recovered'] = 0  # Pas de données de guérison
    df_clean['Active'] = df_clean['Confirmed'] - df_clean['Deaths']
    
    # Ajout du type de pandémie
    df_clean['Pandemic'] = 'Monkeypox'
    
    # Sélection des colonnes pertinentes
    df_clean = df_clean[['Country', 'Date', 'Confirmed', 'Deaths', 'Recovered', 'Active', 'Pandemic']]
    
    return df_clean

# Transformation des données
covid_transformed = transformer_covid(covid_clean)
monkeypox_transformed = transformer_monkeypox(monkeypox)

# Fusion des données transformées
all_data = pd.concat([covid_transformed, monkeypox_transformed], ignore_index=True)

# Suppression des doublons
all_data = all_data.drop_duplicates(subset=['Country', 'Date', 'Pandemic'])

# Sauvegarde des données transformées
all_data.to_csv('donnees_transformees/all_pandemics_data.csv', index=False)

# Affichage d'un aperçu des données transformées
all_data.head()
```

## 3.3 Préparation des tables selon le schéma SQL

```python
# Importation des bibliothèques nécessaires
import pandas as pd
import numpy as np
from datetime import datetime
import os

# Création du dossier pour les données prêtes à charger
os.makedirs('donnees_a_charger', exist_ok=True)

# Chargement des données transformées
all_data = pd.read_csv('donnees_transformees/all_pandemics_data.csv')
all_data['Date'] = pd.to_datetime(all_data['Date'])

# 1. Préparation de la table calendrier
def preparer_table_calendrier(df):
    # Extraction des dates uniques
    dates = df['Date'].unique()
    
    # Création du DataFrame calendrier
    calendrier = pd.DataFrame({
        'date_id': range(1, len(dates) + 1),
        'date': dates,
        'jour': pd.to_datetime(dates).day,
        'mois': pd.to_datetime(dates).month,
        'annee': pd.to_datetime(dates).year
    })
    
    return calendrier

# 2. Préparation de la table localisation
def preparer_table_localisation(df):
    # Extraction des pays uniques
    pays = df['Country'].unique()
    
    # Création du DataFrame localisation (simplifié)
    localisation = pd.DataFrame({
        'localisation_id': range(1, len(pays) + 1),
        'pays': pays,
        'continent': 'À déterminer'  # À compléter avec des données réelles
    })
    
    return localisation

# 3. Préparation de la table pandemie
def preparer_table_pandemie(df):
    # Extraction des types de pandémies uniques
    pandemies = df['Pandemic'].unique()
    
    # Création du DataFrame pandemie
    pandemie = pd.DataFrame({
        'pandemie_id': range(1, len(pandemies) + 1),
        'nom': pandemies
    })
    
    return pandemie

# 4. Préparation de la table data
def preparer_table_data(df, calendrier, localisation, pandemie):
    # Fusion avec les tables de référence pour obtenir les IDs
    df_avec_date_id = pd.merge(
        df,
        calendrier[['date_id', 'date']],
        left_on='Date',
        right_on='date',
        how='left'
    )
    
    df_avec_loc_id = pd.merge(
        df_avec_date_id,
        localisation[['localisation_id', 'pays']],
        left_on='Country',
        right_on='pays',
        how='left'
    )
    
    df_avec_pandemie_id = pd.merge(
        df_avec_loc_id,
        pandemie[['pandemie_id', 'nom']],
        left_on='Pandemic',
        right_on='nom',
        how='left'
    )
    
    # Création de la table data
    data = pd.DataFrame({
        'data_id': range(1, len(df_avec_pandemie_id) + 1),
        'date_id': df_avec_pandemie_id['date_id'],
        'localisation_id': df_avec_pandemie_id['localisation_id'],
        'pandemie_id': df_avec_pandemie_id['pandemie_id'],
        'cas': df_avec_pandemie_id['Confirmed'],
        'deces': df_avec_pandemie_id['Deaths'],
        'guerisons': df_avec_pandemie_id['Recovered'],
        'cas_actifs': df_avec_pandemie_id['Active']
    })
    
    return data

# Préparation des tables
calendrier = preparer_table_calendrier(all_data)
localisation = preparer_table_localisation(all_data)
pandemie = preparer_table_pandemie(all_data)
data = preparer_table_data(all_data, calendrier, localisation, pandemie)

# Sauvegarde des tables
calendrier.to_csv('donnees_a_charger/sql_calendrier.csv', index=False)
localisation.to_csv('donnees_a_charger/sql_localisation.csv', index=False)
pandemie.to_csv('donnees_a_charger/sql_pandemie.csv', index=False)
data.to_csv('donnees_a_charger/sql_data.csv', index=False)

# Affichage des premières lignes de chaque table
print("Table calendrier:")
print(calendrier.head())
print("\nTable localisation:")
print(localisation.head())
print("\nTable pandemie:")
print(pandemie.head())
print("\nTable data:")
print(data.head())
```

## 3.4 Chargement des données dans la base de données

```python
# Importation des bibliothèques nécessaires
import pandas as pd
import mysql.connector
from mysql.connector import Error
import os

# Fonction pour créer une connexion à la base de données
def creer_connexion():
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='',  # Modifier selon votre configuration
            database='epiviz'
        )
        if conn.is_connected():
            print('Connexion à la base de données réussie')
            return conn
    except Error as e:
        print(f"Erreur lors de la connexion à MySQL: {e}")
        return None

# Fonction pour créer les tables dans la base de données
def creer_tables(conn):
    try:
        cursor = conn.cursor()
        
        # Création de la table calendrier
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS calendrier (
            date_id INT PRIMARY KEY,
            date DATE NOT NULL,
            jour INT NOT NULL,
            mois INT NOT NULL,
            annee INT NOT NULL
        )
        ''')
        
        # Création de la table localisation
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS localisation (
            localisation_id INT PRIMARY KEY,
            pays VARCHAR(100) NOT NULL,
            continent VARCHAR(100)
        )
        ''')
        
        # Création de la table pandemie
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS pandemie (
            pandemie_id INT PRIMARY KEY,
            nom VARCHAR(100) NOT NULL
        )
        ''')
        
        # Création de la table data
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS data (
            data_id INT PRIMARY KEY,
            date_id INT,
            localisation_id INT,
            pandemie_id INT,
            cas INT,
            deces INT,
            guerisons INT,
            cas_actifs INT,
            FOREIGN KEY (date_id) REFERENCES calendrier(date_id),
            FOREIGN KEY (localisation_id) REFERENCES localisation(localisation_id),
            FOREIGN KEY (pandemie_id) REFERENCES pandemie(pandemie_id)
        )
        ''')
        
        conn.commit()
        print("Tables créées avec succès")
    except Error as e:
        print(f"Erreur lors de la création des tables: {e}")

# Fonction pour charger les données dans une table
def charger_donnees(conn, nom_table, fichier_csv):
    try:
        # Lecture du fichier CSV
        df = pd.read_csv(fichier_csv)
        
        # Préparation des données pour l'insertion
        colonnes = ', '.join(df.columns)
        placeholders = ', '.join(['%s'] * len(df.columns))
        
        # Requête d'insertion
        query = f"INSERT INTO {nom_table} ({colonnes}) VALUES ({placeholders})"
        
        # Exécution de l'insertion
        cursor = conn.cursor()
        for _, row in df.iterrows():
            cursor.execute(query, tuple(row))
        
        conn.commit()
        print(f"Données chargées dans la table {nom_table}: {len(df)} lignes")
    except Error as e:
        print(f"Erreur lors du chargement des données dans {nom_table}: {e}")

# Établissement de la connexion
conn = creer_connexion()

if conn:
    # Création des tables
    creer_tables(conn)
    
    # Chargement des données
    charger_donnees(conn, 'calendrier', 'donnees_a_charger/sql_calendrier.csv')
    charger_donnees(conn, 'localisation', 'donnees_a_charger/sql_localisation.csv')
    charger_donnees(conn, 'pandemie', 'donnees_a_charger/sql_pandemie.csv')
    charger_donnees(conn, 'data', 'donnees_a_charger/sql_data.csv')
    
    # Fermeture de la connexion
    conn.close()
    print("Processus ETL terminé avec succès")
```

## 3.5 Vérification des données chargées

```python
# Importation des bibliothèques nécessaires
import pandas as pd
import mysql.connector
from mysql.connector import Error

# Fonction pour créer une connexion à la base de données
def creer_connexion():
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='',  # Modifier selon votre configuration
            database='epiviz'
        )
        if conn.is_connected():
            print('Connexion à la base de données réussie')
            return conn
    except Error as e:
        print(f"Erreur lors de la connexion à MySQL: {e}")
        return None

# Fonction pour exécuter une requête et retourner les résultats
def executer_requete(conn, query):
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query)
        results = cursor.fetchall()
        return results
    except Error as e:
        print(f"Erreur lors de l'exécution de la requête: {e}")
        return None

# Établissement de la connexion
conn = creer_connexion()

if conn:
    # Vérification du nombre d'enregistrements dans chaque table
    tables = ['calendrier', 'localisation', 'pandemie', 'data']
    for table in tables:
        results = executer_requete(conn, f"SELECT COUNT(*) as count FROM {table}")
        print(f"Table {table}: {results[0]['count']} enregistrements")
    
    # Exemple de requête pour vérifier les données de COVID-19 en France
    query = '''
    SELECT c.date, l.pays, p.nom, d.cas, d.deces, d.guerisons, d.cas_actifs
    FROM data d
    JOIN calendrier c ON d.date_id = c.date_id
    JOIN localisation l ON d.localisation_id = l.localisation_id
    JOIN pandemie p ON d.pandemie_id = p.pandemie_id
    WHERE l.pays = 'France' AND p.nom = 'COVID-19'
    ORDER BY c.date
    LIMIT 10
    '''
    
    results = executer_requete(conn, query)
    if results:
        print("\nExemple de données COVID-19 en France:")
        df_results = pd.DataFrame(results)
        print(df_results)
    
    # Fermeture de la connexion
    conn.close()
```
