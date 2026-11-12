// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ────────── Local Imports ──────────
import 'package:bookbank/Widgets/select_date_time.dart';
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';
import 'package:bookbank/utils/calculations.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/transaction/transaction_in_out/widgets/transaction_amount.dart';
import 'package:bookbank/features/transaction/transaction_in_out/widgets/transaction_note.dart';
import 'package:bookbank/features/transaction/transaction_in_out/widgets/transaction_wallwt.dart';
import 'package:bookbank/features/transaction/transaction_in_out/widgets/transaction_category.dart';
import 'package:provider/provider.dart';

class TransactionInOut extends StatefulWidget {
  final String title;

  const TransactionInOut({super.key, required this.title});

  @override
  State<TransactionInOut> createState() => _TransactionInOutState();
}

class _TransactionInOutState extends State<TransactionInOut> {
  DateTime? _selectedDateTime;

  String _amount = '';
  String _note = '';
  String _wallet = 'bank';
  String? _category;
  double _totalBalance = 0;
  bool _isErrorAmount = false;

  bool get _isIncome => widget.title == 'Tang in';

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _loadBalance();
  }

  // ────────── Load Balance ──────────
  Future<void> _loadBalance() async {
    try {
      final data = await DatabaseHelper.instance.getAllData();
      if (!mounted) return;
      setState(() {
        _totalBalance = FinancialCalculations(data).sumAll();
      });
    } catch (_) {}
  }

  // ────────── Save Transaction ──────────
  Future<void> _saveTransaction() async {
    final loc = context.read<LocalizationProvider>().loc;

    final amount = num.tryParse(_amount);
    if (amount == null || amount <= 0) {
      setState(() {
        _isErrorAmount = true;
      });
      return;
    }

    final date = _selectedDateTime ?? DateTime.now();
    final item = MyData(
      amount: amount,
      moneyType: _isIncome ? 'income' : 'expense',
      moneyList: _wallet,
      moneyGroup: _category ?? '',
      date: DateFormat('yyyy-MM-dd').format(date),
      title: _note.trim().isNotEmpty ? _note.trim() : loc.anonymous,
    );

    await DatabaseHelper.instance.insertData(item);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.addedSuccess)),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ────────── Header ──────────
          Container(
            width: double.infinity,
            height: 60.h,
            color: theme.colorScheme.surface,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                children: [
                  // ────────── Back Button ──────────
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(LucideIcons.chevronLeft, size: 28.sp),
                  ),
                  SizedBox(width: 18.w),

                  // ────────── Icon Container ──────────
                  Container(
                    width: 35.w,
                    height: 35.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _isIncome
                          ? LucideIcons.arrowDownToLine
                          : LucideIcons.arrowUpFromLine,
                      color: theme.colorScheme.onPrimary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // ────────── Title and Balance ──────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: TextStyle(fontSize: 14.sp)),
                      SizedBox(height: 2.h),

                      // Total Balance
                      Text(
                        locProvider.formatAmount(_totalBalance),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // ────────── Info Icon ──────────
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            title: Text("Info"),
                            content: Text("This is an info dialog"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Close"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(LucideIcons.info, size: 20.sp),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
              child: Form(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount input
                      TransactionAmount(
                        onChanged: (value) {
                          setState(() {
                            _amount = value ?? '';
                            _isErrorAmount = false;
                          });
                        },
                      ),

                      // Error message for amount
                      if (_isErrorAmount)
                        Row(
                          children: [
                            Icon(LucideIcons.alertCircle, color: Colors.red, size: 12.w),
                            SizedBox(width: 8.w),
                            Text(
                              loc.pleaseEnterAmount,
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      SizedBox(height: 18.h),

                      // Note input
                      TransactionNote(
                        onChanged: (value) => _note = value,
                      ),
                      SizedBox(height: 18.h),

                      // Wallet selection
                      TransactionWallwt(
                        onChanged: (value) => _wallet = value,
                      ),
                      SizedBox(height: 18.h),

                      // Category selection
                      TransactionCategory(
                        onChanged: (value) => _category = value,
                      ),
                      SizedBox(height: 18.h),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Column(
              children: [
                // ────────── Calendar Button ──────────
                FilledButton.icon(
                  onPressed: () => showSelectDateTime(
                    context: context,
                    initialDateTime: _selectedDateTime,
                    onDateTimeSelected: (dateTime) {
                      setState(() {
                        _selectedDateTime = dateTime;
                      });
                    },
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  icon: Icon(LucideIcons.calendar, size: 18),
                  label: Text(
                    _selectedDateTime != null
                        ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                        : loc.selectDateTime,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                SizedBox(height: 18.h),

                // ────────── Save Button ──────────
                FilledButton(
                  onPressed: _saveTransaction,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface,
                    foregroundColor: theme.colorScheme.surface,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Text(loc.save, style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
