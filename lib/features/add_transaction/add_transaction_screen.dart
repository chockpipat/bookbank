// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ────────── Data & Database ──────────
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';

// ────────── Feature Widgets ──────────
import 'package:bookbank/features/add_transaction/widgets/type_selector.dart';
import 'package:bookbank/features/add_transaction/widgets/position_selector.dart';
import 'package:bookbank/features/add_transaction/widgets/category_selector.dart';
import 'package:bookbank/features/add_transaction/widgets/header.dart';
import 'package:bookbank/features/add_transaction/widgets/amount_input.dart';
import 'package:bookbank/features/add_transaction/widgets/transfer_mode.dart';
import 'package:bookbank/features/add_transaction/widgets/title_input.dart';
import 'package:bookbank/features/add_transaction/widgets/save_button.dart';

// ────────── Shared Widgets ──────────
import 'package:bookbank/Widgets/inWell.dart';

// ────────── Theme & Providers ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Add Transaction Screen ──────────
class AddTransactionScreen extends StatefulWidget {
  final MyData? existingItem;

  const AddTransactionScreen({super.key, this.existingItem});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

// ────────── State Management ──────────
class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // State variables
  num _number = 0;
  DateTime? selectedDate;
  String? selectedOption = 'Expense';
  String? selectedType = 'Bank';
  String? selectedGroup;
  String? _amountError;
  bool _isTransferMode = false;
  String _transferFrom = 'Bank';
  String _transferTo = 'Cash';

