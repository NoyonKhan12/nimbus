import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../services/feedback_service.dart';

/// Post-trip driver rating: 1–5 stars + optional comment.
/// Backend rejects duplicates and non-completed journeys.
class RatingSheet extends StatefulWidget {
  final String bookingId;
  final String toUserId;

  const RatingSheet({
    super.key,
    required this.bookingId,
    required this.toUserId,
  });

  static Future<void> show(
    BuildContext context, {
    required String bookingId,
    required String toUserId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RatingSheet(bookingId: bookingId, toUserId: toUserId),
    );
  }

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _stars = 5;
  final _comment = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await context.read<FeedbackService>().createRating(
            bookingId: widget.bookingId,
            ratedUserId: widget.toUserId,
            score: _stars.toDouble(),
            comment: _comment.text.trim().isEmpty
                ? null
                : _comment.text.trim(),
          );
      setState(() {
        _submitted = true;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _submitted ? 'Thanks for the feedback!' : 'Rate your driver',
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (!_submitted) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _stars = star),
                  icon: Icon(
                    star <= _stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              maxLines: 2,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText: 'Add a comment (optional)',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Rating failed. It may already have been submitted.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.error, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit rating'),
            ),
          ] else ...[
            const Text(
              'Have a safe commute!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ],
      ),
    );
  }
}
