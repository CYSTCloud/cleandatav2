# Guide d'Utilisation de la Solution ETL pour les Données de Pandémies

## Introduction

Ce guide explique comment utiliser la solution ETL (Extract, Transform, Load) développée pour traiter les données de pandémies mondiales. Cette solution permet d'extraire des données depuis des fichiers CSV, de les transformer et de les charger dans une base de données MySQL pour analyse.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les éléments suivants :

1. **Python 3.8 ou supérieur**
2. **Jupyter Notebook**
3. **MySQL** (ou MariaDB)
4. **Bibliothèques Python requises** :
   - pandas
   - numpy
   - sqlalchemy
   - pymysql
   - matplotlib
   - seaborn

Vous pouvez installer les bibliothèques requises avec la commande :

```bash
pip install pandas numpy sqlalchemy pymysql matplotlib seaborn
```

## Structure du Projet

Le projet est organisé en trois parties principales, suivant le processus ETL :

```
ETL-Pandemies-FR/
├── README.md                      # Description générale du projet
├── epiviz.sql                     # Schéma de la base de données
├── Guide_Utilisation.md           # Ce guide d'utilisation
├── Partie-01-Extraction/          # Partie extraction des données
│   ├── Extraction.ipynb           # Notebook pour l'extraction
│   └── Donnees Brutes/            # Dossier contenant les fichiers de données brutes
├── Partie-02-Transformation/      # Partie transformation des données
│   ├── Transformation.ipynb       # Notebook pour la transformation
│   ├── Donnees Brutes/            # Dossier contenant les fichiers bruts copiés
│   └── donnees_nettoyees/         # Dossier contenant les fichiers transformés
└── Partie-03-Chargement/          # Partie chargement des données
    ├── Chargement.ipynb           # Notebook pour le chargement
    └── donnees_nettoyees/         # Dossier contenant les fichiers transformés
```

## Étape 1 : Préparation des Données

1. Placez vos fichiers de données CSV dans le dossier `Partie-01-Extraction/Donnees Brutes/` :
   - `covid_19_clean_complete.csv`
   - `owid-monkeypox-data.csv`
   - `worldometer_coronavirus_daily_data.csv`

2. Créez la base de données MySQL en exécutant le script `epiviz.sql` :
   ```bash
   mysql -u votre_utilisateur -p < epiviz.sql
   ```

## Étape 2 : Extraction des Données

1. Ouvrez le notebook `Partie-01-Extraction/Extraction.ipynb` avec Jupyter Notebook.
2. Exécutez toutes les cellules du notebook pour :
   - Charger les données depuis les fichiers CSV
   - Examiner la structure des données
   - Sauvegarder les données extraites pour la phase de transformation

## Étape 3 : Transformation des Données

1. Ouvrez le notebook `Partie-02-Transformation/Transformation.ipynb` avec Jupyter Notebook.
2. Exécutez toutes les cellules du notebook pour :
   - Nettoyer les données (valeurs manquantes, formats de date, etc.)
   - Normaliser les noms de pays et de régions
   - Calculer des métriques supplémentaires (taux d'incidence, taux de mortalité, etc.)
   - Préparer les données selon le schéma de la base de données
   - Sauvegarder les données transformées pour la phase de chargement

## Étape 4 : Chargement des Données

1. Ouvrez le notebook `Partie-03-Chargement/Chargement.ipynb` avec Jupyter Notebook.
2. Modifiez les paramètres de connexion à la base de données dans la section "Configuration de la connexion à la base de données" :
   ```python
   db_user = 'votre_utilisateur'
   db_password = 'votre_mot_de_passe'
   db_host = 'localhost'
   db_port = '3306'
   db_name = 'pandemies_db'
   ```
3. Exécutez toutes les cellules du notebook pour :
   - Charger les données transformées
   - Établir une connexion à la base de données MySQL
   - Charger les données dans les tables correspondantes
   - Vérifier les données chargées
   - Exécuter quelques requêtes d'analyse

## Exécution du Processus ETL Complet

Pour exécuter le processus ETL complet en une seule fois, suivez ces étapes dans l'ordre :

1. Exécutez le notebook d'extraction
2. Exécutez le notebook de transformation
3. Exécutez le notebook de chargement

## Requêtes SQL Utiles

Voici quelques exemples de requêtes SQL pour analyser les données chargées :

### Top 5 des pays avec le plus de cas confirmés
```sql
SELECT l.pays, MAX(d.cas_confirmes) as total_cas
FROM data d
JOIN localisation l ON d.id_localisation = l.id_localisation
JOIN pandemie p ON d.id_pandemie = p.id_pandemie
WHERE p.nom = 'COVID-19'
GROUP BY l.pays
ORDER BY total_cas DESC
LIMIT 5;
```

### Évolution des cas par mois
```sql
SELECT YEAR(c.date) as annee, MONTH(c.date) as mois, SUM(d.nouveaux_cas) as total_nouveaux_cas
FROM data d
JOIN calendrier c ON d.id_date = c.id_date
JOIN pandemie p ON d.id_pandemie = p.id_pandemie
WHERE p.nom = 'COVID-19'
GROUP BY YEAR(c.date), MONTH(c.date)
ORDER BY annee, mois;
```

### Comparaison des taux de mortalité entre continents
```sql
SELECT l.continent, AVG(d.taux_mortalite) as taux_mortalite_moyen
FROM data d
JOIN localisation l ON d.id_localisation = l.id_localisation
JOIN pandemie p ON d.id_pandemie = p.id_pandemie
WHERE p.nom = 'COVID-19'
GROUP BY l.continent
ORDER BY taux_mortalite_moyen DESC;
```

## Dépannage

### Problèmes de connexion à la base de données
- Vérifiez que le serveur MySQL est en cours d'exécution
- Vérifiez les paramètres de connexion (utilisateur, mot de passe, hôte, port)
- Assurez-vous que la base de données a été créée avec le script `epiviz.sql`

### Problèmes de chargement des données
- Vérifiez que les fichiers CSV sont présents dans les dossiers appropriés
- Assurez-vous que les formats de données sont corrects
- Vérifiez les erreurs dans les notebooks pour identifier les problèmes spécifiques

## Personnalisation

Vous pouvez personnaliser cette solution ETL en :
- Ajoutant de nouvelles sources de données
- Modifiant les transformations pour répondre à des besoins spécifiques
- Ajoutant de nouvelles requêtes d'analyse
- Intégrant la solution avec d'autres outils (Power BI, Tableau, etc.)

## Conclusion

Cette solution ETL vous permet de traiter efficacement les données de pandémies mondiales et de les préparer pour l'analyse. En suivant ce guide, vous pouvez extraire, transformer et charger les données dans une base de données relationnelle, puis effectuer des analyses pour obtenir des insights précieux sur l'évolution des pandémies.
