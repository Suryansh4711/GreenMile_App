import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';

class StepsDetailsPage extends StatefulWidget {
  const StepsDetailsPage({super.key});

  @override
  State<StepsDetailsPage> createState() => _StepsDetailsPageState();
}

class _StepsDetailsPageState extends State<StepsDetailsPage> {
  final List<FlSpot> _stepData = [];
  Timer? _updateTimer;
  StreamSubscription? _stepsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeStepData();
    _setupRealTimeUpdates();
  }

  void _initializeStepData() {
    final now = DateTime.now();
    for (int i = 0; i < 24; i++) {
      _stepData.add(FlSpot(i.toDouble(), 0));
    }
  }

  void _setupRealTimeUpdates() {
    final dataService = Provider.of<DataService>(context, listen: false);
    
    _stepsSubscription = dataService.stepsStream.listen((steps) {
      if (mounted) {
        setState(() {
          final hour = DateTime.now().hour;
          if (hour < _stepData.length) {
            _stepData[hour] = FlSpot(hour.toDouble(), steps.toDouble());
          }
        });
      }
    });

    // Initialize with current steps
    _stepData[DateTime.now().hour] = FlSpot(
      DateTime.now().hour.toDouble(),
      dataService.totalSteps.toDouble(),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _stepsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Tracking', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20), // Darker green for app bar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20), // Dark green
              Color(0xFF2E7D32), // Medium dark green
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildStepCounter(context, dataService.totalSteps),
              _buildCaloriesCard(context, dataService.totalSteps),
              _buildStepChart(context),
              _buildStatsGrid(context, dataService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCounter(BuildContext context, int steps) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: TweenAnimationBuilder(
        tween: IntTween(begin: 0, end: steps),
        duration: const Duration(seconds: 1),
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: value / 10000, // Assuming daily goal of 10,000 steps
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'steps',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaloriesCard(BuildContext context, int steps) {
    return Card(
      color: const Color(0xFF2E7D32).withOpacity(0.9), // Slightly transparent dark green
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calories Burned',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${(steps * 0.04).round()} kcal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepChart(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1000,
            verticalInterval: 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.primary.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: theme.colorScheme.primary.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2000,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}:00',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _stepData,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4CAF50), // Lighter green
                  Color(0xFF81C784), // Very light green
                ],
              ),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: theme.colorScheme.primary,
                    strokeWidth: 1,
                    strokeColor: theme.colorScheme.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
          minX: 0,
          maxX: 23,
          minY: 0,
          maxY: 10000,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DataService dataService) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          context,
          'Distance',
          '${(dataService.totalSteps * 0.0007).toStringAsFixed(2)} km',
          Icons.directions_walk,
        ),
        _buildStatCard(
          context,
          'Active Time',
          '${(dataService.totalSteps * 0.01).round()} min',
          Icons.timer,
        ),
        _buildStatCard(
          context,
          'Goal Progress',
          '${((dataService.totalSteps / 10000) * 100).round()}%',
          Icons.flag,
        ),
        _buildStatCard(
          context,
          'CO₂ Saved',
          '${(dataService.totalSteps * 0.0002).toStringAsFixed(2)} kg',
          Icons.eco,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      color: const Color(0xFF2E7D32).withOpacity(0.9), // Slightly transparent dark green
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
