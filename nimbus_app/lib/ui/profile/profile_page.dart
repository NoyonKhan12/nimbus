import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/state_views.dart';
import '../complaint/complaint_page.dart';
import '../notifications/notifications_page.dart';
import 'edit_profile_page.dart';
import 'saved_locations_page.dart';

/// Profile tab — account summary and entry points for settings/support.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileFailure) {
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileLoadRequested()),
            );
          }
          if (state is ProfileLoaded || state is ProfileSaving) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileSaving).profile;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              AppTheme.primary.withOpacity(0.12),
                          // Handles both no-URL and broken/offline URL:
                          // Image.network's errorBuilder falls back to the
                          // initials-based avatar (same pattern used when
                          // photoUrl is null/empty).
                          child: profile.photoUrl != null &&
                                  profile.photoUrl!.isNotEmpty
                              ? Image.network(
                                  profile.photoUrl!,
                                  // CircleAvatar(radius: 32) → 64x64 box.
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          _ProfileInitials(
                                    name: profile.name,
                                    fontSize: 24,
                                  ),
                                )
                              : _ProfileInitials(
                                  name: profile.name,
                                  fontSize: 24,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name ?? 'Nimbus commuter',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.phone ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state is ProfileSaving)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Menu
                Card(
                  child: Column(
                    children: [
                      _menuItem(
                        icon: Icons.edit_outlined,
                        label: 'Edit profile',
                        onTap: () => _push(const EditProfilePage()),
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.bookmark_border,
                        label: 'Saved locations',
                        onTap: () => _push(const SavedLocationsPage()),
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => _push(const NotificationsPage()),
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.support_agent,
                        label: 'Report a problem',
                        onTap: () => _push(const ComplaintPage()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _menuItem(
                        icon: Icons.logout,
                        label: 'Log out',
                        color: AppTheme.error,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Nimbus · Dhaka commuter pooling',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/auth',
                (route) => false,
              );
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
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primary),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);
}

/// Initials-based avatar fallback: first character of the name (or 'N'),
/// matching AppConstants.defaultPhotoUrl's initials-avatar pattern.
class _ProfileInitials extends StatelessWidget {
  final String? name;
  final double fontSize;

  const _ProfileInitials({required this.name, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        (name?.isNotEmpty == true ? name![0] : 'N').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
