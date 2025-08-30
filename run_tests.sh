#!/bin/bash

# Script pour exécuter tous les tests de Boitodex

echo "🧪 Lancement des tests Boitodex"
echo "================================"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2 - SUCCÈS${NC}"
    else
        echo -e "${RED}❌ $2 - ÉCHEC${NC}"
        exit 1
    fi
}

# Nettoyer et récupérer les dépendances
echo -e "${YELLOW}📦 Installation des dépendances...${NC}"
flutter clean
flutter pub get

# Génération des mocks
echo -e "${YELLOW}🔧 Génération des mocks...${NC}"
flutter packages pub run build_runner build --delete-conflicting-outputs
print_result $? "Génération des mocks"

# Tests unitaires - Utils
echo -e "${YELLOW}🧪 Tests unitaires - Utilitaires...${NC}"
flutter test test/unit/core/utils/ --coverage
print_result $? "Tests utilitaires"

# Tests unitaires - Domain
echo -e "${YELLOW}🧪 Tests unitaires - Domaine...${NC}"
flutter test test/unit/domain/ --coverage
print_result $? "Tests domaine"

# Tests unitaires - Data
echo -e "${YELLOW}🧪 Tests unitaires - Données...${NC}"
flutter test test/unit/data/ --coverage
print_result $? "Tests données"

# Tests unitaires - Features
echo -e "${YELLOW}🧪 Tests unitaires - Fonctionnalités...${NC}"
flutter test test/unit/features/ --coverage
print_result $? "Tests fonctionnalités"

# Tests de widgets
echo -e "${YELLOW}🧪 Tests de widgets...${NC}"
flutter test test/widget/ --coverage
print_result $? "Tests widgets"

# Tests d'intégration
echo -e "${YELLOW}🧪 Tests d'intégration...${NC}"
flutter test test/integration/ --coverage
print_result $? "Tests intégration"

# Tous les tests ensemble
echo -e "${YELLOW}🧪 Exécution de tous les tests...${NC}"
flutter test --coverage
print_result $? "Tous les tests"

# Génération du rapport de couverture
echo -e "${YELLOW}📊 Génération du rapport de couverture...${NC}"
genhtml coverage/lcov.info -o coverage/html
print_result $? "Rapport de couverture"

echo -e "${GREEN}🎉 Tous les tests ont réussi !${NC}"
echo -e "${YELLOW}📊 Rapport de couverture disponible dans: coverage/html/index.html${NC}"

# Affichage du résumé de couverture
echo -e "${YELLOW}📈 Résumé de couverture:${NC}"
lcov --summary coverage/lcov.info