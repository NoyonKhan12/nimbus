import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/notification/notification_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
// Prefixed: material exports Flutter's own `Notification` (scroll etc.).
import '../../dto/notification_dto.dart' as dtos;
import '../../widgets/state_views.dart';

/// Notification list; tapping marks a notification read.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationsFailure) {
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<NotificationBloc>()
                  .add(const NotificationsLoadRequested()),
            );
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none,
                title: 'No notifications',
                subtitle: 'Ride updates will appear here.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.notifications.length,
              itemBuilder: (context, i) {
                final n = state.notifications[i];
                return _NotificationTile(
                  notification: n,
                  onTap: n.read == true
                      ? null
                      : () => context
                          .read<NotificationBloc>()
                          .add(NotificationMarkRead(n.id)),
                );
              },

            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final dtos.Notification notification;
  final VoidCallback? onTap;

  const _NotificationTile({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = notification.read != true;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: unread
          ? AppTheme.primary.withOpacity(0.05)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Icon(
            _iconFor(notification.type),
            size: 20,
            color: AppTheme.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      unread ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (unread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              AppFormatters.dateTime(notification.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _iconFor(String? type) {
    final t = (type ?? '').toUpperCase();
    if (t.contains('RIDE')) return Icons.directions_car;
    if (t.contains('BOOKING')) return Icons.event_seat;
    if (t.contains('PAYMENT')) return Icons.payment;
    if (t.contains('SAFETY') || t.contains('SOS')) return Icons.shield;
    if (t.contains('VOUCHER')) return Icons.local_offer;
    return Icons.notifications;
  }
}
