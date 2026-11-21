import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/localization_provider.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

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
        title: Text(loc.privacyPolicyTitle, style: TextStyle(fontSize: 14.sp)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.shieldKeyhole,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(loc.privacyPolicyTitle),
              ],
            ),
            SizedBox(height: 16.h),

            Text(
              loc.privacyPolicyContent,
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
