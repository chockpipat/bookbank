import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/core/theme/app_theme.dart';

// ────────── Widgets ──────────
import 'package:bookbank/Widgets/header/header.dart';
import 'package:bookbank/features/home/widgets/dashboard_summary.dart';
import 'package:bookbank/features/home/widgets/cash_box.dart';
import 'package:bookbank/features/home/widgets/group_card.dart';
import 'package:bookbank/features/home/popup/transfer_popup.dart';
import 'package:bookbank/utils/calculations.dart';
import 'package:bookbank/features/home/widgets/menu_items.dart';
import 'package:bookbank/features/menu/editGroup/editGroup_sgreen.dart';
import 'package:bookbank/features/transaction/transaction_in_out/transaction_in_out.dart';

// ────────── Database ──────────
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';

// ────────── Group Data Model ──────────
class GroupData {
  final String groupId;
  final String groupName;
  final int groupCount;
  final double groupAmount;
  final Color groupColor;
  final IconData groupIcon;
  final double percentage;
  final bool savingsGoalEnabled;
  final double savingsGoalAmount;

  GroupData({
    required this.groupId,
    required this.groupName,
    required this.groupCount,
    required this.groupAmount,
    required this.groupColor,
    required this.groupIcon,
    required this.percentage,
    this.savingsGoalEnabled = false,
    this.savingsGoalAmount = 0,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MyData> _transactions = [];
  double _totalBalance = 0;
  double _bankBalance = 0;
  double _cashBalance = 0;

  // Unallocated amount
  double _unallocatedAmount = 0;
  double _unallocatedPercentage = 0;

  // Totals
  double _incomeTotal = 0;
  double _expenseTotal = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  List<FlSpot> _spots = [];

  // Icons
  final List<IconData> _availableIcons = [
    Icons.shopping_cart_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.flight_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.sports_soccer_rounded,
    Icons.health_and_safety_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.bar_chart_rounded,
    Icons.fastfood_rounded,
    Icons.coffee_rounded,
    Icons.card_giftcard_rounded,
    Icons.celebration_rounded,
    Icons.favorite_rounded,
    Icons.fitness_center_rounded,
    Icons.filter_hdr_rounded,
    Icons.handyman_outlined,
  ];

  // Helper methods
  IconData _getIconFromCodePoint(int codePoint) {
    return _availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.add,
    );
  }

  GroupData _buildGroupData(
    GroupSettings settings,
    FinancialCalculations calc,
  ) {
    return GroupData(
      groupId: settings.groupId,
      groupName: settings.groupName,
      groupCount: calc.groupCount(settings.groupId),
      groupAmount: calc.sumGroup(settings.groupId).toDouble(),
      groupColor: settings.colorValue != 0
          ? Color(settings.colorValue)
          : Colors.blue,
      groupIcon: _getIconFromCodePoint(settings.iconCodePoint),
      percentage: calc.calculateGroupPercentage(settings.groupId),
      savingsGoalEnabled: settings.savingsGoalEnabled,
      savingsGoalAmount: settings.savingsGoalAmount,
    );
  }

  Widget _buildGroupCard(GroupData group) {
    return GroupCard(
      groupName: group.groupName,
      groupId: group.groupId,
      groupCount: group.groupCount,
      groupAmount: group.groupAmount,
      groupColor: group.groupColor,
      groupIcon: group.groupIcon,
      transactions: _transactions,
      percentage: group.percentage,
      savingsGoalEnabled: group.savingsGoalEnabled,
      savingsGoalAmount: group.savingsGoalAmount,
      onTransferDrop: (source) => _onTransferDrop(source, group),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from database
  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllData();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _calculateTotals();
    });
  }

  // ────────── Calculate financial totals from transactions ──────────
  void _calculateTotals() {
    final calc = FinancialCalculations(_transactions);

    // Calculate total balance
    _totalBalance = calc.sumAll().toDouble();
    _bankBalance = calc.sumBank().toDouble();
    _cashBalance = calc.sumCash().toDouble();
    _incomeTotal = calc.income().toDouble();
    _expenseTotal = calc.expense().toDouble();
    _monthlyIncome = calc.monthlyIncome();
    _monthlyExpense = calc.monthlyExpense();

    // Calculate unallocated amount
    _unallocatedAmount = calc.unallocatedAmount();
    _unallocatedPercentage = calc.calculateUnallocatedPercentage();

    // Generate monthly spots
    _spots = calc.generateMonthlySpots();
  }

