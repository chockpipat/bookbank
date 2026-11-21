// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Database ──────────
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/menu/editGroup/group_edit_dialog.dart';
import 'package:bookbank/Widgets/hasError.dart';
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

  // ────────── Get Icon from Code Point ──────────
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

  // ────────── Load Group Settings ──────────
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

  // ────────── Edit Group ──────────
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

  // ────────── Add Group ──────────
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.chevronLeft, size: 28.sp),
        ),
        title: Text(
          loc.editGroup,
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
              child: Haserror(loadData: _loadGroupSettings),
            )
          : _groupSettings.isEmpty
          ? Center(
              child: Text(
                loc.noCategory,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 100.h),
              itemCount: _groupSettings.length,
              itemBuilder: (context, index) {
                final group = _groupSettings[index];
                final groupColor = Color(group.colorValue);
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: groupColor),
                        color: groupColor.withValues(alpha: 0.3),
                      ),
                      child: Icon(
                        _getIconFromCodePoint(group.iconCodePoint),
                        color: groupColor,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      group.groupName,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    trailing: IconButton(
                      onPressed: () => _editGroup(group),
                      icon: Icon(
                        LucideIcons.pencil,
                        size: 18.sp,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGroup,
        backgroundColor: theme.colorScheme.onSurface,
        foregroundColor: theme.colorScheme.surface,
        child: Icon(LucideIcons.plus, size: 24.sp),
      ),
    );
  }
}
