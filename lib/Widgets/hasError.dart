import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/localization_provider.dart';

class Haserror extends StatelessWidget {
  final VoidCallback _loadData;
  const Haserror({super.key, required this._loadData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.read<LocalizationProvider>().loc;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              LucideIcons.databaseX,
              size: 34.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              loc.loadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          FilledButton.icon(
            onPressed: _loadData,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: theme.colorScheme.onSurface,
            ),
            icon: Icon(LucideIcons.refreshCw),
            label: Text(loc.retry, style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }
}
