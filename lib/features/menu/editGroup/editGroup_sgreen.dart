import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';
import 'package:bookbank/features/menu/editGroup/group_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

class EditGroupSgreen extends StatefulWidget {
  const EditGroupSgreen({super.key});

  @override
  State<EditGroupSgreen> createState() => _EditGroupSgreenState();
}

class _EditGroupSgreenState extends State<EditGroupSgreen> {
  List<GroupSettings> _groupSettings = [];
  bool _isLoading = true;
  bool _hasError = false;

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

  IconData _getIconFromCodePoint(int codePoint) {
    return _availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.add,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadGroupSettings();
  }

  Future<void> _loadGroupSettings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final settings = await DatabaseHelper.instance.getAllGroupSettings();
      if (!mounted) return;
      setState(() {
        _groupSettings = settings;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _editGroup(GroupSettings settings) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          Dialog(child: GroupEditDialog(groupSettings: settings)),
    );
    if (result == true) {
      await _loadGroupSettings();
    }
  }

  Future<void> _addGroup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: GroupEditDialog(
          isNew: true,
          groupSettings: GroupSettings(
            groupId: '',
            groupName: '',
            iconCodePoint: Icons.add.codePoint,
            colorValue: const Color(0xFF2196F3).toARGB32(),
            savingsGoalEnabled: false,
            savingsGoalAmount: 0,
          ),
        ),
      ),
    );
    if (result == true) {
      await _loadGroupSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationProvider>().loc;
    return Container(
      width: 400,
      constraints: BoxConstraints(maxHeight: 500),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.colorScheme.surfaceDim),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: AppSize.l),
              SizedBox(width: 8),
              Text(loc.editGroup, style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          SizedBox(height: 16),

          // Group List
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_hasError)
            Flexible(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.databaseX,
                      size: 48.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 12),

                    Text(
                      loc.loadFailed,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSize.m,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    TextButton.icon(
                      onPressed: _loadGroupSettings,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                      icon: Icon(LucideIcons.refreshCw, size: 16.sp),
                      label: Text(loc.retry),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _groupSettings.length,
                itemBuilder: (context, index) {
                  final group = _groupSettings[index];
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(5),
                      border: Border(
                        bottom: index == _groupSettings.length - 1
                            ? BorderSide.none
                            : BorderSide(
                                color: AppColors.grey.withValues(alpha: 0.3),
                                width: 1,
                              ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color(group.colorValue)),
                            color: Color(
                              group.colorValue,
                            ).withValues(alpha: 0.3),
                          ),
                          child: Icon(
                            _getIconFromCodePoint(group.iconCodePoint),
                            color: Color(group.colorValue),
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 16),

                        // Group Name
                        Expanded(
                          child: Text(
                            group.groupName,
                            style: TextStyle(
                              fontSize: AppSize.m,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Edit Button
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.grey),
                          onPressed: () => _editGroup(group),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Add Group Button
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: OutlinedButton.icon(
              onPressed: _addGroup,
              icon: Icon(Icons.add, size: 18.sp),
              label: Text(loc.addCategory),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(color: theme.colorScheme.onSurfaceVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, 40.h),
              foregroundColor: theme.scaffoldBackgroundColor,
              backgroundColor: theme.colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.r),
              ),
            ),
            child: Text(loc.cancel),
          ),
        ],
      ),
    );
  }
}
