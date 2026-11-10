import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/data/database.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

class GroupEditDialog extends StatefulWidget {
  final GroupSettings groupSettings;
  final bool isNew;

  const GroupEditDialog({
    super.key,
    required this.groupSettings,
    this.isNew = false,
  });

  @override
  State<GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<GroupEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late bool _savingsGoalEnabled;

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

  final List<Color> _availableColors = [
    const Color.fromARGB(255, 2, 140, 253),
    const Color.fromARGB(255, 5, 223, 13),
    const Color.fromARGB(255, 217, 0, 255),
    const Color.fromARGB(255, 255, 0, 85),
    Colors.red,
    const Color.fromARGB(255, 255, 115, 0),
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.groupSettings.groupName,
    );
    _amountController = TextEditingController(
      text: widget.groupSettings.savingsGoalAmount.toStringAsFixed(2),
    );
    // Find the icon from the available list that matches the codePoint
    _selectedIcon = _availableIcons.firstWhere(
      (icon) => icon.codePoint == widget.groupSettings.iconCodePoint,
      orElse: () => Icons.add,
    );
    _selectedColor = Color(widget.groupSettings.colorValue);
    _savingsGoalEnabled = widget.groupSettings.savingsGoalEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_nameController.text.trim().isEmpty) return;

    final updatedSettings = GroupSettings(
      id: widget.groupSettings.id,
      groupId: widget.groupSettings.groupId,
      groupName: _nameController.text.trim(),
      iconCodePoint: _selectedIcon.codePoint,
      colorValue: _selectedColor.toARGB32(),
      savingsGoalEnabled: _savingsGoalEnabled,
      savingsGoalAmount: _savingsGoalEnabled
          ? double.tryParse(_amountController.text) ?? 0
          : 0,
    );

    // Notify provider to refresh group settings across all screens
    if (mounted) {
      final groupProvider = Provider.of<GroupSettingsProvider>(
        context,
        listen: false,
      );
      if (widget.isNew) {
        await groupProvider.addGroup(
          groupName: _nameController.text.trim(),
          iconCodePoint: _selectedIcon.codePoint,
          colorValue: _selectedColor.toARGB32(),
          savingsGoalEnabled: _savingsGoalEnabled,
          savingsGoalAmount: _savingsGoalEnabled
              ? double.tryParse(_amountController.text) ?? 0
              : 0,
        );
      } else {
        await groupProvider.updateGroupSettings(updatedSettings);
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationProvider>().loc;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final locProvider = Provider.of<LocalizationProvider>(context);

    return Container(
      width: 400,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.onSurfaceVariant),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: 24 + keyboardHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: AppColors.grey),
                ),
              ],
            ),

            Text(
              widget.isNew ? '${loc.add} ${loc.group}' : loc.editGroup,
              style: TextStyle(
                fontSize: AppSize.l,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),

            // ──────────Group Name ────────── 
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              style: TextStyle(height: 1.5, fontSize: AppSize.m),
            ),
            SizedBox(height: 16),

            // ────────── Icon Selection ──────────
            Text(loc.icon, style: TextStyle(fontSize: AppSize.xs.sp)),
            SizedBox(height: 8),
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon.codePoint == _selectedIcon.codePoint;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.3)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : theme.colorScheme.onSurfaceVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(icon, color: _selectedColor, size: 16),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Color Selection
            Text(loc.color, style: TextStyle(fontSize: AppSize.xs.sp)),
            SizedBox(height: 8),
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected =
                      color.toARGB32() == _selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.grey
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Savings Goal Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.enableSavingsGoal,
                  style: TextStyle(fontSize: AppSize.xs.sp),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _savingsGoalEnabled,
                    onChanged: (value) {
                      setState(() {
                        _savingsGoalEnabled = value;
                      });
                    },
                    activeThumbColor: _selectedColor,
                    inactiveTrackColor: theme.colorScheme.surface,
                    trackOutlineColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return _selectedColor;
                      }
                      return theme.colorScheme.onSurfaceVariant;
                    }),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return _selectedColor;
                      }
                      return theme.colorScheme.onSurfaceVariant;
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Savings Goal Amount
            if (_savingsGoalEnabled) ...[
              Text(
                loc.savingsGoalAmount,
                style: TextStyle(
                  fontSize: AppSize.xs.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '${locProvider.currencySymbol} ',
                  prefixStyle: TextStyle(color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                style: TextStyle(fontSize: AppSize.m, height: 1.2),
              ),
              SizedBox(height: 16),
            ],

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc.save,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
