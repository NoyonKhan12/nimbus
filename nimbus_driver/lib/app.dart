import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/driver/driver_bloc.dart';
import 'bloc/ride_control/ride_control_bloc.dart';
import 'bloc/rides/rides_bloc.dart';
import 'core/theme/app_theme.dart';
import 'network/backend_api.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/driver_service.dart';
import 'services/ride_service.dart';
import 'services/user_service.dart';
import 'services/websocket_service.dart';
import 'services/wallet_service.dart';
import 'ui/auth/auth_wrapper.dart';
import 'ui/home/home_page.dart';
import 'ui/splash/splash_page.dart';

/// Root widget for the Nimbus Driver application.
class NimbusDriverApp extends StatelessWidget {
  const NimbusDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
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
        RepositoryProvider<DriverService>(
          create: (_) => DriverService(backendApi),
        ),
        RepositoryProvider<RideService>(
          create: (_) => RideService(backendApi),
        ),
        RepositoryProvider<BookingService>(
          create: (_) => BookingService(backendApi),
        ),
        RepositoryProvider<WalletService>(
          create: (_) => WalletService(backendApi),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DriverBloc>(
            create: (context) => DriverBloc(
              driverService: context.read<DriverService>(),
              userService: context.read<UserService>(),
            ),
          ),
          BlocProvider<RidesBloc>(
            create: (context) => RidesBloc(
              rideService: context.read<RideService>(),
            ),
          ),
          BlocProvider<RideControlBloc>(
            create: (context) => RideControlBloc(
              rideService: context.read<RideService>(),
              bookingService: context.read<BookingService>(),
              socket: WebsocketService(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Nimbus Driver',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: Builder(
            builder: (context) {
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
            '/home': (_) => const HomePage(),
          },
        ),
      ),
    );
  }
}
