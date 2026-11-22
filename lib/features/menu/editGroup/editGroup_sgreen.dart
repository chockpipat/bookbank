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
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';
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

  // ────────── Delete Group ──────────
  Future<void> _deleteGroup(GroupSettings group) async {
    final loc = Provider.of<LocalizationProvider>(context, listen: false).loc;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(loc.confirmDelete),
        content: Text('${loc.delete} "${group.groupName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final groupProvider = Provider.of<GroupSettingsProvider>(
        context,
        listen: false,
      );
      await groupProvider.deleteGroupSettings(group);
      if (!mounted) return;
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
                return _SwipeableGroupTile(
                  group: group,
                  groupColor: Color(group.colorValue),
                  icon: _getIconFromCodePoint(group.iconCodePoint),
                  onEdit: () => _editGroup(group),
                  onDelete: () => _deleteGroup(group),
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

// ────────── Swipeable Group Tile ──────────
class _SwipeableGroupTile extends StatefulWidget {
  const _SwipeableGroupTile({
    required this.group,
    required this.groupColor,
    required this.icon,
    this.onEdit,
    this.onDelete,
  });

  final GroupSettings group;
  final Color groupColor;
  final IconData icon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_SwipeableGroupTile> createState() => _SwipeableGroupTileState();
}

class _SwipeableGroupTileState extends State<_SwipeableGroupTile> {
  // 0 = closed, 1 = fully open
  double _dragExtent = 0;
  static const double _actionsWidth = 168;

  // ────────── Drag Handlers ──────────
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = (_dragExtent - details.delta.dx / _actionsWidth.w).clamp(
        0.0,
        1.0,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      final velocity = details.velocity.pixelsPerSecond.dx;
      _dragExtent = (_dragExtent > 0.5 || velocity < -300) ? 1.0 : 0.0;
    });
  }

  void _close() {
    if (_dragExtent != 0) {
      setState(() => _dragExtent = 0);
    }
  }

  // ────────── Action Button Builder ──────────
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _close();
          onTap?.call();
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: label == 'Delete'
                ? BorderRadius.only(
                    topRight: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationProvider>().loc;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        children: [
          // ────────── Background actions (revealed on swipe) ──────────
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _actionsWidth.w,
                height: double.infinity,
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: LucideIcons.pencil,
                      label: loc.edit,
                      color: theme.colorScheme.primary,
                      onTap: widget.onEdit,
                    ),
                    _buildActionButton(
                      icon: LucideIcons.trash2,
                      label: loc.delete,
                      color: Colors.red,
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),

          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTap: _close,
            child: Transform.translate(
              offset: Offset(-_dragExtent * _actionsWidth.w, 0),
              child: Container(
                width: double.infinity,
                height: 60.h,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: widget.groupColor),
                      color: widget.groupColor.withValues(alpha: 0.3),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.groupColor,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    widget.group.groupName,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
