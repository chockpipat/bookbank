// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Database ──────────
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';

// ────────── Records Utils ──────────
import 'package:bookbank/features/records/utils/record_filter.dart';
import 'package:bookbank/features/records/utils/record_utils.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/records/widgets/record_list.dart';
import 'package:bookbank/Widgets/select_date_time.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  List<MyData> _allTransactions = [];
  RecordFilter _filter = RecordFilter.all;
  bool _isLoading = true;
  bool _hasError = false;

  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedIds = {};
  bool _isMultiSelectMode = false;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final data = await DatabaseHelper.instance.getAllData();
      if (!mounted) return;
      setState(() {
        _allTransactions = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ────────── Filtered Transactions ──────────
  List<MyData> get _filteredTransactions {
    final query = _searchController.text.trim().toLowerCase();

    // Filter by type (income/expense/all)
    var filtered = _allTransactions.where((item) {
      if (_filter == RecordFilter.income && item.moneyType != 'income') {
        return false;
      }
      if (_filter == RecordFilter.expense && item.moneyType != 'expense') {
        return false;
      }
      return true;
    }).toList();

    // Date Filter
    if (_selectedDateTime != null) {
      final selectedDateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDateTime!);
      filtered = filtered.where((item) {
        final date = item.date;
        return date != null && date.startsWith(selectedDateStr);
      }).toList();
    }

    // Search Filter
    if (query.isNotEmpty) {
      final locProvider = Provider.of<LocalizationProvider>(
        context,
        listen: false,
      );
      final loc = locProvider.loc;
      filtered = filtered.where((item) {
        final name = getItemName(
          item,
          anonymousText: loc.anonymous,
        ).toLowerCase();
        return name.contains(query);
      }).toList();
    }

    return filtered;
  }

  // ────────── Selection Toggle ──────────
  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedIds.add(id);
        _isMultiSelectMode = true;
      }
    });
  }

  // ────────── Selection Clearing ──────────
  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isMultiSelectMode = false;
    });
  }

  // ────────── Selected Records Deletion ──────────
  Future<void> _deleteSelectedRecords() async {
    if (_selectedIds.isEmpty) return;

    final locProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final loc = locProvider.loc;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(loc.delete),
        content: Text('${loc.delete} ${_selectedIds.length} ${loc.records}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Execute deletion if confirmed
    if (confirmed == true && mounted) {
      for (final id in _selectedIds) {
        await DatabaseHelper.instance.deleteData(id);
      }
      _clearSelection();
      await _loadData();
    }
  }

  // ────────── Record Row Builder ──────────
  Widget _buildRecordRow(MyData item, {bool showDateHeader = true}) {
    return RecordListItem(
      item: item,
      isMultiSelectMode: _isMultiSelectMode,
      isSelected: _selectedIds.contains(item.id ?? 0),
      showDateHeader: showDateHeader,
      onTap: () {
        if (_isMultiSelectMode) _toggleSelection(item.id ?? 0);
      },
      onLongPress: () => _toggleSelection(item.id ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer2<GroupSettingsProvider, LocalizationProvider>(
      builder: (context, groupProvider, locProvider, child) {
        final loc = locProvider.loc;
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 130.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ────────── Header ──────────
                    Row(
                      children: [
                        Icon(
                          LucideIcons.layoutList,
                          size: 24.sp,
                          color: theme.iconTheme.color,
                        ),
                        SizedBox(width: 16.w),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.record,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: AppSize.l.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              loc.transactionHistory,
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Filter button
                        IconButton(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: Icon(
                            LucideIcons.filter,
                            size: 18.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 16.w),

                        // Date picker
                        IconButton(
                          onPressed: () => showSelectDateTime(
                            context: context,
                            initialDateTime: _selectedDateTime,
                            onDateTimeSelected: (dateTime) {
                              setState(() {
                                _selectedDateTime = dateTime;
                              });
                            },
                          ),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: Icon(
                            LucideIcons.calendar,
                            size: 18.sp,
                            color: _selectedDateTime != null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),

                        // Clear date filter
                        if (_selectedDateTime != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDateTime = null;
                              });
                            },
                            icon: Icon(
                              LucideIcons.x,
                              size: 18.sp,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ────────── Multi-select Mode ──────────
                    if (_isMultiSelectMode)
                      Container(
                        height: 48.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.r),
                          color: theme.colorScheme.onSurface,
                        ),
                        child: Row(
                          children: [
                            // ────────── Selected Count ──────────
                            Text(
                              '${_selectedIds.length} ${loc.selected}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: theme.scaffoldBackgroundColor,
                              ),
                            ),
                            const Spacer(),

                            // ────────── Close Button ──────────
                            InkWell(
                              onTap: _clearSelection,
                              borderRadius: BorderRadius.circular(20.r),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.close,
                                  size: 20.sp,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),

                            // ────────── Delete Button ──────────
                            InkWell(
                              onTap: _deleteSelectedRecords,
                              borderRadius: BorderRadius.circular(20.r),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.delete,
                                  size: 20.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          // ────────── Search Bar ──────────
                          Expanded(
                            child: Container(
                              height: 48.h,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(50.r),
                                color: theme.colorScheme.surface,
                              ),
                              child: Row(
                                children: [
                                  // ────────── Search Icon ──────────
                                  Icon(
                                    Icons.search,
                                    size: 20.sp,
                                    color: theme.iconTheme.color,
                                  ),
                                  SizedBox(width: 8.w),

                                  // ────────── Search Input ──────────
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 12.sp,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: loc.search,
                                        hintStyle: textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.5),
                                              fontSize: 12.sp,
                                            ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),

                                  // ────────── Clear Search Button ──────────
                                  if (_searchController.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 18.sp,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 18.h),

                    // ────────── Records List ──────────
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _hasError
                          // ────────── Error State ──────────
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.databaseZap,
                                    size: 48.sp,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  SizedBox(height: 12.h),

                                  Text(
                                    loc.loadFailed,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),

                                  TextButton.icon(
                                    onPressed: _loadData,
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.onSurface,
                                    ),
                                    icon: Icon(
                                      LucideIcons.refreshCw,
                                      size: 16.sp,
                                    ),
                                    label: Text(loc.retry),
                                  ),
                                ],
                              ),
                            )
                          : filtered.isEmpty
                          // ────────── Empty State ──────────
                          ? Center(
                              child: Text(
                                loc.noRecord,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            )
                          // ────────── Records List ──────────
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final showDateHeader =
                                    index == 0 ||
                                    filtered[index - 1].date !=
                                        filtered[index].date;
                                return _buildRecordRow(
                                  filtered[index],
                                  showDateHeader: showDateHeader,
                                );
                              },
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
