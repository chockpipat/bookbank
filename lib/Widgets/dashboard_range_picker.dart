// ────────── Packages ──────────
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ────────── Cupertino calendar picker ──────────
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
// ignore: implementation_imports
import 'package:cupertino_calendar_picker/src/src.dart'
    show CustomCupertinoDatePicker;
import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoDatePickerMode, CupertinoPicker;

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Pick mode ──────────

enum DashboardPickMode { day, month, year }

// ────────── Picked range result ──────────

class DashboardPickedRange {
  const DashboardPickedRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

// ────────── Show picker ──────────

Future<DashboardPickedRange?> showDashboardRangePicker(
  BuildContext context, {
  required DashboardPickMode mode,
  required DateTime initialStart,
  DateTime? initialEnd,
}) {
  return showDialog<DashboardPickedRange>(
    context: context,
    builder: (_) => _DashboardRangePickerDialog(
      mode: mode,
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}

// ────────── Dialog ──────────

class _DashboardRangePickerDialog extends StatefulWidget {
  final DashboardPickMode mode;
  final DateTime initialStart;
  final DateTime? initialEnd;

  const _DashboardRangePickerDialog({
    required this.mode,
    required this.initialStart,
    this.initialEnd,
  });

  @override
  State<_DashboardRangePickerDialog> createState() =>
      _DashboardRangePickerDialogState();
}

class _DashboardRangePickerDialogState
    extends State<_DashboardRangePickerDialog> {
  static final DateTime _minDate = DateTime(2000);
  static final DateTime _maxDate = DateTime.now().add(
    const Duration(days: 3650),
  );
  static final int _minYear = 2000;
  static final int _maxYear = DateTime.now().year + 10;

  late DateTime _from;
  late DateTime _to;
  late bool _isRange;

  DashboardPickMode get _mode => widget.mode;

  @override
  void initState() {
    super.initState();
    _from = _normalize(widget.initialStart, isEnd: false);
    _to = _normalize(
      widget.initialEnd ?? widget.initialStart,
      isEnd: true,
    );
    _isRange = _mode != DashboardPickMode.year && _isDifferentPeriod();
  }

  bool _isDifferentPeriod() {
    return switch (_mode) {
      DashboardPickMode.day =>
        _from.year != _to.year ||
            _from.month != _to.month ||
            _from.day != _to.day,
      DashboardPickMode.month =>
        _from.year != _to.year || _from.month != _to.month,
      DashboardPickMode.year => false,
    };
  }

  DateTime _normalize(DateTime d, {required bool isEnd}) {
    switch (_mode) {
      case DashboardPickMode.day:
        return DateTime(d.year, d.month, d.day);
      case DashboardPickMode.month:
        if (isEnd) {
          return DateTime(d.year, d.month + 1, 0);
        }
        return DateTime(d.year, d.month);
      case DashboardPickMode.year:
        return isEnd ? DateTime(d.year, 12, 31) : DateTime(d.year);
    }
  }

  String get _title {
    final loc = context.read<LocalizationProvider>().loc;
    return switch (_mode) {
      DashboardPickMode.day => loc.selectDate,
      DashboardPickMode.month => loc.selectMonth,
      DashboardPickMode.year => loc.selectYear,
    };
  }

  void _confirm() {
    var start = _from;
    var end = _to;

    if (_mode == DashboardPickMode.year) {
      start = DateTime(start.year);
      end = DateTime(start.year, 12, 31);
    } else {
      start = _normalize(start, isEnd: false);
      end = _normalize(end, isEnd: true);
      if (end.isBefore(start)) {
        final tmp = start;
        start = end;
        end = tmp;
      }
    }

    Navigator.pop(
      context,
      DashboardPickedRange(start: start, end: end),
    );
  }

  // ────────── Day pickers ──────────

  Widget _dayCalendar(
    DateTime value,
    ValueChanged<DateTime> onChanged, {
    bool isEnd = false,
  }) {
    final theme = Theme.of(context);
    final fromDay = DateTime(_from.year, _from.month, _from.day);

    return CupertinoCalendar(
      minimumDateTime: _minDate,
      maximumDateTime: _maxDate,
      initialDateTime: value,
      currentDateTime: DateTime.now(),
      mode: CupertinoCalendarMode.date,
      mainColor: theme.colorScheme.primary,
      selectableDayPredicate: isEnd
          ? (date) {
              final d = DateTime(date.year, date.month, date.day);
              return !d.isBefore(fromDay);
            }
          : null,
      onDateSelected: (date) {
        setState(() {
          onChanged(DateTime(date.year, date.month, date.day));
        });
      },
    );
  }

  // ────────── Month pickers ──────────

  Widget _monthPicker(
    DateTime value,
    ValueChanged<DateTime> onChanged,
  ) {
    return SizedBox(
      height: 216.h,
      width: double.infinity,
      child: CustomCupertinoDatePicker(
        mode: CupertinoDatePickerMode.monthYear,
        initialDateTime: value,
        minimumDate: _minDate,
        maximumDate: _maxDate,
        minimumYear: _minYear,
        maximumYear: _maxYear,
        onDateTimeChanged: (date) {
          setState(() {
            onChanged(DateTime(date.year, date.month));
          });
        },
      ),
    );
  }

  // ────────── Year picker ──────────

  Widget _yearPicker() {
    final selectedIndex = (_from.year - _minYear).clamp(
      0,
      _maxYear - _minYear,
    );

    return SizedBox(
      height: 216.h,
      width: double.infinity,
      child: CupertinoPicker.builder(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(
          initialItem: selectedIndex,
        ),
        onSelectedItemChanged: (index) {
          setState(() {
            _from = DateTime(_minYear + index);
          });
        },
        childCount: _maxYear - _minYear + 1,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              '${_minYear + index}',
              style: TextStyle(fontSize: 18.sp),
            ),
          );
        },
      ),
    );
  }

