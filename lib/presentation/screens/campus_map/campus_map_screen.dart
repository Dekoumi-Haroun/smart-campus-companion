import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/permission_denied_widget.dart';
import '../../../data/datasources/local/campus_poi_data.dart';
import '../../../domain/entities/campus_poi.dart';

/// Campus map screen showing user location and hardcoded POIs.
///
/// Uses [flutter_map] with OpenStreetMap tiles (no API key needed).
/// Falls back to [PermissionDeniedWidget] when location is denied.
class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  final LocationService _locationService = const LocationService();
  final MapController _mapController = MapController();

  Position? _userPosition;
  bool _loading = true;
  bool _permissionDenied = false;
  bool _permanentlyDenied = false;
  bool _serviceDisabled = false;

  // Default campus center — fallback if location unavailable.
  static const _campusCenter = LatLng(36.7105, 3.1738);

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _loading = true;
      _permissionDenied = false;
      _serviceDisabled = false;
    });

    final result = await _locationService.getCurrentPosition();

    if (!mounted) return;

    switch (result) {
      case LocationSuccess(:final position):
        setState(() {
          _userPosition = position;
          _loading = false;
        });
      case LocationDenied(:final isPermanentlyDenied):
        setState(() {
          _permissionDenied = true;
          _permanentlyDenied = isPermanentlyDenied;
          _loading = false;
        });
      case LocationServiceDisabled():
        setState(() {
          _serviceDisabled = true;
          _loading = false;
        });
    }
  }

  void _centerOnUser() {
    if (_userPosition != null) {
      _mapController.move(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        16,
      );
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _showPoiDetail(CampusPoi poi) {
    final distance = _userPosition != null
        ? _locationService.getDistanceBetween(
            _userPosition!.latitude,
            _userPosition!.longitude,
            poi.latitude,
            poi.longitude,
          )
        : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: poi.category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      poi.category.icon,
                      color: poi.category.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poi.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (distance != null)
                          Text(
                            _formatDistance(distance),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                poi.description,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.campusMapTitle)),
      body: _buildBody(),
      floatingActionButton:
          (!_permissionDenied &&
              !_serviceDisabled &&
              !_loading &&
              _userPosition != null)
          ? FloatingActionButton.small(
              onPressed: _centerOnUser,
              tooltip: AppStrings.centerOnMe,
              child: const Icon(Icons.my_location_rounded),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionDenied) {
      return PermissionDeniedWidget(
        icon: Icons.location_off_rounded,
        message: AppStrings.locationPermissionReason,
        isPermanentlyDenied: _permanentlyDenied,
        onRetry: _fetchLocation,
      );
    }

    if (_serviceDisabled) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_disabled_rounded,
                size: 56,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Location services are disabled',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please enable GPS to see your position on the campus map.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchLocation,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    final center = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : _campusCenter;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: center, initialZoom: 15.5),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flutter_project',
        ),
        // ── User position ──
        if (_userPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  _userPosition!.latitude,
                  _userPosition!.longitude,
                ),
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        // ── Campus POI markers ──
        MarkerLayer(
          markers: campusPois.map((poi) {
            return Marker(
              point: LatLng(poi.latitude, poi.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showPoiDetail(poi),
                child: Container(
                  decoration: BoxDecoration(
                    color: poi.category.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: poi.category.color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(poi.category.icon, color: Colors.white, size: 20),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
