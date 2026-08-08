import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:svi_app/core/network/api_constants.dart';

class OccupationData {
  OccupationData._();

  // Example:
  // {
  //   "Construction": ["Mason", "Bricklayer"],
  //   "Electrical": ["Electrician", "Wireman"]
  // }
  static final Map<String, List<String>> _categories = {};

  static bool _isLoading = false;
  static bool _loaded = false;

  /// Returns:
  /// Category -> list of subcategories/jobs
  static Map<String, List<String>> get categories {
    _loadFromBackend();

    return Map.unmodifiable(
      _categories.map(
        (key, value) => MapEntry(
          key,
          List<String>.unmodifiable(value),
        ),
      ),
    );
  }

  /// Returns only the category names.
  static List<String> get categoryTitles {
    _loadFromBackend();

    return List.unmodifiable(_categories.keys);
  }

  /// Returns all available job/subrole names.
  ///
  /// Example:
  /// Mason
  /// Bricklayer
  /// Electrician
  /// Wireman
  static List<String> get allOptions {
    _loadFromBackend();

    final List<String> options = [];

    for (final subroles in _categories.values) {
      options.addAll(subroles);
    }

    return List.unmodifiable(options);
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

      _categories.clear();

      for (final categoryData in data) {
        final String category =
            categoryData['category']?.toString().trim() ?? '';

        if (category.isEmpty) {
          continue;
        }

        final List<String> subcategories = [];

        final dynamic rawSubcategories =
            categoryData['subcategories'];

        if (rawSubcategories is List) {
          for (final subcategory in rawSubcategories) {
            if (subcategory is Map) {
              final String name =
                  subcategory['name']?.toString().trim() ?? '';

              if (name.isNotEmpty) {
                subcategories.add(name);
              }
            }
          }
        }

        _categories[category] = subcategories;
      }

      _loaded = true;

      print(
        'OccupationData: loaded '
        '${_categories.length} job categories',
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
    _categories.clear();

    await _loadFromBackend();
  }
}