  // ────────── Build ──────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationProvider>().loc;

    final dialogWidth = math.min(
      360.0,
      MediaQuery.sizeOf(context).width - 48,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(_title, style: TextStyle(fontSize: 16.sp)),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ────────── Range switch (day & month only) ──────────
              if (_mode != DashboardPickMode.year)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.dateRange,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  value: _isRange,
                  onChanged: (value) {
                    setState(() {
                      _isRange = value;
                      if (value) {
                        _to = _from;
                      }
                    });
                  },
                ),

              // ────────── Pickers ──────────
              if (_mode == DashboardPickMode.year) ...[
                _yearPicker(),
              ] else if (_mode == DashboardPickMode.day) ...[
                if (_isRange) ...[
                  _rangeLabel(loc.from),
                  _dayCalendar(_from, (d) => _from = d),
                  SizedBox(height: 8.h),
                  _rangeLabel(loc.to),
                  _dayCalendar(_to, (d) => _to = d, isEnd: true),
                ] else
                  _dayCalendar(_from, (d) => _from = d),
              ] else ...[
                if (_isRange) ...[
                  _rangeLabel(loc.from),
                  _monthPicker(
                    DateTime(_from.year, _from.month),
                    (d) => _from = DateTime(d.year, d.month),
                  ),
                  SizedBox(height: 8.h),
                  _rangeLabel(loc.to),
                  _monthPicker(
                    DateTime(_to.year, _to.month),
                    (d) => _to = DateTime(d.year, d.month),
                  ),
                ] else
                  _monthPicker(
                    DateTime(_from.year, _from.month),
                    (d) => _from = DateTime(d.year, d.month),
                  ),
              ],
            ],
          ),
        ),
      ),

      // ────────── Actions ──────────
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            minimumSize: Size(80.w, 50.h),
          ),
          child: Text(loc.cancel),
        ),
        SizedBox(width: 4.w),

        FilledButton(
          onPressed: _confirm,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.onSurface,
            foregroundColor: theme.colorScheme.surface,
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

  Widget _rangeLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
