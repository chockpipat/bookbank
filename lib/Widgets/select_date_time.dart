// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ────────── theme & localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/core/theme/app_theme.dart';

// ────────── Functions ──────────
Future<void> showSelectDateTime({
  required BuildContext context,
  DateTime? initialDateTime,
  required Function(DateTime) onDateTimeSelected,
}) {
  return showDialog(
    context: context,
    builder: (context) => SelectDateTime(
      initialDateTime: initialDateTime,
      onDateTimeSelected: onDateTimeSelected,
    ),
  );
}

// ────────── Widget ──────────
class SelectDateTime extends StatefulWidget {
  final DateTime? initialDateTime;
  final Function(DateTime) onDateTimeSelected;

  const SelectDateTime({
    super.key,
    this.initialDateTime,
    required this.onDateTimeSelected,
  });

  @override
  State<SelectDateTime> createState() => _SelectDateTimeState();
}

// ────────── State ──────────
class _SelectDateTimeState extends State<SelectDateTime> {
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(loc.selectDateTime, style: TextStyle(fontSize: 16.sp)),
      content: SizedBox(
        width: 350,
        child: CupertinoCalendar(
          minimumDateTime: DateTime.now().subtract(const Duration(days: 365)),
          maximumDateTime: DateTime.now().add(const Duration(days: 365)),
          initialDateTime: _selectedDateTime ?? DateTime.now(),
          currentDateTime: DateTime.now(),
          timeLabel: loc.time,
          mode: CupertinoCalendarMode.dateTime,
          mainColor: Theme.of(context).colorScheme.surfaceContainer,
          onDateTimeChanged: (dateTime) {
            setState(() {
              _selectedDateTime = dateTime;
            });
          },
        ),
      ),

      // ────────── Actions ──────────
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            minimumSize: Size(80.w, 50.h),
          ),
          child: Text(loc.cancel),
        ),
        SizedBox(width: 4.w),

        FilledButton(
          onPressed: () {
            if (_selectedDateTime != null) {
              widget.onDateTimeSelected(_selectedDateTime!);
            }
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            foregroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            minimumSize: Size(80.w, 50.h),
          ),
          child: Text(loc.confirm),
        ),
      ],
    );
  }
}
