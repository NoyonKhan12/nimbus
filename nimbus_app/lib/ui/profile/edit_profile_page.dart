import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../dto/user_dtos.dart';

/// Editable profile fields accepted by `PUT /me`.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _emergencyName;
  late final TextEditingController _emergencyPhone;

  @override
  void initState() {
    super.initState();
    final profile = _currentProfile();
    final name = profile?.name ?? '';
    final parts = name.split(' ');
    _firstName = TextEditingController(
        text: parts.isNotEmpty ? parts.first : '');
    _lastName = TextEditingController(
        text: parts.length > 1 ? parts.sublist(1).join(' ') : '');
    _email = TextEditingController(text: profile?.email ?? '');
    _emergencyName = TextEditingController();
    _emergencyPhone = TextEditingController();
  }

  UserProfile? _currentProfile() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileSaving) return state.profile;
    return null;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(ProfileUpdateRequested(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          emergencyContactName: _emergencyName.text.trim().isEmpty
              ? null
              : _emergencyName.text.trim(),
          emergencyContactPhone: _emergencyPhone.text.trim().isEmpty
              ? null
              : _emergencyPhone.text.trim(),
        ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstName,
                    decoration:
                        const InputDecoration(labelText: 'First name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastName,
                    decoration:
                        const InputDecoration(labelText: 'Last name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
                return ok ? null : 'Enter a valid email';
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Emergency contact',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emergencyName,
              decoration: const InputDecoration(
                  labelText: 'Contact name (e.g. parent, spouse)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emergencyPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact phone',
                hintText: '01XXXXXXXXX',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                return digits.length >= 10
                    ? null
                    : 'Enter a valid phone number';
              },
            ),
            const SizedBox(height: 24),
            BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
