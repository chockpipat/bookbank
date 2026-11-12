
// ────────── MyData ──────────
class MyData {
  MyData({
    this.id,
    required this.amount,
    required this.moneyList,
    required this.moneyType,
    required this.moneyGroup,
    this.date,
    this.title,
  });

  int? id;
  num amount;
  String moneyList;
  String moneyType;
  String moneyGroup;
  String? date;
  String? title;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'moneyList': moneyList,
      'moneyType': moneyType,
      'moneyGroup': moneyGroup,
      'date': date,
      'title': title,
    };
  }

  factory MyData.fromMap(Map<String, dynamic> map) {
    return MyData(
      id: map['id'] as int?,
      amount: (map['amount'] as num?) ?? 0,
      moneyList: (map['moneyList'] as String?) ?? '',
      moneyType: (map['moneyType'] as String?) ?? '',
      moneyGroup: (map['moneyGroup'] as String?) ?? '',
      date: map['date'] as String?,
      title: map['title'] as String?,
    );
  }
}

// ────────── GroupSettings ──────────
class GroupSettings {
  GroupSettings({
    this.id,
    required this.groupId,
    required this.groupName,
    required this.iconCodePoint,
    required this.colorValue,
    required this.savingsGoalEnabled,
    this.savingsGoalAmount = 0,
  });

  int? id;
  String groupId;
  String groupName;
  int iconCodePoint;
  int colorValue;
  bool savingsGoalEnabled;
  double savingsGoalAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'savingsGoalEnabled': savingsGoalEnabled ? 1 : 0,
      'savingsGoalAmount': savingsGoalAmount,
    };
  }

  factory GroupSettings.fromMap(Map<String, dynamic> map) {
    return GroupSettings(
      id: map['id'] as int?,
      groupId: (map['groupId'] as String?) ?? '',
      groupName: (map['groupName'] as String?) ?? '',
      iconCodePoint: (map['iconCodePoint'] as int?) ?? 0,
      colorValue: (map['colorValue'] as int?) ?? 0,
      savingsGoalEnabled: (map['savingsGoalEnabled'] as int?) == 1,
      savingsGoalAmount: (map['savingsGoalAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ────────── QuickNote ──────────
class QuickNote {
  QuickNote({this.id, required this.note, this.sortOrder = 0});

  int? id;
  String note;
  int sortOrder;

  Map<String, dynamic> toMap() {
    return {'id': id, 'note': note, 'sortOrder': sortOrder};
  }

  factory QuickNote.fromMap(Map<String, dynamic> map) {
    return QuickNote(
      id: map['id'] as int?,
      note: (map['note'] as String?) ?? '',
      sortOrder: (map['sortOrder'] as int?) ?? 0,
    );
  }
}

// ────────── NoteModel ──────────
class NoteModel {
  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.colorValue,
    required this.date,
    this.category = 'General',
    this.isPinned = false,
  });

  int? id;
  String title;
  String content;
  int colorValue;
  String date;
  String category;
  bool isPinned;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'colorValue': colorValue,
      'date': date,
      'category': category,
      'isPinned': isPinned ? 1 : 0,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      colorValue: (map['colorValue'] as int?) ?? 0xFF2196F3,
      date: (map['date'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'General',
      isPinned: (map['isPinned'] as int?) == 1,
    );
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    int? colorValue,
    String? date,
    String? category,
    bool? isPinned,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorValue: colorValue ?? this.colorValue,
      date: date ?? this.date,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

