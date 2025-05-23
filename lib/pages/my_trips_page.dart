import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/trip_details.dart';
import 'package:intl/intl.dart';
import 'trip_detail_page.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Trips',
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
              Color(0xFF00C853),
              Color(0xFF1B5E20),
            ],
          ),
        ),
        child: Consumer<DataService>(
          builder: (context, dataService, child) {
            final trips = dataService.trips;
            if (trips.isEmpty) {
              return _buildEmptyState();
            }
            return _buildTripsList(trips);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No trips yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first trip to start tracking',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<TripDetails> trips) {
    return ListView.builder(
      itemCount: trips.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(context, trip); // Pass context here
      },
    );
  }

  Widget _buildTripCard(BuildContext context, TripDetails trip) {
    return Hero(
      tag: 'trip-${trip.id}',
      child: Dismissible(
        key: Key(trip.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text('Are you sure you want to delete this trip?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          final dataService = Provider.of<DataService>(context, listen: false);
          dataService.deleteTrip(trip.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Trip deleted'),
              duration: const Duration(seconds: 2), // Set duration to 2 seconds
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  dataService.addTrip(trip);
                },
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: Colors.black26,
          color: Colors.white.withOpacity(0.9),
          child: InkWell(
            onTap: () => Navigator.push(
              context, // Now context is available
              MaterialPageRoute(
                builder: (context) => TripDetailPage(trip: trip),
              ),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTransportIcon(trip.transportMode),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMM d, y').format(trip.date),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${trip.startLocation} → ${trip.endLocation}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        Icons.straighten,
                        '${trip.distance.toStringAsFixed(1)} km',
                        'Distance',
                      ),
                      _buildStat(
                        Icons.timer_outlined,
                        '${trip.duration} min',
                        'Duration',
                      ),
                      _buildStat(
                        Icons.eco,
                        '${trip.co2Saved.toStringAsFixed(1)} kg',
                        'CO₂ Saved',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransportIcon(TransportMode mode) {
    final IconData icon;
    final Color color;

    switch (mode) {
      case TransportMode.walking:
        icon = Icons.directions_walk;
        color = Colors.blue;
        break;
      case TransportMode.cycling:
        icon = Icons.directions_bike;
        color = Colors.green;
        break;
      case TransportMode.bus:
        icon = Icons.directions_bus;
        color = Colors.amber;
        break;
      case TransportMode.train:
        icon = Icons.train;
        color = Colors.red;
        break;
      case TransportMode.car:
        icon = Icons.directions_car;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1B5E20), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1B5E20),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
