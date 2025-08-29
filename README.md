# Boitodex

Une application Flutter pour la gestion de collections de voitures miniatures.

## Architecture

Ce projet utilise Clean Architecture avec le pattern MVVM :

- **Domain Layer** : Entités, use cases, et abstractions des repositories
- **Data Layer** : Implémentations des repositories, sources de données, et modèles
- **Features Layer** : UI, ViewModels, et widgets spécifiques aux fonctionnalités
- **App Layer** : Configuration de l'application, thèmes, et injection de dépendances
- **Core Layer** : Utilitaires partagés, gestion d'erreurs, et widgets communs

## Structure du projet

```
lib/
├── main.dart
├── app/                    # Configuration de l'application
├── core/                   # Éléments partagés
├── data/                   # Couche de données
├── domain/                 # Logique métier
└── features/               # Fonctionnalités UI
```

## Installation

1. Cloner le repository
```bash
git clone https://github.com/your-username/boitodex.git
cd boitodex
```

2. Installer les dépendances
```bash
flutter pub get
```

3. Générer les mocks pour les tests
```bash
flutter packages pub run build_runner build
```

4. Lancer l'application
```bash
flutter run
```

## Tests

Lancer tous les tests :
```bash
flutter test
```

Lancer les tests avec coverage :
```bash
flutter test --coverage
```

## Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Principles suivis

- **SOLID Principles**
- **Clean Architecture**
- **Dependency Inversion**
- **Single Responsibility**
- **Test-Driven Development**