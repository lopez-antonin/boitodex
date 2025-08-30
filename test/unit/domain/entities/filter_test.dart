import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/domain/entities/filter.dart';

void main() {
  group('CarFilter', () {
    const tFilter = CarFilter(
      brand: 'BMW',
      shape: 'Sedan',
      nameQuery: 'X5',
      sortBy: SortOption.brand,
      sortAscending: false,
    );

    group('copyWith', () {
      test('should return CarFilter with updated fields', () {
        // act
        final result = tFilter.copyWith(
          brand: 'Audi',
          sortAscending: true,
        );

        // assert
        expect(result.brand, 'Audi');
        expect(result.sortAscending, true);
        expect(result.shape, tFilter.shape);
        expect(result.nameQuery, tFilter.nameQuery);
        expect(result.sortBy, tFilter.sortBy);
      });

      test('should return CarFilter with same values when no parameters provided', () {
        // act
        final result = tFilter.copyWith();

        // assert
        expect(result, tFilter);
        expect(result.brand, tFilter.brand);
        expect(result.shape, tFilter.shape);
        expect(result.nameQuery, tFilter.nameQuery);
        expect(result.sortBy, tFilter.sortBy);
        expect(result.sortAscending, tFilter.sortAscending);
      });

      test('should clear fields when explicitly set to null', () {
        // act
        final result = tFilter.copyWith(
          brand: null,
          shape: null,
          nameQuery: '',
        );

        // assert
        expect(result.brand, null);
        expect(result.shape, null);
        expect(result.nameQuery, '');
      });
    });

    group('hasActiveFilters', () {
      test('should return true when brand filter is set', () {
        // arrange
        const filter = CarFilter(brand: 'BMW');

        // act & assert
        expect(filter.hasActiveFilters, true);
      });

      test('should return true when shape filter is set', () {
        // arrange
        const filter = CarFilter(shape: 'Sedan');

        // act & assert
        expect(filter.hasActiveFilters, true);
      });

      test('should return true when name query is set', () {
        // arrange
        const filter = CarFilter(nameQuery: 'X5');

        // act & assert
        expect(filter.hasActiveFilters, true);
      });

      test('should return true when multiple filters are set', () {
        // arrange
        const filter = CarFilter(
          brand: 'BMW',
          shape: 'Sedan',
          nameQuery: 'X5',
        );

        // act & assert
        expect(filter.hasActiveFilters, true);
      });

      test('should return false when no filters are set', () {
        // arrange
        const filter = CarFilter();

        // act & assert
        expect(filter.hasActiveFilters, false);
      });

      test('should return false when filters are empty strings', () {
        // arrange
        const filter = CarFilter(
          nameQuery: '',
        );

        // act & assert
        expect(filter.hasActiveFilters, false);
      });
    });

    group('props', () {
      test('should include all fields in props for equality comparison', () {
        // act
        final props = tFilter.props;

        // assert
        expect(props.length, 5);
        expect(props, contains(tFilter.brand));
        expect(props, contains(tFilter.shape));
        expect(props, contains(tFilter.nameQuery));
        expect(props, contains(tFilter.sortBy));
        expect(props, contains(tFilter.sortAscending));
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        // arrange
        const tFilter2 = CarFilter(
          brand: 'BMW',
          shape: 'Sedan',
          nameQuery: 'X5',
          sortBy: SortOption.brand,
          sortAscending: false,
        );

        // act & assert
        expect(tFilter, equals(tFilter2));
        expect(tFilter.hashCode, equals(tFilter2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // arrange
        const tFilter2 = CarFilter(
          brand: 'Audi', // different brand
          shape: 'Sedan',
          nameQuery: 'X5',
          sortBy: SortOption.brand,
          sortAscending: false,
        );

        // act & assert
        expect(tFilter, isNot(equals(tFilter2)));
      });
    });

    group('default values', () {
      test('should have correct default values', () {
        // arrange & act
        const filter = CarFilter();

        // assert
        expect(filter.brand, null);
        expect(filter.shape, null);
        expect(filter.nameQuery, '');
        expect(filter.sortBy, SortOption.name);
        expect(filter.sortAscending, true);
      });
    });
  });

  group('SortOption', () {
    test('should have correct display names', () {
      expect(SortOption.name.displayName, 'Nom');
      expect(SortOption.brand.displayName, 'Marque');
      expect(SortOption.shape.displayName, 'Forme');
      expect(SortOption.createdAt.displayName, 'Date de création');
      expect(SortOption.updatedAt.displayName, 'Date de modification');
    });

    test('should contain all expected values', () {
      expect(SortOption.values.length, 5);
      expect(SortOption.values, contains(SortOption.name));
      expect(SortOption.values, contains(SortOption.brand));
      expect(SortOption.values, contains(SortOption.shape));
      expect(SortOption.values, contains(SortOption.createdAt));
      expect(SortOption.values, contains(SortOption.updatedAt));
    });
  });
}