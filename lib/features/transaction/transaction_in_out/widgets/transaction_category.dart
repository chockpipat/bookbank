import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';

// ────────── Main Widget ──────────
class TransactionCategory extends StatefulWidget {
  const TransactionCategory({super.key});

  @override
  State<TransactionCategory> createState() => _TransactionCategoryState();
}

// ────────── Category Button Widget ──────────
class _CategoryButton extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  const _CategoryButton({
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }
}

// ────────── State Class ──────────
class _TransactionCategoryState extends State<TransactionCategory> {
  String? _selectedCategory;

  final List<IconData> _availableIcons = [
    Icons.shopping_cart_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.flight_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.sports_soccer_rounded,
    Icons.health_and_safety_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.bar_chart_rounded,
    Icons.fastfood_rounded,
    Icons.coffee_rounded,
    Icons.card_giftcard_rounded,
    Icons.celebration_rounded,
    Icons.favorite_rounded,
    Icons.fitness_center_rounded,
    Icons.filter_hdr_rounded,
    Icons.handyman_outlined,
  ];

  // ────────── Helper Methods ──────────
  IconData _getIconFromCodePoint(int codePoint) {
    return _availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.add,
    );
  }

  // ────────── State Management Methods ──────────
  void _toggleCategory(String categoryId) {
    setState(() {
      _selectedCategory = _selectedCategory == categoryId ? null : categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;
    final theme = Theme.of(context);

    return Consumer<GroupSettingsProvider>(
      builder: (context, groupProvider, child) {
        final groups = groupProvider.groupSettings;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.category,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 8.h),

            // ────────── Empty State ──────────
            if (groups.isEmpty)
              SizedBox(
                height: 100.h,
                child: Center(
                  child: Text(
                    loc.addCategory,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              // ────────── Category Buttons ──────────
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: groups.map((group) {
                  final color = group.colorValue != 0
                      ? Color(group.colorValue)
                      : theme.colorScheme.primary;
                  return _CategoryButton(
                    categoryName: group.groupName,
                    icon: _getIconFromCodePoint(group.iconCodePoint),
                    color: color,
                    isSelected: _selectedCategory == group.groupId,
                    onPressed: () => _toggleCategory(group.groupId),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}
