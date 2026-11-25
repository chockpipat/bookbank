import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScanAuthorization extends StatefulWidget {
  const ScanAuthorization({super.key});

  @override
  State<ScanAuthorization> createState() => _ScanAuthorizationState();
}

class _ScanAuthorizationState extends State<ScanAuthorization> {
  String _selectedScanTest = 'Custom';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (final level in ['Allow', 'Custom']) ...[
          Expanded(
            child: FilledButton(
              onPressed: () {
                setState(() {
                  _selectedScanTest = level;
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: _selectedScanTest == level
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.surface,
                foregroundColor: _selectedScanTest == level
                    ? theme.colorScheme.surface
                    : theme.colorScheme.onSurface,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
              child: Text(level, style: TextStyle(fontSize: 12.sp)),
            ),
          ),
          if (level != 'Custom') SizedBox(width: 12.w),
        ],
      ],
    );
  }
}
