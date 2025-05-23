import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({super.key});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  String _address = '';
  final LocationService _locationService = LocationService();
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    // Get device screen size
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    
    // Calculate actual map height
    final mapHeight = size.height - padding.top - padding.bottom - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: SizedBox(
        width: size.width,
        height: mapHeight,
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: LatLng(17.3850, 78.4867),
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) async {
                setState(() {
                  _mapController = controller;
                });
                // Get current location and move camera there
                try {
                  final location = await _locationService.getCurrentLocation(context);
                  final lat = double.tryParse(location['latitude'] ?? '') ?? 17.3850;
                  final lng = double.tryParse(location['longitude'] ?? '') ?? 78.4867;
                  
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(lat, lng),
                      15,
                    ),
                  );
                  setState(() => _isMapReady = true);
                } catch (e) {
                  setState(() => _isMapReady = true);
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              onTap: _handleTap,
              markers: _selectedLocation != null ? {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedLocation!,
                  draggable: true,
                  onDragEnd: (newPosition) => _handleTap(newPosition),
                ),
              } : {},
            ),
            if (!_isMapReady)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_address.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  color: const Color(0xFF1B5E20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _address,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(
                            context,
                            {
                              'description': _address,
                              'latitude': _selectedLocation?.latitude,
                              'longitude': _selectedLocation?.longitude,
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF69F0AE),
                          ),
                          child: const Text('Select This Location'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(LatLng position) async {
    setState(() => _selectedLocation = position);
    try {
      final locationDetails = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      setState(() => _address = locationDetails['description']!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get address')),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
