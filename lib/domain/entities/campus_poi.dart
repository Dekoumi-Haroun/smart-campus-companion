import 'package:flutter/material.dart';

/// A point of interest on the campus map.
class CampusPoi {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final PoiCategory category;

  const CampusPoi({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
  });
}

/// Categories for campus points of interest.
enum PoiCategory {
  library(Icons.local_library_rounded, Color(0xFF5C6BC0)),
  cafeteria(Icons.restaurant_rounded, Color(0xFFFF7043)),
  admin(Icons.business_rounded, Color(0xFF26A69A)),
  parking(Icons.local_parking_rounded, Color(0xFF66BB6A)),
  lab(Icons.science_rounded, Color(0xFF42A5F5));

  final IconData icon;
  final Color color;

  const PoiCategory(this.icon, this.color);
}
