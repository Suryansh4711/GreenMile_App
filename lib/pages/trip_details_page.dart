import 'package:flutter/material.dart';
import '../models/trip_details.dart';

class TripDetailsPage extends StatelessWidget {
  final TripDetails tripDetails;

  const TripDetailsPage({super.key, required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(context),
            _buildDetailsSection(context),
            _buildEmissionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getTransportIcon(tripDetails.transportMode),
                  size: 32,
                  color: Colors.black87,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tripDetails.startLocation} → ${tripDetails.endLocation}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${tripDetails.date.day}/${tripDetails.date.month}/${tripDetails.date.year}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Distance', '${tripDetails.distance.toStringAsFixed(1)} km'),
            _buildDetailRow('Duration', '${tripDetails.duration} mins'),
            _buildDetailRow('Average Speed', '${tripDetails.averageSpeed.toStringAsFixed(1)} km/h'),
            _buildDetailRow('Calories Burned', '${tripDetails.calories.toStringAsFixed(0)} kcal'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmissionsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environmental Impact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('CO₂ Saved', '${tripDetails.co2Saved.toStringAsFixed(1)} kg'),
            ...tripDetails.emissions.entries.map(
              (e) => _buildDetailRow(e.key, '${e.value.toStringAsFixed(2)} g'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
}
