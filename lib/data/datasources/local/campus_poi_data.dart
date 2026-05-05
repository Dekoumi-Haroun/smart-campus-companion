import '../../../domain/entities/campus_poi.dart';

/// Hardcoded campus points of interest.
///
/// In production these would come from an API or local database.
/// Using coordinates centered around a sample campus area.
const List<CampusPoi> campusPois = [
  CampusPoi(
    name: 'University Library',
    description:
        'Main library with 3 floors, quiet study zones, '
        'and computer labs. Open 8 AM – 10 PM.',
    latitude: 36.7105,
    longitude: 3.1738,
    category: PoiCategory.library,
  ),
  CampusPoi(
    name: 'Student Cafeteria',
    description:
        'Central dining hall serving breakfast, lunch, and snacks. '
        'Halal and vegetarian options available.',
    latitude: 36.7112,
    longitude: 3.1745,
    category: PoiCategory.cafeteria,
  ),
  CampusPoi(
    name: 'Administration Building',
    description:
        'Registration office, academic advising, and student services. '
        'Ground floor reception open 9 AM – 4 PM.',
    latitude: 36.7098,
    longitude: 3.1730,
    category: PoiCategory.admin,
  ),
  CampusPoi(
    name: 'Parking Lot B',
    description:
        'Student parking area with 200 spots. '
        'Accessible from the east entrance.',
    latitude: 36.7090,
    longitude: 3.1755,
    category: PoiCategory.parking,
  ),
  CampusPoi(
    name: 'Computer Science Lab',
    description:
        'Advanced computing lab with GPU workstations, '
        'IoT devices, and robotics equipment.',
    latitude: 36.7108,
    longitude: 3.1722,
    category: PoiCategory.lab,
  ),
];
