import 'package:flutter/material.dart';
import '../models/trip_details.dart';
import '../services/trip_tracking_service.dart';
import 'trip_detail_view.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  final TripTrackingService _trackingService = TripTrackingService();
  late List<TripDetails> _trips;
  double _currentDistance = 0;
  int _currentDuration = 0;

  @override
  void initState() {
    super.initState();
    _setupTracking();
    _trips = _getMockTrips(); // Initialize trips with mock data
  }

  void _setupTracking() {
    _trackingService.distanceStream.listen((distance) {
      setState(() => _currentDistance = distance);
    });
    _trackingService.durationStream.listen((duration) {
      setState(() => _currentDuration = duration);
    });
  }

  Widget _buildActiveTrip() {
    if (!_trackingService.isTracking) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Trip',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Distance', '${(_currentDistance / 1000).toStringAsFixed(2)} km'),
                _buildStatItem('Duration', '${(_currentDuration ~/ 60).toString()} mins'),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _stopTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Stop Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _startTrip() async {
    await _trackingService.startTrip();
    setState(() {});
  }

  Future<void> _stopTrip() async {
    final tripDetails = await _trackingService.stopTrip();
    setState(() {
      _trips.insert(0, tripDetails);
    });
  }

  List<TripDetails> _getMockTrips() {
    return [
      TripDetails(
        id: '1',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        distance: 3.8,
        co2Saved: 0.76,
        startLocation: 'Home, Jubilee Hills',
        endLocation: 'Hitech City Metro Station',
        duration: 22,
        transportMode: TransportMode.walking,
        calories: 187,
        averageSpeed: 4.5,
        emissions: {
          'NOx': 8.2,
          'SO₂': 5.1,
        },
      ),
      TripDetails(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        distance: 12.5,
        co2Saved: 2.85,
        startLocation: 'Office, Mindspace',
        endLocation: 'Gachibowli Stadium',
        duration: 45,
        transportMode: TransportMode.cycling,
        calories: 425,
        averageSpeed: 16.7,
        emissions: {
          'NOx': 15.3,
          'SO₂': 9.8,
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trips = _getMockTrips();
    
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_trackingService.isTracking)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: _startTrip,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Start New Trip'),
              ),
            ),
          _buildActiveTrip(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...trips.map((trip) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                _getTransportModeIcon(trip.transportMode),
                size: 32,
                color: Colors.green[700],
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trip.startLocation} → ${trip.endLocation}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(trip.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${trip.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${trip.duration} mins',
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'CO₂: -${trip.co2Saved.toStringAsFixed(1)}kg',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripDetailView(trip: trip),
                  ),
                );
              },
            ),
          )).toList(),
        ],
      ),
    );
  }

  IconData _getTransportModeIcon(TransportMode mode) {
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  void dispose() {
    _trackingService.dispose();
    super.dispose();
  }
}