  // ────────── Initialize state with existing data if provided ──────────
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    if (widget.existingItem != null) {
      _number = widget.existingItem!.amount;
      selectedOption = widget.existingItem!.moneyType == 'income'
          ? 'Income'
          : 'Expense';
      selectedType = widget.existingItem!.moneyList == 'bank' ? 'Bank' : 'Cash';
      selectedGroup = widget.existingItem!.moneyGroup.isEmpty
          ? null
          : widget.existingItem!.moneyGroup;
      _amountController.text = _number.toString();
      _titleController.text = widget.existingItem!.title ?? '';
    }
  }

  // ────────── Date picker dialog ──────────
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ────────── Format date for display ──────────
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ────────── Dispose controllers ──────────
  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ────────── Build UI ──────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Consumer<GroupSettingsProvider>(
      builder: (context, groupProvider, child) {
        final groupSettings = groupProvider.groupSettings;
        final locProvider = Provider.of<LocalizationProvider>(context);
        final loc = locProvider.loc;

        // ────────── Map group IDs to display names ──────────
        final Map<String, String> categoryNames = {
          'Group1': groupSettings
              .firstWhere(
                (s) => s.groupId == 'Group1',
                orElse: () => GroupSettings(
                  groupId: 'Group1',
                  groupName: 'Group1',
                  iconCodePoint: 0,
                  colorValue: 0,
                  savingsGoalEnabled: false,
                  savingsGoalAmount: 0,
                ),
              )
              .groupName,
          'Group2': groupSettings
              .firstWhere(
                (s) => s.groupId == 'Group2',
                orElse: () => GroupSettings(
                  groupId: 'Group2',
                  groupName: 'Group2',
                  iconCodePoint: 10,
                  colorValue: 0,
                  savingsGoalEnabled: false,
                  savingsGoalAmount: 0,
                ),
              )
              .groupName,
          'Group3': groupSettings
              .firstWhere(
                (s) => s.groupId == 'Group3',
                orElse: () => GroupSettings(
                  groupId: 'Group3',
                  groupName: 'Group3',
                  iconCodePoint: 0,
                  colorValue: 0,
                  savingsGoalEnabled: false,
                  savingsGoalAmount: 0,
                ),
              )
              .groupName,
          'Group4': groupSettings
              .firstWhere(
                (s) => s.groupId == 'Group4',
                orElse: () => GroupSettings(
                  groupId: 'Group4',
                  groupName: 'Group4',
                  iconCodePoint: 0,
                  colorValue: 0,
                  savingsGoalEnabled: false,
                  savingsGoalAmount: 0,
                ),
              )
              .groupName,
        };

        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Header(),
                SizedBox(height: 16.h),

                // ────────── Form section ──────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmountInput(
                        controller: _amountController,
                        errorText: _amountError,
                        isTransferMode: _isTransferMode,
                        onChanged: (value) {
                          setState(() {
                            _amountError = value.isEmpty
                                ? loc.pleaseEnterAmount
                                : null;
                          });
                        },

                        onSaved: (value) {
                          if (value != null && value.isNotEmpty) {
                            _number = num.tryParse(value) ?? 0;
                          }
                        },

                        onTransferModeToggle: () {
                          setState(() {
                            _isTransferMode = !_isTransferMode;
                            if (_isTransferMode) {
                              _transferFrom = selectedType ?? 'Bank';
                              _transferTo = _transferFrom == 'Bank'
                                  ? 'Cash'
                                  : 'Bank';
                            }
                          });
                        },
                      ),
                      SizedBox(height: 20.h),

                      // ────────── Transfer mode section ──────────
                      if (_isTransferMode) ...[
                        TransferMode(
                          transferFrom: _transferFrom,
                          transferTo: _transferTo,
                          onTransferFromChanged: (value) {
                            setState(() {
                              _transferFrom = value;
                              _transferTo = value == 'Bank' ? 'Cash' : 'Bank';
                            });
                          },
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TitleInput(controller: _titleController),
                            ),
                            SizedBox(width: 16.w),

                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.date,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: isTablet ? 14.sp : 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),

                                  DateSelectorInkWell(
                                    selectedDate: selectedDate,
                                    formatDate: _formatDate,
                                    onTap: () => _selectDate(context),
                                    theme: theme,
                                    textTheme: textTheme,
                                    isTablet: isTablet,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ────────── Type selector section ──────────
                        TypeSelector(
                          selectedType: selectedOption,
                          onChanged: (val) =>
                              setState(() => selectedOption = val),
                        ),
                        SizedBox(height: 20.h),

                        // ────────── Position selector section ──────────
                        PositionSelector(
                          selectedPosition: selectedType,
                          onChanged: (val) =>
                              setState(() => selectedType = val),
                        ),
                        SizedBox(height: 20.h),

                        // ────────── Category selector section ──────────
                        CategorySelector(
                          selectedGroup: selectedGroup,
                          onChanged: (val) =>
                              setState(() => selectedGroup = val),
                          categoryNames: categoryNames,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // ────────── Save button ──────────
                SaveButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    // Validate amount
                    if (_amountController.text.isEmpty) {
                      setState(() {
                        _amountError = loc.pleaseEnterAmount;
                      });
                      return;
                    }

                    _formKey.currentState!.save();

                    // ────────── Handle transfer mode ──────────
                    if (_isTransferMode) {
                      final dateStr = DateFormat(
                        'yyyy-MM-dd',
                      ).format(selectedDate ?? DateTime.now());
                      // Save single transfer record: moneyList = from, moneyGroup = to
                      final transferItem = MyData(
                        amount: _number,
                        moneyType: 'transfer',
                        moneyList: _transferFrom == 'Bank' ? 'bank' : 'cash',
                        moneyGroup: _transferTo == 'Bank' ? 'bank' : 'cash',
                        date: dateStr,
                        title: 'Money Position',
                      );
                      await DatabaseHelper.instance.insertData(transferItem);
                    } else {
                      // ────────── Handle normal income/expense ──────────
                      final newItem = MyData(
                        id: widget.existingItem?.id,
                        amount: _number,
                        moneyType: selectedOption == 'Income'
                            ? 'income'
                            : 'expense',
                        moneyList: selectedType == 'Bank' ? 'bank' : 'cash',
                        moneyGroup: selectedGroup ?? '',
                        date: DateFormat(
                          'yyyy-MM-dd',
                        ).format(selectedDate ?? DateTime.now()),
                        title: _titleController.text.isNotEmpty
                            ? _titleController.text
                            : 'Anonymous',
                      );
                      // Insert or update based on whether item exists
                      if (widget.existingItem == null) {
                        await DatabaseHelper.instance.insertData(newItem);
                      } else {
                        await DatabaseHelper.instance.updateData(newItem);
                      }
                    }

                    if (!context.mounted) return;

                    // ────────── Show success snackbar ──────────
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom + 20.h,
                          left: 16.w,
                          right: 16.w,
                        ),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        content: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppColors.background,
                                width: 3,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.only(left: 8.w),
                          child: Row(
                            children: [
                              // Success icon
                              Icon(
                                Icons.check_circle_outline,
                                color: AppColors.background,
                                size: isTablet ? 24.sp : 20.sp,
                              ),
                              SizedBox(width: 12.w),

                              // Success message
                              Expanded(
                                child: Text(
                                  widget.existingItem == null
                                      ? loc.addedSuccess
                                      : loc.updatedSuccess,
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontSize: isTablet ? 16.sp : 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // ────────── Navigate back or reset form ──────────
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, true);
                    } else {
                      _formKey.currentState!.reset();
                      setState(() {
                        selectedOption = null;
                        selectedType = null;
                        selectedGroup = null;
                        _number = 0;
                      });
                    }
                  },
                ),
                SizedBox(height: 30.h),
              ],
            );
          },
        );
      },
    );
  }
}

// ────────── Bottom sheet for add transaction ──────────
Future<void> showAddItemBottomSheet(
  BuildContext context, {
  MyData? existingItem,
  VoidCallback? onSaved,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final isTablet = ResponsiveBreakpoints.of(context).isTablet;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(isTablet ? 24.r : 20.r),
          child: SingleChildScrollView(
            child: AddTransactionScreen(existingItem: existingItem),
          ),
        ),
      );
    },
  );

  if (result == true && onSaved != null) {
    onSaved();
  }
}
