// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ────────── Theme & Providers ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/data/database.dart';

// ────────── Feature Widgets ──────────
import 'package:bookbank/features/add_transaction/widgets/list_button.dart';

// ────────── Category Selector Widget ──────────
class CategorySelector extends StatelessWidget {
  final String? selectedGroup;
  final ValueChanged<String?> onChanged;
  final List<GroupSettings> groups;

  const CategorySelector({
    super.key,
    required this.selectedGroup,
    required this.onChanged,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = Provider.of<LocalizationProvider>(context).loc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ────────── Label ──────────
        Text(
          loc.category,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: AppSize.xs.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        // ────────── Category selection grid ──────────
        if (groups.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.onSurfaceVariant),
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.surface,
            ),
            child: Text(
              '${loc.add} ${loc.group}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.xs.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
        Container(
          padding: EdgeInsets.symmetric(vertical: 3.w),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.onSurfaceVariant),
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.surface,
          ),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: groups.map((group) {
              return ListButton(
                buttonKey: group.groupId,
                titel: group.groupName,
                onKey: selectedGroup,
                function: () {
                  onChanged(
                    selectedGroup == group.groupId ? null : group.groupId,
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
