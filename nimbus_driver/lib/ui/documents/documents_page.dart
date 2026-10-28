import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../network/backend_mapper.dart';
import '../../services/driver_service.dart';
import '../../widgets/state_views.dart';

/// Driver documents — license, registration and vehicle papers.
///
/// Files are captured from the camera or photo library and uploaded
/// directly; the backend stores them outside the web root and exposes an
/// ownership-checked download URL.
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late Future<List<DriverDocument>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DriverService>().getDocuments();
  }

  void _reload() {
    setState(() => _future = context.read<DriverService>().getDocuments());
  }

  Future<void> _addDocument() async {
    final service = context.read<DriverService>();
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddDocumentSheet(service: service),
    );
    if (created == true) {
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded — verification is pending'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add document',
            onPressed: _addDocument,
          ),
        ],
      ),
      body: FutureBuilder<List<DriverDocument>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final docs = snapshot.data ?? const <DriverDocument>[];
          if (docs.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              title: 'No documents yet',
              subtitle:
                  'Add your license and vehicle papers so operations '
                  'can verify your application.',
              actionLabel: 'Add document',
              onAction: _addDocument,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _VerificationNotice(),
                const SizedBox(height: 8),
                ...docs.map((d) => _DocumentCard(document: d)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDocument,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add document'),
      ),
    );
  }
}

class _VerificationNotice extends StatelessWidget {
  const _VerificationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: AppTheme.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Take a clear photo of the whole document. Make sure the '
              'number and expiry date are readable. Operations reviews '
              'uploads before you can publish rides.',
              style: TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DriverDocument document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final status = (document.status ?? 'PENDING').toUpperCase();
    final color = _statusColor(status);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(_statusIcon(status), color: color, size: 22),
        ),
        title: Text(
          statusLabel(document.documentType),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          [
            document.documentNumber ?? 'No number on file',
            if (document.expiresAt != null)
              'Expires ${_date(document.expiresAt!)}',
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusLabel(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return AppTheme.success;
      case 'REJECTED':
        return AppTheme.error;
      case 'EXPIRED':
        return AppTheme.warning;
      default:
        return AppTheme.warning;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return Icons.verified_outlined;
      case 'REJECTED':
        return Icons.error_outline;
      case 'EXPIRED':
        return Icons.event_busy_outlined;
      default:
        return Icons.hourglass_top;
    }
  }

  static String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
}

class _AddDocumentSheet extends StatefulWidget {
  final DriverService service;

  const _AddDocumentSheet({required this.service});

  @override
  State<_AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends State<_AddDocumentSheet> {
  static const _types = <String, String>{
    'DRIVER_LICENSE': 'Driving license',
    'NATIONAL_ID': 'National ID (NID)',
    'VEHICLE_REGISTRATION': 'Vehicle registration',
    'INSURANCE': 'Insurance',
    'ROAD_PERMIT': 'Road permit',
    'OTHER': 'Other',
  };

  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _picker = ImagePicker();
  String _type = 'DRIVER_LICENSE';
  DateTime? _expiresAt;
  XFile? _file;
  bool _uploading = false;
  double _progress = 0;
  String? _error;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 2400,
      );
      if (picked != null) {
        setState(() {
          _file = picked;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Could not open the camera or gallery: $e');
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
      helpText: 'Document expiry date',
    );
    if (date != null) setState(() => _expiresAt = date);
  }

  Future<void> _submit() async {
    if (_uploading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_file == null) {
      setState(() => _error = 'Choose a photo of the document first.');
      return;
    }
    setState(() {
      _uploading = true;
      _progress = 0;
      _error = null;
    });
    try {
      await widget.service.uploadDocument(
            filePath: _file!.path,
            documentType: _type,
            documentNumber: _number.text.trim(),
            expiresAt: _expiresAt,
            onProgress: (sent, total) {
              if (!mounted || total <= 0) return;
              setState(() => _progress = sent / total);
            },
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add document',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Upload a photo from your camera or gallery.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.muted(context),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Document type'),
                items: _types.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: _uploading
                    ? null
                    : (value) {
                        if (value != null) setState(() => _type = value);
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _number,
                enabled: !_uploading,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Document number',
                  hintText: 'As printed on the document',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Document number is required'
                    : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _uploading ? null : _pickExpiry,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry date (optional)',
                    suffixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(
                    _expiresAt == null
                        ? 'Not set'
                        : '${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}',
                    style: TextStyle(
                      color: _expiresAt == null
                          ? AppTheme.muted(context)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FilePicker(
                fileName: _file?.name,
                enabled: !_uploading,
                onCamera: () => _pick(ImageSource.camera),
                onGallery: () => _pick(ImageSource.gallery),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppTheme.error, fontSize: 13),
                ),
              ],
              if (_uploading) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _progress > 0
                      ? 'Uploading ${(_progress * 100).round()}%'
                      : 'Uploading…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.muted(context),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploading ? null : _submit,
                child: Text(_uploading ? 'Uploading…' : 'Upload document'),
              ),
              TextButton(
                onPressed: _uploading
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilePicker extends StatelessWidget {
  final String? fileName;
  final bool enabled;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _FilePicker({
    required this.fileName,
    required this.enabled,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: fileName == null
              ? Theme.of(context).colorScheme.outline.withOpacity(0.4)
              : AppTheme.success,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                fileName == null
                    ? Icons.upload_file_outlined
                    : Icons.check_circle_outline,
                color: fileName == null ? null : AppTheme.success,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName ?? 'No file selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: enabled ? onCamera : null,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: enabled ? onGallery : null,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
