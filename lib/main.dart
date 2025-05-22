import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/ocr_service.dart';
import 'services/location_service.dart';
import 'services/data_service.dart';
import 'models/emission_result.dart';
import 'pages/challenges_page.dart';
import 'pages/rewards_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/track_page.dart'; // Import TrackPage
import 'pages/ocr_page.dart';
import 'pages/my_trips_page.dart'; // Import MyTripsPage
import 'models/trip_details.dart';
import 'pages/trip_detail_view.dart';
import 'widgets/animated_stat_card.dart';
import 'pages/steps_details_page.dart'; // Import StepsDetailsPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),  // Medium green
          brightness: Brightness.light,
          background: const Color.fromARGB(255, 19, 99, 26),  // Very light green
          surface: const Color.fromARGB(255, 199, 255, 201),     // Light green
          surfaceVariant: const Color(0xFFA5D6A7), // Lighter green
          primary: const Color(0xFF43A047),     // Less dark green
          primaryContainer: const Color(0xFF66BB6A), // Light medium green
          secondary: const Color(0xFF7CB342),    // Light lime green
          tertiary: const Color(0xFF26A69A),     // Light teal
          error: const Color.fromARGB(255, 221, 55, 55),        // Light red
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 20, 45, 22), // Darker green
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF43A047),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // Remove userDetails requirement

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  final OcrService _ocrService = OcrService();
  final LocationService _locationService = LocationService();
  EmissionResult? _lastScanResult;
  int _selectedIndex = 0;
  double _currentDistance = 0.0;
  int _currentSteps = 0;

  static Widget _buildFeatureCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 227, 236, 227)
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: Color.fromARGB(255, 12, 8, 8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      HomeContent(
        currentSteps: _currentSteps,
        currentDistance: _currentDistance,
      ),
      const MyTripsPage(),  // Replace Center widget with MyTripsPage
      const TrackPage(),
      const RewardsPage(),
      const ChallengesPage(),
      const OcrPage(),  // Add OCR page
      const ProfilePage(),
      const SettingsPage(),
    ];
  }

  void _handleLogout() async {
    try {
      await _authService.signOut(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.3) : null,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _scanEmissions(bool fromCamera) async {
    final result = fromCamera 
      ? await _ocrService.processImageFromCamera()
      : await _ocrService.processImageFromGallery();
    
    if (result != null) {
      setState(() => _lastScanResult = result);
      _showResultDialog(result);
    }
  }

  void _showResultDialog(EmissionResult result) {
    final textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Results', 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CO₂ Saved: ${result.co2Saved.toStringAsFixed(2)} kg', style: textStyle),
            Text('NOx Saved: ${result.noxSaved.toStringAsFixed(2)} g', style: textStyle),
            Text('SO₂ Saved: ${result.so2Saved.toStringAsFixed(2)} g', style: textStyle),
            Text('Fuel Saved: ${result.fuelSaved.toStringAsFixed(2)} L', style: textStyle),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeTracking() async {
    try {
      await _locationService.startTracking();
      _locationService.distanceStream.listen((distance) {
        setState(() => _currentDistance = distance);
      });
      _locationService.stepsStream.listen((steps) {
        setState(() => _currentSteps = steps);
      });
    } catch (e) {
      print('Error initializing tracking: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationService.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Image.asset(
          'assets/removed_bg_logo.png',
          height: 40,
          color: Colors.white,
        ),
        centerTitle: true,
        actions: [
          if (currentUser != null)
            PopupMenuButton(
              offset: const Offset(0, 50),
              icon: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
              ),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Profile'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    // Handle profile action
                    break;
                  case 'settings':
                    // Handle settings action
                    break;
                  case 'logout':
                    _handleLogout();
                    break;
                }
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1B5E20),  // Dark green
                    const Color(0xFF2E7D32),  // Medium dark green
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/removed_bg_logo.png',
                      height: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'GreenMile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.home_outlined, 'Home', 0),
                  _buildDrawerItem(Icons.directions_car_outlined, 'My Trips', 1),
                  _buildDrawerItem(Icons.map_outlined, 'Track', 2),
                  _buildDrawerItem(Icons.card_giftcard, 'Rewards', 3),
                  _buildDrawerItem(Icons.emoji_events_outlined, 'Challenges', 4),
                  _buildDrawerItem(Icons.document_scanner, 'Scan', 5),  // Add OCR item
                  _buildDrawerItem(Icons.person_outline, 'Profile', 6),
                  const Divider(),
                  _buildDrawerItem(Icons.settings, 'Settings', 7),
                  if (currentUser != null)
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 15, 35, 17), // Darker surface
              const Color.fromARGB(255, 25, 55, 28), // Darker surface container
            ],
          ),
        ),
        child: _buildPages()[_selectedIndex],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final int currentSteps;
  final double currentDistance;

  const HomeContent({
    super.key,
    required this.currentSteps,
    required this.currentDistance,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    AnimatedStatCard(
                      title: 'Total Trips',
                      value: dataService.totalTrips.toString(),
                      icon: Icons.directions_car,
                      color: theme.colorScheme.primary,
                    ),
                    AnimatedStatCard(
                      title: 'Steps',
                      value: dataService.totalSteps.toString(),
                      icon: Icons.directions_walk,
                      color: theme.colorScheme.secondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StepsDetailsPage(),
                        ),
                      ),
                    ),
                    AnimatedStatCard(
                      title: 'Distance',
                      value: '${dataService.totalDistance.toStringAsFixed(1)} km',
                      icon: Icons.map,
                      color: theme.colorScheme.tertiary,
                    ),
                    AnimatedStatCard(
                      title: 'CO₂ Saved',
                      value: '${dataService.totalCO2Saved.toStringAsFixed(1)} kg',
                      icon: Icons.eco,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildRecentActivitySection(context, dataService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s make today\'s journey eco-friendly',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, DataService dataService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity history
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataService.trips.take(3).length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final trip = dataService.trips[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        _getTransportIcon(trip.transportMode),
                        color: theme.colorScheme.primary
                      ),
                    ),
                    title: Text('${trip.startLocation} → ${trip.endLocation}'),
                    subtitle: Text(
                      '${trip.distance.toStringAsFixed(1)} km • ${_formatDate(trip.date)}'
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
      default:
        return Icons.directions_car; // Default icon
    }
  }
}
