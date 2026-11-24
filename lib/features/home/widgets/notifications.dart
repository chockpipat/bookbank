import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String type;

  const NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: type == 'scan'
                  ? Colors.green.withValues(alpha: 0.1)
                  : type == 'note'
                  ? Colors.yellow.withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50.r),
            ),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              type == 'scan'
                  ? LucideIcons.scanLine
                  : type == 'note'
                  ? LucideIcons.bookmark
                  : LucideIcons.info,
              color: type == 'scan'
                  ? Colors.green
                  : type == 'note'
                  ? Colors.yellow
                  : theme.colorScheme.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 18.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),

                Text(
                  description,
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: TextStyle(color: theme.colorScheme.outline, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 62.h,
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.w),

        // ────────── Back button ──────────
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            LucideIcons.chevronLeft,
            color: theme.colorScheme.onSurface,
            size: 28.sp,
          ),
        ),

        // ────────── Title ──────────
        title: Text(
          'Notifications',
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        child: Column(
          children: [
            NotificationItem(
              title: 'New book available',
              description: 'A new book has been added to the library',
              time: '2 hours ago',
              type: 'scan',
            ),

            NotificationItem(
              title: 'New note available',
              description: 'A new note has been added to the library',
              time: '2 hours ago',
              type: 'note',
            ),

            NotificationItem(
              title: 'New book available',
              description: 'A new book has been added to the library',
              time: '2 hours ago',
              type: 'info',
            ),
          ],
        ),
      ),
    );
  }
}
