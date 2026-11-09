// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Database ──────────
import 'package:bookbank/data/database.dart';

// ────────── Records Utils ──────────
import 'package:bookbank/features/records/utils/record_filter.dart';

/// Shows the record filter bottom sheet.
/// [onChanged] is called immediately whenever a filter option is selected.
void showRecordFilterSheet(
  BuildContext context, {
  required List<GroupSettings> groups,
  required RecordFilters currentFilters,
  required ValueChanged<RecordFilters> onChanged,
}) {
  final theme = Theme.of(context);
  final loc = Provider.of<LocalizationProvider>(
    context,
    listen: false,
  ).loc;

  RecordFilters filters = currentFilters;

  // ────────── Chip Widget ──────────
  Widget chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.onSurface,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: theme.colorScheme.outline),
      labelStyle: TextStyle(
        fontSize: 12.sp,
        color: selected
            ? theme.colorScheme.surface
            : theme.colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }

  // ────────── Helper Widgets ──────────
  Widget section(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: AppSize.s.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(spacing: 8.w, runSpacing: 8.h, children: chips),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ────────── Bottom Sheet ──────────
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          void select(RecordFilters newFilters) {
            filters = newFilters;
            onChanged(newFilters);
            setSheetState(() {});
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ────────── Sheet Header ──────────
                  Row(
                    children: [
                      Icon(
                        LucideIcons.filter,
                        size: 20.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                      SizedBox(width: 8.w),

                      Expanded(
                        child: Text(
                          loc.filter,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSize.m.sp,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(Icons.close, size: 20.sp),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ────────── Type Filter ──────────
                  section(loc.moneyPosition, [
                    chip(
                      label: loc.all,
                      selected: filters.type == RecordFilter.all,
                      onTap: () =>
                          select(filters.copyWith(type: RecordFilter.all)),
                    ),

                    chip(
                      label: loc.income,
                      selected: filters.type == RecordFilter.income,
                      onTap: () =>
                          select(filters.copyWith(type: RecordFilter.income)),
                    ),

                    chip(
                      label: loc.expense,
                      selected: filters.type == RecordFilter.expense,
                      onTap: () =>
                          select(filters.copyWith(type: RecordFilter.expense)),
                    ),

                    chip(
                      label: loc.transfer,
                      selected: filters.type == RecordFilter.transfer,
                      onTap: () =>
                          select(filters.copyWith(type: RecordFilter.transfer)),
                    ),
                  ]),

                  // ────────── Money List Filter ──────────
                  section(loc.moneyList, [
                    chip(
                      label: loc.all,
                      selected: filters.moneyList == null,
                      onTap: () =>
                          select(filters.copyWith(clearMoneyList: true)),
                    ),

                    chip(
                      label: loc.cash,
                      selected: filters.moneyList == 'cash',
                      onTap: () =>
                          select(filters.copyWith(moneyList: 'cash')),
                    ),

                    chip(
                      label: loc.bank,
                      selected: filters.moneyList == 'bank',
                      onTap: () =>
                          select(filters.copyWith(moneyList: 'bank')),
                    ),
                  ]),

                  // ────────── Category Filter ──────────
                  section(loc.category, [
                    chip(
                      label: loc.all,
                      selected: filters.category == null,
                      onTap: () =>
                          select(filters.copyWith(clearCategory: true)),
                    ),
                    ...groups.map(
                      (g) => chip(
                        label: g.groupName,
                        selected: filters.category == g.groupId,
                        onTap: () =>
                            select(filters.copyWith(category: g.groupId)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
