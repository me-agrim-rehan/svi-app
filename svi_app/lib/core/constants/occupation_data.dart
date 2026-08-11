import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:svi_app/core/network/api_constants.dart';

class JobSubcategory {
  final int id;
  final String name;

  JobSubcategory({
    required this.id,
    required this.name,
  });
}

class OccupationData {
  OccupationData._();

  static final Map<String, List<JobSubcategory>> _categories = {};

  static bool _isLoading = false;
  static bool _loaded = false;

  /// Load jobs from the backend.
  ///
  /// This must be awaited before reading [categories].
  static Future<void> load() async {
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

        final List<JobSubcategory> subcategories = [];

        final dynamic rawSubcategories =
            categoryData['subcategories'];

        if (rawSubcategories is List) {
          for (final subcategory in rawSubcategories) {
            if (subcategory is Map) {
              final dynamic rawId = subcategory['id'];

              final String name =
                  subcategory['name']?.toString().trim() ?? '';

              if (rawId == null || name.isEmpty) {
                continue;
              }

              final int? id = int.tryParse(rawId.toString());

              if (id == null) {
                continue;
              }

              subcategories.add(
                JobSubcategory(
                  id: id,
                  name: name,
                ),
              );
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

  /// Returns:
  /// Category -> list of subcategories/jobs
  ///
  /// Call [load] before using this.
  static Map<String, List<JobSubcategory>> get categories {
    return Map.unmodifiable(
      _categories.map(
        (key, value) => MapEntry(
          key,
          List<JobSubcategory>.unmodifiable(value),
        ),
      ),
    );
  }

  /// Returns only the category names.
  static List<String> get categoryTitles {
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
    final List<String> options = [];

    for (final subroles in _categories.values) {
      for (final subrole in subroles) {
        options.add(subrole.name);
      }
    }

    return List.unmodifiable(options);
  }

  /// Force reload jobs from the backend.
  static Future<void> refresh() async {
    _loaded = false;
    _categories.clear();

    await load();
  }
}