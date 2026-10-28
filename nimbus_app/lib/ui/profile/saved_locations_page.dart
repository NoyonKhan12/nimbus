import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../dto/user_dtos.dart';
import '../../widgets/location_entry_sheet.dart';
import '../../widgets/state_views.dart';

/// Saved locations (home, work, ...) backed by `/me/locations`.
class SavedLocationsPage extends StatefulWidget {
  const SavedLocationsPage({super.key});

  @override
  State<SavedLocationsPage> createState() => _SavedLocationsPageState();
}

class _SavedLocationsPageState extends State<SavedLocationsPage> {
  Future<void> _add() async {
    final location = await LocationEntrySheet.show(
      context,
      'New saved location',
    );
    if (location == null || !mounted) return;

    final labelController = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Label this place'),
        content: TextField(
          controller: labelController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Home, Office, Gym',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx)
                .pop(labelController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (label == null || label.isEmpty || !mounted) return;

    context.read<ProfileBloc>().add(ProfileSavedLocationAdded(
          label: label,
          address: location.address ?? label,
          latitude: location.latitude,
          longitude: location.longitude,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add location',
            onPressed: _add,
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          List<SavedLocation> locations = const [];
          if (state is ProfileLoaded) locations = state.savedLocations;
          if (state is ProfileSaving) locations = state.savedLocations;
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (locations.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border,
              title: 'No saved locations',
              subtitle: 'Save Home or Office for quicker booking.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: locations
                .map((l) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppTheme.secondary.withOpacity(0.12),
                          child: Icon(
                            _iconFor(l.label),
                            size: 20,
                            color: AppTheme.secondary,
                          ),
                        ),
                        title: Text(
                          l.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: Text(
                          l.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('home')) return Icons.home;
    if (l.contains('office') || l.contains('work')) return Icons.work;
    return Icons.place;
  }
}
