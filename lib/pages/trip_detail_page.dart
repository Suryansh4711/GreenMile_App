import 'package:flutter/material.dart';
import '../models/trip_details.dart';
import 'package:intl/intl.dart';

class TripDetailPage extends StatelessWidget {
  final TripDetails trip;

  const TripDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
                ),
              ),
              child: Column(
                children: [
                  _buildTripHeader(),
                  _buildStatisticsCard(),
                  _buildEnvironmentalImpact(),
                  _buildRouteDetails(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          DateFormat('MMMM d, y').format(trip.date),
          style: const TextStyle(color: Color.fromARGB(255, 248, 245, 245)),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF00C853).withOpacity(0.8),
                const Color(0xFF1B5E20),
              ],
            ),
          ),
          child: Icon(
            _getTransportIcon(),
            size: 80,
            color: const Color(0xFF00C853), // Updated color to match My Trips
          ),
        ),
      ),
    );
  }

  Widget _buildTripHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.startLocation,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.endLocation,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Distance', '${trip.distance.toStringAsFixed(1)} km', Icons.straighten),
                _buildStat('Duration', '${trip.duration} min', Icons.timer),
                _buildStat('Speed', '${trip.averageSpeed.toStringAsFixed(1)} km/h', Icons.speed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpact() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Environmental Impact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
            const SizedBox(height: 16),
            _buildImpactRow('CO₂ Saved', '${trip.co2Saved.toStringAsFixed(2)} kg'),
            _buildImpactRow('NOx Reduced', '${trip.emissions['NOx']?.toStringAsFixed(2)} g'),
            _buildImpactRow('SO₂ Reduced', '${trip.emissions['SO₂']?.toStringAsFixed(2)} g'),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteDetails() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Activity Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (trip.calories > 0)
              _buildImpactRow('Calories Burned', '${trip.calories} kcal'),
            _buildImpactRow(
              'Transport Mode', 
              _getTransportName(),
              icon: Icon(
                _getTransportIcon(),
                color: const Color(0xFF00C853),  // Updated color to match My Trips
              ),
            ),
            _buildImpactRow('Time of Day', 
              DateFormat('hh:mm a').format(trip.date)),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[700]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactRow(String label, String value, {Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransportIcon() {
    switch (trip.transportMode) {
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

  String _getTransportName() {
    return trip.transportMode.toString().split('.').last[0].toUpperCase() +
           trip.transportMode.toString().split('.').last.substring(1);
  }
}
