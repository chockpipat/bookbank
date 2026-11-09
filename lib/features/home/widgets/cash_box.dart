// ────────── Packages & provider ──────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────── Theme & Localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ─────────── Drag data ──────────
import 'package:bookbank/features/home/widgets/group_card.dart';

class UnallocatedSummary extends StatefulWidget {
  final double unallocatedAmount;

  final void Function(GroupDragData source)? onTransferDrop;

  const UnallocatedSummary({
    super.key,
    required this.unallocatedAmount,
    this.onTransferDrop,
  });

  @override
  State<UnallocatedSummary> createState() => _UnallocatedSummaryState();
}

class _UnallocatedSummaryState extends State<UnallocatedSummary>
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

  static const String cashBoxGroupId = 'CashBox';

  GroupDragData get _dragData => GroupDragData(
    groupId: cashBoxGroupId,
    groupName: 'Cash Box',
    groupColor: Colors.amber,
    groupIcon: LucideIcons.box,
    groupAmount: widget.unallocatedAmount,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    return LongPressDraggable<GroupDragData>(
      data: _dragData,
      delay: const Duration(milliseconds: 350),
      onDragStarted: () {
        HapticFeedback.mediumImpact();
      },

      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.06,
          child: Container(
            width: MediaQuery.of(context).size.width - 48.w,
            height: 65.h,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.cashBox,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.xs.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 4.h),

                Text(
                  locProvider.formatAmount(widget.unallocatedAmount),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sm.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      childWhenDragging: Opacity(
        opacity: 0.25,
        child: _buildCardShell(
          theme,
          textTheme,
          locProvider,
          isHovering: false,
        ),
      ),

      child: DragTarget<GroupDragData>(
        onWillAcceptWithDetails: (details) {
          return details.data.groupId != cashBoxGroupId;
        },

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
          final hovering = _isHovering || candidateData.isNotEmpty;
          return GestureDetector(
            onTap: () {},
            child: _buildCardShell(
              theme,
              textTheme,
              locProvider,
              isHovering: hovering,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardShell(
    ThemeData theme,
    TextTheme textTheme,
    LocalizationProvider locProvider, {
    required bool isHovering,
  }) {
    final loc = locProvider.loc;

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 65.h,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.cashBox,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: AppSize.xs.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                locProvider.formatAmount(widget.unallocatedAmount),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: AppSize.sm.sp,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
