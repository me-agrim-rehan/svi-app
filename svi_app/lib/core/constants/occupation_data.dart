import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:svi_app/core/network/api_constants.dart';

class OccupationData {
  OccupationData._();

  static final List<String> _allOptions = [];

  static bool _isLoading = false;
  static bool _loaded = false;

  /// Returns only job categories.
  static List<String> get allOptions {
    _loadFromBackend();
    return List.unmodifiable(_allOptions);
  }

  static Future<void> _loadFromBackend() async {
    if (_isLoading || _loaded) {
      return;
    }

    _isLoading = true;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/jobs'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch jobs: ${response.statusCode}',
        );
      }

      final List<dynamic> data = jsonDecode(response.body);

      final List<String> categories = [];

      for (final categoryData in data) {
        final String category =
            categoryData['category']?.toString().trim() ?? '';

        if (category.isEmpty) {
          continue;
        }

        categories.add(category);
      }

      _allOptions
        ..clear()
        ..addAll(categories);

      _loaded = true;

      print(
        'OccupationData: loaded ${_allOptions.length} job categories',
      );
    } catch (e) {
      print(
        'OccupationData: failed to load jobs: $e',
      );
    } finally {
      _isLoading = false;
    }
  }

  static Future<void> refresh() async {
    _loaded = false;
    _allOptions.clear();

    await _loadFromBackend();
  }
}