  /// ────────── Handle transfer drop ──────────
  Future<void> _onTransferDrop(GroupDragData source, GroupData target) async {
    if (!mounted) return;

    final result = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (_) => TransferPopup(
        sourceGroupId: source.groupId,
        sourceGroupName: source.groupName,
        sourceGroupColor: source.groupColor,
        sourceGroupIcon: source.groupIcon,
        sourceGroupAmount: source.groupAmount,
        targetGroupId: target.groupId,
        targetGroupName: target.groupName,
        targetGroupColor: target.groupColor,
        targetGroupIcon: target.groupIcon,
      ),
    );

    if (result == null || result <= 0) return;

    final now = DateTime.now().toIso8601String().substring(0, 10);

    await DatabaseHelper.instance.insertData(
      MyData(
        amount: result,
        moneyList: source.groupId,
        moneyType: 'transfer',
        moneyGroup: target.groupId,
        date: now,
        title: 'Transfer: ${source.groupName} → ${target.groupName}',
      ),
    );

    await _loadData();

    // ────────── Show success message ──────────
    if (mounted) {
      final loc = context.read<LocalizationProvider>().loc;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
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
                left: BorderSide(color: AppColors.background, width: 3),
              ),
            ),
            padding: EdgeInsets.only(left: 8.w),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.background,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    loc.transferSuccess,
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.read<LocalizationProvider>().loc;

    return Consumer<GroupSettingsProvider>(
      builder: (context, groupProvider, child) {
        final groupSettings = groupProvider.groupSettings;
        final calc = FinancialCalculations(_transactions);
        final groups = groupSettings
            .map((s) => _buildGroupData(s, calc))
            .toList();

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 115.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ────────── Header ──────────
                    Header(),
                    SizedBox(height: 16.h),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ────────── Dashboard Summary ──────────
                            DashboardSummary(
                              totalBalance: _totalBalance,
                              bankBalance: _bankBalance,
                              cashBalance: _cashBalance,
                              incomeTotal: _incomeTotal,
                              expenseTotal: _expenseTotal,
                              monthlyIncome: _monthlyIncome,
                              monthlyExpense: _monthlyExpense,
                              spots: _spots,
                            ),
                            SizedBox(height: 12.h),

                            // ────────── Menu Items ──────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MenuItems(
                                  late: 'Tang in',
                                  icon: LucideIcons.arrowDownToLine,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionInOut(title: 'Tang in'),
                                      ),
                                    );
                                  },
                                ),

                                MenuItems(
                                  late: 'Tang out',
                                  icon: LucideIcons.arrowUpFromLine,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionInOut(title: 'Tang out'),
                                      ),
                                    );
                                  },
                                ),

                                MenuItems(
                                  late: 'Transfer',
                                  icon: LucideIcons.repeat,
                                  onPressed: () {},
                                ),

                                MenuItems(
                                  late: 'Scan',
                                  icon: LucideIcons.scan,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            // ────────── Unallocated Summary ──────────
                            Text(
                              loc.cashBox,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            UnallocatedSummary(
                              unallocatedAmount: _unallocatedAmount,

                              // Callback when a group is dropped onto the cash box
                              onTransferDrop: (source) => _onTransferDrop(
                                source,
                                GroupData(
                                  groupId: 'CashBox',
                                  groupName: loc.cashBox,
                                  groupCount: 0,
                                  groupAmount: _unallocatedAmount,
                                  groupColor: Colors.amber,
                                  groupIcon: Icons.savings_rounded,
                                  percentage: _unallocatedPercentage,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // ────────── Group Header ──────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.group,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.colorScheme.outline,
                                  ),
                                ),

                                // Edit Group Button
                                FilledButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          Dialog(child: EditGroupSgreen()),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: theme.colorScheme.outline,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  label: Text(
                                    loc.editGroup,
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  icon: Icon(LucideIcons.edit, size: 16.sp),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // ────────── Group Cards (2 per row) ──────────
                            if (groups.isNotEmpty) ...[
                              for (var i = 0; i < groups.length; i += 2) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: _buildGroupCard(groups[i])),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: i + 1 < groups.length
                                          ? _buildGroupCard(groups[i + 1])
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                              ],
                            ] else ...[
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 50.h),

                                    Icon(
                                      LucideIcons.folderX,
                                      size: 24.sp,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),

                                    Text(
                                      loc.noCategory,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),

                                    FilledButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              Dialog(child: EditGroupSgreen()),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor:
                                            theme.colorScheme.onSurface,
                                      ),
                                      icon: Icon(LucideIcons.plus),
                                      label: Text(
                                        loc.addCategory,
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
