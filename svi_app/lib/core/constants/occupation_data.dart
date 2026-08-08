// lib/core/constants/occupation_data.dart

// ============================================================================
// 🚧 TEMPORARY HARDCODED DATA — DB INTEGRATION POINT 🚧
// ------------------------------------------------------------------------
// DB TEAM: this is the single source of truth for occupation categories +
// subroles until a backend endpoint exists. Two things read from this file:
//   1. occupation_autocomplete_field.dart — shows CATEGORY NAMES ONLY
//      (e.g. "Mason") when the user types their occupation.
//   2. preferred_jobs_page.dart — shows CATEGORY + ALL ITS SUBROLES
//      (e.g. "Mason" header, with "Brickwork / Concrete / Plastering" chips)
//
// Suggested endpoint: GET /api/occupations returning:
//   [ { "category": "Mason", "subroles": ["Brickwork","Concrete","Plastering"] }, ... ]
//
// Once that exists: delete the static `categories` map, add a
// fetchOccupations() call to RegistrationService, fetch once in
// RegisterScreen.initState(), and pass the result down instead of
// OccupationData.categories. Then delete this file.
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

  /// Just category titles — used by the occupation autocomplete field.
  static List<String> get categoryTitles => categories.keys.toList();
}