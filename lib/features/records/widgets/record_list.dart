import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/localization_provider.dart';
import '../../../data/database.dart';
import '../../menu/editGroup/providers/group_settings_provider.dart';
import '../utils/record_utils.dart';

// ────────── Record List Item (swipeable card) ──────────
class RecordListItem extends StatefulWidget {
  const RecordListItem({
    super.key,
    required this.item,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.showDateHeader = true,
    this.onTap,
    this.onLongPress,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  final MyData item;
  final bool isMultiSelectMode;
  final bool isSelected;
  final bool showDateHeader;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<RecordListItem> createState() => _RecordListItemState();
}

class _RecordListItemState extends State<RecordListItem> {
  // 0 = closed, 1 = fully open
  double _dragExtent = 0;
  static const double _actionsWidth = 168;

  MyData get item => widget.item;

  // ────────── Drag Handlers ──────────
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.isMultiSelectMode) return;
    setState(() {
      _dragExtent = (_dragExtent - details.delta.dx / _actionsWidth).clamp(
        0.0,
        1.0,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.isMultiSelectMode) return;
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
          color: color.withValues(alpha: 0.15),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18.sp),
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

  // ────────── Date Header ──────────
  String _formatHeaderDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      return DateFormat(
        'dd-MM-yyyy',
      ).format(DateFormat('yyyy-MM-dd').parse(date));
    } catch (_) {
      return date;
    }
  }

  // ────────── Labels ──────────
  String _groupName(String groupId) {
    return context
            .read<GroupSettingsProvider>()
            .getGroupSettings(groupId)
            ?.groupName ??
        groupId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;
    final isTransfer = item.moneyType == 'transfer';
    final isIncome = item.moneyType == 'income';

    final typeColor = isTransfer
        ? Colors.amber
        : (isIncome
              ? const Color.fromARGB(255, 33, 175, 38)
              : const Color.fromARGB(255, 255, 17, 0));

    // Group transfer: moneyList = source groupId, moneyGroup = target groupId
    // Legacy bank/cash transfer: moneyList and moneyGroup are 'bank' or 'cash'
    final isGroupTransfer =
        isTransfer && item.moneyList != 'bank' && item.moneyList != 'cash';
    final fromLabel = item.moneyList == 'bank' ? loc.bank : loc.cash;
    final toLabel = item.moneyGroup == 'bank' ? loc.bank : loc.cash;

    // ────────── Position chip label ──────────
    final String positionLabel;
    if (isTransfer) {
      positionLabel = isGroupTransfer
          ? '${_groupName(item.moneyList)} → ${_groupName(item.moneyGroup)}'
          : '$fromLabel → $toLabel';
    } else {
      positionLabel = item.moneyList == 'bank' ? loc.bank : loc.cash;
    }

    // ────────── Group chip label ──────────
    final String groupLabel;
    if (isTransfer) {
      groupLabel = loc.transferMoney;
    } else {
      groupLabel = _groupName(item.moneyGroup);
    }

    // ────────── Title ──────────
    final String title = isTransfer
        ? loc.alternate
        : (item.title == 'Anonymous' ? loc.anonymous : (item.title ?? ''));

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.showDateHeader ? 5 : 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showDateHeader)
              Text(
                _formatHeaderDate(item.date),
                style: TextStyle(fontSize: 12.sp),
              ),

            // ────────── Card with swipe actions ──────────
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                children: [
                  // ────────── Background actions (revealed on swipe) ──────────
                  if (!widget.isMultiSelectMode)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: _actionsWidth.w,
                          child: Row(
                            children: [
                              // Edit (not available for transfers)
                              if (!isTransfer)
                                _buildActionButton(
                                  icon: LucideIcons.pencil,
                                  label: loc.edit,
                                  color: theme.colorScheme.primary,
                                  onTap: widget.onEdit,
                                ),

                              // Delete
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
                    onTap: () {
                      _close();
                      widget.onTap?.call();
                    },
                    child: Transform.translate(
                      offset: Offset(-_dragExtent * _actionsWidth.w, 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: widget.isSelected
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                )
                              : theme.colorScheme.surface,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ────────── Leading: checkbox or type icon ──────────
                              if (widget.isMultiSelectMode)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 6.h,
                                  ),
                                  child: Icon(
                                    widget.isSelected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 24.sp,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                )
                              else ...[
                                Container(
                                  height: 35.h,
                                  width: 35.w,
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.3),
                                    border: Border.all(
                                      color: typeColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(50.r),
                                  ),
                                  child: Icon(
                                    isIncome
                                        ? Icons.trending_up
                                        : isTransfer
                                        ? Icons.swap_horiz
                                        : Icons.trending_down,
                                    color: typeColor,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                              ],

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ────────── Title & Amount ──────────
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),

                                        Text(
                                          locProvider.formatAmount(
                                            item.amount.toDouble(),
                                          ),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),

                                    // ────────── Chips: position & group ──────────
                                    Row(
                                      children: [
                                        _buildChip(theme, positionLabel),
                                        SizedBox(width: 8.w),

                                        Flexible(
                                          child: _buildChip(theme, groupLabel),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),

                                    Divider(color: theme.colorScheme.outline),
                                    SizedBox(height: 4.h),

                                    // ────────── Date ──────────
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatDisplayDate(item.date),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────── Chip Builder ──────────
  Widget _buildChip(ThemeData theme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceDim,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Flexible(
        child: Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: theme.colorScheme.onSurface),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
