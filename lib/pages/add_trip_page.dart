import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip_details.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import 'map_location_picker.dart';

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  TransportMode _selectedMode = TransportMode.walking;
  bool _isElectric = false;
  String _startLocation = '';
  String _endLocation = '';
  int _duration = 0;
  double _distance = 0;
  bool _isCalculating = false;
  int _hours = 0;
  int _minutes = 0;

  List<Map<String, String>> _startSuggestions = [];
  List<Map<String, String>> _endSuggestions = [];

  final LocationService _locationService = LocationService();
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  Map<TransportMode, Map<String, double>> emissionFactors = {
    TransportMode.car: {'co2': 192.0, 'nox': 0.30, 'so2': 0.002},  // g/km
    TransportMode.bus: {'co2': 82.0, 'nox': 0.89, 'so2': 0.001},   // g/km
    TransportMode.train: {'co2': 41.0, 'nox': 0.02, 'so2': 0.02},  // g/km
    TransportMode.walking: {'co2': 0.0, 'nox': 0.0, 'so2': 0.0},
    TransportMode.cycling: {'co2': 0.0, 'nox': 0.0, 'so2': 0.0},
  };

  Map<String, double> _calculateEmissions() {
    final factors = emissionFactors[_selectedMode] ?? {'co2': 0, 'nox': 0, 'so2': 0};
    
    // If electric vehicle, calculate saved emissions compared to regular vehicle
    if (_isElectric) {
      final regularFactors = emissionFactors[_selectedMode]!;
      return {
        'co2': regularFactors['co2']! * _distance / 1000, // Convert g to kg
        'nox': regularFactors['nox']! * _distance,
        'so2': regularFactors['so2']! * _distance,
      };
    }
    
    // For non-motorized modes, calculate savings compared to car emissions
    if (_selectedMode == TransportMode.walking || _selectedMode == TransportMode.cycling) {
      final carFactors = emissionFactors[TransportMode.car]!;
      return {
        'co2': carFactors['co2']! * _distance / 1000, // Convert g to kg
        'nox': carFactors['nox']! * _distance,
        'so2': carFactors['so2']! * _distance,
      };
    }

    // For regular vehicles, return 0 since no emissions are saved
    return {
      'co2': 0,
      'nox': 0,
      'so2': 0,
    };
  }

  void _submitTrip() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final emissions = _calculateEmissions();
      final trip = TripDetails(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        distance: _distance,
        co2Saved: emissions['co2']!,
        startLocation: _startLocation,
        endLocation: _endLocation,
        duration: _duration,
        transportMode: _selectedMode,
        calories: _selectedMode == TransportMode.walking ? _duration * 4 : 
                 _selectedMode == TransportMode.cycling ? _duration * 7 : 0,
        averageSpeed: _distance / (_duration / 60),
        emissions: {
          'NOx': emissions['nox']!,
          'SO₂': emissions['so2']!,
        },
      );

      final dataService = Provider.of<DataService>(context, listen: false);
      dataService.addTrip(trip);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip saved! CO₂ saved: ${emissions['co2']?.toStringAsFixed(2)} kg'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Replace current page with MyTrips page
      Navigator.pushReplacementNamed(context, '/my-trips');
    }
  }

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Trip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF00C853),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00C853),  // Bright green
              Color(0xFF1B5E20),  // Dark green
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTransportSection(),
              const SizedBox(height: 20),
              _buildLocationSection(),
              const SizedBox(height: 20),
              _buildDetailsSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transport Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TransportMode.values.map((mode) {
                bool isSelected = mode == _selectedMode;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMode = mode),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTransportIcon(mode),
                          color: isSelected ? const Color(0xFF00C853) : Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTransportName(mode),
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF00C853) : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_showElectricOption())
            SwitchListTile(
              title: const Text(
                'Electric Vehicle',
                style: TextStyle(color: Colors.white),
              ),
              value: _isElectric,
              onChanged: (value) => setState(() => _isElectric = value),
              activeColor: const Color(0xFF69F0AE),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLocationField(
            label: 'Start Location',
            icon: Icons.location_on_outlined,
            suggestions: _startSuggestions,
            onChanged: (value) async {
              final suggestions = await _locationService.searchPlaces(value);
              setState(() => _startSuggestions = suggestions);
            },
            onSelected: (selected) {
              setState(() {
                _startLocation = selected['description']!;
                _startLocationController.text = _startLocation;
                _startSuggestions = [];
                _calculateDistance();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildLocationField(
            label: 'End Location',
            icon: Icons.location_on,
            suggestions: _endSuggestions,
            onChanged: (value) async {
              final suggestions = await _locationService.searchPlaces(value);
              setState(() => _endSuggestions = suggestions);
            },
            onSelected: (selected) {
              setState(() {
                _endLocation = selected['description']!;
                _endLocationController.text = _endLocation;
                _endSuggestions = [];
                _calculateDistance();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required IconData icon,
    required List<Map<String, String>> suggestions,
    required Function(String) onChanged,
    required Function(Map<String, String>) onSelected,
  }) {
    final controller = label == 'Start Location' 
        ? _startLocationController 
        : _endLocationController;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: Icon(icon, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                onChanged: onChanged,
              ),
            ),
            if (label == 'Start Location')
              IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white),
                onPressed: () async {
                  try {
                    final currentLocation = await _locationService.getCurrentLocation(context);
                    setState(() {
                      _startLocation = currentLocation['description']!;
                      _startLocationController.text = _startLocation;
                      _startSuggestions = [];
                      _calculateDistance();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Current location detected'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to detect location'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            if (label == 'End Location')
              IconButton(
                icon: const Icon(Icons.map, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(builder: (context) => const MapLocationPicker()),
                  );
                  if (result != null) {
                    setState(() {
                      _endLocation = result['description'];
                      _endLocationController.text = _endLocation;
                      _endSuggestions = [];
                      _calculateDistance();
                    });
                  }
                },
              ),
          ],
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]['description']!),
                  subtitle: Text(
                    'Tap to select',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    controller.text = suggestions[index]['description']!;
                    onSelected(suggestions[index]);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _calculateDistance() async {
    if (_startLocation.isNotEmpty && _endLocation.isNotEmpty) {
      setState(() => _isCalculating = true);
      try {
        final distance = await _locationService.calculateDistance(
          _startLocation,
          _endLocation,
        );
        setState(() {
          _distance = distance;
          _distanceController.text = distance.toStringAsFixed(2);
          _isCalculating = false;
        });
      } catch (e) {
        setState(() => _isCalculating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to calculate distance')),
        );
      }
    }
  }

  Widget _buildDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _distanceController,
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Distance (km)',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.straighten, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              suffixIcon: _isCalculating 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _hours,
                            dropdownColor: const Color(0xFF1B5E20),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Hours',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                            ),
                            items: List.generate(24, (index) => index)
                                .map((hour) => DropdownMenuItem(
                                      value: hour,
                                      child: Text('$hour'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _hours = value ?? 0;
                                _duration = _hours * 60 + _minutes;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _minutes,
                            dropdownColor: const Color(0xFF1B5E20),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Minutes',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                            ),
                            items: List.generate(60, (index) => index)
                                .map((minute) => DropdownMenuItem(
                                      value: minute,
                                      child: Text('$minute'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _minutes = value ?? 0;
                                _duration = _hours * 60 + _minutes;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitTrip,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF69F0AE),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: const Color(0xFF69F0AE).withOpacity(0.5),
      ),
      child: const Text(
        'Save Trip',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return Icons.directions_walk;
      case TransportMode.cycling:
        return Icons.directions_bike;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.car:
        return Icons.directions_car;
    }
  }

  String _getTransportName(TransportMode mode) {
    return mode.toString().split('.').last[0].toUpperCase() +
           mode.toString().split('.').last.substring(1);
  }

  bool _showElectricOption() {
    return _selectedMode == TransportMode.car || 
           _selectedMode == TransportMode.bus || 
           _selectedMode == TransportMode.train;
  }
}
