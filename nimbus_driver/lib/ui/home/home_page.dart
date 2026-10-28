import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver/driver_bloc.dart';
import '../../bloc/rides/rides_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/user_service.dart';
import '../../services/websocket_service.dart';
import '../dashboard/dashboard_page.dart';
import '../earnings/earnings_page.dart';
import '../profile/profile_page.dart';
import '../rides/my_rides_page.dart';

/// HomePage — driver shell: Dashboard, Rides, Earnings, Profile.
///
/// Owns the real-time layer: connects the STOMP WebSocket after login and
/// subscribes to `/topic/driver/{driverUserId}` so NEW_BOOKING pushes
/// surface immediately (in-app banner + dashboard/rides refresh). A broken
/// or failing socket never crashes the app — the REST refresh paths in the
/// blocs keep working as graceful degradation.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final WebsocketService _socket = WebsocketService();

  StreamSubscription<WsEvent>? _eventSub;
  StreamSubscription<PushNotification>? _pushSub;
  StreamSubscription<PushNotification>? _pushTapSub;
  String? _driverId;
  bool _driverTopicRequested = false;
  int _currentIndex = 0;
  DateTime _lastEventRefreshAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _refreshThrottle = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ensureConnected();
    _pushSub = PushNotificationService.instance.messages.listen((message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message.body.isEmpty ? message.title : '${message.title}: ${message.body}',
          ),
        ),
      );
      _throttledReload();
    });
    _pushTapSub = PushNotificationService.instance.taps.listen((message) {
      if (!mounted) return;
      setState(() => _currentIndex = 1);
      _reloadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSub?.cancel();
    _pushSub?.cancel();
    _pushTapSub?.cancel();
    if (_driverId != null && _driverTopicRequested) {
      try {
        _socket.unsubscribeFromDriver(_driverId!);
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Resume: reconnect subscriptions (connect() is idempotent and the
    // service itself auto-reconnects with backoff) and catch up on anything
    // missed while backgrounded.
    if (state == AppLifecycleState.resumed) {
      _ensureConnected();
      _reloadData();
    }
  }

  void _ensureConnected() {
    try {
      _socket.connect().catchError((e) {
        if (mounted) debugPrint('HomePage: socket connect failed: $e');
      });
    } catch (e) {
      // No token yet (e.g. session refresh race) — the REST refresh paths
      // in the blocs keep the UI usable.
      debugPrint('HomePage: socket connect threw: $e');
    }
    _listen();
  }

  void _listen() {
    _eventSub ??= _socket.events.listen(
      _onEvent,
      onError: (e) => debugPrint('HomePage: socket event error: $e'),
    );
    _subscribeDriverTopic();
  }

  /// Resolves the current driver's user id (the topic key) and subscribes.
  /// Idempotent; retried on resume if the id wasn't available yet.
  Future<void> _subscribeDriverTopic() async {
    if (_driverTopicRequested || _driverId != null || !mounted) return;
    _driverTopicRequested = true;
    try {
      final authService = context.read<AuthService>();
      final userService = context.read<UserService>();
      var userId = await authService.getUserId();
      if (userId == null || userId.isEmpty) {
        // Fall back to the authoritative /me endpoint.
        userId = (await userService.getCurrentUser()).id;
      }
      if (userId.isEmpty || !mounted) return;
      _driverId = userId;
      _socket.subscribeToDriver(userId);
    } catch (e) {
      debugPrint('HomePage: driver-topic subscribe failed: $e');
    }
  }

  void _onEvent(WsEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case 'NEW_BOOKING':
        _showNewBookingBanner(event);
        _throttledReload();
        break;
      default:
        break;
    }
  }

  void _showNewBookingBanner(WsEvent event) {
    final seats = event.data['seats'];
    final seatsText = seats != null ? ' · $seats seat(s)' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: AppTheme.primary,
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'New booking confirmed on your ride $seatsText',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _throttledReload() {
    final now = DateTime.now();
    if (now.difference(_lastEventRefreshAt) < _refreshThrottle) return;
    _lastEventRefreshAt = now;
    _reloadData();
  }

  void _reloadData() {
    if (!mounted) return;
    context.read<RidesBloc>().add(const RidesLoadRequested());
    context.read<DriverBloc>().add(const DriverDashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardPage(),
          MyRidesPage(),
          EarningsPage(),
          DriverProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: AppTheme.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route, color: AppTheme.primary),
            label: 'Rides',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments, color: AppTheme.primary),
            label: 'Earnings',
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
