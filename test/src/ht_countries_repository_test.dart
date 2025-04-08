//
// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values, lines_longer_than_80_chars

import 'package:ht_countries_client/ht_countries_client.dart';
import 'package:ht_countries_repository/ht_countries_repository.dart';
import 'package:ht_shared/ht_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Define a mock class for HtCountriesClient using mocktail
class MockHtCountriesClient extends Mock implements HtCountriesClient {}

// Define a fallback value for the Country type, required by mocktail
// when verifying calls with custom objects.
class FakeCountry extends Fake implements Country {}

void main() {
  // Register the fallback value before any tests run
  setUpAll(() {
    registerFallbackValue(FakeCountry());
  });

  group('HtCountriesRepository', () {
    late HtCountriesRepository htCountriesRepository;
    late MockHtCountriesClient mockHtCountriesClient;

    // Sample Country objects for testing
    final country1 = Country(
      id: 'id1',
      isoCode: 'US',
      name: 'United States',
      flagUrl: 'url_us',
    );
    final country2 = Country(
      id: 'id2',
      isoCode: 'CA',
      name: 'Canada',
      flagUrl: 'url_ca',
    );
    final country3 = Country(
      id: 'id3',
      isoCode: 'MX',
      name: 'Mexico',
      flagUrl: 'url_mx',
    );

    setUp(() {
      mockHtCountriesClient = MockHtCountriesClient();
      htCountriesRepository = HtCountriesRepository(
        countriesClient: mockHtCountriesClient,
      );
    });

    test('can be instantiated', () {
      expect(htCountriesRepository, isNotNull);
      expect(htCountriesRepository, isA<HtCountriesRepository>());
    });

    group('fetchCountries', () {
      const limit = 2;

      test(
        'returns PaginatedResponse with hasMore=true on first page success',
        () async {
          // Arrange
          final expectedCountries = [country1, country2];
          when(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: null,
            ),
          ).thenAnswer((_) async => expectedCountries);

          // Act
          final result = await htCountriesRepository.fetchCountries(
            limit: limit,
          );

          // Assert
          expect(result, isA<PaginatedResponse<Country>>());
          expect(result.items, equals(expectedCountries));
          expect(result.hasMore, isTrue);
          expect(result.cursor, equals(country2.id)); // Last item's ID
          verify(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: null,
            ),
          ).called(1);
        },
      );

      test(
        'returns PaginatedResponse with hasMore=false on subsequent page success',
        () async {
          // Arrange
          final expectedCountries = [country3]; // Only one item left
          const cursor = 'id2'; // Cursor from previous page
          when(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: cursor,
            ),
          ).thenAnswer((_) async => expectedCountries);

          // Act
          final result = await htCountriesRepository.fetchCountries(
            limit: limit,
            cursor: cursor,
          );

          // Assert
          expect(result.items, equals(expectedCountries));
          expect(result.hasMore, isFalse); // Less items than limit
          expect(result.cursor, isNull); // No next cursor
          verify(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: cursor,
            ),
          ).called(1);
        },
      );

      test(
        'returns PaginatedResponse with empty list when client returns empty',
        () async {
          // Arrange
          when(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: null,
            ),
          ).thenAnswer((_) async => []);

          // Act
          final result = await htCountriesRepository.fetchCountries(
            limit: limit,
          );

          // Assert
          expect(result.items, isEmpty);
          expect(result.hasMore, isFalse);
          expect(result.cursor, isNull);
          verify(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: null,
            ),
          ).called(1);
        },
      );

      test(
        'throws CountryFetchFailure when client throws CountryFetchFailure',
        () async {
          // Arrange
          final exception = CountryFetchFailure('API error');
          when(
            () => mockHtCountriesClient.fetchCountries(
              limit: any(named: 'limit'),
              startAfterId: any(named: 'startAfterId'),
            ),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.fetchCountries(limit: limit),
            throwsA(isA<CountryFetchFailure>()),
          );
          verify(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: null,
            ),
          ).called(1);
        },
      );

      test(
        'throws CountryFetchFailure when client throws unexpected error',
        () async {
          // Arrange
          final exception = Exception('Unexpected network issue');
          when(
            () => mockHtCountriesClient.fetchCountries(
              limit: any(named: 'limit'),
              startAfterId: any(named: 'startAfterId'),
            ),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.fetchCountries(limit: limit),
            throwsA(isA<CountryFetchFailure>()),
          );
          verify(
            () => mockHtCountriesClient.fetchCountries(
              limit: limit,
              startAfterId: null,
            ),
          ).called(1);
        },
      );
    });

    group('fetchCountry', () {
      const isoCode = 'US';

      test('returns Country on success', () async {
        // Arrange
        when(
          () => mockHtCountriesClient.fetchCountry(isoCode),
        ).thenAnswer((_) async => country1);

        // Act
        final result = await htCountriesRepository.fetchCountry(isoCode);

        // Assert
        expect(result, equals(country1));
        verify(() => mockHtCountriesClient.fetchCountry(isoCode)).called(1);
      });

      test(
        'throws CountryNotFound when client throws CountryNotFound',
        () async {
          // Arrange
          final exception = CountryNotFound('Not found');
          when(
            () => mockHtCountriesClient.fetchCountry(isoCode),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.fetchCountry(isoCode),
            throwsA(isA<CountryNotFound>()),
          );
          verify(() => mockHtCountriesClient.fetchCountry(isoCode)).called(1);
        },
      );

      test(
        'throws CountryFetchFailure when client throws CountryFetchFailure',
        () async {
          // Arrange
          final exception = CountryFetchFailure('API error');
          when(
            () => mockHtCountriesClient.fetchCountry(isoCode),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.fetchCountry(isoCode),
            throwsA(isA<CountryFetchFailure>()),
          );
          verify(() => mockHtCountriesClient.fetchCountry(isoCode)).called(1);
        },
      );

      test(
        'throws CountryFetchFailure when client throws unexpected error',
        () async {
          // Arrange
          final exception = Exception('Unexpected');
          when(
            () => mockHtCountriesClient.fetchCountry(isoCode),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.fetchCountry(isoCode),
            throwsA(isA<CountryFetchFailure>()),
          );
          verify(() => mockHtCountriesClient.fetchCountry(isoCode)).called(1);
        },
      );
    });

    group('createCountry', () {
      test('completes successfully when client completes', () async {
        // Arrange
        when(
          () => mockHtCountriesClient.createCountry(any()),
        ).thenAnswer((_) async {}); // Mock void return

        // Act & Assert
        await expectLater(
          htCountriesRepository.createCountry(country1),
          completes,
        );
        verify(() => mockHtCountriesClient.createCountry(country1)).called(1);
      });

      test(
        'throws CountryCreateFailure when client throws CountryCreateFailure',
        () async {
          // Arrange
          final exception = CountryCreateFailure('Creation failed');
          when(
            () => mockHtCountriesClient.createCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.createCountry(country1),
            throwsA(isA<CountryCreateFailure>()),
          );
          verify(() => mockHtCountriesClient.createCountry(country1)).called(1);
        },
      );

      test(
        'throws CountryCreateFailure when client throws unexpected error',
        () async {
          // Arrange
          final exception = Exception('Unexpected');
          when(
            () => mockHtCountriesClient.createCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.createCountry(country1),
            throwsA(isA<CountryCreateFailure>()),
          );
          verify(() => mockHtCountriesClient.createCountry(country1)).called(1);
        },
      );
    });

    group('updateCountry', () {
      test('completes successfully when client completes', () async {
        // Arrange
        when(
          () => mockHtCountriesClient.updateCountry(any()),
        ).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          htCountriesRepository.updateCountry(country1),
          completes,
        );
        verify(() => mockHtCountriesClient.updateCountry(country1)).called(1);
      });

      test(
        'throws CountryUpdateFailure when client throws CountryUpdateFailure',
        () async {
          // Arrange
          final exception = CountryUpdateFailure('Update failed');
          when(
            () => mockHtCountriesClient.updateCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.updateCountry(country1),
            throwsA(isA<CountryUpdateFailure>()),
          );
          verify(() => mockHtCountriesClient.updateCountry(country1)).called(1);
        },
      );

      test(
        'throws CountryNotFound when client throws CountryNotFound',
        () async {
          // Arrange
          final exception = CountryNotFound('Not found');
          when(
            () => mockHtCountriesClient.updateCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.updateCountry(country1),
            throwsA(isA<CountryNotFound>()),
          );
          verify(() => mockHtCountriesClient.updateCountry(country1)).called(1);
        },
      );

      test(
        'throws CountryUpdateFailure when client throws unexpected error',
        () async {
          // Arrange
          final exception = Exception('Unexpected');
          when(
            () => mockHtCountriesClient.updateCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.updateCountry(country1),
            throwsA(isA<CountryUpdateFailure>()),
          );
          verify(() => mockHtCountriesClient.updateCountry(country1)).called(1);
        },
      );
    });

    group('deleteCountry', () {
      const isoCode = 'US';

      test('completes successfully when client completes', () async {
        // Arrange
        when(
          () => mockHtCountriesClient.deleteCountry(any()),
        ).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          htCountriesRepository.deleteCountry(isoCode),
          completes,
        );
        verify(() => mockHtCountriesClient.deleteCountry(isoCode)).called(1);
      });

      test(
        'throws CountryDeleteFailure when client throws CountryDeleteFailure',
        () async {
          // Arrange
          final exception = CountryDeleteFailure('Delete failed');
          when(
            () => mockHtCountriesClient.deleteCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.deleteCountry(isoCode),
            throwsA(isA<CountryDeleteFailure>()),
          );
          verify(() => mockHtCountriesClient.deleteCountry(isoCode)).called(1);
        },
      );

      test(
        'throws CountryNotFound when client throws CountryNotFound',
        () async {
          // Arrange
          final exception = CountryNotFound('Not found');
          when(
            () => mockHtCountriesClient.deleteCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.deleteCountry(isoCode),
            throwsA(isA<CountryNotFound>()),
          );
          verify(() => mockHtCountriesClient.deleteCountry(isoCode)).called(1);
        },
      );

      test(
        'throws CountryDeleteFailure when client throws unexpected error',
        () async {
          // Arrange
          final exception = Exception('Unexpected');
          when(
            () => mockHtCountriesClient.deleteCountry(any()),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => htCountriesRepository.deleteCountry(isoCode),
            throwsA(isA<CountryDeleteFailure>()),
          );
          verify(() => mockHtCountriesClient.deleteCountry(isoCode)).called(1);
        },
      );
    });
  });
}
