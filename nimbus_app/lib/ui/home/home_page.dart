import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../services/booking_service.dart';
import '../../dto/ride_booking_dtos.dart';
import '../../services/push_notification_service.dart';
import '../booking/my_bookings_page.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';
import '../ride/ride_search_page.dart';
import '../ride/trip_tracking_page.dart';
import '../wallet/wallet_page.dart';

/// HomePage — passenger shell: Home, Rides, Wallet, Profile.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            onNavigate: (index) => setState(() => _currentIndex = index),
          ),
          const MyBookingsPage(),
          const WalletPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppTheme.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon:
                Icon(Icons.directions_car, color: AppTheme.primary),
            label: 'Rides',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet,
                color: AppTheme.primary),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Landing tab: quick ride search entry and shortcuts.
class _HomeTab extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const _HomeTab({required this.onNavigate});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Future<Booking?>? _activeBooking;
  StreamSubscription<PushNotification>? _pushSub;
  StreamSubscription<PushNotification>? _pushTapSub;

  @override
  void initState() {
    super.initState();
    _activeBooking = _findActiveBooking();
    _pushSub = PushNotificationService.instance.messages.listen((message) {
      if (!mounted) return;
      _showPushMessage(message);
    });
    _pushTapSub = PushNotificationService.instance.taps.listen((message) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsPage()),
      );
    });
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    _pushTapSub?.cancel();
    super.dispose();
  }

  void _showPushMessage(PushNotification message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          message.body.isEmpty ? message.title : '${message.title}: ${message.body}',
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          ),
        ),
      ),
    );
  }

  /// Most recent HELD/CONFIRMED/PICKED_UP booking, if any.
  Future<Booking?> _findActiveBooking() async {
    try {
      final bookings = await context.read<BookingService>().listBookings();
      final active = bookings.where((b) =>
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.pickedUp);
      if (active.isEmpty) return null;
      return active.first;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nimbus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _activeBooking = _findActiveBooking());
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Active trip banner
            FutureBuilder<Booking?>(
              future: _activeBooking,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SizedBox.shrink();
                }
                final booking = snap.data;
                if (booking == null) return const SizedBox.shrink();
                return Card(
                  color: AppTheme.secondary.withOpacity(0.1),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.secondary,
                      child:
                          Icon(Icons.radar, color: Colors.white, size: 20),
                    ),
                    title: const Text(
                      'You have an active trip',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Booking #${booking.id.substring(0, 8)} · tap to track',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: AppTheme.secondary),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TripTrackingPage(
                            rideId: booking.rideId,
                            bookingId: booking.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Search card
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const RideSearchPage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.search,
                                color: AppTheme.primary),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Where are you headed?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Search pooled rides for your commute — pay only '
                        'for your segment.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _chip(Icons.trip_origin, 'Pickup'),
                          const Icon(Icons.arrow_forward,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          _chip(Icons.location_on, 'Drop-off'),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Shortcuts
            Row(
              children: [
                _shortcut(
                  icon: Icons.directions_car_outlined,
                  label: 'My rides',
                  color: AppTheme.primary,
                  onTap: () => widget.onNavigate(1),
                ),
                const SizedBox(width: 12),
                _shortcut(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  color: AppTheme.secondary,
                  onTap: () => widget.onNavigate(2),
                ),
                const SizedBox(width: 12),
                _shortcut(
                  icon: Icons.support_agent,
                  label: 'Support',
                  color: AppTheme.warning,
                  onTap: () => widget.onNavigate(3),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Shared commutes for Dhaka · Pay per segment',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _shortcut({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
