import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A small colored chip for backend statuses (`HELD`, `IN_PROGRESS`, ...).
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  /// Builds a chip from a raw backend status string.
  factory StatusChip.of(String? rawStatus) {
    final status = (rawStatus ?? '').toUpperCase();
    return StatusChip(
      label: status
          .split('_')
          .map((w) =>
              w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
          .join(' '),
      color: _colorFor(status),
    );
  }

  static Color _colorFor(String status) {
    switch (status) {
      case 'HELD':
      case 'DRAFT':
        return AppTheme.warning;
      case 'CONFIRMED':
      case 'PUBLISHED':
      case 'ROUTE_LOCKED':
      case 'PENDING':
        return AppTheme.primary;
      case 'DRIVER_ARRIVING':
      case 'IN_PROGRESS':
      case 'PICKED_UP':
        return AppTheme.secondary;
      case 'COMPLETED':
      case 'SUCCESS':
      case 'SUCCESSFUL':
        return AppTheme.success;
      case 'CANCELLED':
      case 'EXPIRED':
      case 'FAILED':
      case 'REJECTED':
        return AppTheme.error;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Centered empty-state placeholder.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered error-state placeholder with an optional retry action.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
