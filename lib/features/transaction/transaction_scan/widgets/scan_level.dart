import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScanLevel extends StatefulWidget {
  const ScanLevel({super.key});

  @override
  State<ScanLevel> createState() => _ScanLevelState();
}

class _ScanLevelState extends State<ScanLevel> {
  String _selectedScanLevel = 'Medium';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ────────── Scan level options ──────────
        Row(
          children: [
            for (final level in ['Low', 'Medium', 'High']) ...[
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _selectedScanLevel = level;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedScanLevel == level
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.surface,
                    foregroundColor: _selectedScanLevel == level
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
              if (level != 'High') SizedBox(width: 12.w),
            ],
          ],
        ),
      ],
    );
  }
}
