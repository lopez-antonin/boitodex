# Tests Boitodex

Ce document décrit l'organisation des tests dans l'application Boitodex et comment les exécuter.

## Structure des tests

```
test/
├── integration/           # Tests d'intégration
│   └── app_test.dart     # Tests bout en bout de l'application
├── unit/                 # Tests unitaires
│   ├── core/
│   │   └── utils/        # Tests des utilitaires
│   ├── data/
│   │   ├── datasources/  # Tests des sources de données
│   │   ├── models/       # Tests des modèles de données
│   │   └── repositories/ # Tests des repositories
│   ├── domain/
│   │   ├── entities/     # Tests des entités
│   │   └── usecases/     # Tests des cas d'usage
│   └── features/
│       ├── car_form/     # Tests du formulaire de voiture
│       └── home/         # Tests de l'écran d'accueil
└── widget/               # Tests de widgets
    ├── car_form_fields_test.dart
    └── car_list_item_test.dart
```

## Types de tests

### 1. Tests unitaires

Les tests unitaires vérifient le comportement des classes individuelles de manière isolée.

**Couverture :**
- ✅ Entités du domaine (Car, CarFilter)
- ✅ Cas d'usage (AddCar, DeleteCar, GetCars, UpdateCar)
- ✅ Modèles de données (CarModel, FilterModel)
- ✅ Utilitaires (ValidationUtils, ImageUtils)
- ✅ Repositories et sources de données
- ✅ ViewModels

### 2. Tests de widgets

Les tests de widgets vérifient l'affichage et l'interaction des composants UI.

**Couverture :**
- ✅ CarFormFields - Champs du formulaire
- ✅ CarListItem - Élément de liste de voiture

### 3. Tests d'intégration

Les tests d'intégration vérifient le fonctionnement complet de l'application.

**Couverture :**
- ✅ Navigation entre écrans
- ✅ Ajout/modification/suppression de voitures
- ✅ Recherche et filtrage
- ✅ Validation de formulaire
- ✅ États vides

## Exécuter les tests

### Prérequis

1. **Flutter SDK** installé
2. **Dépendances** installées :
   ```bash
   flutter pub get
   ```
3. **Mocks générés** :
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

### Commandes de test

#### Tous les tests
```bash
flutter test --coverage
```

#### Tests par catégorie
```bash
# Tests unitaires uniquement
flutter test test/unit/

# Tests de widgets uniquement  
flutter test test/widget/

# Tests d'intégration uniquement
flutter test test/integration/
```

#### Tests spécifiques
```bash
# Tests d'un fichier particulier
flutter test test/unit/domain/entities/car_test.dart

# Tests d'un dossier particulier
flutter test test/unit/features/home/
```

### Visualiser la couverture

Après avoir exécuté les tests avec `--coverage` :

```bash
# Installer lcov (Ubuntu/Debian)
sudo apt-get install lcov

# Générer le rapport HTML
genhtml coverage/lcov.info -o coverage/html

# Ouvrir le rapport
open coverage/html/index.html
```

### Objectifs de couverture

- **Couverture globale** : > 90%
- **Logique métier** (domain) : > 95%
- **Repositories** : > 90%
- **ViewModels** : > 85%

## Mocks et stubs

Le projet utilise **Mockito** pour créer des mocks dans les tests.

### Générer les mocks

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Utilisation des mocks

Les mocks sont générés automatiquement à partir des annotations `@GenerateMocks` :

```dart
@GenerateMocks([CarRepository])
void main() {
  late MockCarRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCarRepository();
  });
  
  test('should return cars when call is successful', () async {
    // arrange
    when(mockRepository.getCars()).thenAnswer((_) async => Right([]));
    
    // act & assert
    // ...
  });
}
```

## CI/CD

Les tests sont automatiquement exécutés via **GitHub Actions** :

- ✅ Tests unitaires et widgets
- ✅ Tests d'intégration (avec émulateur Android)
- ✅ Analyse de code statique
- ✅ Rapport de couverture (Codecov)
- ✅ Build APK de debug

Voir `.github/workflows/tests.yml` pour la configuration complète.

## Bonnes pratiques

### Structure des tests

```dart
void main() {
  group('ClasseTestée', () {
    // Setup commun
    late ClasseTestée objetTeste;
    
    setUp(() {
      objetTeste = ClasseTestée();
    });
    
    group('méthodeTestée', () {
      test('should do something when condition', () async {
        // arrange - préparer les données et mocks
        
        // act - exécuter la méthode
        
        // assert - vérifier les résultats
      });
    });
  });
}
```

### Nommage

- **Fichiers** : `nom_classe_test.dart`
- **Tests** : `should [action] when [condition]`
- **Groupes** : nom de la classe ou méthode testée

### Assertions

- Utiliser des assertions spécifiques : `expect(result, isA<Type>())`
- Vérifier les appels de méthodes : `verify(mock.method())`
- Tester les cas d'erreur : `expect(() => action, throwsA(isA<Exception>()))`

## Debugging des tests

### Exécuter un seul test

```bash
flutter test test/unit/domain/entities/car_test.dart -n "should return Car with updated fields"
```

### Debug mode

```bash
flutter test --start-paused
```

### Logs verbose

```bash
flutter test --verbose
```

## Ajout de nouveaux tests

1. **Créer le fichier de test** dans le bon dossier
2. **Ajouter les annotations** `@GenerateMocks` si nécessaire
3. **Régénérer les mocks** avec build_runner
4. **Écrire les tests** en suivant la structure AAA (Arrange, Act, Assert)
5. **Vérifier la couverture** avec `flutter test --coverage`

---

Pour toute question sur les tests, consultez la documentation Flutter Testing ou créez une issue dans le repository.