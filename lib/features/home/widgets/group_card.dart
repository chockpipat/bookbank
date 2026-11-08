import 'package:bookbank/data/database.dart';
import 'package:bookbank/features/home/popup/popup_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

/// Data class ส่งระหว่าง Draggable source → DragTarget
class GroupDragData {
  final String groupId;
  final String groupName;
  final Color groupColor;
  final IconData groupIcon;
  final double groupAmount;

  const GroupDragData({
    required this.groupId,
    required this.groupName,
    required this.groupColor,
    required this.groupIcon,
    required this.groupAmount,
  });
}

class GroupCard extends StatefulWidget {
  final String groupName;
  final String groupId;
  final int groupCount;
  final double groupAmount;
  final Color groupColor;
  final IconData groupIcon;
  final List<MyData> transactions;
  final double percentage;
  final bool savingsGoalEnabled;
  final double savingsGoalAmount;

  /// Callback เมื่อมีการ drop GroupDragData มาที่การ์ดนี้
  final void Function(GroupDragData source)? onTransferDrop;

  const GroupCard({
    super.key,
    required this.groupName,
    required this.groupId,
    required this.groupCount,
    required this.groupAmount,
    required this.groupColor,
    required this.groupIcon,
    required this.transactions,
    required this.percentage,
    this.savingsGoalEnabled = false,
    this.savingsGoalAmount = 0,
    this.onTransferDrop,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  GroupDragData get _dragData => GroupDragData(
    groupId: widget.groupId,
    groupName: widget.groupName,
    groupColor: widget.groupColor,
    groupIcon: widget.groupIcon,
    groupAmount: widget.groupAmount,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);

    final cardContent = _CardContent(
      theme: theme,
      locProvider: locProvider,
      groupName: widget.groupName,
      groupAmount: widget.groupAmount,
      groupColor: widget.groupColor,
      groupIcon: widget.groupIcon,
      savingsGoalEnabled: widget.savingsGoalEnabled,
      savingsGoalAmount: widget.savingsGoalAmount,
    );

    return LongPressDraggable<GroupDragData>(
      data: _dragData,
      delay: const Duration(milliseconds: 350),
      onDragStarted: () {
        HapticFeedback.mediumImpact();
      },

      // ────────── Feedback (floating card) ──────────
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.06,
          child: Container(
            height: 140.h,
            width: MediaQuery.of(context).size.width / 2 - 30.w,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: widget.groupColor.withValues(alpha: 0.8),
                width: 2,
              ),
            ),
            child: cardContent,
          ),
        ),
      ),

      // ────────── Child When Dragging ──────────
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: _buildCardShell(theme, locProvider, isHovering: false),
      ),
      child: DragTarget<GroupDragData>(
        onWillAcceptWithDetails: (details) {
          return details.data.groupId != widget.groupId;
        },

        // On Accept With Details
        onAcceptWithDetails: (details) {
          setState(() => _isHovering = false);
          HapticFeedback.lightImpact();
          widget.onTransferDrop?.call(details.data);
        },

        onMove: (details) {
          if (!_isHovering) setState(() => _isHovering = true);
        },

        onLeave: (_) {
          if (_isHovering) setState(() => _isHovering = false);
        },

        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return Dialog(
                    child: PopupGroup(
                      groupName: widget.groupName,
                      groupId: widget.groupId,
                      groupColor: widget.groupColor,
                      transactions: widget.transactions,
                      icon: widget.groupIcon,
                      percentage: widget.percentage,
                      savingsGoalAmount: widget.savingsGoalAmount,
                      savingsGoalEnabled: widget.savingsGoalEnabled,
                      groupAmount: widget.groupAmount,
                    ),
                  );
                },
              );
            },
            child: _buildCardShell(
              theme,
              locProvider,
              isHovering: _isHovering || candidateData.isNotEmpty,
            ),
          );
        },
      ),
    );
  }

  // ────────── Build Card Shell ──────────
  Widget _buildCardShell(
    ThemeData theme,
    LocalizationProvider locProvider, {
    required bool isHovering,
  }) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: (widget.savingsGoalEnabled && widget.savingsGoalAmount > 0)
              ? 130.h
              : 115.h,
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: _CardContent(
            theme: theme,
            locProvider: locProvider,
            groupName: widget.groupName,
            groupAmount: widget.groupAmount,
            groupColor: widget.groupColor,
            groupIcon: widget.groupIcon,
            savingsGoalEnabled: widget.savingsGoalEnabled,
            savingsGoalAmount: widget.savingsGoalAmount,
          ),
        );
      },
    );
  }
}

// ────────── Card Content (shared between normal & feedback) ──────────

class _CardContent extends StatelessWidget {
  final ThemeData theme;
  final LocalizationProvider locProvider;
  final String groupName;
  final double groupAmount;
  final Color groupColor;
  final IconData groupIcon;
  final bool savingsGoalEnabled;
  final double savingsGoalAmount;

  const _CardContent({
    required this.theme,
    required this.locProvider,
    required this.groupName,
    required this.groupAmount,
    required this.groupColor,
    required this.groupIcon,
    required this.savingsGoalEnabled,
    required this.savingsGoalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45.w,
              height: 45.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.r),
                border: Border.all(color: groupColor),
                color: groupColor.withValues(alpha: 0.3),
              ),
              child: Icon(groupIcon, color: groupColor, size: 22.sp),
            ),
            Icon(
              Icons.arrow_outward_sharp,
              size: 20.sp,
              color: theme.colorScheme.outline,
            ),
          ],
        ),

        Text(
          groupName,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: AppSize.xs.sp,
          ),
        ),

        Row(
          children: [
            Text(
              locProvider.formatAmount(groupAmount),
              style: TextStyle(
                fontSize: AppSize.m.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),

            if (savingsGoalEnabled && savingsGoalAmount > 0) ...[
              Text(
                locProvider.formatAmount(savingsGoalAmount),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ],
        ),

        if (savingsGoalEnabled && savingsGoalAmount > 0) ...[
          SizedBox(height: 8.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: (groupAmount / savingsGoalAmount).clamp(0.0, 1.0),
                  backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(groupColor),
                  minHeight: 4.h,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
