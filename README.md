# Détecteur de maladies du pommier

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/Licence-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Plateforme-iOS%20%7C%20Android-lightgrey.svg)]()

Une application mobile multiplateforme pour la détection des maladies des feuilles de pommier utilisant **ONNX Runtime** pour l'inférence sur l'appareil et **Google Gemini/OpenAI** pour des conseils agricoles intelligents.

## Fonctionnalités

### Détection des Maladies

- Capture de photos depuis l'appareil photo ou sélection dans la galerie
- Inférence en temps réel avec le modèle ONNX pour une classification rapide
- Distribution détaillée des probabilités pour toutes les classes de maladies
- Scores de confiance avec métriques d'incertitude

### Assistance par IA

- Intégration de Google Gemini et OpenAI ChatGPT
- Recommandations de traitement contextuelles
- Stratégies de prévention et options biologiques/chimiques
- Chat interactif pour les questions de suivi

### Analyses et Statistiques

- Stockage persistant de toutes les analyses et sessions de chat
- Tableau de bord statistique avec visualisations
- Export des données au format CSV pour analyse approfondie

### Support Multilingue

- Anglais
- Français
- Arabe (avec disposition RTL)

### Expérience Utilisateur

- Mode sombre
- Material Design 3
- Animations fluides
- Mise en page responsive

## Informations sur le Modèle

Le modèle ONNX classe les maladies des feuilles de pommier en 5 catégories :

| Classe               | Description                                 |
| -------------------- | ------------------------------------------- |
| Alternaria leaf spot | Maladie fongique causant des taches sombres |
| Brown spot           | Infection fongique avec lésions brunes      |
| Gray spot            | Maladie fongique avec taches grisâtres      |
| Healthy leaf         | Feuille saine, aucune maladie détectée      |
| Rust                 | Maladie fongique avec taches orange/rouille |

Le modèle a été exporté à partir d'un modèle PyTorch entraîné sur l'ensemble de données Kaggle en utilisant le notebook :  
[98% Accurate Apple Tree Leaf Classifier](https://www.kaggle.com/code/killa92/98-accurate-apple-tree-leaf-classifier)

## Pile Technologique

| Catégorie       | Technologie                   |
| --------------- | ----------------------------- |
| Framework       | Flutter (Dart)                |
| Gestion d'État  | Provider (ChangeNotifier)     |
| IA sur Appareil | ONNX Runtime                  |
| IA Cloud        | API Google Gemini, API OpenAI |
| Base de Données | SQLite (sqflite)              |
| Appareil Photo  | camera, image_picker          |
| Graphiques      | fl_chart                      |
| Localisation    | flutter_localizations, intl   |
| Export          | csv, share_plus               |

## Installation

### Prérequis

- Flutter SDK (3.16.0 ou supérieur)
- Android Studio / VS Code avec extensions Flutter
- Android SDK (pour Android) ou Xcode (pour iOS)

### Étapes

1. Cloner le dépôt

   ```bash
   git clone https://github.com/El-HadroubiYoussef/AppleGuard.git
   cd AppleGuard/
   ```

2. Installer les dépendances

   ```bash
   flutter pub get
   ```

3. Lancer l'application
   ```bash
   flutter run
   ```

### Configuration des Clés API

Pour utiliser les fonctionnalités d'assistance IA :

1. Accédez à **Paramètres** → **Configuration IA**
2. Sélectionnez votre service IA préféré (Google Gemini ou OpenAI)
3. Saisissez votre clé API
4. Appuyez sur **Enregistrer la clé API**

Obtenir des clés API :

- **Google Gemini :** https://makersuite.google.com/app/apikey
- **OpenAI :** https://platform.openai.com/api-keys

## Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── l10n/                     # Fichiers de localisation (en, fr, ar)
├── models/                   # Modèles de données
├── providers/                # Gestion d'état (ChangeNotifier)
├── screens/                  # Écrans de l'interface
│   ├── camera/               # Écran appareil photo
│   ├── chat/                 # Écrans de chat IA
│   ├── dashboard/            # Tableau de bord principal
│   ├── settings/             # Écrans de paramètres
│   └── statistics/           # Statistiques avec graphiques
├── services/                 # Logique métier
│   ├── ai_service.dart       # Intégration LLM
│   ├── database_service.dart # Opérations SQLite
│   ├── onnx_service.dart     # Inférence ONNX
│   └── image_picker_service.dart
├── utils/                    # Utilitaires
└── widgets/                  # Widgets réutilisables
```

## Tests

Exécuter les tests unitaires :

```bash
flutter test
```

Couverture des tests :

- 14 tests unitaires
- Tests du service ONNX (softmax, entropie)
- Tests du provider de navigation
- Tests du service de base de données
- Tests des widgets

## Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.

## Remerciements

- Kaggle et killa92 pour le notebook d'entraînement du modèle
- ONNX Runtime pour l'inférence mobile efficace
- Google Gemini et OpenAI pour leurs API LLM
- Flutter et sa communauté pour les excellents packages
- L'enseignant superviseur pour la fourniture du modèle de base

## Auteur

El Hadroubi Youssef
Projet de Fin d'Études - 2025/2026
