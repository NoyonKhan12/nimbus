import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver/driver_bloc.dart';
import '../../core/theme/app_theme.dart';

/// Driver application — license details plus the first vehicle.
/// The backend bundles both into `DriverApplicationRequest`.
class ApplyPage extends StatefulWidget {
  const ApplyPage({super.key});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final _formKey = GlobalKey<FormState>();
  final _license = TextEditingController();
  final _registration = TextEditingController();
  final _model = TextEditingController();
  final _color = TextEditingController();
  final _year = TextEditingController();
  String _vehicleType = 'CAR';
  int _seats = 4;
  DateTime? _licenseExpiry;

  static const _vehicleTypes = ['SEDAN', 'SUV', 'PICKUP', 'VAN', 'BIKE', 'TRUCK', 'OTHER'];

  @override
  void dispose() {
    _license.dispose();
    _registration.dispose();
    _model.dispose();
    _color.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _licenseExpiry ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _licenseExpiry = date);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<DriverBloc>().add(DriverApplyRequested(
          licenseNumber: _license.text.trim(),
          licenseExpiry: _licenseExpiry,
          vehicleRegistrationNumber: _registration.text.trim(),
          vehicleType: _vehicleType,
          vehicleModel: _model.text.trim(),
          vehicleYear: int.tryParse(_year.text.trim()),
          vehicleColor: _color.text.trim(),
          seatCapacity: _seats,
        ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver application')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Driving license',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _license,
              decoration: const InputDecoration(
                  labelText: 'License number'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickExpiry,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'License expiry'),
                child: Text(
                  _licenseExpiry == null
                      ? 'Not set (optional)'
                      : '${_licenseExpiry!.day}/${_licenseExpiry!.month}/${_licenseExpiry!.year}',
                  style: TextStyle(
                      color:
                          _licenseExpiry == null ? Colors.grey : null),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your vehicle',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _registration,
              decoration: const InputDecoration(
                labelText: 'Registration number',
                hintText: 'e.g. DHAKA-METRO-GA-1234',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _vehicleType,
              decoration:
                  const InputDecoration(labelText: 'Vehicle type'),
              items: _vehicleTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _vehicleType = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _model,
              decoration: const InputDecoration(
                  labelText: 'Model', hintText: 'e.g. Toyota Noah'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Year'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final y = int.tryParse(v);
                      return (y == null || y < 1990 || y > 2100)
                          ? 'Invalid year'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _color,
                    decoration: const InputDecoration(
                        labelText: 'Color'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Passenger seats',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton.outlined(
                  onPressed: _seats > 1
                      ? () => setState(() => _seats--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('$_seats',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                IconButton.outlined(
                  onPressed: _seats < 10
                      ? () => setState(() => _seats++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 20, color: AppTheme.warning),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Operations will review your application. '
                      'You can publish rides once approved.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<DriverBloc, DriverState>(
              builder: (context, state) {
                final busy = state is DriverApplying;
                return ElevatedButton(
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : const Text('Submit application'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
