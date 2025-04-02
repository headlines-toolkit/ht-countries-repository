# ht_countries_repository

[![Coverage Status](coverage_badge.svg)](https://github.com/headlines-toolkit/ht-countries-firestore)
[![style: very_good_analysis](https://img.shields.io/badge/style-very_good_analysis-B22C8E.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial 1.0.0](https://img.shields.io/badge/License-PolyForm%20Free%20Trial%201.0.0-blue.svg)](LICENSE)

A repository layer for managing country data, acting as an intermediary between the application's business logic (e.g., BLoCs) and the underlying `ht_countries_client` data source abstraction.

## Usage

Import the package and instantiate the repository with a configured `HtCountriesClient` implementation.

```dart
import 'package:ht_countries_client/ht_countries_client.dart'; // Or your client implementation
import 'package:ht_countries_repository/ht_countries_repository.dart';
import 'package:ht_shared/ht_shared.dart'; // For PaginatedResponse

void main() async {
  // 1. Instantiate your HtCountriesClient implementation
  //    (e.g., HtInMemoryCountriesClient, HtApiCountriesClient)
  final countriesClient = YourHtCountriesClientImplementation(); // Replace with actual client

  // 2. Instantiate the repository
  final countriesRepository = HtCountriesRepository(countriesClient: countriesClient);

  // 3. Fetch countries (paginated)
  try {
    const limit = 10;
    PaginatedResponse<Country> firstPage = await countriesRepository.fetchCountries(limit: limit);
    print('First page countries: ${firstPage.items.length}');

    if (firstPage.hasMore && firstPage.cursor != null) {
      PaginatedResponse<Country> secondPage = await countriesRepository.fetchCountries(
        limit: limit,
        cursor: firstPage.cursor,
      );
      print('Second page countries: ${secondPage.items.length}');
    }

  } on CountryFetchFailure catch (e) {
    print('Error fetching countries: $e');
  }

  // 4. Fetch a single country
  try {
    const isoCode = 'US';
    Country country = await countriesRepository.fetchCountry(isoCode);
    print('Fetched country: ${country.name}');
  } on CountryNotFound catch (e) {
    print('Country not found: $e');
  } on CountryFetchFailure catch (e) {
    print('Error fetching country: $e');
  }

  // Other operations (create, update, delete) follow a similar pattern
  // using try-catch blocks for specific exceptions.
}

// Placeholder for your client implementation
class YourHtCountriesClientImplementation implements HtCountriesClient {
  // Implement all methods from HtCountriesClient...
  @override
  Future<void> createCountry(Country country) {
    // TODO: implement createCountry
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCountry(String isoCode) {
    // TODO: implement deleteCountry
    throw UnimplementedError();
  }

  @override
  Future<Country> fetchCountry(String isoCode) {
    // TODO: implement fetchCountry
    throw UnimplementedError();
  }

  @override
  Future<List<Country>> fetchCountries({required int limit, String? startAfterId}) {
    // TODO: implement fetchCountries
    throw UnimplementedError();
  }

  @override
  Future<void> updateCountry(Country country) {
    // TODO: implement updateCountry
    throw UnimplementedError();
  }
}
```

## Testing

This package uses `mocktail` for mocking dependencies in tests. To run tests and ensure minimum coverage:

```bash
very_good test --min-coverage 90
```

## License

This package is licensed under the **PolyForm Free Trial License 1.0.0**. Please review the [LICENSE](LICENSE) file for full details.
