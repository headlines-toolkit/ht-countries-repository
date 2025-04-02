//
// ignore_for_file: lines_longer_than_80_chars

import 'package:ht_countries_client/ht_countries_client.dart'; // Exports client, exceptions, and Country model
import 'package:ht_shared/ht_shared.dart'; // Exports PaginatedResponse

/// {@template ht_countries_repository}
/// A repository that manages country data interactions.
///
/// This class acts as an intermediary between the application's business logic
/// (e.g., BLoCs) and the underlying data source abstraction (`HtCountriesClient`).
/// It handles data fetching, creation, updates, and deletion, while also
/// managing pagination logic and error handling specific to the repository layer.
/// {@endtemplate}
class HtCountriesRepository {
  /// {@macro ht_countries_repository}
  ///
  /// Requires an instance of [HtCountriesClient] to interact with the data source.
  const HtCountriesRepository({
    required HtCountriesClient countriesClient,
  }) : _countriesClient = countriesClient;

  final HtCountriesClient _countriesClient;

  /// Fetches a paginated list of countries.
  ///
  /// [limit]: The maximum number of countries to return per page.
  /// [cursor]: The cursor indicating the starting point for the next page.
  ///   If null or omitted, fetches the first page. This corresponds to the
  ///   `id` of the last country fetched in the previous page.
  ///
  /// Returns a [Future] containing a [PaginatedResponse] with the list of
  /// [Country] objects for the requested page, the cursor for the next page,
  /// and a flag indicating if more pages are available.
  ///
  /// Throws a [CountryFetchFailure] if the underlying data fetch fails.
  Future<PaginatedResponse<Country>> fetchCountries({
    required int limit,
    String? cursor,
  }) async {
    try {
      final countries = await _countriesClient.fetchCountries(
        limit: limit,
        startAfterId: cursor,
      );

      final hasMore = countries.length == limit;
      final nextCursor =
          hasMore && countries.isNotEmpty ? countries.last.id : null;

      return PaginatedResponse(
        items: countries,
        cursor: nextCursor,
        hasMore: hasMore,
      );
    } on CountryFetchFailure {
      rethrow; // Re-throw specific client exceptions
    } catch (e, st) {
      // Catch any other unexpected errors and wrap them
      throw CountryFetchFailure(e, st);
    }
  }

  /// Fetches a single country by its unique ISO 3166-1 alpha-2 code.
  ///
  /// [isoCode]: The ISO code of the country to fetch.
  ///
  /// Returns the corresponding [Country] object.
  ///
  /// Throws a [CountryFetchFailure] if the fetch operation fails.
  /// Throws a [CountryNotFound] if no country with the given [isoCode] exists.
  Future<Country> fetchCountry(String isoCode) async {
    try {
      return await _countriesClient.fetchCountry(isoCode);
    } on CountryFetchFailure {
      rethrow;
    } on CountryNotFound {
      rethrow;
    } catch (e, st) {
      throw CountryFetchFailure(e, st); // Assume fetch failure for unknowns
    }
  }

  /// Creates a new country record.
  ///
  /// [country]: The [Country] object containing the data for the new record.
  ///
  /// Returns a [Future] that completes when the operation is successful.
  ///
  /// Throws a [CountryCreateFailure] if the creation operation fails.
  Future<void> createCountry(Country country) async {
    try {
      await _countriesClient.createCountry(country);
    } on CountryCreateFailure {
      rethrow;
    } catch (e, st) {
      throw CountryCreateFailure(e, st);
    }
  }

  /// Updates an existing country record.
  ///
  /// [country]: The [Country] object containing the updated data.
  ///
  /// Returns a [Future] that completes when the operation is successful.
  ///
  /// Throws a [CountryUpdateFailure] if the update operation fails.
  /// Throws a [CountryNotFound] if the country to update does not exist.
  Future<void> updateCountry(Country country) async {
    try {
      await _countriesClient.updateCountry(country);
    } on CountryUpdateFailure {
      rethrow;
    } on CountryNotFound {
      rethrow;
    } catch (e, st) {
      throw CountryUpdateFailure(e, st);
    }
  }

  /// Deletes a country record by its unique ISO 3166-1 alpha-2 code.
  ///
  /// [isoCode]: The ISO code of the country to delete.
  ///
  /// Returns a [Future] that completes when the operation is successful.
  ///
  /// Throws a [CountryDeleteFailure] if the deletion operation fails.
  /// Throws a [CountryNotFound] if the country to delete does not exist.
  Future<void> deleteCountry(String isoCode) async {
    try {
      await _countriesClient.deleteCountry(isoCode);
    } on CountryDeleteFailure {
      rethrow;
    } on CountryNotFound {
      rethrow;
    } catch (e, st) {
      throw CountryDeleteFailure(e, st);
    }
  }
}
