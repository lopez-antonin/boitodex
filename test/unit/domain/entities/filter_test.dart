import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/domain/entities/filter.dart';

void main() {
  group('CarFilter', () {
    test('should create filter with default values', () {
      const filter = CarFilter();

      expect(filter.brand, isNull);
      expect(filter.shape, isNull);
      expect(filter.nameQuery, equals(''));
      expect(filter.sortBy, equals(SortOption.name));
      expect(filter.sortAscending, isTrue);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('should create filter with all properties', () {
      const filter = CarFilter(
        brand: 'BMW',
        shape: 'Berline',
        nameQuery: 'Serie 3',
        sortBy: SortOption.brand,
        sortAscending: false,
      );

      expect(filter.brand, equals('BMW'));
      expect(filter.shape, equals('Berline'));
      expect(filter.nameQuery, equals('Serie 3'));
      expect(filter.sortBy, equals(SortOption.brand));
      expect(filter.sortAscending, isFalse);
      expect(filter.hasActiveFilters, isTrue);
    });

    group('copyWith', () {
      const originalFilter = CarFilter(
        brand: 'BMW',
        shape: 'Berline',
        nameQuery: 'Serie 3',
        sortBy: SortOption.brand,
        sortAscending: false,
      );

      test('should return CarFilter with updated fields', () {
        final updatedFilter = originalFilter.copyWith(
          brand: 'Audi',
          sortBy: SortOption.name,
          sortAscending: true,
        );

        expect(updatedFilter.brand, equals('Audi'));
        expect(updatedFilter.shape, equals('Berline'));
        expect(updatedFilter.nameQuery, equals('Serie 3'));
        expect(updatedFilter.sortBy, equals(SortOption.name));
        expect(updatedFilter.sortAscending, isTrue);
      });

      test('should return same filter when no fields are updated', () {
        final sameFilter = originalFilter.copyWith();

        expect(sameFilter.brand, equals('BMW'));
        expect(sameFilter.shape, equals('Berline'));
        expect(sameFilter.nameQuery, equals('Serie 3'));
        expect(sameFilter.sortBy, equals(SortOption.brand));
        expect(sameFilter.sortAscending, isFalse);
      });

      test('should update specific fields while keeping others unchanged', () {
        final updatedFilter = originalFilter.copyWith(
          brand: 'Mercedes',
          nameQuery: '',
        );

        expect(updatedFilter.brand, equals('Mercedes'));
        expect(updatedFilter.shape, equals('Berline')); // unchanged
        expect(updatedFilter.nameQuery, equals(''));
        expect(updatedFilter.sortBy, equals(SortOption.brand)); // unchanged
        expect(updatedFilter.sortAscending, isFalse); // unchanged
      });
    });

    group('hasActiveFilters', () {
      test('should return true when brand filter is active', () {
        const filter = CarFilter(brand: 'BMW');
        expect(filter.hasActiveFilters, isTrue);
      });

      test('should return true when shape filter is active', () {
        const filter = CarFilter(shape: 'Berline');
        expect(filter.hasActiveFilters, isTrue);
      });

      test('should return true when name query is active', () {
        const filter = CarFilter(nameQuery: 'Serie');
        expect(filter.hasActiveFilters, isTrue);
      });

      test('should return false when no filters are active', () {
        const filter = CarFilter(
          sortBy: SortOption.brand,
          sortAscending: false,
        );
        expect(filter.hasActiveFilters, isFalse);
      });

      test('should return true when multiple filters are active', () {
        const filter = CarFilter(
          brand: 'BMW',
          shape: 'Berline',
          nameQuery: 'Serie 3',
        );
        expect(filter.hasActiveFilters, isTrue);
      });

      test('should return false when filters are empty strings', () {
        const filter = CarFilter(
          brand: '',
          shape: '',
          nameQuery: '',
        );
        expect(filter.hasActiveFilters, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        const filter1 = CarFilter(
          brand: 'BMW',
          shape: 'Berline',
          nameQuery: 'Serie 3',
          sortBy: SortOption.brand,
          sortAscending: false,
        );

        const filter2 = CarFilter(
          brand: 'BMW',
          shape: 'Berline',
          nameQuery: 'Serie 3',
          sortBy: SortOption.brand,
          sortAscending: false,
        );

        expect(filter1, equals(filter2));
        expect(filter1.hashCode, equals(filter2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const filter1 = CarFilter(brand: 'BMW');
        const filter2 = CarFilter(brand: 'Audi');

        expect(filter1, isNot(equals(filter2)));
        expect(filter1.hashCode, isNot(equals(filter2.hashCode)));
      });
    });
  });

  group('SortOption', () {
    test('should have correct display names', () {
      expect(SortOption.name.displayName, equals('Nom'));
      expect(SortOption.brand.displayName, equals('Marque'));
      expect(SortOption.shape.displayName, equals('Forme'));
      expect(SortOption.createdAt.displayName, equals('Date de création'));
      expect(SortOption.updatedAt.displayName, equals('Date de modification'));
    });

    test('should have all expected values', () {
      expect(SortOption.values.length, equals(5));
      expect(SortOption.values, contains(SortOption.name));
      expect(SortOption.values, contains(SortOption.brand));
      expect(SortOption.values, contains(SortOption.shape));
      expect(SortOption.values, contains(SortOption.createdAt));
      expect(SortOption.values, contains(SortOption.updatedAt));
    });
  });
}