import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_theme.dart';
import '../../services/safety_service.dart';

/// SOS confirmation and dispatch sheet.
///
/// Records ride + GPS + timestamp server-side (guide §19); the GPS fix is
/// best-effort so the alert never blocks on location availability.
class SosSheet extends StatefulWidget {
  final String rideId;

  const SosSheet({super.key, required this.rideId});

  static Future<void> show(BuildContext context,
      {required String rideId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SosSheet(rideId: rideId),
    );
  }

  @override
  State<SosSheet> createState() => _SosSheetState();
}

enum _SosStage { confirm, sending, sent, failed }

class _SosSheetState extends State<SosSheet> {
  _SosStage _stage = _SosStage.confirm;
  String? _error;

  Future<void> _dispatch() async {
    setState(() => _stage = _SosStage.sending);
    final safetyService = context.read<SafetyService>();
    try {
      double? lat;
      double? lng;
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        // Alert goes out without GPS rather than not at all.
      }
      await safetyService.triggerSos(
            rideId: widget.rideId,
            latitude: lat,
            longitude: lng,
          );
      setState(() => _stage = _SosStage.sent);
    } catch (e) {
      setState(() {
        _stage = _SosStage.failed;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            switch (_stage) {
              _SosStage.confirm => _confirmBody(),
              _SosStage.sending => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppTheme.error),
                        SizedBox(height: 16),
                        Text('Sending SOS alert…'),
                      ],
                    ),
                  ),
                ),
              _SosStage.sent => _sentBody(),
              _SosStage.failed => _failedBody(),
            },
          ],
        ),
      ),
    );
  }

  Widget _confirmBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.emergency, color: AppTheme.error, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Trigger emergency SOS?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Your ride details and current position will be shared with '
          'the Nimbus safety team immediately.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          onPressed: _dispatch,
          child: const Text('SEND SOS'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }

  Widget _sentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.shield, color: AppTheme.success, size: 48),
        const SizedBox(height: 12),
        const Text(
          'SOS alert sent',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'The safety team has been notified and will respond. '
          'Stay calm and stay put if safe to do so.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _failedBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.cloud_off, color: AppTheme.error, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Could not send SOS',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Please try again, or call national emergency '
              'services directly (999).',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          onPressed: _dispatch,
          child: const Text('Retry'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}
