import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../services/feedback_service.dart';

/// Report a problem — files a complaint via `POST /complaints`.
class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  static const _categories = <String, String>{
    'DRIVER_BEHAVIOR': 'Driver behaviour',
    'SAFETY': 'Safety concern',
    'CLEANLINESS': 'Vehicle cleanliness',
    'DELAY': 'Delay',
    'OVERCHARGING': 'Overcharging',
    'APP_ISSUE': 'App issue',
    'OTHER': 'Other',
  };

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _bookingId = TextEditingController();
  String _category = 'DRIVER_BEHAVIOR';
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _description.dispose();
    _bookingId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await context.read<FeedbackService>().createComplaint(
            category: _category,
            description: _description.text.trim(),
            bookingId:
                _bookingId.text.trim().isEmpty ? null : _bookingId.text.trim(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Report a problem')),
      body: _submitted ? _success() : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _description,
            maxLines: 6,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'What happened?',
              alignLabelWithHint: true,
            ),
            validator: (v) =>
                (v == null || v.trim().length < 10)
                    ? 'Please describe the issue (at least 10 characters)'
                    : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bookingId,
            decoration: const InputDecoration(
              labelText: 'Booking ID (optional)',
              hintText: 'From My rides → booking details',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              'Submission failed: $_error',
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit complaint'),
          ),
        ],
      ),
    );
  }

  Widget _success() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_read_outlined,
                size: 56, color: AppTheme.success),
            const SizedBox(height: 16),
            const Text(
              'Complaint received',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team will follow up. You can track the '
              'response from this app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
