import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../services/driver_service.dart';
import '../../dto/ride_dtos.dart';

/// Driver HomePage — shows active rides and driver controls.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DriverService _driverService;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _driverService = context.read<DriverService>();
  }

  Future<List<Ride>> _fetchRides() async {
    return await _driverService.getAssignedRides();
  }

  void _logout() {
    context.read<AuthBloc>().add(const AuthLoggedOut());
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nimbus Driver'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _RidesTab(),
          Center(child: Text('Earnings')),
          Center(child: Text('Profile')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Rides'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _RidesTab extends StatelessWidget {
  const _RidesTab();

  @override
  Widget build(BuildContext context) {
    final driverService = context.read<DriverService>();
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<List<Ride>>(
        future: driverService.getAssignedRides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final rides = snapshot.data ?? [];
          if (rides.isEmpty) {
            return const Center(child: Text('No assigned rides'));
          }
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, i) {
              final ride = rides[i];
              return ListTile(
                title: Text('Ride #${ride.id.substring(0, 8)}'),
                subtitle: Text('Status: ${ride.status.name}'),
                trailing: Icon(Icons.chevron_right,
                    color: Theme.of(context).colorScheme.primary),
                onTap: () {
                  // TODO: Navigate to ride detail
                },
              );
            },
          );
        },
      ),
    );
  }
}
