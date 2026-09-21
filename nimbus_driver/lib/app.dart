import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'bloc/auth/auth_bloc.dart';
import 'ui/auth/auth_wrapper.dart';
import 'ui/home/home_page.dart';
import 'ui/splash/splash_page.dart';
import 'api/api_client.dart';
import 'services/driver_service.dart';

/// Root widget for the Nimbus Driver application.
class NimbusDriverApp extends StatelessWidget {
  const NimbusDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>(
          create: (_) => ApiClient(
            ApiService().dio,
            baseUrl: AppConstants.apiBaseUrl,
          ),
        ),
        RepositoryProvider<ApiService>(create: (_) => ApiService()),
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(
            context.read<ApiClient>(),
            context.read<ApiService>(),
          ),
        ),
        RepositoryProvider<DriverService>(
          create: (context) => DriverService(
            context.read<ApiClient>(),
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
          builder: (context) => BlocProvider(
            create: (_) => AuthBloc(
              authService: context.read<AuthService>(),
            ),
            child: const SplashPage(),
          ),
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
    );
  }
}
