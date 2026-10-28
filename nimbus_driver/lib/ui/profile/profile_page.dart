import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/driver/driver_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/state_views.dart';
import '../documents/documents_page.dart';

/// Driver profile tab — account info, documents and logout.
class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const DriverDashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          if (state is DriverLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DriverFailure && state.data == null) {
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<DriverBloc>()
                  .add(const DriverDashboardLoadRequested()),
            );
          }
          final data = state is DriverLoaded
              ? state.data
              : state is DriverApplying
                  ? (state as DriverApplying).data
                  : state is DriverFailure
                      ? (state as DriverFailure).data!
                      : null;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primary.withOpacity(0.12),
                        child: Text(
                          (data.user.name?.isNotEmpty == true
                                  ? data.user.name![0]
                                  : 'D')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.user.name ?? 'Nimbus driver',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.user.phone ?? '',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _menuItem(
                      icon: Icons.description_outlined,
                      label: 'Documents',
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const DocumentsPage())),
                    ),
                    _divider(),
                    _menuItem(
                      icon: Icons.directions_car_outlined,
                      label: 'My vehicles',
                      trailing: '${data.vehicles.length}',
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const DocumentsPage())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: _menuItem(
                  icon: Icons.logout,
                  label: 'Log out',
                  color: AppTheme.error,
                  onTap: _logout,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Nimbus Driver · Dhaka',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to verify your phone again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthLoggedOut());
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/auth', (route) => false);
            },
            child: const Text('Log out',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    String? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primary),
      title: Text(
        label,
        style: TextStyle(
            fontSize: 15, color: color, fontWeight: FontWeight.w500),
      ),
      trailing: trailing != null
          ? Text(trailing, style: const TextStyle(color: Colors.grey))
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);
}
