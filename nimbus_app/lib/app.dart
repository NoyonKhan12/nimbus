import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'bloc/auth/auth_bloc.dart';
import 'ui/auth/auth_wrapper.dart';
import 'ui/home/home_page.dart';
import 'ui/splash/splash_page.dart';
import 'api/api_client.dart';

/// Root widget for the Nimbus Flutter application.
class NimbusApp extends StatelessWidget {
  const NimbusApp({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        /// Provides the Dio-based API client.
        RepositoryProvider<ApiClient>(
          create: (_) => ApiClient(
            apiService.dio,
            baseUrl: AppConstants.apiBaseUrl,
          ),
        ),
        /// Provides the API service (handles token storage and refresh).
        RepositoryProvider<ApiService>.value(value: apiService),
        /// Provides the auth service.
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(
            context.read<ApiClient>(),
            context.read<ApiService>(),
          ),
        ),
        /// Provides the user service.
        RepositoryProvider<UserService>(
          create: (context) => UserService(context.read<ApiClient>()),
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
            // Provide AuthBloc to the splash page using the injected AuthService.
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
    );
  }
}
