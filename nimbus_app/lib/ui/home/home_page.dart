import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../core/theme/app_theme.dart';

/// HomePage — the main passenger home screen.
/// Shows a map-like placeholder, ride search, and booking controls.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _routes = ['/home', '/rides', '/wallet', '/profile'];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    if (index != 0 && _routes[index] != '/') {
      // Placeholder for future navigation.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeContent(),
          Center(child: Text('Rides')),
          Center(child: Text('Wallet')),
          Center(child: Text('Profile')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Rides'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nimbus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLoggedOut());
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/auth',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location input card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Where from?'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Pickup location',
                        prefixIcon: Icon(Icons.location_on, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Where to?'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Drop-off location',
                        prefixIcon: Icon(Icons.location_on, color: AppTheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search rides button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to ride search
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ride search coming soon')),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Search Rides'),
            ),
            const SizedBox(height: 24),
            // Info section
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Rides', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('No upcoming rides', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
