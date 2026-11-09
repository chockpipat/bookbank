/// Enum for filtering records by type.
enum RecordFilter { all, income, expense, transfer }

/// Active record list filters.
class RecordFilters {
  const RecordFilters({
    this.type = RecordFilter.all,
    this.moneyList,
    this.category,
  });

  /// Income / expense / transfer filter.
  final RecordFilter type;

  /// 'bank' or 'cash', null means all.
  final String? moneyList;

  /// Group id, null means all categories.
  final String? category;

  bool get isAll =>
      type == RecordFilter.all && moneyList == null && category == null;

  RecordFilters copyWith({
    RecordFilter? type,
    String? moneyList,
    String? category,
    bool clearMoneyList = false,
    bool clearCategory = false,
  }) {
    return RecordFilters(
      type: type ?? this.type,
      moneyList: clearMoneyList ? null : (moneyList ?? this.moneyList),
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}
