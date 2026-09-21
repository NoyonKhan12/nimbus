import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// A reusable widget for picking a location (origin or destination).
class LocationPicker extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  const LocationPicker({
    super.key,
    required this.hintText,
    required this.icon,
    this.onTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outline, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: controller != null
                  ? TextField(
                      controller: controller,
                      readOnly: onTap != null,
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    )
                  : Text(
                      hintText,
                      style: const TextStyle(color: Colors.grey),
                    ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
