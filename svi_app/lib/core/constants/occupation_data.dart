// lib/core/constants/occupation_data.dart

// 👉 DB / BACKEND TEAM: replace this static map with data from the database.
//    Suggested endpoint: GET /api/occupations returning something like:
//    [
//      { "category": "Mason", "subroles": ["Brickwork", "Concrete", "Plastering"] },
//      ...
//    ]
//
// Once that endpoint exists:
//   1. Delete the static `categories` map below.
//   2. Add a `fetchOccupations()` method to RegistrationService that GETs
//      the endpoint and returns the same shape (Map<String, List<String>>).
//   3. Fetch it once (e.g. in RegisterScreen.initState) and pass the result
//      down to OccupationAutocompleteField instead of OccupationData.allOptions.
//   4. Delete this whole file when done.
// ============================================================================
class OccupationData {
  static const Map<String, List<String>> categories = {
    'Mason': ['Brickwork', 'Concrete', 'Plastering'],
    'Carpenter': ['Shuttering', 'Furniture'],
    'Steel Fixer': ['Bar Bender', 'Steel Work'],
    'Tile & Stone Fitter': ['Tiles', 'Marble', 'Granite'],
    'Painter & Finishing Worker': [
      'Painter',
      'Polisher',
      'POP/Gypsum',
      'Waterproofing',
    ],
    'Welder & Fabricator': [
      'Arc',
      'TIG',
      'MIG',
      'Gas Welding',
      'Structural Fabrication',
    ],
    'Electrician': [
      'Electrician',
      'Cable Puller',
      'Instrumentation',
      'AC/HVAC Technician',
    ],
    'Plumber': [
      'Pipe Fitter',
      'Sanitary Fitter',
      'Sprinkler',
      'Fire Fighting',
    ],
    'Heavy Equipment Operator': ['JCB', 'Excavator', 'Crane', 'Forklift'],
    'Machine Operator': [
      'Industrial Machines',
      'Boiler Operator',
      'Mechanical Fitter',
      'Turner',
    ],
    'Housekeeping & Facility Staff': [
      'Housekeeping',
      'Sweeper',
      'Gardener',
      'Pantry',
      'Window Cleaning',
    ],
    'Pest Control Technician': [
      'Pest Control',
      'Fumigation',
      'Termite Control',
    ],
    'Security Staff': [
      'Security Guard',
      'Armed Guard',
      'Fire Watchman',
      'Traffic Marshal',
    ],
    'General Labour': [
      'Helper',
      'Loader',
      'Site Cleaner',
      'Head Load Worker',
      'Water Boy',
    ],
    'Site Supervisor & Safety': [
      'Site Supervisor',
      'Foreman',
      'Safety Officer',
      'Store Keeper',
      'QC Inspector',
      'Surveyor',
    ],
  };

  /// Flattened "Category (Subrole)" strings used by the autocomplete dropdown.
  /// e.g. "Mason (Brickwork)", "Electrician (Cable Puller)"
  static List<String> get allOptions {
    final List<String> options = [];
    categories.forEach((category, subroles) {
      for (final sub in subroles) {
        options.add('$category ($sub)');
      }
    });
    return options;
  }
}