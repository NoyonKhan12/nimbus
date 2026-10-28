import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme/app_theme.dart';
import '../dto/location_dto.dart';
import '../network/backend_api.dart';
import '../services/api_service.dart';

/// Full-screen map location picker (OpenStreetMap — no API key required).
///
/// The pin sits at the centre of the map: drag the map to move the pin,
/// or tap anywhere to re-centre on that point. The address is auto-filled
/// via Nominatim reverse geocoding (best-effort, editable by hand).
class LocationEntrySheet extends StatefulWidget {
  final String title;
  final LocationDto? initial;

  const LocationEntrySheet({super.key, required this.title, this.initial});

  /// Returns the picked location, or null if dismissed.
  static Future<LocationDto?> show(BuildContext context, String title,
      {LocationDto? initial}) {
    return showModalBottomSheet<LocationDto>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LocationEntrySheet(title: title, initial: initial),
    );
  }

  @override
  State<LocationEntrySheet> createState() => _LocationEntrySheetState();
}

class _LocationEntrySheetState extends State<LocationEntrySheet> {
  static const LatLng _dhakaCenter = LatLng(23.8103, 90.4125);

  final MapController _mapController = MapController();
  final TextEditingController _address = TextEditingController();
  late LatLng _selected;
  bool _locating = false;
  bool _geocoding = false;
  Timer? _geocodeDebounce;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial != null
        ? LatLng(widget.initial!.latitude, widget.initial!.longitude)
        : _dhakaCenter;
    _address.text = widget.initial?.address ?? '';
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _address.dispose();
    super.dispose();
  }

  LatLng get _mapCenter {
    try {
      return _mapController.camera.center;
    } catch (_) {
      return _selected;
    }
  }

  void _onMapMoved(MapCamera position, bool hasGesture) {
    if (!hasGesture) return;
    _selected = _mapCenter;
    setState(() {});
    _scheduleGeocode();
  }

  void _onTap(TapPosition _, LatLng latlng) {
    _mapController.move(latlng, _mapController.camera.zoom);
    _selected = latlng;
    setState(() {});
    _scheduleGeocode();
  }

  void _scheduleGeocode() {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 800), _reverseGeocode);
  }

  /// Best-effort address lookup. Fails silently — the field stays editable.
  Future<void> _reverseGeocode() async {
    if (_geocoding) return;
    setState(() => _geocoding = true);
    try {
      final dio = ApiService().dio;
      final resp = await dio.getUri(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${_selected.latitude}&lon=${_selected.longitude}'
        '&format=json&zoom=18&addressdetails=1',
      ), options: Options(headers: {'User-Agent': 'nimbus-app-demo'}));
      final display = resp.data is Map
          ? (resp.data as Map)['display_name']?.toString()
          : null;
      if (mounted && display != null && display.isNotEmpty) {
        setState(() => _address.text = display);
      }
    } catch (_) {
      // Offline / rate-limited: leave the manual label as-is.
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw ApiException(code: 'GPS', message: 'Location services are disabled.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw ApiException(code: 'GPS', message: 'Location permission denied.');
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      final latlng = LatLng(pos.latitude, pos.longitude);
      _mapController.move(latlng, 16);
      setState(() => _selected = latlng);
      _scheduleGeocode();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get your location.')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _submit() {
    Navigator.of(context).pop(LocationDto(
      latitude: _selected.latitude,
      longitude: _selected.longitude,
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: Column(
        children: [
          // Grab handle + title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Map with centre pin
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected,
                    initialZoom: 15,
                    onTap: _onTap,
                    onPositionChanged: _onMapMoved,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.nimbus.app',
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => {},
                        ),
                      ],
                    ),
                  ],
                ),
                // Fixed centre pin
                const IgnorePointer(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            size: 48, color: AppTheme.primary),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
                // "Use my location" FAB
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'locate_${widget.title}',
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    onPressed: _locating ? null : _useCurrentLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          // Address + coordinates + confirm
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _address,
                    decoration: InputDecoration(
                      hintText: 'Address label (optional)',
                      prefixIcon: const Icon(Icons.place_outlined),
                      suffixIcon: _geocoding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_selected.latitude.toStringAsFixed(5)}, '
                    '${_selected.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Confirm location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
