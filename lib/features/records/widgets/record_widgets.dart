// ────────── Imports ──────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ────────── Theme ──────────
import '../../../core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Functions ──────────
import '../utils/record_filter.dart';

// ────────── Detail Row Widget ──────────
Widget buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontSize: AppSize.s, color: AppColors.grey),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: AppSize.s)),
        ),
      ],
    ),
  );
}

// ────────── Filter Tab Widget ──────────
Widget buildFilterTab({
  required BuildContext context,
  required RecordFilter value,
  required RecordFilter selectedFilter,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  final isSelected = selectedFilter == value;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Icon(icon, size: AppSize.s, color: theme.colorScheme.surface),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: AppSize.xs,
                color: isSelected ? theme.colorScheme.surface : AppColors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ────────── Record List View Widget ──────────
Widget recondListView(IconData icon, String title, String data) {
  return Row(
    children: [
      Icon(icon, size: AppSize.xl),
      const SizedBox(width: 8),
      Text(
        '$title :',
        style: TextStyle(fontSize: AppSize.s, color: AppColors.grey),
      ),
      const SizedBox(width: 8),
      Text(data),
    ],
  );
}

// ────────── Menu item widgets ──────────
class ViewMenuItem extends StatelessWidget {
  const ViewMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>().loc;
    return Text(loc.view);
  }
}

class EditMenuItem extends StatelessWidget {
  const EditMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>().loc;
    return Text(loc.edit);
  }
}

class DeleteMenuItem extends StatelessWidget {
  const DeleteMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>().loc;
    return Text(loc.delete);
  }
}
