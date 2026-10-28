import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/notification/notification_bloc.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/ride_search/ride_search_bloc.dart';
import 'bloc/trip/trip_bloc.dart';
import 'bloc/wallet/wallet_bloc.dart';
import 'core/theme/app_theme.dart';
import 'network/backend_api.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/feedback_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/ride_service.dart';
import 'services/safety_service.dart';
import 'services/user_service.dart';
import 'services/wallet_service.dart';
import 'services/websocket_service.dart';
import 'ui/auth/auth_wrapper.dart';
import 'ui/home/home_page.dart';
import 'ui/splash/splash_page.dart';

/// Root widget for the Nimbus passenger application.
///
/// Provides the backend contract layer ([BackendApi]), the domain
/// services over it, and the app-lifetime BLoCs (one active trip, one
/// wallet, one profile at a time — per-passenger singletons).
class NimbusApp extends StatelessWidget {
  const NimbusApp({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    final backendApi = BackendApi(apiService.dio);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>.value(value: apiService),
        RepositoryProvider<BackendApi>.value(value: backendApi),
        RepositoryProvider<AuthService>(
          create: (_) => AuthService(apiService),
        ),
        RepositoryProvider<UserService>(
          create: (_) => UserService(backendApi),
        ),
        RepositoryProvider<RideService>(
          create: (_) => RideService(backendApi),
        ),
        RepositoryProvider<BookingService>(
          create: (_) => BookingService(backendApi),
        ),
        RepositoryProvider<PaymentService>(
          create: (_) => PaymentService(backendApi),
        ),
        RepositoryProvider<WalletService>(
          create: (_) => WalletService(backendApi),
        ),
        RepositoryProvider<SafetyService>(
          create: (_) => SafetyService(backendApi),
        ),
        RepositoryProvider<NotificationService>(
          create: (_) => NotificationService(backendApi),
        ),
        RepositoryProvider<FeedbackService>(
          create: (_) => FeedbackService(backendApi),
        ),
        RepositoryProvider<WebsocketService>(
          create: (_) => WebsocketService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RideSearchBloc>(
            create: (context) => RideSearchBloc(
              rideService: context.read<RideService>(),
            ),
          ),
          BlocProvider<TripBloc>(
            create: (context) => TripBloc(
              rideService: context.read<RideService>(),
              bookingService: context.read<BookingService>(),
              socket: context.read<WebsocketService>(),
            ),
          ),
          BlocProvider<WalletBloc>(
            create: (context) => WalletBloc(
              walletService: context.read<WalletService>(),
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationService: context.read<NotificationService>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              userService: context.read<UserService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Nimbus',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: Builder(
            builder: (context) {
              // Provide AuthBloc to the splash page using the injected
              // AuthService.
              return BlocProvider(
                create: (_) => AuthBloc(
                  authService: context.read<AuthService>(),
                ),
                child: const SplashPage(),
              );
            },
          ),
          routes: {
            '/auth': (_) => BlocProvider(
                  create: (context) =>
                      AuthBloc(authService: context.read<AuthService>()),
                  child: const AuthWrapper(),
                ),
            '/home': (_) => HomePage(),
          },
        ),
      ),
    );
  }
}
